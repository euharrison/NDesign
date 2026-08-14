/**
 * Tuning carried over 1:1 from the AS3 original so the stacks behave the same.
 * Stage coordinates are pixels; the physics world runs in metres at 30 px/m.
 */
export const PIXELS_PER_METER = 30;

/** `m_timeStep = GetB2Nums(1.0, false)` — one thirtieth of a second. */
export const PHYSICS_STEP = 1 / 30;
export const VELOCITY_ITERATIONS = 10;
export const POSITION_ITERATIONS = 8;

export const GRAVITY = 10;

/** Half-extent of the world box, in metres (`worldAABB` in the original). */
export const WORLD_LIMIT = 100;

/** The stage the levels were authored against. */
export const STAGE_WIDTH = 1000;
export const STAGE_HEIGHT = 580;

/** Ground slab: `CreateBox(500, 564, 2000, 14, true, 'Chao', ...)`. */
export const GROUND = {
  x: 500,
  y: 564,
  width: 2000,
  height: 14,
  restitution: 0.3,
  friction: 0.3,
} as const;

/** Density of a destructible block; the ground is static, so zero. */
export const BLOCK_DENSITY = 1;

/** Cooldown between demolitions — `new Timer(500, 1)` in `_rechargeBomb`. */
export const BOMB_COOLDOWN = 0.5;

/**
 * The N is lost once it leaves the stage sideways:
 * `if (N.x > 1015 || N.x < -15) endLevel('lose')`.
 */
export const LOSE_X_MAX = 1015;
export const LOSE_X_MIN = -15;

/** Also treat a fall well below the ground as a loss (the original could not). */
export const LOSE_Y = 900;

/**
 * How long the N must stay asleep before the level is won. The original just
 * read `IsSleeping()`; a short dwell makes the win read as deliberate rather
 * than accidental, and guards against a one-frame sleep during a collapse.
 */
export const VICTORY_DWELL = 0.35;

/** Blocks named `Box*` are the demolishable ones. */
export const DESTROYABLE_PREFIX = 'Box';
