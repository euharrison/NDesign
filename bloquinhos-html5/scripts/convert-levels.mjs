/**
 * Converts the original Flash project's two `Level.as` files into the typed
 * level table used by the HTML5 port (`src/game/levels/levels.ts`).
 *
 * Each row in the AS3 source is:
 *   [x, y, width, height, static, name, destroyable, restitution, friction, cover]
 *
 * Run with `npm run levels`. The generated file is committed, so this script is
 * only needed when the source changes.
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const ORIGINAL = resolve(here, '../../bloquinhos');
const TARGET = resolve(here, '../src/game/levels/levels.ts');

const PACKS = [
  { id: 'primeiro', dir: 'primeiro jogo', title: 'Primeiro jogo' },
  { id: 'viciados', dir: 'para viciados', title: 'Para viciados' },
];

/**
 * The first game named every green block after its dimensions
 * (`Verde90x30`); the sequel collapsed them all to `Verde`. Sizes already come
 * from the width/height columns, so normalise to the material name.
 */
const normaliseMaterial = (cover) => {
  const match = /^Verde\d+x\d+$/.exec(cover);
  return match ? 'Verde' : cover;
};

const MATERIALS = new Set([
  'Azul',
  'Marrom',
  'Roxo',
  'Vermelho',
  'Preto',
  'Verde',
  'Branco',
  'Transparente',
  'Gelo',
  'Chao',
  'N',
  'Rio021',
  'Rio021_90Graus',
]);

/** Splits a level body into rows, ignoring comments and whitespace. */
function parseRows(body) {
  const rows = [];

  for (const [, row] of body.matchAll(/\[([^\]]*)\]/g)) {
    const parts = row.split(',').map((part) => part.trim());
    if (parts.length !== 10) throw new Error(`Expected 10 columns, got ${parts.length}: ${row}`);

    const unquote = (value) => value.replace(/^['"]|['"]$/g, '');
    const material = normaliseMaterial(unquote(parts[9]));
    if (!MATERIALS.has(material)) throw new Error(`Unknown material: ${material}`);

    rows.push({
      x: Number(parts[0]),
      y: Number(parts[1]),
      width: Number(parts[2]),
      height: Number(parts[3]),
      fixed: parts[4] === 'true',
      name: unquote(parts[5]),
      destroyable: parts[6] === 'true',
      restitution: Number(parts[7]),
      friction: Number(parts[8]),
      material,
    });
  }

  return rows;
}

/** Pulls the `FASE` / `SENHA` arrays out of SenhasNomes.as. */
function parseNamesAndPasswords(dir) {
  let source;
  try {
    source = readFileSync(resolve(ORIGINAL, dir, 'SenhasNomes.as'), 'utf8');
  } catch {
    return { names: [], passwords: [] };
  }

  const list = (label) => {
    const block = new RegExp(`${label}:Array = new Array\\s*\\(([^)]*)\\)`, 's').exec(source);
    if (!block) return [];
    return [...block[1].matchAll(/'([^']*)'/g)].map(([, value]) => value);
  };

  return { names: list('FASE'), passwords: list('SENHA') };
}

const packs = PACKS.map(({ id, dir, title }) => {
  const source = readFileSync(resolve(ORIGINAL, dir, 'Level.as'), 'utf8');
  const { names, passwords } = parseNamesAndPasswords(dir);

  // `public static var L1:Array = new Array( ... );`
  const levels = [
    ...source.matchAll(/public static var L(\d+):Array = new Array\s*\(([\s\S]*?)\n\s*\);/g),
  ]
    .map(([, index, body]) => ({ index: Number(index), blocks: parseRows(body) }))
    .sort((a, b) => a.index - b.index)
    .map(({ index, blocks }, position) => ({
      name: names[position] ?? `Fase ${index}`,
      password: passwords[position] ?? '',
      blocks,
    }));

  return { id, title, levels };
});

const serialiseBlock = (b) =>
  `      { x: ${b.x}, y: ${b.y}, width: ${b.width}, height: ${b.height}, fixed: ${b.fixed}, ` +
  `name: '${b.name}', destroyable: ${b.destroyable}, restitution: ${b.restitution}, ` +
  `friction: ${b.friction}, material: '${b.material}' },`;

const body = packs
  .map(
    (pack) => `  {
    id: '${pack.id}',
    title: ${JSON.stringify(pack.title)},
    levels: [
${pack.levels
  .map(
    (level) => `    {
      name: ${JSON.stringify(level.name)},
      password: '${level.password}',
      blocks: [
${level.blocks.map(serialiseBlock).join('\n')}
      ],
    },`,
  )
  .join('\n')}
    ],
  },`,
  )
  .join('\n');

writeFileSync(
  TARGET,
  `// GENERATED FILE - do not edit by hand.
// Source: bloquinhos/*/Level.as and SenhasNomes.as (original Flash project)
// Regenerate with: npm run levels
import type { LevelPack } from './types';

export const PACKS: readonly LevelPack[] = [
${body}
];
`,
);

for (const pack of packs) {
  console.log(
    `${pack.id}: ${pack.levels.length} levels, ${pack.levels.reduce((n, l) => n + l.blocks.length, 0)} blocks`,
  );
}
console.log(`Wrote ${TARGET}`);
