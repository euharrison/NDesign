import type { Body, World } from 'planck';

import { Rider } from './Rider';

/** Port of `projeto.game.ui.personagens.CarrinhoCompras`. */
export class ShoppingCart extends Rider {
  readonly label = 'Carrinho';

  private head_!: Body;
  private torso!: Body;
  private arm!: Body;
  private forearm!: Body;
  private hand!: Body;
  private thigh!: Body;
  private foot!: Body;
  private cart!: Body;

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
    this.cart = this.wheeled(20, 27);

    this.head = this.head_;
    this.vehicle = this.cart;
    // Only the head breaks on this one, as in the original.
    this.breakables.push(this.head_);
  }

  protected layout(): void {
    this.place(this.head_, 0, 0, 0);
    this.place(this.torso, -2, 33, 0);
    this.place(this.arm, 0, 30, -29);
    this.place(this.forearm, 8, 38, -60);
    this.place(this.hand, 15, 40, -73);
    this.place(this.thigh, 2, 38, -140);
    this.place(this.foot, 10, 38, -37);
    this.place(this.cart, 8, 42, 0);

    this.joint(this.head_, this.torso, -1, 22, -15, 15);
    this.joint(this.arm, this.torso, -2, 26, -29, -29);
    this.joint(this.forearm, this.arm, 3, 35, -60, -60);
    this.joint(this.hand, this.forearm, 13, 40, -73, -73);
    this.joint(this.thigh, this.torso, -3, 43, -140, -140);
    this.joint(this.foot, this.thigh, 6, 32, -37, -37);

    this.joint(this.torso, this.cart, -2, 29, 0, 0);
    this.joint(this.arm, this.cart, 3, 35, -29, -29);
    this.joint(this.forearm, this.cart, 13, 40, -60, -60);
    this.joint(this.hand, this.cart, 18, 41, -73, -73);
    this.joint(this.thigh, this.cart, 6, 32, -140, -140);
    this.joint(this.foot, this.cart, 15, 43, -37, -37);
  }
}
