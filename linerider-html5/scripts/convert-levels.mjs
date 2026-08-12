/**
 * Converts the original Flash project's `bin/xml/level.xml` into the typed
 * level table used by the HTML5 port (`src/game/levels/levels.ts`).
 *
 * Run with `npm run levels`. The generated file is committed, so this script is
 * only needed when the source XML changes.
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const SOURCE = resolve(here, '../../linerider/bin/xml/level.xml');
const TARGET = resolve(here, '../src/game/levels/levels.ts');

/** Original library symbol name -> palette key used by the renderer. */
const TARGET_STYLE = {
  EscolhaAmarelo: 'yellow',
  EscolhaAmareloLight: 'yellowLight',
  EscolhaAzul: 'blue',
  EscolhaAzulLight: 'blueLight',
  EscolhaLaranja: 'orange',
  EscolhaMagenta: 'magenta',
  EscolhaPiscina: 'teal',
  EscolhaRoxo: 'purple',
  EscolhaVerde: 'green',
  EscolhaVerdeLight: 'greenLight',
  EscolhaN: 'logo',
  EscolhaNNot: 'logoFalse',
};

const attr = (tag, name) => {
  const match = tag.match(new RegExp(`${name}="([^"]*)"`));
  return match ? match[1] : undefined;
};

const decode = (text) =>
  text
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&amp;/g, '&')
    .replace(/&quot;/g, '"')
    .trim();

const xml = readFileSync(SOURCE, 'utf8');
const levels = [];

for (const [, block] of xml.matchAll(/<level>([\s\S]*?)<\/level>/g)) {
  const startTag = block.match(/<startAt[^>]*>/)?.[0] ?? '';
  const question = decode(block.match(/<pergunta>([\s\S]*?)<\/pergunta>/)?.[1] ?? '');

  const targets = [...block.matchAll(/<resposta[^>]*>/g)].map(([tag]) => {
    const kind = attr(tag, 'tipo');
    const style = TARGET_STYLE[kind];
    if (!style) throw new Error(`Unknown target kind: ${kind}`);
    return {
      x: Number(attr(tag, 'x')),
      y: Number(attr(tag, 'y')),
      style,
      label: decode(attr(tag, 'label') ?? ''),
      value: attr(tag, 'value') ?? '',
    };
  });

  levels.push({
    start: { x: Number(attr(startTag, 'x')), y: Number(attr(startTag, 'y')) },
    mirrored: attr(startTag, 'espelhado') === 'true',
    question,
    targets,
  });
}

const body = levels
  .map((level) => {
    const targets = level.targets
      .map(
        (t) =>
          `      { x: ${t.x}, y: ${t.y}, style: '${t.style}', label: ${JSON.stringify(t.label)}, value: '${t.value}' },`,
      )
      .join('\n');
    return `  {
    start: { x: ${level.start.x}, y: ${level.start.y} },
    mirrored: ${level.mirrored},
    question: ${JSON.stringify(level.question)},
    targets: [
${targets}
    ],
  },`;
  })
  .join('\n');

writeFileSync(
  TARGET,
  `// GENERATED FILE - do not edit by hand.
// Source: linerider/bin/xml/level.xml (original Flash project)
// Regenerate with: npm run levels
import type { Level } from './types';

export const LEVELS: readonly Level[] = [
${body}
];
`,
);

console.log(`Wrote ${levels.length} levels to ${TARGET}`);
