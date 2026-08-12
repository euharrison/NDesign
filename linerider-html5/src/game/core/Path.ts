import type { Body } from 'planck';

import { PathType } from './constants';
import type { Point } from './geometry';

/**
 * One drawn line segment (`Caminho` in the original). Decorative segments have
 * no physics body — they are scenery only.
 */
export class Path {
  /** Set by the engine when the segment is given a physics body. */
  body: Body | null = null;

  constructor(
    readonly from: Point,
    readonly to: Point,
    readonly type: PathType,
  ) {}

  get solid(): boolean {
    return this.type !== PathType.Decorative;
  }

  toJSON(): SerializedPath {
    return { o: [this.from.x, this.from.y], d: [this.to.x, this.to.y], t: this.type };
  }

  static fromJSON({ o, d, t }: SerializedPath): Path {
    return new Path({ x: o[0], y: o[1] }, { x: d[0], y: d[1] }, t);
  }
}

/** Compact wire format: origin, destination, type — as in the original save. */
export interface SerializedPath {
  o: [number, number];
  d: [number, number];
  t: PathType;
}
