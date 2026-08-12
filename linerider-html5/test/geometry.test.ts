import { describe, expect, it } from 'vitest';

import {
  angleDegrees,
  clamp,
  distance,
  distanceToSegment,
  fillZero,
  midpoint,
} from '../src/game/core/geometry';

describe('geometry', () => {
  it('measures distance between points', () => {
    expect(distance({ x: 0, y: 0 }, { x: 3, y: 4 })).toBe(5);
  });

  it('reports the angle in degrees, y pointing down', () => {
    expect(angleDegrees({ x: 0, y: 0 }, { x: 1, y: 0 })).toBe(0);
    expect(angleDegrees({ x: 0, y: 0 }, { x: 0, y: 1 })).toBe(90);
    expect(angleDegrees({ x: 0, y: 0 }, { x: -1, y: 0 })).toBe(180);
  });

  it('finds the midpoint', () => {
    expect(midpoint({ x: 0, y: 0 }, { x: 10, y: 4 })).toEqual({ x: 5, y: 2 });
  });

  describe('distanceToSegment', () => {
    const a = { x: 0, y: 0 };
    const b = { x: 10, y: 0 };

    it('projects onto the segment', () => {
      expect(distanceToSegment({ x: 5, y: 3 }, a, b)).toBe(3);
    });

    it('clamps to the endpoints instead of the infinite line', () => {
      expect(distanceToSegment({ x: -4, y: 0 }, a, b)).toBe(4);
      expect(distanceToSegment({ x: 14, y: 0 }, a, b)).toBe(4);
    });

    it('handles degenerate segments', () => {
      expect(distanceToSegment({ x: 0, y: 5 }, a, a)).toBe(5);
    });
  });

  it('clamps values', () => {
    expect(clamp(5, 0, 3)).toBe(3);
    expect(clamp(-5, 0, 3)).toBe(0);
    expect(clamp(2, 0, 3)).toBe(2);
  });

  it('pads level numbers like the original fillZero', () => {
    expect(fillZero(1)).toBe('001');
    expect(fillZero(21)).toBe('021');
    expect(fillZero(100)).toBe('100');
  });
});
