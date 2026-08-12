export type TargetStyle =
  | 'yellow'
  | 'yellowLight'
  | 'blue'
  | 'blueLight'
  | 'orange'
  | 'magenta'
  | 'teal'
  | 'purple'
  | 'green'
  | 'greenLight'
  | 'logo'
  | 'logoFalse';

/** A goal circle. Reaching one with `value: 'die'` wipes out instead of scoring. */
export interface LevelTarget {
  x: number;
  y: number;
  style: TargetStyle;
  label: string;
  value: string;
}

export interface Level {
  /** Where the rider is spawned, in scene pixels. */
  start: { x: number; y: number };
  /** `true` spawns the rider facing left (the original's `espelhado`). */
  mirrored: boolean;
  question: string;
  targets: readonly LevelTarget[];
}

/** Radius of a goal circle in scene pixels (`Escolha.RAIO` in the original). */
export const TARGET_RADIUS = 33;
