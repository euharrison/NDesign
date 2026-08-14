# Bloquinhos · NDesign — HTML5 port

A modern web port of the Flash/ActionScript 3 block-demolition game that lives in
[`../bloquinhos`](../bloquinhos). Blow up the coloured blocks so the **N** settles without sliding
off the screen. 42 levels across the two original games.

No plugin, no binary assets: TypeScript, a `<canvas>`, and a physics engine.

## Stack

| Concern     | Original (2010)                 | Port                                         |
| ----------- | ------------------------------- | -------------------------------------------- |
| Language    | ActionScript 3                  | TypeScript 5 (strict)                        |
| Build       | Flash IDE                       | Vite 8                                       |
| Physics     | Box2DFlash 2.0a                 | [planck.js](https://piqnt.com/planck.js) 1.5 |
| Rendering   | Flash display list + MovieClips | Canvas 2D                                    |
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
publishes them together. Line Rider keeps the site root so its existing URL still works; this game
sits in `/bloquinhos/`. The bundle uses `base: './'`, so it runs from any subdirectory.

## Playing

Click a block to blow it up. The bomb then recharges for half a second — the ring around the
crosshair shows the wait. The black **N** cannot be destroyed: it has to come to rest somewhere on
screen. If it slides off the side, the level is over.

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
Fundo.as           -> src/game/render/Background.ts (parallax clouds)
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

**One rule had to be inferred.** The original tested `NFound.IsSleeping()` but only when a
`checkVictory` flag was set, and that flag is never assigned in any `.as` file — it was set from a
movie clip's timeline, inside a `.fla` whose zip central directory is corrupt and cannot be read.
Arming the check on the player's first demolition is the only reading that works: the stacks start
settled, so an unguarded test would award the level before the player touched anything. There's a
test (`lets an untouched stack come to rest`) that pins this down.

Two smaller departures:

- A short dwell is required before the win registers, so a one-frame sleep mid-collapse cannot
  award the level by accident.
- Losing also triggers if the N falls far below the ground, which the original could not detect —
  it only watched the horizontal bounds.

### Art

The block graphics were MovieClips inside the `.fla` libraries, so they are drawn from their
collision shapes instead, one flat colour per original library symbol. The parallax sky is a
reconstruction of `Fundo.as`, keeping its layer divisors (1, 3, 3, 5, 15 for the clouds, 10 for the
mountains) so it drifts at the same rates.

### Out of scope

The preloader, the soundtrack (no audio in the repo), the e-mail registration form, the prize
download and the SWFAddress deep links are not ported. Progress and best times go to `localStorage`.
