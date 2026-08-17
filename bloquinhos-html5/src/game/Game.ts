import { BOMB_COOLDOWN, LOSE_X_MAX, LOSE_X_MIN, LOSE_Y, VICTORY_DWELL } from './core/constants';
import { Engine, type Block } from './core/Engine';
import type { Point } from './core/geometry';
import { PACKS } from './levels/levels';
import type { Level, LevelPack } from './levels/types';
import { Renderer } from './render/Renderer';
import { loadSave, writeSave } from './storage';

export type GameState = 'playing' | 'won' | 'lost' | 'finished';

export type GameEvent = { type: 'state'; state: GameState } | { type: 'level' } | { type: 'tick' };

export type GameListener = (event: GameEvent) => void;

/**
 * The game loop and rules (`Jogo.as`): blow blocks up, keep the N on stage, and
 * win once it settles.
 */
export class Game {
  readonly engine = new Engine();
  readonly renderer: Renderer;

  state: GameState = 'playing';
  packIndex = 0;
  levelIndex = 0;

  /** Total elapsed time for the run — the original's clock never reset. */
  elapsed = 0;

  /** Remaining bomb cooldown in seconds. */
  cooldown = 0;

  /** Blocks blown up on this level. */
  demolished = 0;

  private readonly listeners = new Set<GameListener>();
  private readonly reached: Record<string, number> = {};
  private readonly best: Record<string, number> = {};

  private pointer: Point = { x: 500, y: 290 };
  private pointerInside = false;
  private hovered: Block | null = null;
  private restingFor = 0;
  private frame = 0;
  private lastTime = 0;

  constructor(private readonly canvas: HTMLCanvasElement) {
    this.renderer = new Renderer(canvas);

    this.restore();

    canvas.addEventListener('pointermove', this.handlePointerMove);
    canvas.addEventListener('pointerdown', this.handlePointerDown);
    canvas.addEventListener('pointerenter', () => (this.pointerInside = true));
    canvas.addEventListener('pointerleave', () => (this.pointerInside = false));
    canvas.addEventListener('contextmenu', (event) => event.preventDefault());
    window.addEventListener('resize', this.resize);

    this.resize();
    this.loadLevel();
  }

  // ------------------------------------------------------------------ level

  get pack(): LevelPack {
    return PACKS[this.packIndex];
  }

  get level(): Level {
    return this.pack.levels[this.levelIndex];
  }

  get totalLevels(): number {
    return this.pack.levels.length;
  }

  get isLastLevel(): boolean {
    return this.levelIndex >= this.totalLevels - 1;
  }

  get bestTime(): number | null {
    return this.best[this.pack.id] ?? null;
  }

  get packs(): readonly LevelPack[] {
    return PACKS;
  }

  subscribe(listener: GameListener): () => void {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  private emit(event: GameEvent): void {
    for (const listener of this.listeners) listener(event);
  }

  // ---------------------------------------------------------------- actions

  /** Loads the current level and starts play. */
  loadLevel(): void {
    this.engine.load(this.level);
    this.demolished = 0;
    this.cooldown = 0;
    this.restingFor = 0;
    this.hovered = null;
    this.setState('playing');

    const reached = this.reached[this.pack.id] ?? 0;
    if (this.levelIndex > reached) {
      this.reached[this.pack.id] = this.levelIndex;
      this.persist();
    }

    this.emit({ type: 'level' });
  }

  retry(): void {
    this.loadLevel();
  }

  next(): void {
    if (this.isLastLevel) return;
    this.levelIndex += 1;
    this.loadLevel();
  }

  /** Jumps to a level, resetting the clock — used by the pack picker. */
  goTo(packIndex: number, levelIndex: number, resetClock = true): void {
    this.packIndex = Math.min(Math.max(packIndex, 0), PACKS.length - 1);
    this.levelIndex = Math.min(Math.max(levelIndex, 0), this.totalLevels - 1);
    if (resetClock) this.elapsed = 0;
    this.persist();
    this.loadLevel();
  }

  /**
   * Jumps to whichever level a code unlocks, as the original password box did.
   * Returns `false` when nothing matches.
   */
  enterPassword(code: string): boolean {
    const wanted = code.trim().toUpperCase();
    if (!wanted) return false;

    for (const [packIndex, pack] of PACKS.entries()) {
      const levelIndex = pack.levels.findIndex((level) => level.password === wanted);
      if (levelIndex !== -1) {
        this.goTo(packIndex, levelIndex);
        return true;
      }
    }

    return false;
  }

  // ------------------------------------------------------------------- loop

  start(): void {
    if (this.frame) return;
    this.lastTime = performance.now();
    this.frame = requestAnimationFrame(this.tick);
  }

  stop(): void {
    cancelAnimationFrame(this.frame);
    this.frame = 0;
  }

  private tick = (now: number): void => {
    const elapsed = Math.min((now - this.lastTime) / 1000, 0.25);
    this.lastTime = now;

    if (this.state === 'playing') {
      this.elapsed += elapsed;
      this.cooldown = Math.max(0, this.cooldown - elapsed);
      this.engine.step(elapsed);
      this.checkOutcome(elapsed);
      this.emit({ type: 'tick' });
    }

    this.renderer.update(elapsed);
    this.updateHover();
    this.render();

    this.frame = requestAnimationFrame(this.tick);
  };

  /**
   * The N has to come to rest standing on the `Rio021` pedestal. Touching the
   * ground loses, and so does leaving the stage.
   *
   * This is what `checkVictory` was for. The flag is declared in `Jogo.as` but
   * never assigned there — it was set from a movie clip's timeline, inside a
   * .fla whose zip directory is corrupt — and `_checkingVictory()` only tests
   * `NFound.IsSleeping()` once it is armed. Landing on the pedestal is what
   * arms it: every one of the 42 levels declares exactly one `Rio021` block —
   * 31 standing on the ground, the other 11 built up into the structure.
   *
   * The first-demolition guard stays because one level ("Mosh") starts with the
   * N already on its pedestal, and would otherwise be won on frame one.
   */
  private checkOutcome(elapsed: number): void {
    const { x, y } = this.engine.nPosition;

    if (x > LOSE_X_MAX || x < LOSE_X_MIN || y > LOSE_Y || this.engine.nOnGround) {
      this.setState('lost');
      return;
    }

    if (this.demolished === 0) return;

    if (this.engine.nAtRest && this.engine.nOnTarget) {
      this.restingFor += elapsed;
      if (this.restingFor >= VICTORY_DWELL) this.win();
    } else {
      this.restingFor = 0;
    }
  }

  private win(): void {
    if (this.isLastLevel) {
      const previous = this.best[this.pack.id];
      if (previous === undefined || this.elapsed < previous) {
        this.best[this.pack.id] = this.elapsed;
      }
      this.persist();
      this.setState('finished');
    } else {
      this.setState('won');
    }
  }

  // ------------------------------------------------------------------ input

  private handlePointerMove = (event: PointerEvent): void => {
    this.pointer = this.renderer.toStage(this.canvasPoint(event));
    this.pointerInside = true;
  };

  private handlePointerDown = (event: PointerEvent): void => {
    this.pointer = this.renderer.toStage(this.canvasPoint(event));

    if (this.state !== 'playing' || this.cooldown > 0) return;

    const destroyed = this.engine.demolishAt(this.pointer);
    if (!destroyed) return;

    this.renderer.addExplosion(this.pointer.x, this.pointer.y, destroyed.spec.material);
    this.cooldown = BOMB_COOLDOWN;
    this.demolished += 1;
    this.restingFor = 0;
    this.hovered = null;
  };

  private canvasPoint(event: PointerEvent): Point {
    const rect = this.canvas.getBoundingClientRect();
    return { x: event.clientX - rect.left, y: event.clientY - rect.top };
  }

  private updateHover(): void {
    if (this.state !== 'playing' || this.cooldown > 0) {
      this.hovered = null;
      return;
    }

    const block = this.engine.blockAt(this.pointer);
    this.hovered = block?.spec.destroyable ? block : null;
  }

  // ----------------------------------------------------------------- render

  private render(): void {
    this.renderer.render({
      blocks: this.engine.blocks,
      pointer: this.pointer,
      cooldown: this.cooldown / BOMB_COOLDOWN,
      showCursor: this.pointerInside && this.state === 'playing',
      hovered: this.hovered,
    });
  }

  private resize = (): void => {
    this.renderer.resize();
  };

  private setState(state: GameState): void {
    if (this.state === state) return;
    this.state = state;
    this.emit({ type: 'state', state });
  }

  // ------------------------------------------------------------------- save

  private persist(): void {
    writeSave({
      packId: this.pack.id,
      levelIndex: this.levelIndex,
      reached: this.reached,
      best: this.best,
    });
  }

  private restore(): void {
    const save = loadSave();

    const packIndex = PACKS.findIndex((pack) => pack.id === save.packId);
    if (packIndex !== -1) this.packIndex = packIndex;

    if (typeof save.levelIndex === 'number') {
      this.levelIndex = Math.min(Math.max(save.levelIndex, 0), this.totalLevels - 1);
    }

    Object.assign(this.reached, save.reached ?? {});
    Object.assign(this.best, save.best ?? {});
  }
}
