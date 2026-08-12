import { describe, expect, it } from 'vitest';

import { PathType } from '../src/game/core/constants';
import { Path } from '../src/game/core/Path';
import { Viewport } from '../src/game/render/Viewport';
import { MAX_ZOOM, MIN_ZOOM, SCENE_WIDTH } from '../src/game/core/constants';

describe('Path', () => {
  it('treats decorative lines as non-solid', () => {
    expect(new Path({ x: 0, y: 0 }, { x: 1, y: 1 }, PathType.Normal).solid).toBe(true);
    expect(new Path({ x: 0, y: 0 }, { x: 1, y: 1 }, PathType.Accelerated).solid).toBe(true);
    expect(new Path({ x: 0, y: 0 }, { x: 1, y: 1 }, PathType.Decorative).solid).toBe(false);
  });

  it('round-trips through JSON', () => {
    const path = new Path({ x: 12, y: 34 }, { x: 56, y: 78 }, PathType.Accelerated);
    const restored = Path.fromJSON(JSON.parse(JSON.stringify(path.toJSON())));

    expect(restored.from).toEqual(path.from);
    expect(restored.to).toEqual(path.to);
    expect(restored.type).toBe(PathType.Accelerated);
  });
});

describe('Viewport', () => {
  const viewport = (): Viewport => {
    const v = new Viewport();
    v.resize(1400, 800);
    v.reset();
    return v;
  };

  it('centres the original 1000px stage on reset', () => {
    expect(viewport().x).toBe((1400 - SCENE_WIDTH) / 2);
    expect(viewport().scale).toBe(1);
  });

  it('converts between screen and scene space', () => {
    const v = viewport();
    v.zoomAt({ x: 700, y: 400 }, 2);

    const scene = { x: 123, y: 456 };
    const round = v.toScene(v.toScreen(scene));

    expect(round.x).toBeCloseTo(scene.x, 9);
    expect(round.y).toBeCloseTo(scene.y, 9);
  });

  it('keeps the zoom anchor fixed on screen', () => {
    const v = viewport();
    const anchor = { x: 500, y: 300 };
    const before = v.toScene(anchor);

    v.zoomAt(anchor, 1.5);
    const after = v.toScene(anchor);

    expect(after.x).toBeCloseTo(before.x, 9);
    expect(after.y).toBeCloseTo(before.y, 9);
    expect(v.scale).toBeCloseTo(1.5, 9);
  });

  it('clamps the zoom range', () => {
    const v = viewport();

    for (let i = 0; i < 60; i += 1) v.zoomAt({ x: 0, y: 0 }, 1.2);
    expect(v.scale).toBeCloseTo(MAX_ZOOM, 9);

    for (let i = 0; i < 120; i += 1) v.zoomAt({ x: 0, y: 0 }, 0.8);
    expect(v.scale).toBeCloseTo(MIN_ZOOM, 9);
  });

  it('centres on a scene point when following the rider', () => {
    const v = viewport();
    v.centreOn({ x: 200, y: 150 });

    const screen = v.toScreen({ x: 200, y: 150 });
    expect(screen.x).toBeCloseTo(700, 9);
    expect(screen.y).toBeCloseTo(400, 9);
  });
});
