import { describe, expect, it } from 'vitest';

import { LEVELS } from '../src/game/levels/levels';
import { TARGET_COLORS } from '../src/game/render/palette';

describe('levels', () => {
  it('carries every level from the original level.xml', () => {
    expect(LEVELS).toHaveLength(21);
  });

  it('gives each level a question, a start point and at least two targets', () => {
    for (const [index, level] of LEVELS.entries()) {
      expect(level.question, `level ${index}`).not.toBe('');
      expect(Number.isFinite(level.start.x)).toBe(true);
      expect(Number.isFinite(level.start.y)).toBe(true);
      expect(level.targets.length).toBeGreaterThanOrEqual(2);
    }
  });

  it('only uses target styles the palette knows about', () => {
    for (const level of LEVELS) {
      for (const target of level.targets) {
        expect(TARGET_COLORS[target.style]).toBeDefined();
      }
    }
  });

  it('keeps at least one winnable target per level', () => {
    for (const [index, level] of LEVELS.entries()) {
      const winnable = level.targets.filter((target) => target.value !== 'die');
      expect(winnable.length, `level ${index} has no winnable target`).toBeGreaterThan(0);
    }
  });

  it('preserves the mirrored spawns', () => {
    expect(LEVELS.filter((level) => level.mirrored).length).toBeGreaterThan(0);
    expect(LEVELS[7].mirrored).toBe(true);
    expect(LEVELS[0].mirrored).toBe(false);
  });
});
