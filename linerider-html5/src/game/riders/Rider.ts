import type { World } from 'planck';
import { Box, Circle, RevoluteJoint, Vec2, type Body, type Joint } from 'planck';

import type { PartArt, PartMaterial } from '../core/bodyData';
import { PIXELS_PER_METER } from '../core/constants';
import type { EngineRider } from '../core/Engine';

const toMetres = (pixels: number): number => pixels / PIXELS_PER_METER;

const boxShape = (width: number, height: number) => Box(toMetres(width / 2), toMetres(height / 2));

/**
 * Base class for the ragdolls (`Personagem` in the original).
 *
 * Bodies are created once and reused; spawning only resets their transforms and
 * rebuilds the joints, and a wipe-out destroys the joints alone so the parts
 * scatter — exactly how the Flash version behaved.
 */
export abstract class Rider implements EngineRider {
  readonly bodies: Body[] = [];
  readonly breakables: Body[] = [];

  vehicle!: Body;
  /** Followed by the camera. */
  head!: Body;

  created = false;
  mirrored = false;

  private joints: Joint[] = [];
  private originX = 0;
  private originY = 0;

  protected constructor(protected readonly world: World) {}

  /** Human-readable name used by the rider picker. */
  abstract readonly label: string;

  /** Creates the bodies. Called once, right after construction. */
  protected abstract createBodies(): void;

  /** Positions the bodies and wires up the joints for a fresh spawn. */
  protected abstract layout(): void;

  build(): this {
    this.createBodies();
    return this;
  }

  spawn(x: number, y: number, mirrored = false): void {
    this.created = true;
    this.mirrored = mirrored;
    this.originX = x;
    this.originY = y;

    for (const body of this.bodies) {
      body.setLinearVelocity(new Vec2(0, 0));
      body.setAngularVelocity(0);
      body.setAwake(true);
    }

    this.joints = [];
    this.layout();
  }

  /** Breaks the ragdoll apart; the bodies keep simulating as they tumble. */
  destroy(): void {
    this.created = false;

    for (const joint of this.joints) {
      this.world.destroyJoint(joint);
    }
    this.joints = [];
  }

  /** Removes the rider from the world entirely. */
  dispose(): void {
    this.destroy();
    for (const body of this.bodies) {
      this.world.destroyBody(body);
    }
    this.bodies.length = 0;
    this.breakables.length = 0;
  }

  /** Head position in scene pixels. */
  get headPosition(): { x: number; y: number } {
    const position = this.head.getPosition();
    return { x: position.x * PIXELS_PER_METER, y: position.y * PIXELS_PER_METER };
  }

  // --- construction helpers (createCircle / createSquare / createCarrinho) ---

  protected circle(radius: number, material: PartMaterial, density = 1): Body {
    const body = this.createBody({ material, shape: 'circle', width: radius, height: radius });
    body.createFixture(Circle(toMetres(radius)), { density, friction: 0 });
    return body;
  }

  protected box(
    width: number,
    height: number,
    material: PartMaterial,
    density = 1,
    tip?: PartMaterial,
  ): Body {
    const body = this.createBody({ material, shape: 'box', width, height, tip });
    body.createFixture(boxShape(width, height), { density, friction: 0 });
    return body;
  }

  /** A board/frame plus two wheels, as `createCarrinho` built it. */
  protected wheeled(width: number, height: number, density = 90): Body {
    const body = this.createBody({ material: 'vehicle', shape: 'vehicle', width, height });
    body.createFixture(boxShape(width, height), { density, friction: 0 });

    for (const side of [-1, 1]) {
      body.createFixture(Circle(new Vec2(toMetres((side * width) / 2), 0), toMetres(height / 2)), {
        density,
        friction: 0,
      });
    }

    return body;
  }

  private createBody(art: PartArt): Body {
    const body = this.world.createDynamicBody();
    body.setUserData({ kind: 'part', art });
    this.bodies.push(body);
    return body;
  }

  // --- layout helpers (position / createJoint) ---

  /** Places a body relative to the spawn point, in scene pixels and degrees. */
  protected place(body: Body, x: number, y: number, rotation = 0): void {
    body.setTransform(
      new Vec2(toMetres(this.originX + this.mirror(x)), toMetres(this.originY + y)),
      (this.mirror(rotation) * Math.PI) / 180,
    );
  }

  /**
   * Pins two bodies together at a scene-pixel anchor.
   *
   * NOTE: the original divided the limit angles by 180 without multiplying by
   * PI — so the "degrees" are really radians/180. The joints are much stiffer
   * than the numbers suggest, and the whole game was tuned around that, so the
   * quirk is preserved deliberately.
   */
  protected joint(
    bodyA: Body,
    bodyB: Body,
    x: number,
    y: number,
    lowerAngle?: number,
    upperAngle?: number,
  ): void {
    const anchor = new Vec2(toMetres(this.originX + this.mirror(x)), toMetres(this.originY + y));
    const limited = Boolean(lowerAngle) || Boolean(upperAngle);

    const lower = lowerAngle ?? 0;
    const upper = upperAngle ?? 0;

    const joint = this.world.createJoint(
      new RevoluteJoint(
        {
          enableLimit: limited,
          lowerAngle: (this.mirrored ? this.mirror(upper) : lower) / 180,
          upperAngle: (this.mirrored ? this.mirror(lower) : upper) / 180,
        },
        bodyA,
        bodyB,
        anchor,
      ),
    );

    if (joint) this.joints.push(joint);
  }

  protected mirror(value: number): number {
    return this.mirrored ? -value : value;
  }
}
