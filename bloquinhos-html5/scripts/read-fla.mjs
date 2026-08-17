#!/usr/bin/env node
// Reads the original Flash .fla files in ../bloquinhos.
//
// They come in two formats and neither needs Flash to open:
//
//   * XFL (CS5+) is a ZIP. These two have a damaged central directory, so the
//     entries are recovered by scanning for local file headers instead.
//   * The older binary .fla is an OLE compound file. Timeline scripts and frame
//     labels sit in the `S <n>` streams as UTF-16LE.
//
// Usage:
//   node scripts/read-fla.mjs <file.fla>              list entries
//   node scripts/read-fla.mjs <file.fla> --scripts    print every ActionScript
//   node scripts/read-fla.mjs <file.fla> --dump <re>  dump entries matching a regex
import { Buffer } from 'node:buffer';
import { readFileSync } from 'node:fs';
import { inflateRawSync } from 'node:zlib';

// ----------------------------------------------------------------- XFL (zip)

/**
 * Recovers a zip by walking its local file headers. The central directory in
 * `para viciados/*.fla` is corrupt, which is why the normal readers give up.
 */
function readZip(buf) {
  const entries = new Map();

  for (let i = 0; (i = buf.indexOf('PK\x03\x04', i, 'latin1')) !== -1; i += 4) {
    const flags = buf.readUInt16LE(i + 6);
    const method = buf.readUInt16LE(i + 8);
    const csize = buf.readUInt32LE(i + 18);
    const nameLen = buf.readUInt16LE(i + 26);
    const extraLen = buf.readUInt16LE(i + 28);

    const name = buf.subarray(i + 30, i + 30 + nameLen).toString('utf8');
    const start = i + 30 + nameLen + extraLen;

    let blob;
    if (csize === 0 && flags & 0x08) {
      // Streamed entry: the size lives in a trailing descriptor, so run to the
      // next header and trim it back off.
      const next = buf.indexOf('PK\x03\x04', start, 'latin1');
      blob = buf.subarray(start, next === -1 ? buf.length : next);
      const descriptor = blob.lastIndexOf('PK\x07\x08', undefined, 'latin1');
      if (descriptor > 0) blob = blob.subarray(0, descriptor);
    } else {
      blob = buf.subarray(start, start + csize);
    }

    try {
      entries.set(name, method === 8 ? inflateRawSync(blob) : blob);
    } catch {
      // A partially overwritten entry; the rest of the archive still reads.
    }
  }

  return entries;
}

// ------------------------------------------------------- OLE compound file

const OLE_MAGIC = 'd0cf11e0a1b11ae1';
const END_OF_CHAIN = 0xfffffffe;

/** Minimal CFB reader — enough to pull every stream out of a binary .fla. */
function readOle(buf) {
  const sectorSize = 1 << buf.readUInt16LE(30);
  const miniSectorSize = 1 << buf.readUInt16LE(32);
  const dirStart = buf.readUInt32LE(48);
  const miniCutoff = buf.readUInt32LE(56);
  const miniFatStart = buf.readUInt32LE(60);
  const difatStart = buf.readUInt32LE(68);
  const difatCount = buf.readUInt32LE(72);

  const at = (sector) => (sector + 1) * sectorSize;

  // The DIFAT lists the FAT sectors: 109 inline, the rest in a chain.
  const fatSectors = [];
  for (let i = 0; i < 109; i += 1) {
    const s = buf.readUInt32LE(76 + i * 4);
    if (s < END_OF_CHAIN) fatSectors.push(s);
  }
  let next = difatStart;
  for (let n = 0; n < difatCount && next < END_OF_CHAIN; n += 1) {
    const base = at(next);
    for (let i = 0; i < sectorSize / 4 - 1; i += 1) {
      const s = buf.readUInt32LE(base + i * 4);
      if (s < END_OF_CHAIN) fatSectors.push(s);
    }
    next = buf.readUInt32LE(base + sectorSize - 4);
  }

  const fat = [];
  for (const sector of fatSectors) {
    const base = at(sector);
    for (let i = 0; i < sectorSize / 4; i += 1) fat.push(buf.readUInt32LE(base + i * 4));
  }

  const chain = (start, table) => {
    const out = [];
    for (let s = start; s < END_OF_CHAIN && out.length < 1e6; s = table[s]) out.push(s);
    return out;
  };

  const readChain = (start, size, table, sectorBytes, origin) => {
    const parts = chain(start, table).map((s) => {
      const base = origin ? origin(s) : at(s);
      return buf.subarray(base, base + sectorBytes);
    });
    return Buffer.concat(parts).subarray(0, size);
  };

  // Directory entries, then the mini-FAT they may depend on.
  const dir = readChain(dirStart, Number.MAX_SAFE_INTEGER, fat, sectorSize);
  const entries = [];
  for (let off = 0; off + 128 <= dir.length; off += 128) {
    const nameLen = dir.readUInt16LE(off + 64);
    if (nameLen < 2) continue;
    entries.push({
      name: dir.subarray(off, off + nameLen - 2).toString('utf16le'),
      type: dir.readUInt8(off + 66),
      start: dir.readUInt32LE(off + 116),
      size: Number(dir.readBigUInt64LE(off + 120)),
    });
  }

  const miniFat = [];
  if (miniFatStart < END_OF_CHAIN) {
    const raw = readChain(miniFatStart, Number.MAX_SAFE_INTEGER, fat, sectorSize);
    for (let i = 0; i + 4 <= raw.length; i += 4) miniFat.push(raw.readUInt32LE(i));
  }

  const root = entries.find((e) => e.type === 5);
  const miniStream = root ? readChain(root.start, root.size, fat, sectorSize) : Buffer.alloc(0);
  const miniAt = (s) => s * miniSectorSize;

  const streams = new Map();
  for (const entry of entries) {
    if (entry.type !== 2) continue;
    streams.set(
      entry.name,
      entry.size < miniCutoff
        ? Buffer.concat(
            chain(entry.start, miniFat).map((s) =>
              miniStream.subarray(miniAt(s), miniAt(s) + miniSectorSize),
            ),
          ).subarray(0, entry.size)
        : readChain(entry.start, entry.size, fat, sectorSize),
    );
  }

  return streams;
}

// ------------------------------------------------------------------- output

/** Printable UTF-16LE runs — how scripts and frame labels are stored in CFB. */
function utf16Runs(buf, min = 4) {
  const out = [];
  // A printable byte followed by NUL, four or more times over: the low-byte
  // half of a UTF-16LE ASCII run.
  // eslint-disable-next-line no-control-regex
  const re = /(?:[\x20-\x7e\n\r\t]\x00){4,}/g;
  const text = buf.toString('latin1');
  for (const m of text.matchAll(re)) {
    const s = Buffer.from(m[0], 'latin1').toString('utf16le');
    if (s.length >= min) out.push(s);
  }
  return out;
}

const decode = (s) =>
  s
    .replace(/^<!\[CDATA\[|\]\]>$/g, '')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&apos;/g, "'")
    .replace(/&amp;/g, '&');

function main() {
  const [file, ...rest] = process.argv.slice(2);
  if (!file) {
    console.error('usage: read-fla.mjs <file.fla> [--scripts] [--dump <regex>]');
    process.exit(1);
  }

  const buf = readFileSync(file);
  const isOle = buf.subarray(0, 8).toString('hex') === OLE_MAGIC;
  const entries = isOle ? readOle(buf) : readZip(buf);

  console.log(`${file}: ${isOle ? 'OLE compound file' : 'XFL (zip)'}, ${entries.size} entries\n`);

  if (rest.includes('--scripts')) {
    for (const [name, data] of entries) {
      const found = isOle
        ? utf16Runs(data).filter((t) => /[;{}()]/.test(t) && /\w\s*[({=]/.test(t))
        : [...data.toString('utf8').matchAll(/<Actionscript>\s*<script>([\s\S]*?)<\/script>/g)].map(
            (m) => decode(m[1]).trim(),
          );
      if (found.length) {
        console.log(`### ${name}`);
        for (const script of found) console.log(`    ${script.replace(/\n/g, '\n    ')}`);
        console.log();
      }
    }
    return;
  }

  const dumpIndex = rest.indexOf('--dump');
  if (dumpIndex !== -1) {
    const pattern = new RegExp(rest[dumpIndex + 1] ?? '.');
    for (const [name, data] of entries) {
      if (!pattern.test(name)) continue;
      console.log(`### ${name} (${data.length} bytes)`);
      console.log(isOle ? utf16Runs(data).join('\n') : data.toString('utf8'));
      console.log();
    }
    return;
  }

  for (const [name, data] of entries) {
    console.log(`  ${String(data.length).padStart(9)}  ${name}`);
  }
}

main();
