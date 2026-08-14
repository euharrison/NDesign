import { Box, Vec2, World, type Body } from 'planck';

import type { BlockSpec, Level } from '../levels/types';
import {
  BLOCK_DENSITY,
  GRAVITY,
  GROUND,
  PHYSICS_STEP,
  PIXELS_PER_METER,
  POSITION_ITERATIONS,
  VELOCITY_ITERATIONS,
} from './constants';
import type { Point } from './geometry';

const toMetres = (pixels: number): number => pixels / PIXELS_PER_METER;

/** What each body carries, so the renderer and the click test can read it. */
export interface BlockData {
  spec: BlockSpec;
  /** Set when the block has been blown up; kept for the explosion effect. */
  destroyed: boolean;
}

export interface Block {
  body: Body;
  spec: BlockSpec;
}

/**
 * Owns the physics world (`Jogo.as`). Knows how to build a level out of the
 * level table, blow a block up, and report where the N is.
 */
export class Engine {
  readonly world: World;
  readonly ground: Body;

  /** Every live block, in the order the level declared them. */
  readonly blocks: Block[] = [];

  /** The N logo — the block that has to survive. */
  n: Body | null = null;

  private accumulator = 0;

  constructor() {
    this.world = new World({ gravity: new Vec2(0, GRAVITY), allowSleep: true });
    this.ground = this.createGround();
  }

  private createGround(): Body {
    const body = this.world.createBody();
    body.createFixture(Box(toMetres(GROUND.width / 2), toMetres(GROUND.height / 2)), {
      density: 0,
      friction: GROUND.friction,
      restitution: GROUND.restitution,
    });
    body.setPosition(new Vec2(toMetres(GROUND.x), toMetres(GROUND.y)));
    body.setUserData({ ground: true });
    return body;
  }

  /** Clears the board and builds `level`, exactly as `CreateLevel` did. */
  load(level: Level): void {
    this.clear();

    for (const spec of level.blocks) {
      const body = this.world.createDynamicBody(new Vec2(toMetres(spec.x), toMetres(spec.y)));

      body.createFixture(Box(toMetres(spec.width / 2), toMetres(spec.height / 2)), {
        // Static blocks got density 0 in the original; none of the levels use them.
        density: spec.fixed ? 0 : BLOCK_DENSITY,
        friction: spec.friction,
        restitution: spec.restitution,
      });

      const data: BlockData = { spec, destroyed: false };
      body.setUserData(data);

      this.blocks.push({ body, spec });
      if (spec.name === 'N') this.n = body;
    }
  }

  clear(): void {
    for (const { body } of this.blocks) this.world.destroyBody(body);
    this.blocks.length = 0;
    this.n = null;
    this.accumulator = 0;
  }

  /**
   * Blows up the destructible block under `point` (stage pixels), if any.
   * Mirrors `destroyBody` + `GetBodyAtMouse`: static bodies are ignored, and
   * only blocks flagged `destroyable` come apart.
   */
  demolishAt(point: Point): Block | null {
    const target = this.blockAt(point);
    if (!target || !target.spec.destroyable) return null;

    this.world.destroyBody(target.body);
    this.blocks.splice(this.blocks.indexOf(target), 1);

    // Everything resting on the hole needs to start falling again.
    this.wakeAll();

    return target;
  }

  /** Topmost block containing `point`, or `null`. */
  blockAt(point: Point): Block | null {
    const target = new Vec2(toMetres(point.x), toMetres(point.y));

    for (let i = this.blocks.length - 1; i >= 0; i -= 1) {
      const block = this.blocks[i];
      for (let fixture = block.body.getFixtureList(); fixture; fixture = fixture.getNext()) {
        if (fixture.testPoint(target)) return block;
      }
    }

    return null;
  }

  private wakeAll(): void {
    for (const { body } of this.blocks) body.setAwake(true);
  }

  /** Advances the world with a fixed timestep. `elapsed` is in seconds. */
  step(elapsed: number): void {
    this.accumulator = Math.min(this.accumulator + elapsed, PHYSICS_STEP * 5);

    while (this.accumulator >= PHYSICS_STEP) {
      this.world.step(PHYSICS_STEP, VELOCITY_ITERATIONS, POSITION_ITERATIONS);
      this.accumulator -= PHYSICS_STEP;
    }
  }

  /** Centre of the N in stage pixels. */
  get nPosition(): Point {
    if (!this.n) return { x: 0, y: 0 };
    const position = this.n.getPosition();
    return { x: position.x * PIXELS_PER_METER, y: position.y * PIXELS_PER_METER };
  }

  /** `NFound.IsSleeping()` — the original's victory test. */
  get nAtRest(): boolean {
    return this.n ? !this.n.isAwake() : false;
  }

  get destroyableCount(): number {
    return this.blocks.filter((block) => block.spec.destroyable).length;
  }
}
