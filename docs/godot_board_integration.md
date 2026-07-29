# Flutter–Godot board integration

Flutter is the source of truth for game rules, players, money, dice, tile
resolution, and turn order. Godot renders all 18 city theme parks and performs
the camera, dice, and movement animation.

## Protocol v1

Flutter sends:

- `scene_state`: board ID, localized tile names and types, prices, ownership,
  upgrades, mortgage state, logical tile count, visual spot count, current
  turn, dice, and player state.
- `animate_roll`: dice values, logical start/destination, and a mapped visual
  path. Godot uses that path for the route preview, destination beacon, dice
  focus, movement camera, and landing reaction before returning completion.
- `camera_gesture`: orbit, pinch zoom, and reset-view commands.
- `board_tap`: normalized view coordinates for interactive object picking.

Godot returns:

- `boardReady`: the runtime plugin and GDScript scene are connected.
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

## Refreshing the embedded projects

After changing files in `godot_3d`, run:

```sh
./tool/export_godot_android_pack.sh
GODOT_IOS_BINARY=/path/to/Godot-4.6.x ./tool/export_godot_ios_pack.sh
```

The generated packs are written to:

- `android/app/src/main/assets/godot/property_tycoon.pck`
- `ios/Runner/Godot/property_tycoon.pck`
