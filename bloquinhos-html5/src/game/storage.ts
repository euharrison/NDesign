const KEY = 'bloquinhos-html5:v1';

export interface SaveData {
  packId: string;
  levelIndex: number;
  /** Highest level reached per pack id. */
  reached: Record<string, number>;
  /** Best completion time per pack id, in seconds. */
  best: Record<string, number>;
}

/**
 * Replaces the PHP e-mail registration of the Flash version: progress and best
 * times simply live in `localStorage`.
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
    // Private mode or a full quota is not worth interrupting play for.
  }
};
