import type { Material } from '../levels/types';

export interface MaterialStyle {
  fill: string;
  edge: string;
  /** Drawn semi-transparent, like the glass and ice blocks. */
  alpha?: number;
  /** Outline only — the invisible block. */
  ghost?: boolean;
}

/**
 * One entry per library symbol in the original `Decode()`. The green blocks
 * were the bouncy ones (`restitution 0.8`) and the ice blocks the slippery
 * ones, so they keep visually distinct treatments.
 */
export const MATERIALS: Record<Material, MaterialStyle> = {
  Azul: { fill: '#3a76c4', edge: '#27528b' },
  Marrom: { fill: '#8b5a2b', edge: '#5f3d1c' },
  Roxo: { fill: '#7b4397', edge: '#552d69' },
  Vermelho: { fill: '#d33f3f', edge: '#962b2b' },
  Preto: { fill: '#33363b', edge: '#1b1d20' },
  Verde: { fill: '#5cb85c', edge: '#3d7d3d' },
  Branco: { fill: '#f4f2ec', edge: '#c9c5b8' },
  Transparente: { fill: 'rgba(255,255,255,0.14)', edge: 'rgba(255,255,255,0.55)', ghost: true },
  Gelo: { fill: '#bfe6f2', edge: '#7fb8cc', alpha: 0.85 },
  Chao: { fill: '#6f9c3c', edge: '#4d6e28' },
  N: { fill: '#f5f5f5', edge: '#c9c5b8' },
  Rio021: { fill: '#f5f5f5', edge: '#b8b6ad' },
  Rio021_90Graus: { fill: '#f5f5f5', edge: '#b8b6ad' },
};

/** The brand blue, sampled from `n.gif`. */
export const N_BLUE = '#00a6e5';

/** Below `chao.gif`, matching the darkest tone in its bottom row. */
export const GROUND_BELOW = '#728b03';

export const SKY_TOP = '#8ecae6';
export const SKY_BOTTOM = '#dff1f7';
export const MOUNTAIN = '#7ea86b';
export const MOUNTAIN_FAR = '#9dbd8c';
export const CLOUD = '#ffffff';
