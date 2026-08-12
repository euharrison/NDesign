import { MAX_ZOOM, MIN_ZOOM, SCENE_WIDTH } from '../core/constants';
import type { Point } from '../core/geometry';

/**
 * The pan/zoom transform of the drawing surface — the `Cena` sprite plus the
 * `Camera` that follows the rider in the original.
 */
export class Viewport {
  x = 0;
  y = 0;
  scale = 1;

  width = 0;
  height = 0;

  resize(width: number, height: number): void {
    this.width = width;
    this.height = height;
  }

  /** Centres the 1000px-wide stage the levels were authored against. */
  reset(): void {
    this.x = (this.width - SCENE_WIDTH) / 2;
    this.y = 0;
    this.scale = 1;
  }

  toScene(screen: Point): Point {
    return { x: (screen.x - this.x) / this.scale, y: (screen.y - this.y) / this.scale };
  }

  toScreen(scene: Point): Point {
    return { x: scene.x * this.scale + this.x, y: scene.y * this.scale + this.y };
  }

  /** Scales by `factor` while keeping `anchor` (screen space) fixed. */
  zoomAt(anchor: Point, factor: number): void {
    let f = factor;
    if (this.scale * f >= MAX_ZOOM) f = MAX_ZOOM / this.scale;
    if (this.scale * f <= MIN_ZOOM) f = MIN_ZOOM / this.scale;
    if (f === 1) return;

    this.x = anchor.x - (anchor.x - this.x) * f;
    this.y = anchor.y - (anchor.y - this.y) * f;
    this.scale *= f;
  }

  panBy(dx: number, dy: number): void {
    this.x += dx;
    this.y += dy;
  }

  /** Keeps a scene point in the middle of the screen (camera follow). */
  centreOn(point: Point): void {
    this.x = -point.x * this.scale + this.width / 2;
    this.y = -point.y * this.scale + this.height / 2;
  }
}
