import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:property_tycoon/config/board_factory.dart';
import 'package:property_tycoon/config/city_board_registry.dart';
import 'package:property_tycoon/integration/godot_board_controller.dart';
import 'package:property_tycoon/models/game_state.dart';
import 'package:property_tycoon/models/player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('property_tycoon/godot_board_bridge');

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('resetForNewSession clears the 2D fallback and preparation error', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'isAvailable':
            case 'syncState':
              return true;
            case 'animateRoll':
              return false;
            default:
              return null;
          }
        });
    final controller = GodotBoardController();
    addTearDown(controller.dispose);

    await controller.initialize();
    await controller.syncGameState(
      _minimalState(),
      boardId: 'usa_new_york',
    );
    controller.continueIn2D();
    expect(controller.is2DFallback, isTrue);

    // A new session (Continue / New Game / Replay) starts clean: a past
    // preparation failure or 2D choice must not pin later sessions to 2D.
    controller.resetForNewSession();
    expect(controller.is2DFallback, isFalse);
    expect(controller.stateApplyError, isNull);
    debugDefaultTargetPlatformOverride = null;
  });

  test('setBoardVisible forwards the flag once the board is available', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final visibilityCalls = <bool>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'isAvailable') return true;
          if (call.method == 'setBoardVisible') {
            final payload =
                (call.arguments as String).contains('"visible":true');
            visibilityCalls.add(payload);
            return true;
          }
          return null;
        });
    final controller = GodotBoardController();
    addTearDown(controller.dispose);

    // No native host yet: the toggle must be a harmless no-op.
    await controller.setBoardVisible(visible: false);
    expect(visibilityCalls, isEmpty);

    await controller.initialize();
    await controller.setBoardVisible(visible: false);
    await controller.setBoardVisible(visible: true);
    expect(visibilityCalls, orderedEquals([false, true]));
    debugDefaultTargetPlatformOverride = null;
  });
}

GameState _minimalState() {
  final city = CityBoardRegistry.all.first;
  return GameState.initial(
    players: [
      Player(
        id: 'player_0',
        name: 'Player 1',
        icon: PlayerIcon.dog,
        color: const Color(0xFFFF4F5E),
      ),
    ],
    tiles: BoardFactory.generateTiles(city),
    cityBoardId: city.boardId,
  );
}
