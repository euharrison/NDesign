import './style.css';

import { Game } from './game/Game';
import { loadSprites } from './game/render/sprites';
import { Ui } from './ui/Ui';

const canvas = document.querySelector<HTMLCanvasElement>('#stage');
if (!canvas) throw new Error('#stage canvas not found');

const game = new Game(canvas);
new Ui(game);
game.start();

// The original bitmaps swap in once they decode; until then the game runs on
// the vector fallback, so a slow connection never blocks the first frame.
loadSprites().then(
  (sprites) => game.renderer.setSprites(sprites),
  (error) => console.warn('Falling back to vector artwork:', error),
);

// Handy for poking at the simulation from the console.
declare global {
  interface Window {
    game?: Game;
  }
}
window.game = game;
