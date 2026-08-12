import { describe, expect, it } from 'vitest';

import { isPath, isWall } from '../src/game/core/bodyData';
import { PIXELS_PER_METER, PathType } from '../src/game/core/constants';
import { Engine } from '../src/game/core/Engine';
import { Path } from '../src/game/core/Path';
import { createRider } from '../src/game/riders';

const countBodies = (engine: Engine): number => {
  let count = 0;
  for (let body = engine.world.getBodyList(); body; body = body.getNext()) count += 1;
  return count;
};

/** Runs the world for `seconds` of simulated time. */
const simulate = (engine: Engine, seconds: number): void => {
  engine.play();
  for (let t = 0; t < seconds; t += 1 / 30) engine.step(1 / 30);
};

describe('Engine', () => {
  it('walls the world in', () => {
    const engine = new Engine();
    expect(isWall(engine.walls.getUserData())).toBe(true);
    expect(countBodies(engine)).toBe(1);
  });

  it('gives solid lines a physics body and tags it with the line type', () => {
    const engine = new Engine();
    const path = new Path({ x: 0, y: 100 }, { x: 300, y: 100 }, PathType.Accelerated);

    engine.addPath(path);

    expect(path.body).not.toBeNull();
    const data = path.body?.getUserData();
    expect(isPath(data) && data.type).toBe(PathType.Accelerated);
  });

  it('leaves decorative lines out of the simulation', () => {
    const engine = new Engine();
    const path = new Path({ x: 0, y: 0 }, { x: 100, y: 0 }, PathType.Decorative);

    engine.addPath(path);

    expect(path.body).toBeNull();
    expect(countBodies(engine)).toBe(1);
  });

  it('removes line bodies again', () => {
    const engine = new Engine();
    const path = new Path({ x: 0, y: 0 }, { x: 100, y: 0 }, PathType.Normal);

    engine.addPath(path);
    expect(countBodies(engine)).toBe(2);

    engine.removePath(path);
    expect(countBodies(engine)).toBe(1);
    expect(path.body).toBeNull();
  });

  it('does not advance the world while paused', () => {
    const engine = new Engine();
    const rider = createRider('skate', engine.world);
    rider.spawn(100, 100);

    const before = rider.headPosition.y;
    engine.step(1);

    expect(rider.headPosition.y).toBe(before);
  });

  it('drops the rider under gravity once playing', () => {
    const engine = new Engine();
    const rider = createRider('skate', engine.world);
    engine.setRider(rider);
    rider.spawn(500, 100);

    const before = rider.headPosition.y;
    simulate(engine, 0.5);

    expect(rider.headPosition.y).toBeGreaterThan(before);
  });

  it('kills the rider when the head lands on a solid line', () => {
    const engine = new Engine();
    const rider = createRider('skate', engine.world);
    engine.setRider(rider);

    let deaths = 0;
    engine.onDeath = () => (deaths += 1);

    // A wall of line right under the spawn point, so the head hits it head-on.
    const path = new Path({ x: 300, y: 160 }, { x: 700, y: 160 }, PathType.Normal);
    engine.addPath(path);
    rider.spawn(500, 100);

    simulate(engine, 2);

    expect(deaths).toBe(1);
  });

  it('speeds the vehicle up on accelerated lines', () => {
    const speedOn = (type: PathType): number => {
      const engine = new Engine();
      const rider = createRider('skate', engine.world);
      engine.setRider(rider);

      // A long, gentle ramp so the board keeps contact for a while.
      engine.addPath(new Path({ x: 0, y: 200 }, { x: 3000, y: 800 }, type));
      rider.spawn(60, 120);

      simulate(engine, 4);
      return rider.vehicle.getLinearVelocity().length();
    };

    expect(speedOn(PathType.Accelerated)).toBeGreaterThan(speedOn(PathType.Normal));
  });

  it('positions line bodies at the segment midpoint, in metres', () => {
    const engine = new Engine();
    const path = new Path({ x: 0, y: 0 }, { x: 300, y: 0 }, PathType.Normal);

    engine.addPath(path);

    const fixture = path.body?.getFixtureList();
    const shape = fixture?.getShape();
    // The box is offset inside the shape, so check via a world point test.
    expect(fixture?.testPoint({ x: 150 / PIXELS_PER_METER, y: 0 })).toBe(true);
    expect(shape?.getType()).toBe('polygon');
  });
});
