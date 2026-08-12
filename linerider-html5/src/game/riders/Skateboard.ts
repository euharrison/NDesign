import type { Body, World } from 'planck';

import { Rider } from './Rider';

/** Port of `projeto.game.ui.personagens.Skate`. */
export class Skateboard extends Rider {
  readonly label = 'Skate';

  private head_!: Body;
  private torso!: Body;
  private armL!: Body;
  private armR!: Body;
  private forearmL!: Body;
  private forearmR!: Body;
  private thighL!: Body;
  private thighR!: Body;
  private footL!: Body;
  private footR!: Body;
  private board!: Body;

  constructor(world: World) {
    super(world);
  }

  protected createBodies(): void {
    this.head_ = this.circle(35 / 2, 'head', 0.1);
    this.torso = this.box(15, 28, 'shirt');
    this.armL = this.box(6, 16, 'shirt');
    this.armR = this.box(6, 16, 'shirt');
    this.forearmL = this.box(6, 22, 'shirt', 1, 'skin');
    this.forearmR = this.box(6, 22, 'shirt', 1, 'skin');
    this.thighL = this.box(6, 20, 'pants');
    this.thighR = this.box(6, 20, 'pants');
    this.footL = this.box(6, 19, 'pants');
    this.footR = this.box(6, 19, 'pants');
    this.board = this.wheeled(30, 8);

    this.head = this.head_;
    this.vehicle = this.board;
    this.breakables.push(this.head_, this.torso);
  }

  protected layout(): void {
    this.place(this.head_, 0, 0, 0);
    this.place(this.torso, 0, 33, 0);
    this.place(this.armL, -10, 28, 40);
    this.place(this.armR, 10, 27, -50);
    this.place(this.forearmL, -16, 40, 10);
    this.place(this.forearmR, 16, 39, -10);
    this.place(this.thighL, -7, 50, 30);
    this.place(this.thighR, 7, 50, -17);
    this.place(this.footL, -13, 63, 15);
    this.place(this.footR, 9, 64, 0);
    this.place(this.board, 1, 75, 0);

    this.joint(this.head_, this.torso, 0, 15, -15, 15);
    this.joint(this.armL, this.torso, -6, 25, 40, 40);
    this.joint(this.armR, this.torso, 6, 25, -50, -50);
    this.joint(this.forearmL, this.armL, -15, 34, 10, 10);
    this.joint(this.forearmR, this.armR, 16, 33, -10, -10);
    this.joint(this.thighL, this.torso, -5, 47, 30, 30);
    this.joint(this.thighR, this.torso, 6, 47, -17, -17);
    this.joint(this.footL, this.thighL, -11, 58, 15, 15);
    this.joint(this.footR, this.thighR, 9, 58, 0, 0);
    this.joint(this.footL, this.board, -15, 73, 15, 15);
    this.joint(this.footR, this.board, 9, 74, 0, 0);
  }
}
