import type { PathType } from './core/constants';
import { DEATH_DELAY, PIXELS_PER_METER, SCENE_WIDTH } from './core/constants';
import { DrawController, type DrawHost } from './core/DrawController';
import { Engine } from './core/Engine';
import { distance, type Point } from './core/geometry';
import { Path, type SerializedPath } from './core/Path';
import { LEVELS } from './levels/levels';
import { TARGET_RADIUS, type Level } from './levels/types';
import { Renderer } from './render/Renderer';
import { DEFAULT_RIDER_PALETTE, type RiderPalette } from './render/palette';
import { Viewport } from './render/Viewport';
import { createRider, type Rider, type RiderType } from './riders';
import { clearSave, loadSave, writeSave } from './storage';

export type GameState = 'init' | 'draw' | 'play' | 'pause' | 'die';

/** Fired so the UI layer can re-render without polling. */
export type GameEvent =
  | { type: 'state'; state: GameState }
  | { type: 'level' }
  | { type: 'won'; answer: string; last: boolean }
  | { type: 'paths' };

export type GameListener = (event: GameEvent) => void;

/** Shortest line that still makes a valid physics shape, in scene pixels. */
const MIN_SEGMENT = 1;

/**
 * The game's state machine and main loop — `projeto.game.Game` in the original,
 * with `Levels` folded in since the level table is now plain data.
 */
export class Game implements DrawHost {
  readonly engine = new Engine();
  readonly viewport = new Viewport();
  readonly renderer: Renderer;
  readonly tools: DrawController;

  state: GameState = 'init';
  levelIndex = 0;
  readonly paths: Path[] = [];
  readonly answers = new Map<number, string>();

  riderType: RiderType = 'skate';
  palette: RiderPalette = { ...DEFAULT_RIDER_PALETTE };

  private rider: Rider;
  private readonly pathsByLevel = new Map<number, SerializedPath[]>();
  private readonly listeners = new Set<GameListener>();
  private readonly reached = new Set<string>();

  private frame = 0;
  private lastTime = 0;
  private deathTimer = 0;

  constructor(canvas: HTMLCanvasElement) {
    this.renderer = new Renderer(canvas);
    this.tools = new DrawController(canvas, this.viewport, this);
    this.tools.onChange = () => this.emit({ type: 'paths' });

    this.restoreSave();

    this.rider = createRider(this.riderType, this.engine.world);
    this.engine.setRider(this.rider);
    this.engine.onDeath = () => this.dieState();
    this.renderer.palette = this.palette;

    this.resize();
    window.addEventListener('resize', this.resize);

    this.initState();
  }

  // ------------------------------------------------------------------ level

  get level(): Level {
    return LEVELS[this.levelIndex];
  }

  get totalLevels(): number {
    return LEVELS.length;
  }

  get isLastLevel(): boolean {
    return this.levelIndex >= LEVELS.length - 1;
  }

  get startPoint(): Point {
    return this.level.start;
  }

  subscribe(listener: GameListener): () => void {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  private emit(event: GameEvent): void {
    for (const listener of this.listeners) listener(event);
  }

  // ------------------------------------------------------------------ states

  initState(): void {
    this.setState('init');

    this.clearPaths();
    this.reached.clear();
    this.viewport.reset();
    this.tools.clearAnchor();
    this.tools.enabled = false;

    this.emit({ type: 'level' });
  }

  drawState(): void {
    this.setState('draw');

    this.deathTimer = 0;
    this.tools.enabled = true;
    this.tools.setTool(this.tools.tool);
    this.viewport.x = (this.viewport.width - SCENE_WIDTH * this.viewport.scale) / 2;
    this.viewport.y = 0;
  }

  playState(): void {
    if (!this.rider.created) {
      this.rider.spawn(this.startPoint.x, this.startPoint.y, this.level.mirrored);
    }

    this.setState('play');
    this.tools.enabled = false;
    this.engine.play();
  }

  pauseState(): void {
    this.setState('pause');
    this.engine.pause();
  }

  dieState(): void {
    if (this.state === 'die') return;

    this.setState('die');
    this.deathTimer = 0;
    this.engine.markDead();
    this.rider.destroy();
  }

  // ----------------------------------------------------------------- actions

  /** Stop button: back to the drawing board with the lines intact. */
  stop(): void {
    this.pauseState();
    this.despawnRider();
    this.drawState();
  }

  /** Bin button (`refazer`): wipe the lines and start the level over. */
  redo(): void {
    this.clearPaths();
    this.stop();
  }

  replay(): void {
    this.despawnRider();
    this.playState();
  }

  next(): void {
    this.despawnRider();
    if (!this.isLastLevel) this.levelIndex += 1;
    this.initState();
    this.persist();
  }

  /** Starts the current level from its question screen. */
  begin(): void {
    this.drawState();
  }

  restart(): void {
    clearSave();
    this.pathsByLevel.clear();
    this.answers.clear();
    this.levelIndex = 0;
    this.despawnRider();
    this.initState();
  }

  undo(): void {
    const path = this.paths.at(-1);
    if (path) this.deletePath(path);
  }

  setRiderType(type: RiderType): void {
    if (type === this.riderType) return;

    this.riderType = type;
    this.despawnRider();
    this.rider.dispose();
    this.rider = createRider(type, this.engine.world);
    this.engine.setRider(this.rider);
    this.persist();
    this.emit({ type: 'level' });
  }

  setPalette(palette: Partial<RiderPalette>): void {
    this.palette = { ...this.palette, ...palette };
    // Keep the face tone in step with the exposed skin.
    this.palette.head = this.palette.skin;
    this.renderer.palette = this.palette;
    this.persist();
  }

  // ------------------------------------------------------------- DrawHost

  createPath(from: Point, to: Point, type: PathType): Path | null {
    if (distance(from, to) < MIN_SEGMENT) return null;

    const path = new Path({ ...from }, { ...to }, type);
    this.engine.addPath(path);
    this.paths.push(path);
    return path;
  }

  deletePath(path: Path): void {
    const index = this.paths.indexOf(path);
    if (index === -1) return;

    this.engine.removePath(path);
    this.paths.splice(index, 1);
    this.tools.setAnchor(this.paths.at(-1)?.to ?? null);
    this.emit({ type: 'paths' });
  }

  private clearPaths(): void {
    for (const path of this.paths) this.engine.removePath(path);
    this.paths.length = 0;
    this.tools.clearAnchor();
    this.emit({ type: 'paths' });
  }

  // ---------------------------------------------------------------- the loop

  start(): void {
    if (this.frame) return;
    this.lastTime = performance.now();
    this.frame = requestAnimationFrame(this.tick);
  }

  stopLoop(): void {
    cancelAnimationFrame(this.frame);
    this.frame = 0;
  }

  private tick = (now: number): void => {
    const elapsed = Math.min((now - this.lastTime) / 1000, 0.25);
    this.lastTime = now;

    this.tools.update();

    if (this.state === 'play' || this.state === 'die') {
      this.engine.step(elapsed);
      this.viewport.centreOn(this.rider.headPosition);
    }

    if (this.state === 'play') this.checkTargets();

    if (this.state === 'die') {
      this.deathTimer += elapsed;
      if (this.deathTimer >= DEATH_DELAY) {
        this.pauseState();
        this.despawnRider();
        this.drawState();
      }
    }

    this.render();
    this.frame = requestAnimationFrame(this.tick);
  };

  private render(): void {
    this.renderer.render(
      {
        paths: this.paths,
        targets: this.level.targets,
        reached: this.reached,
        bodies: this.rider.bodies,
        riderVisible: this.rider.created || this.state === 'die',
        preview: this.tools.preview,
        anchor: this.state === 'draw' ? this.tools.anchor : null,
        start: this.state === 'draw' || this.state === 'init' ? this.startPoint : null,
        startMirrored: this.level.mirrored,
        hovered: this.tools.hovered,
      },
      this.viewport,
    );
  }

  /** `Levels.check` in the original: did the rider reach a goal circle? */
  private checkTargets(): void {
    for (const target of this.level.targets) {
      const hit = this.rider.bodies.some((body) => {
        const position = body.getPosition();
        return (
          distance(
            { x: position.x * PIXELS_PER_METER, y: position.y * PIXELS_PER_METER },
            target,
          ) <= TARGET_RADIUS
        );
      });

      if (!hit) continue;

      if (target.value === 'die') {
        this.dieState();
        return;
      }

      this.win(target.value);
      return;
    }
  }

  private win(answer: string): void {
    this.pauseState();
    this.reached.add(answer);
    this.answers.set(this.levelIndex, answer);
    this.pathsByLevel.set(
      this.levelIndex,
      this.paths.map((path) => path.toJSON()),
    );
    this.persist();

    this.emit({ type: 'won', answer, last: this.isLastLevel });
  }

  private despawnRider(): void {
    if (this.rider.created) this.rider.destroy();
  }

  private setState(state: GameState): void {
    this.state = state;
    this.emit({ type: 'state', state });
  }

  private resize = (): void => {
    const { width, height } = this.renderer.resize();
    const first = this.viewport.width === 0;
    this.viewport.resize(width, height);
    if (first) this.viewport.reset();
  };

  // ------------------------------------------------------------------- save

  private persist(): void {
    writeSave({
      levelIndex: this.levelIndex,
      rider: this.riderType,
      palette: this.palette,
      answers: Object.fromEntries(this.answers),
      paths: Object.fromEntries(this.pathsByLevel),
    });
  }

  private restoreSave(): void {
    const save = loadSave();

    if (save.rider) this.riderType = save.rider;
    if (save.palette) this.palette = { ...DEFAULT_RIDER_PALETTE, ...save.palette };
    if (typeof save.levelIndex === 'number') {
      this.levelIndex = Math.min(Math.max(save.levelIndex, 0), LEVELS.length - 1);
    }
    for (const [key, value] of Object.entries(save.answers ?? {})) {
      this.answers.set(Number(key), value);
    }
    for (const [key, value] of Object.entries(save.paths ?? {})) {
      this.pathsByLevel.set(Number(key), value);
    }
  }

  /** Answers collected so far, in level order — used by the final screen. */
  get summary(): Array<{ level: number; question: string; answer: string }> {
    return [...this.answers.entries()]
      .sort(([a], [b]) => a - b)
      .map(([level, answer]) => ({ level, question: LEVELS[level].question, answer }));
  }
}
