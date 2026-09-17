import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/config/board_factory.dart';
import 'package:property_tycoon/config/city_board_registry.dart';
import 'package:property_tycoon/integration/godot_board_contract.dart';
import 'package:property_tycoon/integration/godot_board_controller.dart';
import 'package:property_tycoon/models/game_state.dart';
import 'package:property_tycoon/models/player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('property_tycoon/godot_board_bridge');
  const codec = StandardMethodCodec();

  Future<Object?> sendNativeCall(MethodCall call) async {
    final reply = await TestDefaultBinaryMessengerBinding
        .instance
        .defaultBinaryMessenger
        .handlePlatformMessage(
          channel.name,
          codec.encodeMethodCall(call),
          null,
        );
    return reply == null ? null : codec.decodeEnvelope(reply);
  }

  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('rejected native movement falls back without waiting for timeout', () {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'animateRoll');
          return false;
        });
    final controller = GodotBoardController();
    addTearDown(controller.dispose);

    final movement = controller.animateRoll(
      const GodotRollCommand(
        sessionId: 'game_1',
        commandId: '1_player_0',
        playerId: 'player_0',
        playerIndex: 0,
        die1: 3,
        die2: 2,
        fromLogicalPosition: 0,
        toLogicalPosition: 5,
        toVisualPosition: 7,
        logicalTileCount: 40,
        visualSpotCount: 52,
        visualPath: [1, 3, 4, 5, 7],
      ),
    );

    expect(
      movement,
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('rejected'),
        ),
      ),
    );
  });

  test('roll command sends the complete visual route across GO', () {
    final city = CityBoardRegistry.all.first;
    final player = Player(
      id: 'player_0',
      name: 'Player 1',
      icon: PlayerIcon.dog,
      color: Colors.red,
      position: 37,
    );
    final state = GameState.initial(
      players: [player],
      tiles: BoardFactory.generateTiles(city),
    );
    final controller = GodotBoardController();
    addTearDown(controller.dispose);

    final command = controller.createRollCommand(
      gameState: state,
      playerIndex: 0,
      die1: 3,
      die2: 3,
    );

    expect(command.toLogicalPosition, 3);
    expect(command.visualPath, orderedEquals([49, 50, 51, 0, 1, 2, 3, 4]));
    expect(command.toVisualPosition, 4);
    expect(command.presentation, GodotMovementPresentation.standard);
    expect(command.toJson()['visualPath'], command.visualPath);
  });

  test('special move commands carry the typed presentation contract', () {
    final city = CityBoardRegistry.all.first;
    final player = Player(
      id: 'player_0',
      name: 'Player 1',
      icon: PlayerIcon.dog,
      color: Colors.red,
      position: 5,
    );
    final state = GameState.initial(
      players: [player],
      tiles: BoardFactory.generateTiles(city),
    );
    final controller = GodotBoardController();
    addTearDown(controller.dispose);

    // A reverse card walks the visual route backwards.
    final reverse = controller.createSpecialMoveCommand(
      gameState: state,
      playerIndex: 0,
      fromLogicalPosition: 5,
      toLogicalPosition: 2,
      presentation: GodotMovementPresentation.reverse,
    );
    expect(reverse.presentation, GodotMovementPresentation.reverse);
    expect(reverse.toLogicalPosition, 2);
    expect(reverse.visualPath, isNotEmpty);
    expect(reverse.visualPath.first, lessThan(7));
    expect(reverse.die1, 0);
    expect(reverse.die2, 0);
    final reverseJson = reverse.toJson();
    expect(reverseJson['presentation'], 'reverse');
    expect(reverseJson['spaces'], 3);
    expect(reverseJson['toVisualPosition'], 3);

    // Teleports and jail flights skip the route markers entirely and give the
    // native scene an explicit mapped destination visual position.
    final teleport = controller.createSpecialMoveCommand(
      gameState: state,
      playerIndex: 0,
      fromLogicalPosition: 5,
      toLogicalPosition: 24,
      presentation: GodotMovementPresentation.teleport,
    );
    expect(teleport.presentation, GodotMovementPresentation.teleport);
    expect(teleport.visualPath, isEmpty);
    expect(teleport.spaces, 0);
    expect(
      teleport.toVisualPosition,
      GodotBoardProtocol.toVisualPosition(
        logicalPosition: 24,
        logicalTileCount: state.tiles.length,
        visualSpotCount: GodotBoardProtocol.cityVisualSpotCount,
      ),
    );

    final jail = controller.createSpecialMoveCommand(
      gameState: state,
      playerIndex: 0,
      fromLogicalPosition: 30,
      toLogicalPosition: 10,
      presentation: GodotMovementPresentation.jail,
    );
    expect(jail.presentation, GodotMovementPresentation.jail);
    expect(jail.toLogicalPosition, 10);
    expect(jail.visualPath, isEmpty);

    // Forward card movement walks the route like a dice roll without dice.
    final walk = controller.createSpecialMoveCommand(
      gameState: state,
      playerIndex: 0,
      fromLogicalPosition: 5,
      toLogicalPosition: 12,
      presentation: GodotMovementPresentation.walk,
    );
    expect(walk.presentation, GodotMovementPresentation.walk);
    expect(walk.visualPath, isNotEmpty);
    expect(
      walk.visualPath.last,
      GodotBoardProtocol.toVisualPosition(
        logicalPosition: 12,
        logicalTileCount: state.tiles.length,
        visualSpotCount: GodotBoardProtocol.cityVisualSpotCount,
      ),
    );
  });

  test('movementStep events fire footstep callbacks once per waypoint', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'isAvailable') return true;
          return null;
        });
    final controller = GodotBoardController();
    addTearDown(controller.dispose);
    await controller.initialize();
    final steps = <GodotMovementStep>[];
    controller.onMovementStep = steps.add;

    Future<void> sendStep(int index) {
      return sendNativeCall(
        MethodCall('movementStep', {
          'commandId': '1_player_0',
          'playerId': 'player_0',
          'stepIndex': index,
          'totalSteps': 5,
        }),
      );
    }

    await sendStep(1);
    await sendStep(1); // Host retry for the same waypoint is suppressed.
    await sendStep(2);
    await sendStep(5);
    await sendStep(3); // Out-of-order stale waypoint is suppressed.
    expect(steps.map((step) => step.stepIndex), orderedEquals([1, 2, 5]));

    await sendNativeCall(
      MethodCall('movementComplete', {
        'commandId': '1_player_0',
        'playerId': 'player_0',
        'logicalPosition': 5,
        'visualPosition': 7,
      }),
    );
    // A step trailing its completion must never fire a cue.
    await sendStep(6);
    expect(steps, hasLength(3));
    debugDefaultTargetPlatformOverride = null;
  });

  test('setCameraFollow sends the toggle once the board is ready', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final followCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'isAvailable':
              return true;
            case 'syncState':
              return true;
            case 'setCameraFollow':
              followCalls.add(call);
              return true;
            default:
              return null;
          }
        });

    final city = CityBoardRegistry.all.first;
    final state = GameState.initial(
      players: [
        Player(
          id: 'player_0',
          name: 'Player 1',
          icon: PlayerIcon.dog,
          color: Colors.red,
        ),
      ],
      tiles: BoardFactory.generateTiles(city),
      cityBoardId: city.boardId,
    );
    final controller = GodotBoardController();
    addTearDown(controller.dispose);

    // Before the board is ready the toggle is a no-op.
    await controller.setCameraFollow(enabled: true);
    expect(followCalls, isEmpty);

    await controller.initialize();
    await controller.syncGameState(state, boardId: city.boardId);
    controller.markViewCreated();
    await sendNativeCall(
      MethodCall('stateApplied', {
        'sessionId': state.id,
        'stateGeneration': 1,
        'boardId': city.boardId,
      }),
    );
    await sendNativeCall(
      const MethodCall('boardReady', {'sceneReadyToken': 'scene-1'}),
    );
    expect(controller.isBoardReady, isTrue);

    await controller.setCameraFollow(enabled: true);
    expect(followCalls, hasLength(1));
    expect(followCalls.single.arguments, jsonEncode({'enabled': true}));

    await controller.setCameraFollow(enabled: false);
    expect(followCalls, hasLength(2));
    expect(followCalls.last.arguments, jsonEncode({'enabled': false}));
    debugDefaultTargetPlatformOverride = null;
  });

  test('setGraphicsQuality sends the tier once the board is ready', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final qualityCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'isAvailable':
              return true;
            case 'syncState':
              return true;
            case 'setGraphicsQuality':
              qualityCalls.add(call);
              return true;
            default:
              return null;
          }
        });

    final city = CityBoardRegistry.all.first;
    final state = GameState.initial(
      players: [
        Player(
          id: 'player_0',
          name: 'Player 1',
          icon: PlayerIcon.dog,
          color: Colors.red,
        ),
      ],
      tiles: BoardFactory.generateTiles(city),
      cityBoardId: city.boardId,
    );
    final controller = GodotBoardController();
    addTearDown(controller.dispose);

    await controller.setGraphicsQuality(quality: 'low');
    expect(qualityCalls, isEmpty);

    await controller.initialize();
    await controller.syncGameState(state, boardId: city.boardId);
    controller.markViewCreated();
    await sendNativeCall(
      MethodCall('stateApplied', {
        'sessionId': state.id,
        'stateGeneration': 1,
        'boardId': city.boardId,
      }),
    );
    await sendNativeCall(
      const MethodCall('boardReady', {'sceneReadyToken': 'scene-1'}),
    );

    await controller.setGraphicsQuality(quality: 'low');
    expect(qualityCalls.single.arguments, jsonEncode({'quality': 'low'}));
    debugDefaultTargetPlatformOverride = null;
  });

  test(
    'scene ready does not unlock play before exact state is applied',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final sentStates = <Map<String, Object?>>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            switch (call.method) {
              case 'isAvailable':
                return true;
              case 'syncState':
                sentStates.add(
                  (jsonDecode(call.arguments as String) as Map<String, dynamic>)
                      .cast<String, Object?>(),
                );
                return true;
              case 'retryScene':
                return false;
            }
            return null;
          });

      final city = CityBoardRegistry.all.first;
      final state = GameState.initial(
        players: [
          Player(
            id: 'player_0',
            name: 'Player 1',
            icon: PlayerIcon.dog,
            color: Colors.red,
          ),
        ],
        tiles: BoardFactory.generateTiles(city),
        cityBoardId: city.boardId,
      );
      final controller = GodotBoardController();
      addTearDown(controller.dispose);

      await controller.initialize();
      await controller.syncGameState(state, boardId: city.boardId);
      expect(sentStates, hasLength(1));
      controller.markViewCreated();
      expect(sentStates, hasLength(1));
      final requested = sentStates.last;
      expect(requested['sessionId'], state.id);
      expect(requested['stateGeneration'], 1);

      final staleResult = await sendNativeCall(
        MethodCall('stateApplied', {
          'sessionId': state.id,
          'stateGeneration': 0,
          'boardId': city.boardId,
        }),
      );
      expect(staleResult, isFalse);
      expect(controller.isBoardReady, isFalse);

      await sendNativeCall(
        MethodCall('stateApplied', {
          'sessionId': state.id,
          'stateGeneration': requested['stateGeneration'],
          'boardId': city.boardId,
        }),
      );
      expect(controller.isSceneReady, isFalse);
      expect(controller.isBoardReady, isFalse);

      final sendsBeforeSceneReady = sentStates.length;
      await sendNativeCall(
        const MethodCall('boardReady', {'sceneReadyToken': 'scene-1'}),
      );
      expect(controller.isSceneReady, isTrue);
      expect(controller.isBoardReady, isTrue);
      expect(controller.isLoading, isFalse);
      expect(sentStates, hasLength(sendsBeforeSceneReady));

      await controller.syncGameState(state, boardId: city.boardId);
      expect(controller.isBoardReady, isFalse);
      expect(controller.isSynchronizing, isTrue);
      expect(controller.isLoading, isFalse);
      expect(sentStates.last['stateGeneration'], 2);
      expect(sentStates, hasLength(2));

      await controller.retryStateApplication();
      expect(sentStates.last['stateGeneration'], 2);
      expect(sentStates, hasLength(3));
    },
  );

  test('boardReady before stateApplied does not resend cached state', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final sentStates = <Map<String, Object?>>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'isAvailable') return true;
          if (call.method == 'syncState') {
            sentStates.add(
              (jsonDecode(call.arguments as String) as Map<String, dynamic>)
                  .cast<String, Object?>(),
            );
            return true;
          }
          return null;
        });

    final city = CityBoardRegistry.all.first;
    final state = GameState.initial(
      players: [
        Player(
          id: 'player_0',
          name: 'Player 1',
          icon: PlayerIcon.dog,
          color: Colors.red,
        ),
      ],
      tiles: BoardFactory.generateTiles(city),
      cityBoardId: city.boardId,
    );
    final controller = GodotBoardController();
    addTearDown(controller.dispose);

    await controller.initialize();
    await controller.syncGameState(state, boardId: city.boardId);
    controller.markViewCreated();
    expect(sentStates, hasLength(1));

    await sendNativeCall(
      const MethodCall('boardReady', {'sceneReadyToken': 'scene-1'}),
    );
    expect(controller.isSceneReady, isTrue);
    expect(controller.isBoardReady, isFalse);
    expect(sentStates, hasLength(1));

    await sendNativeCall(
      MethodCall('stateApplied', {
        'sessionId': state.id,
        'stateGeneration': 1,
        'boardId': city.boardId,
      }),
    );
    expect(controller.isBoardReady, isTrue);
    expect(sentStates, hasLength(1));
  });

  testWidgets('startup watchdog bounds a platform view that never starts', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'isAvailable' || call.method == 'syncState') {
            return true;
          }
          if (call.method == 'retryScene') return false;
          return null;
        });

    final city = CityBoardRegistry.all.first;
    final state = GameState.initial(
      players: [
        Player(
          id: 'player_0',
          name: 'Player 1',
          icon: PlayerIcon.dog,
          color: Colors.red,
        ),
      ],
      tiles: BoardFactory.generateTiles(city),
      cityBoardId: city.boardId,
    );
    final controller = GodotBoardController(
      stateApplyTimeout: const Duration(milliseconds: 100),
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    await controller.syncGameState(state, boardId: city.boardId);
    await tester.pump(const Duration(milliseconds: 101));

    expect(controller.stateApplyError, GodotBoardStateApplyError.timedOut);
    expect(controller.isLoading, isTrue);

    controller.continueIn2D();
    expect(controller.stateApplyError, isNull);
    expect(controller.isLoading, isFalse);
    await tester.pump(const Duration(seconds: 1));
    expect(controller.stateApplyError, isNull);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets(
    'early stateApplied keeps recovery until view and scene are ready',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      var stateSendCount = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'isAvailable') return true;
            if (call.method == 'syncState') {
              stateSendCount++;
              return true;
            }
            return null;
          });

      final city = CityBoardRegistry.all.first;
      final state = GameState.initial(
        players: [
          Player(
            id: 'player_0',
            name: 'Player 1',
            icon: PlayerIcon.dog,
            color: Colors.red,
          ),
        ],
        tiles: BoardFactory.generateTiles(city),
        cityBoardId: city.boardId,
      );
      final controller = GodotBoardController(
        stateApplyTimeout: const Duration(milliseconds: 100),
      );
      addTearDown(controller.dispose);

      await controller.initialize();
      await controller.syncGameState(state, boardId: city.boardId);
      await tester.pump(const Duration(milliseconds: 101));
      expect(controller.stateApplyError, GodotBoardStateApplyError.timedOut);

      await sendNativeCall(
        MethodCall('stateApplied', {
          'sessionId': state.id,
          'stateGeneration': 1,
          'boardId': city.boardId,
        }),
      );
      expect(controller.stateApplyError, GodotBoardStateApplyError.timedOut);
      expect(controller.isLoading, isTrue);

      await sendNativeCall(
        const MethodCall('boardReady', {'sceneReadyToken': 'scene-1'}),
      );
      expect(controller.stateApplyError, GodotBoardStateApplyError.timedOut);
      expect(controller.isBoardReady, isFalse);
      expect(stateSendCount, 1);

      controller.markViewCreated();
      expect(controller.isBoardReady, isTrue);
      expect(controller.stateApplyError, isNull);
      expect(controller.isLoading, isFalse);
      expect(stateSendCount, 1);
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets('native availability wait is bounded', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final availability = Completer<bool>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
          if (call.method == 'isAvailable') return availability.future;
          return null;
        });
    final controller = GodotBoardController(
      stateApplyTimeout: const Duration(milliseconds: 100),
    );
    addTearDown(controller.dispose);

    final initialization = controller.initialize();
    await tester.pump(const Duration(milliseconds: 101));
    await initialization;
    availability.complete(true);

    expect(controller.isAvailable, isFalse);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('hung native retry keeps recovery bounded', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final retryReply = Completer<bool>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
          if (call.method == 'isAvailable' || call.method == 'syncState') {
            return Future.value(true);
          }
          if (call.method == 'retryScene') return retryReply.future;
          return null;
        });

    final city = CityBoardRegistry.all.first;
    final state = GameState.initial(
      players: [
        Player(
          id: 'player_0',
          name: 'Player 1',
          icon: PlayerIcon.dog,
          color: Colors.red,
        ),
      ],
      tiles: BoardFactory.generateTiles(city),
      cityBoardId: city.boardId,
    );
    final controller = GodotBoardController(
      stateApplyTimeout: const Duration(milliseconds: 100),
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    await controller.syncGameState(state, boardId: city.boardId);
    await tester.pump(const Duration(milliseconds: 101));
    expect(controller.stateApplyError, GodotBoardStateApplyError.timedOut);

    final retry = controller.retryStateApplication();
    expect(controller.stateApplyError, isNull);
    await tester.pump(const Duration(milliseconds: 101));
    await retry;
    expect(controller.stateApplyError, GodotBoardStateApplyError.timedOut);
    expect(controller.isLoading, isTrue);

    retryReply.complete(true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('hung state sync times out and releases its caller', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final syncReply = Completer<bool>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
          if (call.method == 'isAvailable') return Future.value(true);
          if (call.method == 'syncState') return syncReply.future;
          return null;
        });

    final city = CityBoardRegistry.all.first;
    final state = GameState.initial(
      players: [
        Player(
          id: 'player_0',
          name: 'Player 1',
          icon: PlayerIcon.dog,
          color: Colors.red,
        ),
      ],
      tiles: BoardFactory.generateTiles(city),
      cityBoardId: city.boardId,
    );
    final controller = GodotBoardController(
      stateApplyTimeout: const Duration(milliseconds: 100),
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    var completed = false;
    final sync = controller
        .syncGameState(state, boardId: city.boardId)
        .whenComplete(() => completed = true);
    await tester.pump();
    expect(completed, isFalse);

    await tester.pump(const Duration(milliseconds: 101));
    await sync;
    expect(completed, isTrue);
    expect(controller.stateApplyError, GodotBoardStateApplyError.timedOut);

    syncReply.complete(true);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Use 2D releases a hung state sync immediately', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final syncReply = Completer<bool>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
          if (call.method == 'isAvailable') return Future.value(true);
          if (call.method == 'syncState') return syncReply.future;
          return null;
        });

    final city = CityBoardRegistry.all.first;
    final state = GameState.initial(
      players: [
        Player(
          id: 'player_0',
          name: 'Player 1',
          icon: PlayerIcon.dog,
          color: Colors.red,
        ),
      ],
      tiles: BoardFactory.generateTiles(city),
      cityBoardId: city.boardId,
    );
    final controller = GodotBoardController(
      stateApplyTimeout: const Duration(minutes: 1),
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    var completed = false;
    final sync = controller
        .syncGameState(state, boardId: city.boardId)
        .whenComplete(() => completed = true);
    await tester.pump();
    expect(completed, isFalse);

    controller.continueIn2D();
    await sync;
    expect(completed, isTrue);
    expect(controller.stateApplyError, isNull);
    expect(controller.isLoading, isFalse);

    syncReply.complete(true);
    debugDefaultTargetPlatformOverride = null;
  });

  test('disposed view callbacks cannot resend an old session', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    var stateSendCount = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'isAvailable') return true;
          if (call.method == 'syncState') {
            stateSendCount++;
            return true;
          }
          return null;
        });

    final city = CityBoardRegistry.all.first;
    final state = GameState.initial(
      players: [
        Player(
          id: 'player_0',
          name: 'Player 1',
          icon: PlayerIcon.dog,
          color: Colors.red,
        ),
      ],
      tiles: BoardFactory.generateTiles(city),
      cityBoardId: city.boardId,
    );
    final controller = GodotBoardController();

    await controller.initialize();
    await controller.syncGameState(state, boardId: city.boardId);
    expect(stateSendCount, 1);

    controller.dispose();
    controller.markViewCreated();
    await controller.syncGameState(state, boardId: city.boardId);
    expect(stateSendCount, 1);
  });
}
