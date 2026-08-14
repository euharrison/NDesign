import './style.css';

import { Game } from './game/Game';
import { Ui } from './ui/Ui';

const canvas = document.querySelector<HTMLCanvasElement>('#stage');
if (!canvas) throw new Error('#stage canvas not found');

const game = new Game(canvas);
new Ui(game);
game.start();

// Handy for poking at the simulation from the console.
declare global {
  interface Window {
    game?: Game;
  }
}
window.game = game;
