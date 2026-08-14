import { GROUND, PIXELS_PER_METER, STAGE_HEIGHT, STAGE_WIDTH } from '../core/constants';
import type { Block } from '../core/Engine';
import type { Point } from '../core/geometry';
import type { Material } from '../levels/types';
import { Background } from './Background';
import { GROUND_BELOW, MATERIALS, N_BLUE } from './palette';
import type { Sprites } from './sprites';

interface Particle {
  x: number;
  y: number;
  vx: number;
  vy: number;
  life: number;
  size: number;
  color: string;
}

export interface Scene {
  blocks: readonly Block[];
  /** Pointer in stage coordinates. */
  pointer: Point;
  /** 0 while the bomb is ready, 1 right after a demolition. */
  cooldown: number;
  showCursor: boolean;
  /** Highlighted because the pointer is over it and it can be blown up. */
  hovered: Block | null;
}

/**
 * Draws the stage to a canvas. The 1000x580 stage is letterboxed into the
 * canvas, so the level coordinates from the Flash version are used unchanged.
 */
export class Renderer {
  private readonly ctx: CanvasRenderingContext2D;
  private readonly background = new Background();
  private particles: Particle[] = [];

  private sprites: Sprites | null = null;
  private pretoFill: CanvasPattern | null = null;

  private scale = 1;
  private offsetX = 0;
  private offsetY = 0;

  constructor(private readonly canvas: HTMLCanvasElement) {
    const ctx = canvas.getContext('2d', { alpha: false });
    if (!ctx) throw new Error('Canvas 2D context unavailable');
    this.ctx = ctx;
  }

  /**
   * Swaps the vector fallback for the original bitmaps. Called once they have
   * decoded, so the game is playable from the first frame either way.
   */
  setSprites(sprites: Sprites): void {
    this.sprites = sprites;
    // `Preto` was one unsized library symbol, so its 60x60 bitmap has to tile
    // to cover blocks that run up to 2055x480.
    this.pretoFill = this.ctx.createPattern(sprites.preto, 'repeat');
  }

  /** Sizes the backing store for the device pixel ratio and recomputes the fit. */
  resize(): void {
    const ratio = window.devicePixelRatio || 1;
    const { clientWidth, clientHeight } = this.canvas;

    this.canvas.width = Math.round(clientWidth * ratio);
    this.canvas.height = Math.round(clientHeight * ratio);

    this.scale = Math.min(clientWidth / STAGE_WIDTH, clientHeight / STAGE_HEIGHT);
    this.offsetX = (clientWidth - STAGE_WIDTH * this.scale) / 2;
    this.offsetY = (clientHeight - STAGE_HEIGHT * this.scale) / 2;
  }

  /** Converts a canvas-relative point into stage coordinates. */
  toStage(point: Point): Point {
    return {
      x: (point.x - this.offsetX) / this.scale,
      y: (point.y - this.offsetY) / this.scale,
    };
  }

  addExplosion(x: number, y: number, material: Material): void {
    const { fill } = MATERIALS[material];

    for (let i = 0; i < 18; i += 1) {
      const angle = (Math.PI * 2 * i) / 18 + Math.random() * 0.3;
      const speed = 90 + Math.random() * 190;

      this.particles.push({
        x,
        y,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        life: 0.45 + Math.random() * 0.35,
        size: 3 + Math.random() * 5,
        color: fill,
      });
    }
  }

  update(elapsed: number): void {
    for (const particle of this.particles) {
      particle.x += particle.vx * elapsed;
      particle.y += particle.vy * elapsed;
      particle.vy += 420 * elapsed;
      particle.life -= elapsed;
    }

    this.particles = this.particles.filter((particle) => particle.life > 0);
  }

  render(scene: Scene): void {
    const { ctx } = this;
    const ratio = window.devicePixelRatio || 1;

    ctx.setTransform(ratio, 0, 0, ratio, 0, 0);
    ctx.fillStyle = '#0e1116';
    ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);

    ctx.save();
    ctx.translate(this.offsetX, this.offsetY);
    ctx.scale(this.scale, this.scale);

    // Clip so nothing spills into the letterbox bars.
    ctx.beginPath();
    ctx.rect(0, 0, STAGE_WIDTH, STAGE_HEIGHT);
    ctx.clip();

    this.background.setPointer(scene.pointer);
    this.background.draw(ctx, this.sprites);

    this.drawGround(ctx);
    for (const block of scene.blocks) this.drawBlock(ctx, block, block === scene.hovered);
    this.drawParticles(ctx);

    if (scene.showCursor) this.drawCursor(ctx, scene.pointer, scene.cooldown);

    ctx.restore();
  }

  private drawGround(ctx: CanvasRenderingContext2D): void {
    const top = GROUND.y - GROUND.height / 2;
    const chao = this.sprites?.chao;

    if (!chao) {
      const style = MATERIALS.Chao;
      ctx.fillStyle = style.fill;
      ctx.fillRect(-500, top, STAGE_WIDTH + 1000, STAGE_HEIGHT - top + 40);
      ctx.fillStyle = style.edge;
      ctx.fillRect(-500, top, STAGE_WIDTH + 1000, 3);
      return;
    }

    // `chao.gif` is exactly the 1000x13 grass strip that caps the slab. The
    // slab is 2000 wide, so repeat it sideways and flood the rest of the stage
    // below with the strip's darkest tone.
    ctx.fillStyle = GROUND_BELOW;
    ctx.fillRect(-500, top + chao.height, STAGE_WIDTH + 1000, STAGE_HEIGHT - top + 40);

    for (let x = -STAGE_WIDTH; x < STAGE_WIDTH * 2; x += chao.width) {
      ctx.drawImage(chao, x, top);
    }
  }

  private drawBlock(ctx: CanvasRenderingContext2D, block: Block, hovered: boolean): void {
    const { spec, body } = block;
    const style = MATERIALS[spec.material];
    const position = body.getPosition();

    ctx.save();
    ctx.translate(position.x * PIXELS_PER_METER, position.y * PIXELS_PER_METER);
    ctx.rotate(body.getAngle());

    const w = spec.width;
    const h = spec.height;

    // The coloured blocks were per-size library symbols (`Verde30x30`,
    // `Verde60x90`, ...) whose art only ever existed inside the .fla, so they
    // stay flat. Only the unsized symbols shipped a loose bitmap.
    if (!this.drawTexture(ctx, spec.material, w, h)) {
      if (style.alpha !== undefined) ctx.globalAlpha = style.alpha;

      ctx.fillStyle = style.fill;
      ctx.fillRect(-w / 2, -h / 2, w, h);

      if (!style.ghost) {
        // A soft top highlight, so stacked blocks stay readable.
        ctx.fillStyle = 'rgba(255,255,255,0.16)';
        ctx.fillRect(-w / 2, -h / 2, w, Math.min(4, h / 4));
      }

      ctx.strokeStyle = style.edge;
      ctx.lineWidth = 1.5;
      ctx.strokeRect(-w / 2, -h / 2, w, h);
      ctx.globalAlpha = 1;

      if (spec.material === 'N') this.drawLogo(ctx, w, h);
      if (spec.material === 'Rio021' || spec.material === 'Rio021_90Graus') {
        this.drawRio(ctx, w, h, spec.material === 'Rio021_90Graus');
      }
    }

    if (hovered) {
      ctx.strokeStyle = '#ffffff';
      ctx.lineWidth = 3;
      ctx.strokeRect(-w / 2, -h / 2, w, h);
    }

    ctx.restore();
  }

  /** Draws a block's original bitmap, if it has one. */
  private drawTexture(
    ctx: CanvasRenderingContext2D,
    material: Material,
    w: number,
    h: number,
  ): boolean {
    const sprites = this.sprites;
    if (!sprites) return false;

    switch (material) {
      // Both bitmaps are already the exact block size, so nothing is stretched.
      case 'N':
        ctx.drawImage(sprites.n, -w / 2, -h / 2, w, h);
        return true;

      case 'Rio021':
        ctx.drawImage(sprites.rio021, -w / 2, -h / 2, w, h);
        return true;

      case 'Rio021_90Graus':
        // The one 30x90 block: the same 90x30 label, stood on end.
        ctx.save();
        ctx.rotate(-Math.PI / 2);
        ctx.drawImage(sprites.rio021, -h / 2, -w / 2, h, w);
        ctx.restore();
        return true;

      case 'Preto':
        if (!this.pretoFill) return false;
        ctx.fillStyle = this.pretoFill;
        ctx.fillRect(-w / 2, -h / 2, w, h);
        return true;

      default:
        return false;
    }
  }

  private drawLogo(ctx: CanvasRenderingContext2D, w: number, h: number): void {
    ctx.fillStyle = N_BLUE;
    ctx.font = `700 ${Math.min(w, h) * 0.72}px "Segoe UI", system-ui, sans-serif`;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText('N', 0, h * 0.04);
  }

  private drawRio(ctx: CanvasRenderingContext2D, w: number, h: number, rotated: boolean): void {
    ctx.save();
    if (rotated) ctx.rotate(-Math.PI / 2);

    // After rotating, the label runs along whichever edge is now horizontal.
    const along = rotated ? h : w;
    const across = rotated ? w : h;

    ctx.fillStyle = '#d4372b';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    // Shrink until the word fits inside the block instead of spilling over it.
    const label = 'RIO 021';
    let size = Math.min(across * 0.62, 20);
    do {
      ctx.font = `700 ${size}px "Segoe UI", system-ui, sans-serif`;
      if (ctx.measureText(label).width <= along * 0.86) break;
      size -= 1;
    } while (size > 5);

    ctx.fillText(label, 0, 0);
    ctx.restore();
  }

  private drawParticles(ctx: CanvasRenderingContext2D): void {
    for (const particle of this.particles) {
      ctx.globalAlpha = Math.max(0, Math.min(1, particle.life * 2));
      ctx.fillStyle = particle.color;
      ctx.fillRect(particle.x, particle.y, particle.size, particle.size);
    }
    ctx.globalAlpha = 1;
  }

  /** The bomb cursor, with the recharge ring from `_rechargeBomb`. */
  private drawCursor(ctx: CanvasRenderingContext2D, pointer: Point, cooldown: number): void {
    ctx.save();
    ctx.translate(pointer.x, pointer.y);

    const ready = cooldown <= 0;

    ctx.strokeStyle = ready ? '#111214' : 'rgba(17,18,20,0.35)';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(0, 0, 13, 0, Math.PI * 2);
    ctx.stroke();

    ctx.beginPath();
    ctx.moveTo(-19, 0);
    ctx.lineTo(-7, 0);
    ctx.moveTo(7, 0);
    ctx.lineTo(19, 0);
    ctx.moveTo(0, -19);
    ctx.lineTo(0, -7);
    ctx.moveTo(0, 7);
    ctx.lineTo(0, 19);
    ctx.stroke();

    if (!ready) {
      // Sweeps clockwise as the bomb recharges.
      ctx.strokeStyle = '#d33f3f';
      ctx.lineWidth = 3;
      ctx.beginPath();
      ctx.arc(0, 0, 13, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * (1 - cooldown));
      ctx.stroke();
    }

    ctx.restore();
  }
}
