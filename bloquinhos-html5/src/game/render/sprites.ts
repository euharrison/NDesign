import balao from '../../assets/balao.png';
import chao from '../../assets/chao.gif';
import fundo from '../../assets/fundo.jpg';
import montanhas from '../../assets/montanhas.png';
import n from '../../assets/n.gif';
import nuvem1 from '../../assets/nuvem1.png';
import nuvem2 from '../../assets/nuvem2.png';
import nuvem3 from '../../assets/nuvem3.png';
import nuvem4 from '../../assets/nuvem4.png';
import nuvem5 from '../../assets/nuvem5.png';
import ovni from '../../assets/ovni.png';
import passaro from '../../assets/passaro.png';
import preto from '../../assets/preto60x60.jpg';
import rio021 from '../../assets/rio021.gif';

/**
 * The original bitmaps, recovered from `bloquinhos/*\/images`.
 *
 * Their dimensions are what identifies them: the stage is 1000x580 and the
 * ground slab's top edge sits at y=557, which is exactly `fundo.jpg` (1000x557)
 * above `chao.gif` (1000x13). Every `N` block in all 42 levels is 60x60 and
 * `n.gif` is 60x60; every `Rio021` block is 90x30 and `rio021.gif` is 90x30.
 * These are the sprites themselves, not lookalikes.
 *
 * `FUNDO-novo-jogo.jpg` is deliberately left behind: it is the same sky photo
 * with the grass flattened into it (no pixel differs by more than 18/255 from
 * `fundo.jpg`), so shipping it as a second game's background would cost 62 kB
 * for no visible difference.
 */
const SOURCES = {
  fundo,
  montanhas,
  chao,
  n,
  rio021,
  preto,
  nuvem1,
  nuvem2,
  nuvem3,
  nuvem4,
  nuvem5,
  balao,
  ovni,
  passaro,
} as const;

export type SpriteName = keyof typeof SOURCES;

export type Sprites = Record<SpriteName, HTMLImageElement>;

function load(src: string): Promise<HTMLImageElement> {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.decoding = 'async';
    image.addEventListener('load', () => resolve(image));
    image.addEventListener('error', () => reject(new Error(`Failed to load ${src}`)));
    image.src = src;
  });
}

/**
 * Resolves once every bitmap has decoded. The renderer draws its vector
 * fallback until then, so a slow network delays the artwork but never the game.
 */
export async function loadSprites(): Promise<Sprites> {
  const names = Object.keys(SOURCES) as SpriteName[];
  const images = await Promise.all(names.map((name) => load(SOURCES[name])));

  return Object.fromEntries(names.map((name, index) => [name, images[index]])) as Sprites;
}
