import { ERASER_TOLERANCE, PENCIL_SEGMENT_LENGTH, PathType, SNAP_DISTANCE } from './constants';
import { distance, distanceToSegment, type Point } from './geometry';
import type { Path } from './Path';
import type { PreviewLine } from '../render/Renderer';
import type { Viewport } from '../render/Viewport';

export const TOOLS = ['pencil', 'line', 'erase', 'hand', 'zoom'] as const;
export type Tool = (typeof TOOLS)[number];

export interface DrawHost {
  readonly paths: readonly Path[];
  /** Returns the created path, or `null` if the segment was too short. */
  createPath(from: Point, to: Point, type: PathType): Path | null;
  deletePath(path: Path): void;
}

/**
 * Turns pointer input into lines (`Draw.as`). It owns the tool modes, the
 * pencil's rubber-band preview, snapping, panning, zooming and the eraser.
 */
export class DrawController {
  tool: Tool = 'pencil';
  lineType: PathType = PathType.Normal;

  /** `false` while the game is running — input only pans/zooms then. */
  enabled = true;

  preview: PreviewLine | null = null;
  /** Endpoint of the last drawn line, used for snapping. */
  anchor: Point | null = null;
  readonly hovered = new Set<Path>();

  onChange: (() => void) | null = null;

  private pointer: Point = { x: 0, y: 0 };
  private pointerDown = false;
  private origin: Point | null = null;
  private panLast: Point | null = null;
  private zoomStart: Point | null = null;

  constructor(
    private readonly canvas: HTMLCanvasElement,
    private readonly viewport: Viewport,
    private readonly host: DrawHost,
  ) {
    canvas.addEventListener('pointerdown', this.handlePointerDown);
    canvas.addEventListener('pointermove', this.handlePointerMove);
    canvas.addEventListener('pointerup', this.handlePointerUp);
    canvas.addEventListener('pointercancel', this.handlePointerUp);
    canvas.addEventListener('pointerleave', this.handlePointerUp);
    canvas.addEventListener('wheel', this.handleWheel, { passive: false });
    canvas.addEventListener('contextmenu', (event) => event.preventDefault());
  }

  setTool(tool: Tool): void {
    if (this.tool === tool) return;

    this.cancelStroke();
    this.tool = tool;
    this.hovered.clear();
    this.canvas.style.cursor = CURSORS[tool];
    this.onChange?.();
  }

  setLineType(type: PathType): void {
    this.lineType = type;
    this.onChange?.();
  }

  /** Forgets the snap anchor, e.g. when the board is cleared. */
  clearAnchor(): void {
    this.anchor = null;
  }

  setAnchor(point: Point | null): void {
    this.anchor = point;
  }

  /** Frame-driven behaviour: the zoom drag and the eraser's hover highlight. */
  update(): void {
    if (this.tool === 'zoom' && this.pointerDown && this.zoomStart) {
      this.viewport.zoomAt(this.zoomStart, (this.zoomStart.y - this.pointer.y) / 1000 + 1);
    }

    if (this.tool === 'erase' && this.enabled) {
      this.hovered.clear();
      for (const path of this.pathsUnderCursor()) this.hovered.add(path);
    } else if (this.hovered.size) {
      this.hovered.clear();
    }
  }

  private get scenePointer(): Point {
    return this.viewport.toScene(this.pointer);
  }

  private pathsUnderCursor(): Path[] {
    const point = this.scenePointer;
    const tolerance = ERASER_TOLERANCE / Math.max(this.viewport.scale, 0.1);

    return this.host.paths.filter(
      (path) => distanceToSegment(point, path.from, path.to) <= tolerance,
    );
  }

  private handlePointerDown = (event: PointerEvent): void => {
    this.canvas.setPointerCapture(event.pointerId);
    this.trackPointer(event);
    this.pointerDown = true;

    // Middle-drag and space-drag always pan, whatever the active tool is.
    const panning = this.tool === 'hand' || event.button === 1 || !this.enabled;

    if (panning) {
      this.panLast = { ...this.pointer };
      return;
    }

    switch (this.tool) {
      case 'pencil':
      case 'line': {
        const scene = this.scenePointer;
        this.origin =
          this.anchor && distance(scene, this.anchor) <= SNAP_DISTANCE ? { ...this.anchor } : scene;
        this.preview = { from: this.origin, to: scene, type: this.lineType };
        break;
      }
      case 'erase':
        this.eraseUnderCursor();
        break;
      case 'zoom':
        this.zoomStart = { ...this.pointer };
        break;
    }
  };

  private handlePointerMove = (event: PointerEvent): void => {
    this.trackPointer(event);

    if (this.panLast) {
      this.viewport.panBy(this.pointer.x - this.panLast.x, this.pointer.y - this.panLast.y);
      this.panLast = { ...this.pointer };
      return;
    }

    if (!this.pointerDown || !this.enabled) return;

    switch (this.tool) {
      case 'pencil': {
        if (!this.origin) break;
        const scene = this.scenePointer;
        // The pencil lays down a fresh segment every 30px, as in the original.
        if (distance(this.origin, scene) >= PENCIL_SEGMENT_LENGTH) {
          this.commit(this.origin, scene);
          this.origin = scene;
        }
        this.preview = { from: this.origin, to: scene, type: this.lineType };
        break;
      }
      case 'line':
        if (this.origin)
          this.preview = { from: this.origin, to: this.scenePointer, type: this.lineType };
        break;
      case 'erase':
        this.eraseUnderCursor();
        break;
    }
  };

  private handlePointerUp = (event: PointerEvent): void => {
    if (!this.pointerDown && !this.panLast) return;
    this.trackPointer(event);

    if (this.canvas.hasPointerCapture(event.pointerId)) {
      this.canvas.releasePointerCapture(event.pointerId);
    }

    if (this.origin && this.enabled) this.commit(this.origin, this.scenePointer);

    this.pointerDown = false;
    this.origin = null;
    this.preview = null;
    this.panLast = null;
    this.zoomStart = null;
  };

  private handleWheel = (event: WheelEvent): void => {
    event.preventDefault();
    this.trackPointer(event);
    this.viewport.zoomAt(this.pointer, event.deltaY > 0 ? 0.95 : 1.05);
  };

  private trackPointer(event: PointerEvent | WheelEvent): void {
    const rect = this.canvas.getBoundingClientRect();
    this.pointer = { x: event.clientX - rect.left, y: event.clientY - rect.top };
  }

  private commit(from: Point, to: Point): void {
    const path = this.host.createPath(from, to, this.lineType);
    if (path) {
      this.anchor = { ...to };
      this.onChange?.();
    }
  }

  private eraseUnderCursor(): void {
    const doomed = this.pathsUnderCursor();
    if (!doomed.length) return;

    for (const path of doomed) this.host.deletePath(path);
    this.hovered.clear();
    this.onChange?.();
  }

  private cancelStroke(): void {
    this.pointerDown = false;
    this.origin = null;
    this.preview = null;
    this.panLast = null;
    this.zoomStart = null;
  }
}

const CURSORS: Record<Tool, string> = {
  pencil: 'crosshair',
  line: 'crosshair',
  erase: 'cell',
  hand: 'grab',
  zoom: 'ns-resize',
};
