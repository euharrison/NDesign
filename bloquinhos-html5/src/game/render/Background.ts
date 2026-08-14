import { GROUND, STAGE_HEIGHT, STAGE_WIDTH } from '../core/constants';
import type { Point } from '../core/geometry';
import { CLOUD, MOUNTAIN, MOUNTAIN_FAR, SKY_BOTTOM, SKY_TOP } from './palette';
import type { SpriteName, Sprites } from './sprites';

/** Top edge of the ground slab — where the sky bitmap stops. */
const HORIZON = GROUND.y - GROUND.height / 2;

interface Prop {
  sprite: SpriteName;
  x: number;
  y: number;
  /** Parallax divisor from `Fundo.as` — smaller means it moves more. */
  depth: number;
}

/**
 * The sky layer.
 *
 * The depths are `Fundo.as` verbatim: clouds 1, 3, 3, 5, 15 and the mountains
 * 10. Which bitmap belongs to which depth is settled by their sizes — nuvem1 is
 * the largest at 286x132 and nuvem5 the smallest at 90x48, matching nearest to
 * farthest. Their x/y lived on the `Fundo` movie clip's timeline inside the
 * unreadable .fla, so the positions below are a reconstruction.
 *
 * The balloon, bird and UFO are placed the same way: the bitmaps ship with the
 * game (the bird even carries the N logo) but nothing in the ActionScript says
 * where they went, so they sit at deep parallax, clear of the stacks.
 */
const PROPS: readonly Prop[] = [
  { sprite: 'nuvem5', x: 596, y: 214, depth: 15 },
  { sprite: 'ovni', x: 856, y: 46, depth: 15 },
  { sprite: 'nuvem4', x: 236, y: 246, depth: 5 },
  { sprite: 'balao', x: 118, y: 62, depth: 5 },
  { sprite: 'nuvem3', x: 742, y: 148, depth: 3 },
  { sprite: 'passaro', x: 616, y: 104, depth: 3 },
  { sprite: 'nuvem2', x: 412, y: 54, depth: 3 },
  { sprite: 'nuvem1', x: 26, y: 142, depth: 1 },
];

/** Fallback cloud blobs, used until the bitmaps decode. */
const BLOBS: readonly Prop[] = PROPS.filter((prop) => prop.sprite.startsWith('nuvem'));

/**
 * The parallax sky (`Fundo.as`). Everything drifts against the pointer: the
 * original scaled the offset to 50px across the stage width and 20px across its
 * height, then divided it per layer.
 */
export class Background {
  private pointer: Point = { x: STAGE_WIDTH / 2, y: STAGE_HEIGHT / 2 };

  setPointer(point: Point): void {
    this.pointer = point;
  }

  draw(ctx: CanvasRenderingContext2D, sprites: Sprites | null): void {
    const shiftX = (this.pointer.x / STAGE_WIDTH) * 50;
    const shiftY = (this.pointer.y / STAGE_HEIGHT) * 20;

    if (!sprites) {
      this.drawFallback(ctx, shiftX, shiftY);
      return;
    }

    // `fundo.jpg` is 1000x557 and stops exactly where the ground begins.
    ctx.drawImage(sprites.fundo, 0, 0);

    // `montanhas.x = -20 - (porcentagemX / 10)`, sitting on the horizon. The
    // bitmap is 1060 wide so it still covers the stage at full offset.
    const { montanhas } = sprites;
    ctx.drawImage(montanhas, -20 - shiftX / 10, HORIZON - montanhas.height);

    // Farthest first, so the near clouds overlap the deep ones.
    for (const prop of PROPS) {
      ctx.drawImage(
        sprites[prop.sprite],
        prop.x - shiftX / prop.depth,
        prop.y - shiftY / prop.depth,
      );
    }
  }

  private drawFallback(ctx: CanvasRenderingContext2D, shiftX: number, shiftY: number): void {
    const gradient = ctx.createLinearGradient(0, 0, 0, STAGE_HEIGHT);
    gradient.addColorStop(0, SKY_TOP);
    gradient.addColorStop(1, SKY_BOTTOM);

    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, STAGE_WIDTH, STAGE_HEIGHT);

    this.drawMountainShapes(ctx, shiftX);

    for (const blob of BLOBS) {
      this.drawBlob(ctx, blob.x - shiftX / blob.depth, blob.y - shiftY / blob.depth);
    }
  }

  private drawMountainShapes(ctx: CanvasRenderingContext2D, shiftX: number): void {
    const x = -20 - shiftX / 10;
    const base = HORIZON;

    const ridge = (offset: number, height: number, width: number, color: string): void => {
      ctx.fillStyle = color;
      ctx.beginPath();
      ctx.moveTo(x + offset - width, base);
      ctx.lineTo(x + offset, base - height);
      ctx.lineTo(x + offset + width, base);
      ctx.closePath();
      ctx.fill();
    };

    ridge(180, 210, 260, MOUNTAIN_FAR);
    ridge(560, 250, 300, MOUNTAIN_FAR);
    ridge(900, 200, 250, MOUNTAIN_FAR);
    ridge(340, 150, 220, MOUNTAIN);
    ridge(720, 170, 240, MOUNTAIN);
  }

  private drawBlob(ctx: CanvasRenderingContext2D, x: number, y: number): void {
    ctx.save();
    ctx.translate(x, y);
    ctx.fillStyle = CLOUD;
    ctx.globalAlpha = 0.92;

    ctx.beginPath();
    ctx.arc(-34, 8, 24, 0, Math.PI * 2);
    ctx.arc(0, -6, 32, 0, Math.PI * 2);
    ctx.arc(36, 10, 26, 0, Math.PI * 2);
    ctx.arc(6, 20, 28, 0, Math.PI * 2);
    ctx.fill();

    ctx.restore();
  }
}
