import type { Body, World } from 'planck';

import { Rider } from './Rider';

/** Port of `projeto.game.ui.personagens.Bike`. */
export class Bike extends Rider {
  readonly label = 'Bike';

  private head_!: Body;
  private torso!: Body;
  private arm!: Body;
  private forearm!: Body;
  private hand!: Body;
  private thigh!: Body;
  private foot!: Body;
  private bike!: Body;

  constructor(world: World) {
    super(world);
  }

  protected createBodies(): void {
    this.head_ = this.circle(35 / 2, 'head', 0.1);
    this.torso = this.box(9, 26, 'shirt');
    this.arm = this.box(4, 15, 'shirt');
    this.forearm = this.box(4, 15, 'shirt', 1, 'skin');
    this.hand = this.box(9, 9, 'skin');
    this.thigh = this.box(5, 19, 'pants');
    this.foot = this.box(4, 18, 'pants');
    this.bike = this.wheeled(40, 38);

    this.head = this.head_;
    this.vehicle = this.bike;
    this.breakables.push(this.head_, this.torso);
  }

  protected layout(): void {
    this.place(this.head_, 0, 0, 15);
    this.place(this.torso, -10, 33, 17);
    this.place(this.arm, -5, 31, -23);
    this.place(this.forearm, 2, 40, -50);
    this.place(this.hand, 10, 45, -60);
    this.place(this.thigh, -7, 47, -52);
    this.place(this.foot, -1, 59, 0);
    this.place(this.bike, 2, 62, 0);

    this.joint(this.head_, this.torso, -7, 21, 0, 30);
    this.joint(this.arm, this.torso, -7, 26, -33, -13);
    this.joint(this.forearm, this.arm, -2, 37, -60, -40);
    this.joint(this.hand, this.forearm, 8, 44, -60, -40);
    this.joint(this.thigh, this.torso, -13, 42, -52, -52);
    this.joint(this.foot, this.thigh, -1, 52, 0, 0);

    this.joint(this.hand, this.bike, 10, 46, -60, -40);
    this.joint(this.torso, this.bike, -13, 44, 7, 27);
    this.joint(this.thigh, this.bike, -1, 52, -52, -52);
    this.joint(this.foot, this.bike, 2, 66, 0, 0);
  }
}
