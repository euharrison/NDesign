import type { Body } from 'planck';

import { isPart, type PartArt } from '../core/bodyData';
import { PATH_COLORS, PIXELS_PER_METER, PathType } from '../core/constants';
import type { Point } from '../core/geometry';
import type { Path } from '../core/Path';
import { TARGET_RADIUS, type LevelTarget } from '../levels/types';
import { DEFAULT_RIDER_PALETTE, TARGET_COLORS, type RiderPalette } from './palette';
import type { Viewport } from './Viewport';

export interface PreviewLine {
  from: Point;
  to: Point;
  type: PathType;
}

export interface Scene {
  paths: readonly Path[];
  targets: readonly LevelTarget[];
  /** Targets already reached, drawn dimmed. */
  reached: ReadonlySet<string>;
  bodies: readonly Body[];
  riderVisible: boolean;
  preview: PreviewLine | null;
  /** Ghost of where the next line will start. */
  anchor: Point | null;
  /** Spawn marker, shown while drawing. */
  start: Point | null;
  startMirrored: boolean;
  /** Highlighted while the eraser hovers them. */
  hovered: ReadonlySet<Path>;
}

const GRID_SPACING = 50;

/** Draws the whole scene to a canvas each frame. */
export class Renderer {
  private readonly ctx: CanvasRenderingContext2D;
  palette: RiderPalette = { ...DEFAULT_RIDER_PALETTE };

  constructor(private readonly canvas: HTMLCanvasElement) {
    const ctx = canvas.getContext('2d', { alpha: false });
    if (!ctx) throw new Error('Canvas 2D context unavailable');
    this.ctx = ctx;
  }

  /** Sizes the backing store for the device pixel ratio. Returns CSS size. */
  resize(): { width: number; height: number } {
    const ratio = window.devicePixelRatio || 1;
    const { clientWidth, clientHeight } = this.canvas;

    this.canvas.width = Math.round(clientWidth * ratio);
    this.canvas.height = Math.round(clientHeight * ratio);

    return { width: clientWidth, height: clientHeight };
  }

  render(scene: Scene, viewport: Viewport): void {
    const { ctx } = this;
    const ratio = window.devicePixelRatio || 1;

    ctx.setTransform(ratio, 0, 0, ratio, 0, 0);
    ctx.clearRect(0, 0, viewport.width, viewport.height);
    this.drawBackground(viewport);

    ctx.save();
    ctx.translate(viewport.x, viewport.y);
    ctx.scale(viewport.scale, viewport.scale);

    this.drawTargets(scene);
    this.drawPaths(scene);
    if (scene.start) this.drawStartMarker(scene.start, scene.startMirrored);
    if (scene.anchor) this.drawAnchor(scene.anchor);
    if (scene.preview) this.drawPreview(scene.preview);
    if (scene.riderVisible) this.drawRider(scene.bodies);

    ctx.restore();
  }

  private drawBackground(viewport: Viewport): void {
    const { ctx } = this;

    ctx.fillStyle = '#fbfbf9';
    ctx.fillRect(0, 0, viewport.width, viewport.height);

    const step = GRID_SPACING * viewport.scale;
    if (step < 12) return;

    const offsetX = viewport.x % step;
    const offsetY = viewport.y % step;

    ctx.fillStyle = '#dedcd4';
    for (let x = offsetX; x < viewport.width; x += step) {
      for (let y = offsetY; y < viewport.height; y += step) {
        ctx.fillRect(x, y, 1, 1);
      }
    }
  }

  private drawTargets({ targets, reached }: Scene): void {
    const { ctx } = this;

    for (const target of targets) {
      const colors = TARGET_COLORS[target.style];

      ctx.save();
      ctx.globalAlpha = reached.has(target.value) ? 0.35 : 1;
      ctx.translate(target.x, target.y);

      ctx.beginPath();
      ctx.arc(0, 0, TARGET_RADIUS, 0, Math.PI * 2);
      ctx.fillStyle = colors.fill;
      ctx.fill();

      if (target.label) {
        ctx.fillStyle = colors.text;
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';

        // The original broke labels at hyphens and spaces; keep that, then
        // shrink until the widest line fits inside the circle.
        const lines = target.label.split(/[- ]/).filter(Boolean);
        const size = this.fitFontSize(lines, TARGET_RADIUS * 1.7, lines.length > 1 ? 13 : 21);
        ctx.font = `700 ${size}px "Segoe UI", system-ui, sans-serif`;

        const lineHeight = size * 1.05;
        const top = -((lines.length - 1) * lineHeight) / 2;
        lines.forEach((line, index) => ctx.fillText(line, 0, top + index * lineHeight));
      } else {
        // The unlabelled goals were the "N" logo in the original.
        ctx.fillStyle = colors.text;
        ctx.font = '700 34px "Segoe UI", system-ui, sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('N', 0, 1);
      }

      ctx.restore();
    }
  }

  /** Largest font size (up to `max`) at which every line fits `maxWidth`. */
  private fitFontSize(lines: readonly string[], maxWidth: number, max: number): number {
    const { ctx } = this;

    for (let size = max; size > 7; size -= 1) {
      ctx.font = `700 ${size}px "Segoe UI", system-ui, sans-serif`;
      if (lines.every((line) => ctx.measureText(line).width <= maxWidth)) return size;
    }
    return 7;
  }

  private drawPaths({ paths, hovered }: Scene): void {
    const { ctx } = this;

    ctx.lineCap = 'round';
    for (const path of paths) {
      ctx.globalAlpha = hovered.has(path) ? 0.4 : 1;
      ctx.strokeStyle = PATH_COLORS[path.type];
      ctx.lineWidth = path.type === PathType.Decorative ? 2 : 2.5;
      ctx.beginPath();
      ctx.moveTo(path.from.x, path.from.y);
      ctx.lineTo(path.to.x, path.to.y);
      ctx.stroke();
    }
    ctx.globalAlpha = 1;
  }

  private drawPreview(preview: PreviewLine): void {
    const { ctx } = this;

    ctx.save();
    ctx.strokeStyle = PATH_COLORS[preview.type];
    ctx.lineWidth = 2.5;
    ctx.globalAlpha = 0.75;
    ctx.setLineDash([6, 4]);
    ctx.beginPath();
    ctx.moveTo(preview.from.x, preview.from.y);
    ctx.lineTo(preview.to.x, preview.to.y);
    ctx.stroke();
    ctx.restore();
  }

  private drawAnchor(anchor: Point): void {
    const { ctx } = this;

    ctx.save();
    ctx.strokeStyle = '#f62e8d';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.arc(anchor.x, anchor.y, 4, 0, Math.PI * 2);
    ctx.stroke();
    ctx.restore();
  }

  private drawStartMarker(start: Point, mirrored: boolean): void {
    const { ctx } = this;

    ctx.save();
    ctx.translate(start.x, start.y);
    ctx.scale(mirrored ? -1 : 1, 1);

    ctx.strokeStyle = '#1a1a1a';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(0, 0, 14, 0, Math.PI * 2);
    ctx.stroke();

    ctx.beginPath();
    ctx.moveTo(-4, -6);
    ctx.lineTo(8, 0);
    ctx.lineTo(-4, 6);
    ctx.closePath();
    ctx.fillStyle = '#1a1a1a';
    ctx.fill();

    ctx.restore();
  }

  private drawRider(bodies: readonly Body[]): void {
    const { ctx } = this;

    for (const body of bodies) {
      const data = body.getUserData();
      if (!isPart(data)) continue;

      const position = body.getPosition();
      ctx.save();
      ctx.translate(position.x * PIXELS_PER_METER, position.y * PIXELS_PER_METER);
      ctx.rotate(body.getAngle());
      this.drawPart(data.art);
      ctx.restore();
    }
  }

  private drawPart(art: PartArt): void {
    const { ctx } = this;

    ctx.lineWidth = 1.2;
    ctx.strokeStyle = this.palette.outline;
    ctx.fillStyle = this.palette[art.material];

    switch (art.shape) {
      case 'circle':
        this.drawHead(art.width);
        break;

      case 'vehicle':
        this.drawVehicle(art.width, art.height);
        break;

      case 'box':
      default:
        roundedRect(ctx, -art.width / 2, -art.height / 2, art.width, art.height, 2);
        ctx.fill();
        ctx.stroke();

        if (art.tip) {
          // A bare hand at the far end of a sleeved forearm.
          ctx.fillStyle = this.palette[art.tip];
          const size = Math.max(art.width * 1.4, 6);
          ctx.beginPath();
          ctx.arc(0, art.height / 2 - size / 4, size / 2, 0, Math.PI * 2);
          ctx.fill();
          ctx.stroke();
        }
        break;
    }
  }

  private drawHead(radius: number): void {
    const { ctx } = this;

    ctx.beginPath();
    ctx.arc(0, 0, radius, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();

    // Helmet cap, so the head reads as a rider rather than a ball.
    ctx.save();
    ctx.beginPath();
    ctx.arc(0, 0, radius, Math.PI, Math.PI * 2);
    ctx.closePath();
    ctx.fillStyle = this.palette.shirt;
    ctx.fill();
    ctx.stroke();
    ctx.restore();

    ctx.fillStyle = this.palette.outline;
    ctx.beginPath();
    ctx.arc(radius * 0.35, radius * 0.15, radius * 0.12, 0, Math.PI * 2);
    ctx.fill();

    ctx.beginPath();
    ctx.arc(radius * 0.15, radius * 0.42, radius * 0.35, 0, Math.PI);
    ctx.lineWidth = 1;
    ctx.stroke();
  }

  private drawVehicle(width: number, height: number): void {
    const { ctx } = this;
    const wheelRadius = height / 2;

    roundedRect(ctx, -width / 2, -height / 2, width, height, Math.min(4, height / 2));
    ctx.fill();
    ctx.stroke();

    for (const side of [-1, 1]) {
      ctx.beginPath();
      ctx.arc((side * width) / 2, 0, wheelRadius, 0, Math.PI * 2);
      ctx.fillStyle = '#3d3d3d';
      ctx.fill();
      ctx.stroke();

      ctx.beginPath();
      ctx.arc((side * width) / 2, 0, Math.max(1.5, wheelRadius * 0.3), 0, Math.PI * 2);
      ctx.fillStyle = '#d8d8d8';
      ctx.fill();
    }
  }
}

function roundedRect(
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  width: number,
  height: number,
  radius: number,
): void {
  const r = Math.min(radius, width / 2, height / 2);
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.arcTo(x + width, y, x + width, y + height, r);
  ctx.arcTo(x + width, y + height, x, y + height, r);
  ctx.arcTo(x, y + height, x, y, r);
  ctx.arcTo(x, y, x + width, y, r);
  ctx.closePath();
}
