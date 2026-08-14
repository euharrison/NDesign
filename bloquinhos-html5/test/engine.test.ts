import { describe, expect, it } from 'vitest';

import { PIXELS_PER_METER } from '../src/game/core/constants';
import { Engine } from '../src/game/core/Engine';
import { PACKS } from '../src/game/levels/levels';
import type { Level } from '../src/game/levels/types';

const firstLevel = (): Level => PACKS[0].levels[0];

/** Runs the world for `seconds` of simulated time. */
const simulate = (engine: Engine, seconds: number): void => {
  for (let t = 0; t < seconds; t += 1 / 30) engine.step(1 / 30);
};

const countBodies = (engine: Engine): number => {
  let count = 0;
  for (let body = engine.world.getBodyList(); body; body = body.getNext()) count += 1;
  return count;
};

describe('Engine', () => {
  it('starts with just the ground', () => {
    const engine = new Engine();
    expect(countBodies(engine)).toBe(1);
    expect(engine.blocks).toHaveLength(0);
  });

  it('builds a level into bodies and finds the N', () => {
    const engine = new Engine();
    const level = firstLevel();

    engine.load(level);

    expect(engine.blocks).toHaveLength(level.blocks.length);
    expect(engine.n).not.toBeNull();
    expect(countBodies(engine)).toBe(level.blocks.length + 1);
  });

  it('places blocks at their authored centre', () => {
    const engine = new Engine();
    engine.load(firstLevel());

    const [first] = engine.blocks;
    const position = first.body.getPosition();

    expect(position.x * PIXELS_PER_METER).toBeCloseTo(first.spec.x, 6);
    expect(position.y * PIXELS_PER_METER).toBeCloseTo(first.spec.y, 6);
  });

  it('reloads cleanly, leaving no bodies behind', () => {
    const engine = new Engine();
    const level = firstLevel();

    engine.load(level);
    engine.load(level);

    expect(countBodies(engine)).toBe(level.blocks.length + 1);
  });

  describe('picking blocks', () => {
    it('finds the block under a point', () => {
      const engine = new Engine();
      engine.load(firstLevel());

      const target = engine.blocks[1];
      const found = engine.blockAt({ x: target.spec.x, y: target.spec.y });

      expect(found?.spec.name).toBe(target.spec.name);
    });

    it('returns null over empty sky', () => {
      const engine = new Engine();
      engine.load(firstLevel());

      expect(engine.blockAt({ x: 30, y: 30 })).toBeNull();
    });
  });

  describe('demolition', () => {
    it('removes a destroyable block', () => {
      const engine = new Engine();
      engine.load(firstLevel());

      const target = engine.blocks.find((block) => block.spec.destroyable);
      expect(target).toBeDefined();

      const before = engine.blocks.length;
      const destroyed = engine.demolishAt({ x: target!.spec.x, y: target!.spec.y });

      expect(destroyed?.spec.name).toBe(target!.spec.name);
      expect(engine.blocks).toHaveLength(before - 1);
    });

    it('refuses to destroy the N', () => {
      const engine = new Engine();
      engine.load(firstLevel());

      const logo = engine.blocks.find((block) => block.spec.name === 'N')!;
      const destroyed = engine.demolishAt({ x: logo.spec.x, y: logo.spec.y });

      expect(destroyed).toBeNull();
      expect(engine.n).not.toBeNull();
    });

    it('does nothing when the click misses', () => {
      const engine = new Engine();
      engine.load(firstLevel());

      const before = engine.blocks.length;
      expect(engine.demolishAt({ x: 20, y: 20 })).toBeNull();
      expect(engine.blocks).toHaveLength(before);
    });

    it('wakes the stack so it collapses into the gap', () => {
      const engine = new Engine();
      engine.load(firstLevel());

      simulate(engine, 6);
      expect(engine.nAtRest).toBe(true);

      const support = engine.blocks.find((block) => block.spec.destroyable)!;
      engine.demolishAt({ x: support.spec.x, y: support.spec.y });

      expect(engine.blocks.every((block) => block.body.isAwake())).toBe(true);
    });
  });

  describe('settling', () => {
    it('lets an untouched stack come to rest', () => {
      const engine = new Engine();
      engine.load(firstLevel());

      expect(engine.nAtRest).toBe(false);
      simulate(engine, 6);

      expect(engine.nAtRest).toBe(true);
    });

    it('keeps the N on the stage when nothing is touched', () => {
      const engine = new Engine();
      engine.load(firstLevel());

      simulate(engine, 6);
      const { x } = engine.nPosition;

      expect(x).toBeGreaterThan(0);
      expect(x).toBeLessThan(1000);
    });

    it('drops the N once its whole tower is removed', () => {
      const engine = new Engine();
      engine.load(firstLevel());

      const startY = engine.nPosition.y;
      for (const block of [...engine.blocks]) {
        if (block.spec.destroyable) engine.demolishAt({ x: block.spec.x, y: block.spec.y });
      }
      simulate(engine, 3);

      expect(engine.nPosition.y).toBeGreaterThan(startY);
    });
  });

  it('loads every level in both packs without error', () => {
    const engine = new Engine();

    for (const pack of PACKS) {
      for (const level of pack.levels) {
        engine.load(level);
        expect(engine.n, `${pack.id}/${level.name}`).not.toBeNull();
        simulate(engine, 0.5);
      }
    }
  });
});
