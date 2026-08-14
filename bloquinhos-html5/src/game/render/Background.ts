import { GROUND, STAGE_HEIGHT, STAGE_WIDTH } from '../core/constants';
import type { Point } from '../core/geometry';
import { CLOUD, MOUNTAIN, MOUNTAIN_FAR, SHADOW, SKY_BOTTOM, SKY_TOP } from './palette';
import type { SpriteName, Sprites } from './sprites';

/** Top edge of the ground slab. `chao` sits here in the original too. */
const HORIZON = GROUND.y - GROUND.height / 2;

interface Cloud {
  sprite: SpriteName;
  /** Centre, straight out of the `Fundo` timeline. */
  x: number;
  y: number;
  /** Parallax divisor from `Fundo.as` — smaller means it moves more. */
  depth: number;
}

interface Shadow {
  x: number;
  y: number;
  scale: number;
  depth: number;
}

/**
 * The sky layer, recovered from `Fundo` in `assets.fla`.
 *
 * Positions are the symbol instances' own matrices. Flash registers each cloud
 * at its centre — every bitmap inside its symbol is offset by exactly half its
 * size — so these are centres, not corners. Depths come from `Fundo.as`.
 *
 * Draw order is the timeline's own, bottom layer first. It runs nearest cloud
 * to farthest, which is backwards from the usual painter's order; none of them
 * overlap, so it never shows.
 */
const CLOUDS: readonly Cloud[] = [
  { sprite: 'nuvem1', x: 520.75, y: 131.7, depth: 1 },
  { sprite: 'nuvem2', x: 803.8, y: 268.65, depth: 3 },
  { sprite: 'nuvem4', x: 567.5, y: 382.3, depth: 5 },
  { sprite: 'nuvem3', x: 185.8, y: 234.35, depth: 3 },
  { sprite: 'nuvem5', x: 270.85, y: 356.45, depth: 15 },
];

/**
 * The `sombra nuvens` instances — one per cloud, sharing its x and divisor.
 * `Fundo.as` only ever moves them horizontally, which is why they carry no y
 * offset here.
 */
const SHADOWS: readonly Shadow[] = [
  { x: 520.75, y: 564.3, scale: 1, depth: 1 },
  { x: 803.8, y: 564.4, scale: 0.6295, depth: 3 },
  { x: 185.8, y: 564.45, scale: 0.5216, depth: 3 },
  { x: 567.5, y: 564.45, scale: 0.5421, depth: 5 },
  { x: 270.85, y: 564.5, scale: 0.2126, depth: 15 },
];

/** Half-extents of the shadow ellipse in the symbol's own space, in pixels. */
const SHADOW_RX = 187.4;
const SHADOW_RY = 259.3;

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

  private get shiftX(): number {
    return (this.pointer.x / STAGE_WIDTH) * 50;
  }

  private get shiftY(): number {
    return (this.pointer.y / STAGE_HEIGHT) * 20;
  }

  draw(ctx: CanvasRenderingContext2D, sprites: Sprites | null): void {
    if (!sprites) {
      this.drawFallback(ctx);
      return;
    }

    // `ceu` is `fundo.jpg` at the origin; it is 1000x557 and stops on the
    // horizon, where `chao` begins.
    ctx.drawImage(sprites.fundo, 0, 0);

    // `montanhas` sits at (-20, 504.4) and `Fundo.as` slides it to
    // `-20 - porcentagemX / 10`. The bitmap is 1060 wide to cover the travel.
    ctx.drawImage(sprites.montanhas, -20 - this.shiftX / 10, 504.4);

    for (const cloud of CLOUDS) {
      const image = sprites[cloud.sprite];
      ctx.drawImage(
        image,
        cloud.x - this.shiftX / cloud.depth - image.width / 2,
        cloud.y - this.shiftY / cloud.depth - image.height / 2,
      );
    }
  }

  /**
   * The cloud shadows, drawn after the ground because they fall on it. The
   * original masks them with the `chao` bitmap, so they only ever show on the
   * grass — a 13px band across the middle of a much larger ellipse.
   */
  drawShadows(ctx: CanvasRenderingContext2D, groundHeight: number): void {
    ctx.save();
    ctx.beginPath();
    ctx.rect(0, HORIZON, STAGE_WIDTH, groundHeight);
    ctx.clip();

    for (const shadow of SHADOWS) {
      const rx = SHADOW_RX * shadow.scale;
      const ry = SHADOW_RY * shadow.scale;

      ctx.save();
      ctx.translate(shadow.x - this.shiftX / shadow.depth, shadow.y);
      ctx.scale(1, ry / rx);

      const gradient = ctx.createRadialGradient(0, 0, 0, 0, 0, rx);
      gradient.addColorStop(0, SHADOW);
      gradient.addColorStop(1, 'rgba(3, 77, 24, 0)');

      ctx.fillStyle = gradient;
      ctx.beginPath();
      ctx.arc(0, 0, rx, 0, Math.PI * 2);
      ctx.fill();
      ctx.restore();
    }

    ctx.restore();
  }

  private drawFallback(ctx: CanvasRenderingContext2D): void {
    const gradient = ctx.createLinearGradient(0, 0, 0, STAGE_HEIGHT);
    gradient.addColorStop(0, SKY_TOP);
    gradient.addColorStop(1, SKY_BOTTOM);

    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, STAGE_WIDTH, STAGE_HEIGHT);

    this.drawMountainShapes(ctx);

    for (const cloud of CLOUDS) {
      this.drawBlob(ctx, cloud.x - this.shiftX / cloud.depth, cloud.y - this.shiftY / cloud.depth);
    }
  }

  private drawMountainShapes(ctx: CanvasRenderingContext2D): void {
    const x = -20 - this.shiftX / 10;
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
