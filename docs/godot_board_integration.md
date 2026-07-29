# Flutter–Godot board integration

Flutter is the source of truth for game rules, players, money, dice, tile
resolution, and turn order. Godot renders all 18 city theme parks and performs
the camera, dice, and movement animation.

## Protocol v1

Flutter sends:

- `scene_state`: board ID, localized tile names, logical tile count, visual
  spot count, current turn, dice, and player state.
- `animate_roll`: dice values, logical start/destination, and a mapped visual
  path.

Godot returns:

- `boardReady`: the runtime plugin and GDScript scene are connected.
- `movementComplete`: the command ID, player ID, logical destination, and
  visual destination.

Every board maps Flutter's 40 logical tiles onto 52 visual locations. The 12
additional locations receive city-specific scenic names. Flutter resolves the
landing tile only after the matching movement-complete event returns.

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
