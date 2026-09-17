# Flutter–Godot board integration

Flutter is the source of truth for game rules, players, money, dice, tile
resolution, and turn order. Godot renders all 18 city theme parks and performs
the camera, dice, and movement animation.

## Protocol v2

Flutter sends:

- `scene_state`: game `sessionId`, monotonic `stateGeneration`, board ID,
  localized tile names and types, prices, ownership, upgrades, mortgage state,
  completed color-group state, logical tile count, visual spot count, current
  turn, dice, and player state.
- `animate_roll`: dice values, logical start/destination, and a mapped visual
  path. Godot uses that path for the route preview, destination beacon, dice
  animation, pawn movement, and landing reaction before returning completion.
  A roll never overrides the camera angle, target, or zoom selected by the
  player.
- `animate_roll` also carries every non-dice board movement (jail escorts,
  Chance/Community Chest relocations, teleport prizes) under the same scoped,
  cancellable command contract. A `presentation` field selects how Godot
  stages the movement; missing values mean the historical dice-roll staging:
  - `standard`: dice animation, route preview, waypoint walk (dice rolls).
  - `walk`: route preview and waypoint walk without touching the settled dice
    (forward card moves, nearest railroad/utility).
  - `reverse`: backwards route walk with its own "moves back" staging
    (back-N card moves).
  - `teleport`: a parabolic pawn flight with a destination beacon and no
    route markers (teleport prizes, advance-to-GO).
  - `jail`: the same flight staged as a jail escort (go-to-jail tile and
    card). Flights receive an explicit `toVisualPosition` and an empty
    `visualPath`; walks receive the complete waypoint path and a positive
    `spaces` count.
- `camera_gesture`: one-finger pan, two-finger orbit, pinch zoom, and reset-view
  commands. Two-finger orbit and pinch values can be sent together so rotating
  does not interrupt zooming.
- `camera_follow`: opt-in token-follow framing (3D-09). When enabled, the
  ground target damps toward the active pawn during movements with
  frame-rate-independent easing, respecting the existing target bounds. Any
  manual pan or orbit gesture suppresses the chase until the next accepted
  movement command, so the player's chosen view always wins; Reset View and
  disabling follow both restore the free camera.
- `board_tap`: normalized view coordinates for interactive object picking.

Godot returns:

- `boardReady`: the runtime plugin and GDScript scene are connected. The native
  host may replay this only after observing the scene-created readiness token;
  an initialized engine or Metal surface is not sufficient.
- `stateApplied`: the exact game `sessionId`, `stateGeneration`, and board ID
  that Godot finished applying after any city rebuild, tile refresh, pawn
  placement, active-player update, and dice synchronization.
- `movementStep`: a purely presentational progress event emitted for every
  visual waypoint a walking pawn arrives on (dice rolls and card walks; never
  for flights). It drives footstep audio and carries `commandId`, `playerId`,
  a 1-based `stepIndex`, and `totalSteps`. It never gates gameplay —
  `movementComplete` remains the only authoritative completion signal, and
  stale or cancelled commands stop emitting steps.
- `movementComplete`: the command ID, player ID, logical destination, and
  visual destination.
- `boardObjectTapped`: the selected logical tile, character, dice, landmark,
  scenic stop, or city background.

Every board maps Flutter's 40 logical tiles onto 52 visual locations. The 12
additional locations receive city-specific scenic names. Flutter resolves the
landing tile only after the matching movement-complete event returns.
Flutter also owns all informational and gameplay dialogs. Godot picks the 3D
object, then Flutter opens the same tile facts, player portfolio, card draw, or
city guide UI used by the rest of the app.

The Flutter loading cover stays closed until the first `stateApplied` matches
the requested session, generation, and board exactly. The same cover returns
for a session/city replacement or a startup error; routine same-board state
generations keep the already-applied scene visible to avoid turn-by-turn
flicker. Human and AI roll gates still wait for the latest exact
acknowledgement. Stale acknowledgements from a retained native engine cannot
unlock a replacement session. A 15-second state watchdog offers localized
**Retry 3D** and **Use 2D board** actions; Retry resends the same state
generation and requests only a previously observed scene-ready token.

Flutter sends each new state generation to the native host once. If the Godot
scene is not ready yet, Android/iOS caches that payload and delivers it once on
the observed scene-ready transition; `boardReady` records readiness in Flutter
but never echoes the cached generation back. Retry is an explicit new delivery
attempt of the same generation: both native hosts replay their cached payload
exactly once and reannounce the previously observed readiness token.

Godot bootstraps Atlantic City (`usa`), matching the default setup choice, so
the common new-game path refreshes one scene instead of first building New York
and then rebuilding Atlantic City. Non-default cities still require one full
city rebuild after their first state arrives; deferring all procedural scene
construction until that payload is available remains a performance follow-up.

The default camera framing is responsive. Tablet-like landscape viewports use
a closer overview than very wide phone/desktop viewports, while portrait keeps
its dedicated full-board distance. Camera gestures remain available while dice
and pawns animate, and the chosen view persists between turns. Embedded mobile
boards suppress foreground clouds so ambient scenery cannot cover a pawn,
property, or landmark; standalone previews keep smaller clouds outside the
playable route.

World-space text uses distance-adaptive semantic zoom: tile name labels and
floating landmark labels compensate for camera distance so overview framing
stays legible, and at overview distances tile labels collapse to the name
alone — prices remain on the tap detail sheet and return when the player
zooms in. Harbor craft, piers, and buoys sit at the measured water surface
height; hulls carry a real draft below the waterline and ride a gentle bob,
so boats never hover above the water.

Changing orientation recenters the board target and refits the overview, so a
camera panned for the previous aspect ratio cannot strand the board off-screen.
Pawn plinths stay narrower than the property road. Flutter-hosted boards also
hide transient world-space `SOLD`/`BUILDING` callouts—the Flutter transaction
UI already communicates those changes without labels floating over landmarks.

Pawn tween duration scales with the physical distance between visual
waypoints, keeping route speed consistent when the 40-space game mapping spans
different numbers of the 52 rendered spots. Roll commands should include every
intervening visual waypoint so curved sections follow the road rather than a
straight chord between logical destinations. Jail, card, and teleport
movements use the same command contract: Flutter applies the logical move,
sends one typed movement command, and waits for the matching
`movementComplete`; a rejected, expired, or timed-out presentation settles
with a scene-state sync so the pawn still reaches the authoritative tile.

Property mutations are synchronized immediately after purchases, auctions,
upgrades, free-house prizes, power-ups, trades, mortgages, and unmortgages.
Godot compares the new tile payload with the previous one to animate owner
flags, miniature houses and hotels, complete-district trim, mortgage shutters,
and short status callouts without duplicating any game rules. Unchanged
development nodes are retained between syncs to avoid rebuilding detailed city
models on mobile GPUs.

New York properties additionally select one of 14 location-aware development
families from the stable logical tile index. This keeps Chinatown, Central
Park, Times Square, Wall Street, Brooklyn Bridge, Flatiron, Hudson Yards,
Empire State, the Statue of Liberty, and neighborhood architecture attached to
the correct gameplay space even when the visible location label is localized.

The Flutter splash, main menu, and two-step setup flow use a lightweight
Flutter-drawn miniature city backdrop rather than a second Godot surface. This
keeps startup immediate while matching the embedded renderer's navy, teal,
gold, water, island, skyline, and glass-panel visual language.

The Godot city catalog mirrors `CityBoardRegistry`: Atlantic City, New York
City, Los Angeles, London, Edinburgh, Manchester, Paris, Lyon, Marseille,
Tokyo, Osaka, Kyoto, Beijing, Shanghai, Hong Kong, Mexico City, Guadalajara,
and Cancún. A protocol test prevents either registry from drifting.

## Platforms

- Android uses a `GodotFragment` inside a Flutter platform view with the Godot
  4.7.1 Android library.
- iOS/iPadOS uses a SwiftGodotKit/LibGodot Metal surface inside a Flutter
  `UiKitView`. The current LibGodot binary is based on Godot 4.6, so iOS uses a
  separately exported 4.6-compatible PCK while sharing the same scene source
  and protocol. LibGodot currently supports physical iOS/iPadOS devices only;
  the iOS Simulator automatically uses the existing Flutter 2D board instead
  of showing an endless 3D loading state.

The iOS package vendors SwiftGodotKit's matching 4.6 Swift API. Its Xcode build
pre-action compiles the host-side code generator before SwiftPM invokes it,
which also works around the current Xcode 27 beta package-plugin path issue.

## Mobile renderer budget

An idle four-player Atlantic City board on an iPad Air (5th generation) held
60 FPS with no skipped frames before optimization, but Instruments measured
79–83% GPU use, about 13.6 ms average GPU active time, a 1.356 GiB peak physical
footprint, and 698.8 MiB of Metal allocation. That leaves too little thermal
and animation headroom for a release build even though the instantaneous frame
rate appears healthy. The trace also averaged about 53% of one CPU core, issued
six Metal command buffers per frame, reached 19.4 ms maximum GPU active time,
and showed roughly 62 ms CPU-to-display latency. Thermal state remained nominal
only during the short 20-second sample.

The embedded renderer therefore uses a deliberately conservative mobile
budget:

- iOS renders only the Godot `CAMetalLayer` at 75% of native pixel density
  (2x iPads use 1.5x; 3x iPhones are capped at 2x). Flutter/UIKit controls and
  text remain at native Retina resolution.
- The display link is capped at 60 FPS so ProMotion devices do not double the
  render workload for this turn-based board.
- The 3D viewport uses 2x MSAA, a 2048-pixel directional shadow map, and a
  1024-pixel positional atlas instead of 4x MSAA and two 4096-pixel atlases.
  Only the directional key light casts shadows; warm and cool fill lights
  remain unshadowed.
- Procedural cylinders use 24 radial segments instead of 48. At the supported
  camera range this keeps the stylized silhouettes round while halving their
  color- and shadow-pass vertices. Identical immutable box, cylinder, and
  sphere meshes share their resource buffers within the current city, while
  the cache is cleared on a city rebuild. Sub-0.1-unit spheres such as dice
  pips and eyes no longer enter the shadow pass.

The expected visual tradeoff is a slightly softer 3D image and marginally more
faceting on close-up cylindrical props. Board labels, Flutter HUD elements,
touch geometry, camera behavior, and game rules are unchanged. Re-run the same
Instruments capture on the physical iPad after each renderer change; the values
above are the before baseline, not a claimed post-change result.

## Refreshing the embedded projects

After changing files in `godot_3d`, run:

```sh
./tool/export_godot_android_pack.sh
GODOT_IOS_BINARY=/path/to/Godot-4.6.x ./tool/export_godot_ios_pack.sh
```

The generated packs are written to:

- `android/app/src/main/assets/godot/property_tycoon.pck`
- `ios/Runner/Godot/property_tycoon.pck`
