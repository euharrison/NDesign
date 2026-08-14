/** Block skins, named after the original library symbols. */
export type Material =
  | 'Azul'
  | 'Marrom'
  | 'Roxo'
  | 'Vermelho'
  | 'Preto'
  | 'Verde'
  | 'Branco'
  | 'Transparente'
  | 'Gelo'
  | 'Chao'
  | 'N'
  | 'Rio021'
  | 'Rio021_90Graus';

/**
 * One block, straight from the AS3 level table:
 * `[x, y, width, height, static, name, destroyable, restitution, friction, cover]`.
 *
 * Coordinates are the block's centre in stage pixels; width/height are full
 * extents. `fixed` was `static` in the original — always `false` in the level
 * data, since only the ground is truly static.
 */
export interface BlockSpec {
  x: number;
  y: number;
  width: number;
  height: number;
  fixed: boolean;
  /** `'Box7'`, `'N'` or `'Rio021'`. Only `Box*` blocks can be blown up. */
  name: string;
  destroyable: boolean;
  restitution: number;
  friction: number;
  material: Material;
}

export interface Level {
  name: string;
  /** Level code from the original `SenhasNomes.SENHA`; empty in the first game. */
  password: string;
  blocks: readonly BlockSpec[];
}

export interface LevelPack {
  id: string;
  title: string;
  levels: readonly Level[];
}
