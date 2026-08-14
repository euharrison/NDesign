# Bloquinhos · NDesign — HTML5 port

A modern web port of the Flash/ActionScript 3 block-demolition game that lives in
[`../bloquinhos`](../bloquinhos). Blow up the coloured blocks so the **N** comes to rest standing
on the **RIO 021** block, without ever touching the ground. 42 levels across the two original
games.

No plugin: TypeScript, a `<canvas>`, a physics engine — and the original 2010 artwork.

## Stack

| Concern     | Original (2010)                 | Port                                         |
| ----------- | ------------------------------- | -------------------------------------------- |
| Language    | ActionScript 3                  | TypeScript 5 (strict)                        |
| Build       | Flash IDE                       | Vite 8                                       |
| Physics     | Box2DFlash 2.0a                 | [planck.js](https://piqnt.com/planck.js) 1.5 |
| Rendering   | Flash display list + MovieClips | Canvas 2D, with the original bitmaps         |
| Tweens      | Tweener (caurina)               | CSS transitions                              |
| Deep links  | SWFAddress                      | dropped                                      |
| Levels      | `Level.as` × 2                  | Generated `src/game/levels/levels.ts`        |
| Persistence | PHP e-mail form                 | `localStorage`                               |
| Tests       | —                               | Vitest (26 tests)                            |

## Running it

```bash
npm install
npm run dev       # http://localhost:5173
npm run build     # type-check + production bundle into dist/
npm run preview   # serve the built bundle
npm test          # unit + physics tests
npm run lint
npm run levels    # regenerate levels.ts from the original Level.as files
```

## Deploying

Published to GitHub Pages at **https://euharrison.github.io/NDesign/bloquinhos/** by
[`.github/workflows/pages.yml`](../.github/workflows/pages.yml), which builds both games and
publishes them together under the landing page in [`../site`](../site). The bundle uses
`base: './'`, so it runs from any subdirectory.

## Playing

Click a block to blow it up. The bomb then recharges for half a second — the ring around the
crosshair shows the wait. The **N** block cannot be destroyed: it has to come to rest standing on
the **RIO 021** block. If it touches the ground or slides off the screen, the level is over.

Green blocks bounce, ice blocks slide, and the glass block is nearly invisible but perfectly solid.

| Action            | Input                        |
| ----------------- | ---------------------------- |
| Blow up a block   | Click                        |
| Restart the level | <kbd>R</kbd>, or the toolbar |
| Close a dialog    | <kbd>Esc</kbd>               |
| Help              | <kbd>?</kbd>                 |

Both level packs are in the picker, along with the original password box — the codes from
`SenhasNomes.as` still work (`MEDIEVAL` jumps to level 10 of _Para viciados_).

## How the port maps to the original

```
Jogo.as            -> src/game/Game.ts        (rules, clock, bomb cooldown)
                      src/game/core/Engine.ts (world, blocks, demolition)
Level.as (x2)      -> src/game/levels/levels.ts (generated)
SenhasNomes.as     -> folded into the same generated table
Fundo.as           -> src/game/render/Background.ts (parallax sky)
images/*.{jpg,png,gif} -> src/assets/* via src/game/render/sprites.ts
Main.as            -> src/main.ts + src/ui/Ui.ts
TelaFinal.as       -> the "finished" card in index.html
Musica.as          -> dropped (no audio assets in the repo)
SWFAddress.as      -> dropped
```

### Physics fidelity

The constants come straight across: 30 px/m, gravity `10`, a fixed `1/30 s` step with 10 velocity
iterations, density `1` for every block, the 2000×14 ground slab at (500, 564) with friction and
restitution `0.3`, and per-block friction/restitution from the level table. Sleeping is left on,
because the win condition depends on it.

### The win condition

**The N has to come to rest standing on the `Rio021` pedestal, without touching the ground.**

This is what `checkVictory` was for. The flag is declared in `Jogo.as` but never assigned there —
it was set from a movie clip's timeline, inside a `.fla` whose zip central directory is corrupt and
cannot be read — and `_checkingVictory()` only tests `NFound.IsSleeping()` once it is armed.
Landing on the pedestal is what arms it. The level data backs this up: every one of the 42 levels
declares **exactly one** `Rio021` block (31 standing on the ground, 11 built up into the
structure), and it is the only decorative block that appears everywhere.

It also makes the game a puzzle. Demolishing every destructible block lands the N on its pedestal
in only 13 of the 42 levels and drops it on the ground in 23, so brute force is not a solution.

The first-demolition guard stays, because one level ("Mosh") starts with the N already on its
pedestal and would otherwise be won on frame one.

Three smaller departures:

- A short dwell is required before the win registers, so a one-frame sleep mid-collapse cannot
  award the level by accident.
- The N must be *above* the pedestal's centre, so resting against its side does not count. Across
  all 42 levels this never rejects a contact that would otherwise have registered.
- Losing also triggers if the N falls far below the ground, which the original could not detect —
  it only watched the horizontal bounds.

What is not proven: that all 42 levels are still solvable under this rule. That would mean solving
42 puzzles, and brute force does not do it by design.

### Art

The original bitmaps survive in [`../bloquinhos/primeiro jogo/images`](<../bloquinhos/primeiro jogo/images>)
and the port uses them. Their sizes are what proves they are the real sprites rather than
lookalikes:

| Bitmap                       | Size    | Why it fits                                                       |
| ---------------------------- | ------- | ----------------------------------------------------------------- |
| `fundo.jpg`                  | 1000×557 | The stage is 1000×580 and the ground slab's top edge is at y=557. |
| `chao.gif`                   | 1000×13  | Exactly the strip between the slab's top and its bottom.          |
| `n.gif`                      | 60×60    | Every `N` block in all 42 levels is 60×60.                        |
| `rio021.gif`                 | 90×30    | Every `Rio021` block is 90×30.                                    |
| `montanhas.png`              | 1060×56  | 60px of slack for the ±5px the mountains drift.                   |
| `nuvem1`…`nuvem5`            | 286×132 → 90×48 | Largest to smallest, matching the depths in `Fundo.as`.   |

`Decode()` backs this up: `Chao`, `N`, `Rio021` and `Preto` are the only symbols instantiated
without a size suffix, and they are exactly the four that shipped a loose bitmap. The coloured
blocks were per-size symbols (`Verde30x30`, `Verde60x90`, … — 150-odd of them) whose art only ever
existed inside the `.fla`, so those stay flat colours drawn from their collision shapes. `Preto` is
one unsized symbol used for blocks up to 2055×480, so its 60×60 tile repeats.

The parallax follows `Fundo.as` exactly: 50px of travel across the stage width and 20px across its
height, divided by 1, 3, 3, 5 and 15 for the clouds and 10 for the mountains. What could not be
recovered is *where* each cloud sat — those x/y values lived on the `Fundo` movie clip's timeline
inside the unreadable `.fla` — so the positions in `Background.ts` are a reconstruction. The
balloon, bird and UFO are placed on the same footing: the bitmaps ship with the game and the bird
carries the N logo, but nothing in the ActionScript says where they went.

Two smaller notes. `fundo.jpg` carries a faint stock-photo watermark; it is in the original asset
and is left alone. `FUNDO-novo-jogo.jpg` is not used — it is the same sky photo with the grass
flattened in (no pixel differs by more than 18/255 from `fundo.jpg`), so it would have cost 62 kB
for no visible difference.

The bitmaps load after the first frame and swap in when they decode, so a slow connection delays
the artwork but never the game — the vector fallback is still there underneath.

### Out of scope

The preloader, the soundtrack (no audio in the repo), the e-mail registration form, the prize
download and the SWFAddress deep links are not ported. Progress and best times go to `localStorage`.
