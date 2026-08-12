import { describe, expect, it } from 'vitest';

import { isPart } from '../src/game/core/bodyData';
import { PIXELS_PER_METER } from '../src/game/core/constants';
import { Engine } from '../src/game/core/Engine';
import { RIDER_TYPES, createRider } from '../src/game/riders';

const jointCount = (engine: Engine): number => {
  let count = 0;
  for (let joint = engine.world.getJointList(); joint; joint = joint.getNext()) count += 1;
  return count;
};

describe('riders', () => {
  it.each(RIDER_TYPES)('builds %s with parts, a head and a vehicle', (type) => {
    const engine = new Engine();
    const rider = createRider(type, engine.world);

    expect(rider.bodies.length).toBeGreaterThan(5);
    expect(rider.head).toBeDefined();
    expect(rider.vehicle).toBeDefined();
    expect(rider.breakables.length).toBeGreaterThan(0);
    expect(rider.bodies.every((body) => isPart(body.getUserData()))).toBe(true);
  });

  it.each(RIDER_TYPES)('spawns %s at the requested point', (type) => {
    const engine = new Engine();
    const rider = createRider(type, engine.world);

    rider.spawn(400, 250);

    expect(rider.created).toBe(true);
    // The head sits at the spawn origin, give or take each rider's offset.
    expect(rider.headPosition.x).toBeGreaterThan(350);
    expect(rider.headPosition.x).toBeLessThan(450);
    expect(rider.headPosition.y).toBeCloseTo(250, 0);
    expect(jointCount(engine)).toBeGreaterThan(0);
  });

  it('mirrors the spawn horizontally', () => {
    const engine = new Engine();
    const normal = createRider('bike', engine.world);
    const mirrored = createRider('bike', engine.world);

    normal.spawn(500, 100, false);
    mirrored.spawn(500, 100, true);

    const offset = (rider: typeof normal): number =>
      rider.vehicle.getPosition().x * PIXELS_PER_METER - 500;

    expect(offset(normal)).toBeCloseTo(-offset(mirrored), 5);
  });

  it('breaks the ragdoll apart on destroy, leaving the bodies in the world', () => {
    const engine = new Engine();
    const rider = createRider('bike', engine.world);

    rider.spawn(500, 100);
    const bodies = rider.bodies.length;
    expect(jointCount(engine)).toBeGreaterThan(0);

    rider.destroy();

    expect(rider.created).toBe(false);
    expect(jointCount(engine)).toBe(0);
    expect(rider.bodies.length).toBe(bodies);
  });

  it('reuses the same bodies when respawned', () => {
    const engine = new Engine();
    const rider = createRider('sled', engine.world);

    rider.spawn(200, 100);
    const first = [...rider.bodies];
    rider.destroy();
    rider.spawn(600, 100);

    expect(rider.bodies).toEqual(first);
    expect(rider.headPosition.x).toBeCloseTo(600 - 10, 0);
  });

  it('clears velocity between spawns so a respawn starts at rest', () => {
    const engine = new Engine();
    const rider = createRider('skate', engine.world);
    engine.setRider(rider);
    rider.spawn(500, 100);

    engine.play();
    for (let i = 0; i < 30; i += 1) engine.step(1 / 30);
    expect(rider.vehicle.getLinearVelocity().length()).toBeGreaterThan(0);

    rider.destroy();
    rider.spawn(500, 100);

    expect(rider.vehicle.getLinearVelocity().length()).toBe(0);
  });

  it('disposes every body it created', () => {
    const engine = new Engine();
    const rider = createRider('cart', engine.world);
    rider.spawn(100, 100);

    rider.dispose();

    let bodies = 0;
    for (let body = engine.world.getBodyList(); body; body = body.getNext()) bodies += 1;
    expect(bodies).toBe(1); // only the walls remain
  });
});
