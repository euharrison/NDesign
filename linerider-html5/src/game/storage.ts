import type { SerializedPath } from './core/Path';
import type { RiderPalette } from './render/palette';
import type { RiderType } from './riders';

const KEY = 'linerider-html5:v1';

export interface SaveData {
  levelIndex: number;
  rider: RiderType;
  palette: RiderPalette;
  /** Answer picked per level index. */
  answers: Record<string, string>;
  /** Lines drawn per level index — the original's `caminhoFullList`. */
  paths: Record<string, SerializedPath[]>;
}

/**
 * Replaces the PHP/Facebook backend of the Flash version: progress simply lives
 * in `localStorage`, and a missing or corrupt entry is treated as a fresh game.
 */
export const loadSave = (): Partial<SaveData> => {
  try {
    const raw = localStorage.getItem(KEY);
    return raw ? (JSON.parse(raw) as Partial<SaveData>) : {};
  } catch {
    return {};
  }
};

export const writeSave = (data: SaveData): void => {
  try {
    localStorage.setItem(KEY, JSON.stringify(data));
  } catch {
    // Private-mode or quota failures are not worth interrupting play for.
  }
};

export const clearSave = (): void => {
  try {
    localStorage.removeItem(KEY);
  } catch {
    /* ignore */
  }
};
