import type { World } from 'planck';

import { Bike } from './Bike';
import { Rider } from './Rider';
import { ShoppingCart } from './ShoppingCart';
import { Skateboard } from './Skateboard';
import { Sled } from './Sled';

export { Rider, Bike, Skateboard, Sled, ShoppingCart };

export const RIDER_TYPES = ['skate', 'bike', 'sled', 'cart'] as const;
export type RiderType = (typeof RIDER_TYPES)[number];

const FACTORIES: Record<RiderType, (world: World) => Rider> = {
  skate: (world) => new Skateboard(world),
  bike: (world) => new Bike(world),
  sled: (world) => new Sled(world),
  cart: (world) => new ShoppingCart(world),
};

export const createRider = (type: RiderType, world: World): Rider => FACTORIES[type](world).build();

export const RIDER_LABELS: Record<RiderType, string> = {
  skate: 'Skate',
  bike: 'Bike',
  sled: 'Trenó',
  cart: 'Carrinho',
};
