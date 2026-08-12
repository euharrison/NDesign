import type { Body, World } from 'planck';

import { Rider } from './Rider';

/** Port of `projeto.game.ui.personagens.Treno` (the sled). */
export class Sled extends Rider {
  readonly label = 'Trenó';

  private head_!: Body;
  private torso!: Body;
  private arm!: Body;
  private forearm!: Body;
  private hand!: Body;
  private thigh!: Body;
  private foot!: Body;
  private sled!: Body;

  constructor(world: World) {
    super(world);
  }

  protected createBodies(): void {
    this.head_ = this.circle(35 / 2, 'head', 0.01);
    this.torso = this.box(9, 26, 'shirt', 0.1);
    this.arm = this.box(4, 15, 'shirt', 0.1);
    this.forearm = this.box(4, 15, 'shirt', 0.1, 'skin');
    this.hand = this.box(9, 9, 'skin', 0.1);
    this.thigh = this.box(5, 19, 'pants', 0.1);
    this.foot = this.box(4, 18, 'pants', 0.1);
    this.sled = this.wheeled(35, 26);

    this.head = this.head_;
    this.vehicle = this.sled;
    this.breakables.push(this.head_, this.torso);
  }

  protected layout(): void {
    this.place(this.head_, -10, 0, 0);
    this.place(this.torso, -12, 34, 0);
    this.place(this.arm, -9, 31, -40);
    this.place(this.forearm, 0, 36, -80);
    this.place(this.hand, 9, 36, -90);
    this.place(this.thigh, -4, 45, -90);
    this.place(this.foot, 5, 51, -31);
    this.place(this.sled, 0, 48, 0);

    this.joint(this.head_, this.torso, -12, 21, -15, 15);
    this.joint(this.arm, this.torso, -12, 27, -40, -40);
    this.joint(this.forearm, this.arm, -5, 35, -80, -80);
    this.joint(this.hand, this.forearm, 6, 36, -90, -90);
    this.joint(this.thigh, this.torso, -13, 45, -90, -90);
    this.joint(this.foot, this.thigh, 2, 45, -31, -31);

    this.joint(this.hand, this.sled, 0, 46, -90, -90);
    this.joint(this.torso, this.sled, -3, 44, -90, -90);
    this.joint(this.thigh, this.sled, -11, 52, -90, -90);
    this.joint(this.foot, this.sled, -8, 66, -31, -31);
  }
}
