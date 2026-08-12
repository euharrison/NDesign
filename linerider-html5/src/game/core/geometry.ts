export interface Point {
  x: number;
  y: number;
}

export const distance = (a: Point, b: Point): number => Math.hypot(b.x - a.x, b.y - a.y);

/** Angle from `a` to `b` in degrees, matching the original's `Math.atan2` use. */
export const angleDegrees = (a: Point, b: Point): number =>
  (Math.atan2(b.y - a.y, b.x - a.x) * 180) / Math.PI;

export const midpoint = (a: Point, b: Point): Point => ({
  x: (a.x + b.x) / 2,
  y: (a.y + b.y) / 2,
});

/** Shortest distance from `p` to the segment `a`-`b`. Used by the eraser. */
export function distanceToSegment(p: Point, a: Point, b: Point): number {
  const dx = b.x - a.x;
  const dy = b.y - a.y;
  const lengthSquared = dx * dx + dy * dy;

  if (lengthSquared === 0) return distance(p, a);

  const t = Math.min(1, Math.max(0, ((p.x - a.x) * dx + (p.y - a.y) * dy) / lengthSquared));
  return Math.hypot(p.x - (a.x + t * dx), p.y - (a.y + t * dy));
}

export const clamp = (value: number, min: number, max: number): number =>
  Math.min(max, Math.max(min, value));

/** `fillZero(7)` -> `"007"`, as in the original `DialogBox.fillZero`. */
export const fillZero = (value: number, length = 3): string => String(value).padStart(length, '0');
