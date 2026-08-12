/**
 * Tuning constants carried over 1:1 from the original AS3 project so the port
 * keeps the same feel. Scene coordinates are pixels; the physics world runs in
 * metres, at 30 pixels per metre (`b2Scale` in the original `Engine.as`).
 */
export const PIXELS_PER_METER = 30;

/** The Flash build stepped Box2D once per frame on a 30 fps stage. */
export const PHYSICS_STEP = 1 / 30;
export const VELOCITY_ITERATIONS = 10;
export const POSITION_ITERATIONS = 8;

/** Half-extent of the square that bounds the world, in metres. */
export const WORLD_LIMIT = 200;
export const WORLD_WALL_THICKNESS = 5;

export const GRAVITY = 10;

/** Speed multiplier applied while the vehicle rides an accelerated line. */
export const ACCELERATION_FACTOR = 1.008;

/** Seconds the ragdoll tumbles after a wipe-out before the board resets. */
export const DEATH_DELAY = 3;

export const PathType = {
  Normal: 0,
  Accelerated: 1,
  Decorative: 2,
} as const;
export type PathType = (typeof PathType)[keyof typeof PathType];

export const PATH_COLORS: Record<PathType, string> = {
  [PathType.Normal]: '#000000',
  [PathType.Accelerated]: '#f62e8d',
  [PathType.Decorative]: '#ceda3a',
};

/** Scene width the original artwork was laid out against. */
export const SCENE_WIDTH = 1000;

export const MIN_ZOOM = 0.3;
export const MAX_ZOOM = 5;

/** Pencil auto-commits a segment once the cursor is this far from the anchor. */
export const PENCIL_SEGMENT_LENGTH = 30;

/** Clicking within this radius of the last endpoint snaps lines together. */
export const SNAP_DISTANCE = 20;

/** Half-thickness of a line's eraser hit area, in scene pixels. */
export const ERASER_TOLERANCE = 6;
