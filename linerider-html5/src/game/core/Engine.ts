import { Box, Vec2, World, type Body, type Contact } from 'planck';

import { isPath, isWall } from './bodyData';
import {
  ACCELERATION_FACTOR,
  GRAVITY,
  PHYSICS_STEP,
  PIXELS_PER_METER,
  POSITION_ITERATIONS,
  PathType,
  VELOCITY_ITERATIONS,
  WORLD_LIMIT,
  WORLD_WALL_THICKNESS,
} from './constants';
import { angleDegrees, distance, midpoint } from './geometry';
import type { Path } from './Path';

/** The subset of a rider the engine needs in order to run collision rules. */
export interface EngineRider {
  /** Bodies that kill the rider when they hit a solid line (head, torso). */
  readonly breakables: readonly Body[];
  /** The board/bike/cart — the body the accelerated lines push. */
  readonly vehicle: Body;
}

/**
 * Owns the physics world (`Engine.as`). It knows nothing about the game's
 * screens; the game reacts to `onDeath` and drives `step()`.
 */
export class Engine {
  readonly world: World;
  readonly walls: Body;

  /** Called when the rider hits a wall or lands head/torso first on a line. */
  onDeath: (() => void) | null = null;

  private rider: EngineRider | null = null;
  private running = false;
  private accumulator = 0;
  /** While `true`, contacts no longer trigger deaths — the ragdoll is falling. */
  private dead = false;

  constructor() {
    this.world = new World({ gravity: new Vec2(0, GRAVITY), allowSleep: true });
    this.walls = this.createWalls();

    this.world.on('begin-contact', this.handleBeginContact);
    this.world.on('pre-solve', this.handlePreSolve);
  }

  /** The box the original built around the world; touching it is fatal. */
  private createWalls(): Body {
    const body = this.world.createBody();
    const offsets: Array<[number, number, number, number]> = [
      [WORLD_WALL_THICKNESS, WORLD_LIMIT, WORLD_LIMIT, 0],
      [WORLD_LIMIT, WORLD_WALL_THICKNESS, 0, WORLD_LIMIT],
      [WORLD_WALL_THICKNESS, WORLD_LIMIT, -WORLD_LIMIT, 0],
      [WORLD_LIMIT, WORLD_WALL_THICKNESS, 0, -WORLD_LIMIT],
    ];

    for (const [halfWidth, halfHeight, x, y] of offsets) {
      body.createFixture(Box(halfWidth, halfHeight, new Vec2(x, y)), { density: 0, friction: 0 });
    }

    body.setUserData({ kind: 'wall' });
    return body;
  }

  setRider(rider: EngineRider | null): void {
    this.rider = rider;
  }

  play(): void {
    this.running = true;
    this.dead = false;
    this.accumulator = 0;
  }

  pause(): void {
    this.running = false;
  }

  get isRunning(): boolean {
    return this.running;
  }

  /**
   * Advances the world with a fixed timestep, so behaviour does not depend on
   * the display's refresh rate. `elapsed` is in seconds.
   */
  step(elapsed: number): void {
    if (!this.running) return;

    // Cap catch-up so a backgrounded tab does not spiral.
    this.accumulator = Math.min(this.accumulator + elapsed, PHYSICS_STEP * 5);

    while (this.accumulator >= PHYSICS_STEP) {
      this.world.step(PHYSICS_STEP, VELOCITY_ITERATIONS, POSITION_ITERATIONS);
      this.accumulator -= PHYSICS_STEP;
    }
  }

  /** Creates the thin static box that a drawn line collides with. */
  addPath(path: Path): void {
    if (!path.solid) return;

    const length = distance(path.from, path.to);
    const centre = midpoint(path.from, path.to);
    const angle = (angleDegrees(path.from, path.to) * Math.PI) / 180;

    const body = this.world.createBody();
    body.createFixture(
      Box(
        length / PIXELS_PER_METER / 2,
        1 / PIXELS_PER_METER,
        new Vec2(centre.x / PIXELS_PER_METER, centre.y / PIXELS_PER_METER),
        angle,
      ),
      { density: 0, friction: 0 },
    );
    body.setUserData({ kind: 'path', type: path.type });

    path.body = body;
  }

  removePath(path: Path): void {
    if (path.body) {
      this.world.destroyBody(path.body);
      path.body = null;
    }
  }

  /** Marks the rider dead so the tumbling ragdoll stops re-triggering deaths. */
  markDead(): void {
    this.dead = true;
  }

  private handleBeginContact = (contact: Contact): void => {
    if (this.dead || !this.rider) return;

    const a = contact.getFixtureA().getBody();
    const b = contact.getFixtureB().getBody();

    if (isWall(a.getUserData()) || isWall(b.getUserData())) {
      this.die();
      return;
    }

    for (const breakable of this.rider.breakables) {
      const other = breakable === a ? b : breakable === b ? a : null;
      if (other && isSolidLine(other)) {
        this.die();
        return;
      }
    }
  };

  /**
   * `b2ContactListener.Persist` in the original: while the rider touches an
   * accelerated line, scale the vehicle's velocity up a little each step.
   */
  private handlePreSolve = (contact: Contact): void => {
    if (this.dead || !this.rider) return;

    const a = contact.getFixtureA().getBody().getUserData();
    const b = contact.getFixtureB().getBody().getUserData();

    const accelerated =
      (isPath(a) && a.type === PathType.Accelerated) ||
      (isPath(b) && b.type === PathType.Accelerated);

    if (accelerated) {
      const vehicle = this.rider.vehicle;
      vehicle.setLinearVelocity(Vec2.mul(vehicle.getLinearVelocity(), ACCELERATION_FACTOR));
    }
  };

  private die(): void {
    this.dead = true;
    this.onDeath?.();
  }
}

const isSolidLine = (body: Body): boolean => {
  const data = body.getUserData();
  return isPath(data) && (data.type === PathType.Normal || data.type === PathType.Accelerated);
};
