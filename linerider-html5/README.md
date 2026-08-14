# Line Rider · NDesign — HTML5 port

A modern web port of the Flash/ActionScript 3 game that lives in [`../linerider`](../linerider).
Draw a line, press play, and ride the ragdoll down to one of the coloured answers. Twenty-one
questions later you get the path you drew for yourself.

No plugin, no build-time assets: the whole thing is TypeScript, a `<canvas>`, and a physics engine.

## Stack

| Concern     | Original (2011)                 | Port                                         |
| ----------- | ------------------------------- | -------------------------------------------- |
| Language    | ActionScript 3                  | TypeScript 5 (strict)                        |
| Build       | Flash IDE / Flex SDK            | Vite 8                                       |
| Physics     | Box2DFlash 2.0a                 | [planck.js](https://piqnt.com/planck.js) 1.5 |
| Rendering   | Flash display list + MovieClips | Canvas 2D, drawn from the collision shapes   |
| Tweens      | TweenMax / GreenSock            | CSS transitions                              |
| Levels      | `bin/xml/level.xml`             | Generated `src/game/levels/levels.ts`        |
| Persistence | PHP backend + Facebook Graph    | `localStorage`                               |
| Tests       | —                               | Vitest (42 tests)                            |

## Running it

```bash
npm install
npm run dev       # http://localhost:5173
npm run build     # type-check + production bundle into dist/
npm run preview   # serve the built bundle
npm test          # unit + physics tests
npm run lint
npm run levels    # regenerate levels.ts from the original level.xml
```

## Deploying

The game is published to GitHub Pages at **https://euharrison.github.io/NDesign/linerider/** by
[`.github/workflows/pages.yml`](../.github/workflows/pages.yml), which runs the tests, type-checks,
builds, and uploads `dist/` whenever `linerider-html5/**` changes on `main`. It can also be run
by hand from the Actions tab. Nothing built is committed.

The site root is the landing page in [`../site`](../site), which links to both games.

The bundle uses `base: './'`, so it works from the `/NDesign/linerider/` subpath — and from any
other subdirectory — without configuration.

## Playing

| Action      | Input                                        |
| ----------- | -------------------------------------------- |
| Draw        | Pencil `P` (freehand) or Line `L` (straight) |
| Erase       | `E`, then drag over a line                   |
| Pan         | `H`, hold <kbd>Space</kbd>, or middle-drag   |
| Zoom        | Mouse wheel, or `Z` and drag up/down         |
| Undo        | <kbd>Ctrl</kbd>+<kbd>Z</kbd>                 |
| Play / stop | <kbd>Enter</kbd> / <kbd>Esc</kbd>            |

Black lines are solid, **pink** lines speed you up, **yellow-green** lines are decoration only and
have no physics body. Landing head- or torso-first on a solid line breaks the ragdoll apart.

## How the port maps to the original

```
projeto/game/Game.as            -> src/game/Game.ts          (state machine + main loop)
projeto/game/core/Engine.as     -> src/game/core/Engine.ts   (world, walls, line bodies, contacts)
projeto/game/core/Draw.as       -> src/game/core/DrawController.ts
projeto/game/core/Caminho.as    -> src/game/core/Path.ts
projeto/game/core/Camera.as     ┐
projeto/game/ui/Cena.as         ┘-> src/game/render/Viewport.ts
projeto/game/core/EngineListener-> folded into Engine.ts (begin-contact / pre-solve)
projeto/game/ui/personagens/*   -> src/game/riders/*         (Bike, Skateboard, Sled, ShoppingCart)
projeto/game/ui/Levels.as       ┐
bin/xml/level.xml               ┘-> src/game/levels/levels.ts (generated)
projeto/game/ui/Ferramentas.as  ┐
projeto/game/ui/DialogBox.as    ├-> src/ui/Ui.ts + index.html + src/style.css
projeto/game/ui/ContadorFases.as┘
```

### Physics fidelity

The tuning constants are carried over verbatim so the game feels the same: 30 pixels per metre,
gravity `10`, a fixed `1/30 s` step with 10 velocity iterations, zero friction everywhere, the
`×1.008` per-step boost on accelerated lines, and the ±200 m kill box around the world.

The ragdolls are ported joint for joint from the AS3 classes, including one deliberate quirk: the
original set `joint.lowerAngle = degrees / 180`, forgetting the `× π`. The limits are therefore far
tighter than the numbers suggest — and every rider pose was tuned against that, so the port keeps
it. See the note on `Rider.joint()`.

Two things intentionally differ:

- `b2ContactListener.Persist` fired per contact _point_; planck's `pre-solve` fires per contact
  _pair_, so the acceleration boost compounds slightly more slowly on wide contacts.
- The AS3 `createAt` reset velocities for a body list that omitted one hand. The port resets every
  body, so a respawn always starts at rest.

### Art

The Flash build pinned hand-drawn MovieClips to each Box2D body; those live inside binary `.fla`
libraries and cannot be ported. The renderer instead draws each body from its own collision shape,
so the silhouette and motion match the simulation exactly, with no binary assets to ship. Vehicle,
shirt, trousers and skin colours are configurable in the rider panel — the remains of the original
"crie seu personagem" screen.

### Out of scope

The Flash project was a whole campaign site. Only the game is ported; the marketing pages, photo
upload/cropping, the Facebook Graph integration and the PHP score backend are not. Progress that
used to go to the server is kept in `localStorage` instead.
