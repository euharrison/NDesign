import { describe, expect, it } from 'vitest';

import { clamp, formatClock, pad2 } from '../src/game/core/geometry';

describe('geometry helpers', () => {
  it('pads two-digit values like the original clock', () => {
    expect(pad2(0)).toBe('00');
    expect(pad2(7)).toBe('07');
    expect(pad2(42)).toBe('42');
  });

  it('formats elapsed seconds as mm:ss', () => {
    expect(formatClock(0)).toBe('00:00');
    expect(formatClock(9.9)).toBe('00:09');
    expect(formatClock(65)).toBe('01:05');
    expect(formatClock(600)).toBe('10:00');
  });

  it('never shows a negative clock', () => {
    expect(formatClock(-5)).toBe('00:00');
  });

  it('clamps values', () => {
    expect(clamp(5, 0, 3)).toBe(3);
    expect(clamp(-1, 0, 3)).toBe(0);
    expect(clamp(2, 0, 3)).toBe(2);
  });
});
