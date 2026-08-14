export interface Point {
  x: number;
  y: number;
}

export const clamp = (value: number, min: number, max: number): number =>
  Math.min(max, Math.max(min, value));

/** `05` from `5` — the original padded the clock and level number this way. */
export const pad2 = (value: number): string => String(value).padStart(2, '0');

/** Formats elapsed seconds as `mm:ss`, as the in-game clock did. */
export const formatClock = (seconds: number): string => {
  const whole = Math.max(0, Math.floor(seconds));
  return `${pad2(Math.floor(whole / 60))}:${pad2(whole % 60)}`;
};
