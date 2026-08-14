import { STAGE_HEIGHT, STAGE_WIDTH } from '../core/constants';
import type { Point } from '../core/geometry';
import { CLOUD, MOUNTAIN, MOUNTAIN_FAR, SKY_BOTTOM, SKY_TOP } from './palette';

interface Cloud {
  x: number;
  y: number;
  scale: number;
  /** Parallax divisor from `Fundo.as` — smaller means it moves more. */
  depth: number;
}

/** Cloud layout and depths taken from the original `Fundo` movie clip. */
const CLOUDS: readonly Cloud[] = [
  { x: 170, y: 110, scale: 1.15, depth: 1 },
  { x: 470, y: 70, scale: 0.9, depth: 3 },
  { x: 760, y: 130, scale: 1.0, depth: 3 },
  { x: 300, y: 190, scale: 0.7, depth: 5 },
  { x: 880, y: 210, scale: 0.55, depth: 15 },
];

/**
 * The parallax sky (`Fundo.as`). Clouds and mountains drift against the
 * pointer: the original scaled the offset to 50px across the stage width and
 * 20px across its height, then divided per layer.
 */
export class Background {
  private pointer: Point = { x: STAGE_WIDTH / 2, y: STAGE_HEIGHT / 2 };

  setPointer(point: Point): void {
    this.pointer = point;
  }

  draw(ctx: CanvasRenderingContext2D): void {
    const shiftX = (this.pointer.x / STAGE_WIDTH) * 50;
    const shiftY = (this.pointer.y / STAGE_HEIGHT) * 20;

    this.drawSky(ctx);
    this.drawMountains(ctx, shiftX);

    for (const cloud of CLOUDS) {
      this.drawCloud(
        ctx,
        cloud.x - shiftX / cloud.depth,
        cloud.y - shiftY / cloud.depth,
        cloud.scale,
      );
    }
  }

  private drawSky(ctx: CanvasRenderingContext2D): void {
    const gradient = ctx.createLinearGradient(0, 0, 0, STAGE_HEIGHT);
    gradient.addColorStop(0, SKY_TOP);
    gradient.addColorStop(1, SKY_BOTTOM);

    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, STAGE_WIDTH, STAGE_HEIGHT);
  }

  private drawMountains(ctx: CanvasRenderingContext2D, shiftX: number): void {
    // `montanhas.x = -20 - (porcentagemX / 10)` in the original.
    const x = -20 - shiftX / 10;
    const base = STAGE_HEIGHT - 16;

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

  private drawCloud(ctx: CanvasRenderingContext2D, x: number, y: number, scale: number): void {
    ctx.save();
    ctx.translate(x, y);
    ctx.scale(scale, scale);
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
