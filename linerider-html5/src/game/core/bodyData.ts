import type { PathType } from './constants';

/** Which palette slot a rider part is painted with. */
export type PartMaterial = 'head' | 'shirt' | 'pants' | 'skin' | 'vehicle';

/**
 * Everything the renderer needs to draw a rider part. The original relied on
 * Flash MovieClips pinned to each Box2D body; here the parts are drawn from
 * their collision shape instead, so the port has no binary asset dependency.
 */
export interface PartArt {
  material: PartMaterial;
  shape: 'box' | 'circle' | 'vehicle';
  /** Width in scene pixels (radius for circles). */
  width: number;
  height: number;
  /** Optional second colour for the far end of the part, e.g. a bare hand. */
  tip?: PartMaterial;
}

export type BodyData =
  { kind: 'wall' } | { kind: 'path'; type: PathType } | { kind: 'part'; art: PartArt };

export const isPath = (data: unknown): data is { kind: 'path'; type: PathType } =>
  typeof data === 'object' && data !== null && (data as BodyData).kind === 'path';

export const isWall = (data: unknown): data is { kind: 'wall' } =>
  typeof data === 'object' && data !== null && (data as BodyData).kind === 'wall';

export const isPart = (data: unknown): data is { kind: 'part'; art: PartArt } =>
  typeof data === 'object' && data !== null && (data as BodyData).kind === 'part';
