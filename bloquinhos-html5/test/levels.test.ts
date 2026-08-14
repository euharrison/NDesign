import { describe, expect, it } from 'vitest';

import { PACKS } from '../src/game/levels/levels';
import { MATERIALS } from '../src/game/render/palette';

const allLevels = PACKS.flatMap((pack) => pack.levels.map((level) => ({ pack, level })));

describe('level data', () => {
  it('carries both packs from the original project', () => {
    expect(PACKS.map((pack) => pack.id)).toEqual(['primeiro', 'viciados']);
    for (const pack of PACKS) expect(pack.levels).toHaveLength(21);
  });

  it('gives every level exactly one N to rescue', () => {
    for (const { pack, level } of allLevels) {
      const logos = level.blocks.filter((block) => block.name === 'N');
      expect(logos, `${pack.id}/${level.name}`).toHaveLength(1);
      expect(logos[0].destroyable).toBe(false);
    }
  });

  it('never lets the N be blown up', () => {
    for (const { level } of allLevels) {
      for (const block of level.blocks) {
        if (block.name === 'N' || block.name === 'Rio021') expect(block.destroyable).toBe(false);
      }
    }
  });

  it('leaves something to demolish on every level', () => {
    for (const { pack, level } of allLevels) {
      const destroyable = level.blocks.filter((block) => block.destroyable);
      expect(destroyable.length, `${pack.id}/${level.name}`).toBeGreaterThan(0);
    }
  });

  it('only uses materials the palette knows', () => {
    for (const { level } of allLevels) {
      for (const block of level.blocks) expect(MATERIALS[block.material]).toBeDefined();
    }
  });

  it('gives every block a positive size and sane physics values', () => {
    for (const { level } of allLevels) {
      for (const block of level.blocks) {
        expect(block.width).toBeGreaterThan(0);
        expect(block.height).toBeGreaterThan(0);
        expect(block.restitution).toBeGreaterThanOrEqual(0);
        expect(block.friction).toBeGreaterThanOrEqual(0);
      }
    }
  });

  it('keeps the passwords from the sequel unique', () => {
    const passwords = PACKS[1].levels.map((level) => level.password);

    expect(passwords).toHaveLength(21);
    expect(passwords.every((password) => password.length > 0)).toBe(true);
    expect(new Set(passwords).size).toBe(passwords.length);
  });

  it('names every level in the sequel', () => {
    for (const level of PACKS[1].levels) expect(level.name).not.toMatch(/^Fase \d+$/);
  });
});
