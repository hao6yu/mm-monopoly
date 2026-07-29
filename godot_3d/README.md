# Property Tycoon 3D — World City Theme Parks

This Godot 4 project renders the native 3D board inside the existing Flutter
game. Flutter remains the rules engine; Godot owns the real-time city, dice,
camera, character pieces, and movement presentation.

## Run

From the Flutter repository root:

```bash
../.tools/Godot.app/Contents/MacOS/Godot --path godot_3d
```

## Controls

- Press **Roll Dice** or the space bar to roll and move the active player's
  matching-color token.
- Drag with the right mouse button to orbit the camera.
- Use the mouse wheel to zoom.
- Press **R** to reset the camera.
- Press **F12** to save a screenshot to `preview/initial_build.png`.

The renderer contains theme-park maps for all 18 city boards:

- Atlantic City, New York City, and Los Angeles
- London, Edinburgh, and Manchester
- Paris, Lyon, and Marseille
- Tokyo, Osaka, and Kyoto
- Beijing, Shanghai, and Hong Kong
- Mexico City, Guadalajara, and Cancún

Every city has a 52-location irregular route, a distinct terrain silhouette and
palette, at least five recognizable landmarks, extra scenic stops, clouds, and
city-appropriate environmental details. Coastal boat traffic is constrained to
explicit water-only lanes outside the property route and dice platform.

Manhattan remains the hand-authored flagship map, with Central Park, Midtown,
Downtown, the Statue of Liberty, Brooklyn Bridge, piers, and multiple harbor
lanes. The other cities use the shared procedural theme-park framework so their
gameplay, camera, dice, and Flutter bridge behave consistently.

The scene supports 2–4 color-matched miniature character pieces through the
`active_player_count` exported property. Four are enabled by default for the
showcase build, and turns rotate automatically after movement finishes.

The presentation is intentionally focused on the large table and board, without
full-size human characters or chairs. After a roll, the active miniature turns
toward its path and hops from space to space until it reaches its destination.

The miniature city models are from Kenney's CC0 City Kit (Commercial). See the
license file next to the model assets.

## Validation

```bash
../.tools/Godot.app/Contents/MacOS/Godot \
  --headless \
  --path godot_3d \
  --script res://tests/bridge_smoke.gd
```

The smoke suite rebuilds every city, verifies its landmarks, 52-stop route,
localized Flutter labels, players, dice, camera bridge, movement completion,
and water-only boat lanes.
