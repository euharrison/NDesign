import type { PartMaterial } from '../core/bodyData';
import type { TargetStyle } from '../levels/types';

export interface TargetColors {
  fill: string;
  text: string;
}

/** Goal-circle colours, named after the original library symbols. */
export const TARGET_COLORS: Record<TargetStyle, TargetColors> = {
  yellow: { fill: '#ffc20e', text: '#4a3400' },
  yellowLight: { fill: '#ffe14f', text: '#4a3f00' },
  blue: { fill: '#1b5fd0', text: '#ffffff' },
  blueLight: { fill: '#4fc3f7', text: '#04384a' },
  orange: { fill: '#f26722', text: '#ffffff' },
  magenta: { fill: '#f62e8d', text: '#ffffff' },
  teal: { fill: '#17b6c6', text: '#00343a' },
  purple: { fill: '#7b3fa0', text: '#ffffff' },
  green: { fill: '#3aa63a', text: '#ffffff' },
  greenLight: { fill: '#8dc63f', text: '#1e3300' },
  logo: { fill: '#00a651', text: '#ffffff' },
  logoFalse: { fill: '#9b9b9b', text: '#ffffff' },
};

export interface RiderPalette {
  head: string;
  shirt: string;
  pants: string;
  skin: string;
  vehicle: string;
  outline: string;
}

export const DEFAULT_RIDER_PALETTE: RiderPalette = {
  head: '#f3c9a0',
  shirt: '#f62e8d',
  pants: '#26305c',
  skin: '#f3c9a0',
  vehicle: '#2b2b2b',
  outline: '#1a1a1a',
};

export const materialColor = (palette: RiderPalette, material: PartMaterial): string =>
  palette[material];
