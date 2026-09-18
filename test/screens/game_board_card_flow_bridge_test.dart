import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/config/board_factory.dart';
import 'package:property_tycoon/config/city_board_registry.dart';
import 'package:property_tycoon/config/constants.dart';
import 'package:property_tycoon/controllers/game_session_controller.dart';
import 'package:property_tycoon/integration/godot_board_contract.dart';
import 'package:property_tycoon/l10n/app_localizations.dart';
import 'package:property_tycoon/models/game_state.dart';
import 'package:property_tycoon/models/player.dart';
import 'package:property_tycoon/models/tile.dart';
import 'package:property_tycoon/screens/game_board_screen.dart';
import 'package:property_tycoon/widgets/dialogs/buy_property_dialog.dart';
import 'package:property_tycoon/widgets/dialogs/card_pick_dialog.dart';

/// Delivers a native-side callback into the Dart channel handler, exactly as
/// the iOS/Android host plugin does.
Future<Object?> emulateNativeCall(
  MethodChannel channel,
  MethodCall call,
) {
  const codec = StandardMethodCodec();
  return TestDefaultBinaryMessengerBinding
      .instance
      .defaultBinaryMessenger
      .handlePlatformMessage(
        channel.name,
        codec.encodeMethodCall(call),
        null,
      )
      .then(
        (reply) => reply == null ? null : codec.decodeEnvelope(reply),
      );
}

/// Fake native host: records the exact Dart→native call order and owns
/// movement completion so tests can gate, delay, reject, or drop it.
class FakeNativeBoardHost {
  final List<String> recordedCalls = [];
  final List<Map<String, dynamic>> animatePayloads = [];
  final List<Map<String, dynamic>> sentStates = [];
  final List<String> qualityTiers = [];
  bool rejectAnimateRoll = false;
  bool holdMovementComplete = false;
  bool _sceneReadyAnnounced = false;
  Map<String, dynamic>? _heldMovement;

  Map<String, dynamic> get singleAnimatePayload {
    expect(animatePayloads, hasLength(1));
    return animatePayloads.single;
  }

  Future<Object?> handle(MethodCall call) async {
    switch (call.method) {
      case 'isAvailable':
        return true;
      case 'syncState':
        recordedCalls.add('syncState');
        final state =
            jsonDecode(call.arguments as String) as Map<String, dynamic>;
        sentStates.add(state);
        // The real host applies the state in Godot, then acknowledges the
        // exact session/generation/board triple before returning.
        await emulateNativeCall(
          godotBridgeChannel,
          MethodCall('stateApplied', {
            'sessionId': state['sessionId'],
            'stateGeneration': state['stateGeneration'],
            'boardId': state['boardId'],
          }),
        );
        // A fresh session (generation 1) means a newly created native view:
        // readiness is observed from the scene itself, per contract.
        if (!_sceneReadyAnnounced || state['stateGeneration'] == 1) {
          _sceneReadyAnnounced = true;
          await emulateNativeCall(
            godotBridgeChannel,
            const MethodCall('boardReady', {'sceneReadyToken': 'fake-scene'}),
          );
        }
        return true;
      case 'animateRoll':
        recordedCalls.add('animateRoll');
        final payload =
            jsonDecode(call.arguments as String) as Map<String, dynamic>;
        animatePayloads.add(payload);
        if (rejectAnimateRoll) return false;
        _heldMovement = payload;
        if (!holdMovementComplete) {
          await completePendingMovement();
        }
        return true;
      case 'setGraphicsQuality':
        qualityTiers.add(
          (jsonDecode(call.arguments as String)
              as Map<String, dynamic>)['quality'] as String,
        );
        return true;
      default:
        return null;
    }
  }

  /// Emulates the scene finishing the held movement command.
  Future<void> completePendingMovement() async {
    final payload = _heldMovement;
    if (payload == null) return;
    _heldMovement = null;
    await emulateNativeCall(
      godotBridgeChannel,
      MethodCall('movementComplete', {
        'commandId': payload['commandId'],
        'playerId': payload['playerId'],
        'logicalPosition': payload['toLogicalPosition'],
        'visualPosition': payload['toVisualPosition'],
      }),
    );
  }
}

const godotBridgeChannel = MethodChannel('property_tycoon/godot_board_bridge');
const platformViewsChannel = MethodChannel('flutter/platform_views');

/// Drives the real [GameBoardScreen] card-selection flow against a ready
/// native-board bridge.
///
/// The fake host emulates the native plugin contract end to end: availability,
/// platform-view creation, observed scene readiness, exact-generation state
/// acknowledgements, and scoped movement completion. Unlike the 2D-fallback
/// card-flow tests, these tests prove the orchestration itself:
///
/// - the movement command is sent, accepted, and completes BEFORE the
///   destination state sync;
/// - landing resolution runs only for cards that request it and only after
///   movement completes;
/// - a rejected or timed-out movement degrades to the deterministic state
///   sync without stranding the pawn or the turn; and
/// - a completion arriving after the session was replaced is inert.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final host = FakeNativeBoardHost();

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(godotBridgeChannel, host.handle);
    // Allow the real UiKitView platform-view creation callback to fire so the
    // screen's own GodotBoardHost marks the native view created.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platformViewsChannel, (call) async {
          return null;
        });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(godotBridgeChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platformViewsChannel, null);
    host.rejectAnimateRoll = false;
    host.holdMovementComplete = false;
    host.recordedCalls.clear();
    host.animatePayloads.clear();
    host.sentStates.clear();
    host.qualityTiers.clear();
  });

  Future<GameBoardScreenState> pumpBoard(WidgetTester tester) async {
    final city = CityBoardRegistry.byBoardId('usa_new_york')!;
    final players = [
      Player(id: 'player_0', name: 'Mia', icon: PlayerIcon.dog, color: Colors.red),
      Player(
        id: 'player_1',
        name: 'Noah',
        icon: PlayerIcon.car,
        color: Colors.blue,
      ),
    ];
    final tiles = BoardFactory.generateTiles(city);
    final state = GameState.initial(
      players: players,
      tiles: tiles,
      cityBoardId: city.boardId,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GameBoardScreen(
          session: GameSessionController(state),
          cityBoard: city,
          boardTheme: BoardFactory.getThemeForCityBoard(city),
          onQuit: () {},
          onRestart: () {},
          onGameFinished: (_) {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 250));

    final screenState = tester.state<GameBoardScreenState>(
      find.byType(GameBoardScreen),
    );
    expect(
      screenState.is3DBoardReadyForTesting,
      isTrue,
      reason: 'the fake native board must reach readiness before the flow '
          'starts; otherwise these tests silently cover the 2D fallback',
    );
    return screenState;
  }

  /// The flow's audio ducking schedules an 800 ms timer; expire it so the
  /// test ends without pending timers.
  Future<void> flushAudioTimers(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 900));
  }

  TileData tileOfType(GameState state, TileType type) {
    return state.tiles.firstWhere((tile) => tile.type == type);
  }

  int visualFor(GameState state, int logicalPosition) {
    return GodotBoardProtocol.toVisualPosition(
      logicalPosition: logicalPosition,
      logicalTileCount: state.tiles.length,
      visualSpotCount: GodotBoardProtocol.cityVisualSpotCount,
    );
  }

  void expectMovementCommandOrdering({required bool expectFallbackSync}) {
    // The initial board sync, then the movement command, then — and only
    // then — anything else. A successful presentation carries the
    // destination inside the command, so no immediate destination sync
    // follows it; a failed presentation must settle through the
    // authoritative state sync instead of stranding the pawn.
    if (expectFallbackSync) {
      expect(host.recordedCalls, ['syncState', 'animateRoll', 'syncState']);
      expect(host.sentStates, hasLength(2));
      expect(host.sentStates.last['stateGeneration'], 2);
    } else {
      expect(host.recordedCalls, ['syncState', 'animateRoll']);
      expect(host.sentStates, hasLength(1));
    }
  }

  void resetPlatformOverride() {
    debugDefaultTargetPlatformOverride = null;
  }

  testWidgets(
    'forward card walks across GO on the ready board before the destination sync',
    (tester) async {
      final screenState = await pumpBoard(tester);
      expect(host.qualityTiers, ['high']);
      final gameState = screenState.gameState;
      final player = gameState.players.first;
      final chanceTile = tileOfType(gameState, TileType.chance);
      // Five steps forward from here lands exactly on GO.
      player.position = gameState.tiles.length - 5;
      final goBonus = gameState.getGoBonusForPlayer(player.id);
      final cashBefore = player.cash;

      final flow = screenState.drawCardForTesting(player, chanceTile);
      await tester.pump();
      expect(screenState.waitingForCardPickForTesting, isTrue);

      screenState.handlePickedCardForTesting(
        const PickableCard(text: '🎲', effect: '+5', action: 'forward5'),
      );
      await flow;
      await flushAudioTimers(tester);

      expectMovementCommandOrdering(expectFallbackSync: false);
      final payload = host.singleAnimatePayload;
      expect(payload['presentation'], GodotMovementPresentation.walk);
      expect(payload['fromLogicalPosition'], gameState.tiles.length - 5);
      expect(payload['toLogicalPosition'], 0);
      expect(payload['spaces'], 5);
      expect(payload['die1'], 0);
      expect(payload['die2'], 0);
      final visualPath = (payload['visualPath'] as List).cast<int>();
      expect(visualPath, isNotEmpty);
      expect(visualPath.last, visualFor(gameState, 0));

      expect(player.position, 0);
      expect(player.cash, cashBefore + goBonus);
      expect(screenState.waitingForCardPickForTesting, isFalse);
      expect(tester.takeException(), isNull);
      resetPlatformOverride();
    },
  );

  testWidgets(
    'reverse card walks backwards without a GO bonus before the destination sync',
    (tester) async {
      final screenState = await pumpBoard(tester);
      final gameState = screenState.gameState;
      final player = gameState.players.first;
      final chanceTile = tileOfType(gameState, TileType.chance);
      // Five steps back from here lands exactly on GO.
      player.position = 5;
      final cashBefore = player.cash;

      final flow = screenState.drawCardForTesting(player, chanceTile);
      await tester.pump();

      screenState.handlePickedCardForTesting(
        const PickableCard(text: '🎲', effect: '-5', action: 'back5'),
      );
      await flow;
      await flushAudioTimers(tester);

      expectMovementCommandOrdering(expectFallbackSync: false);
      final payload = host.singleAnimatePayload;
      expect(payload['presentation'], GodotMovementPresentation.reverse);
      expect(payload['fromLogicalPosition'], 5);
      expect(payload['toLogicalPosition'], 0);
      expect(payload['spaces'], 5);
      final visualPath = (payload['visualPath'] as List).cast<int>();
      expect(visualPath, isNotEmpty);
      expect(visualPath.last, visualFor(gameState, 0));

      expect(player.position, 0);
      // Reversing across GO must not award the bonus.
      expect(player.cash, cashBefore);
      expect(tester.takeException(), isNull);
      resetPlatformOverride();
    },
  );

  testWidgets(
    'nearest railroad card walks to the owned railroad and resolves nothing',
    (tester) async {
      final screenState = await pumpBoard(tester);
      final gameState = screenState.gameState;
      final player = gameState.players.first;
      final chanceTile = tileOfType(gameState, TileType.chance);
      final tileCount = gameState.tiles.length;
      final railroadIndex = gameState.tiles.indexWhere(
        (tile) => tile.type == TileType.railroad,
      );
      expect(railroadIndex, greaterThan(0));
      // Own the destination so the landing resolves to nothing.
      (gameState.tiles[railroadIndex] as RailroadTileData).ownerId = player.id;
      // One step before the railroad so the nearest scan lands on it.
      player.position = (railroadIndex - 1 + tileCount) % tileCount;

      final flow = screenState.drawCardForTesting(player, chanceTile);
      await tester.pump();

      screenState.handlePickedCardForTesting(
        const PickableCard(
          text: '🎲',
          effect: '🚂',
          action: 'nearestRailroad',
        ),
      );
      await flow;
      await flushAudioTimers(tester);

      expectMovementCommandOrdering(expectFallbackSync: false);
      final payload = host.singleAnimatePayload;
      expect(payload['presentation'], GodotMovementPresentation.walk);
      expect(payload['fromLogicalPosition'], railroadIndex - 1);
      expect(payload['toLogicalPosition'], railroadIndex);
      final visualPath = (payload['visualPath'] as List).cast<int>();
      expect(visualPath, isNotEmpty);
      expect(visualPath.last, visualFor(gameState, railroadIndex));

      expect(player.position, railroadIndex);
      expect(find.byType(BuyPropertyDialog), findsNothing);
      expect(tester.takeException(), isNull);
      resetPlatformOverride();
    },
  );

  testWidgets(
    'nearest utility card walks to the owned utility and resolves nothing',
    (tester) async {
      final screenState = await pumpBoard(tester);
      final gameState = screenState.gameState;
      final player = gameState.players.first;
      final chanceTile = tileOfType(gameState, TileType.chance);
      final tileCount = gameState.tiles.length;
      final utilityIndex = gameState.tiles.indexWhere(
        (tile) => tile.type == TileType.utility,
      );
      expect(utilityIndex, greaterThan(0));
      (gameState.tiles[utilityIndex] as UtilityTileData).ownerId = player.id;
      player.position = (utilityIndex - 1 + tileCount) % tileCount;

      final flow = screenState.drawCardForTesting(player, chanceTile);
      await tester.pump();

      screenState.handlePickedCardForTesting(
        const PickableCard(
          text: '🎲',
          effect: '💡',
          action: 'nearestUtility',
        ),
      );
      await flow;
      await flushAudioTimers(tester);

      expectMovementCommandOrdering(expectFallbackSync: false);
      final payload = host.singleAnimatePayload;
      expect(payload['presentation'], GodotMovementPresentation.walk);
      expect(payload['toLogicalPosition'], utilityIndex);
      final visualPath = (payload['visualPath'] as List).cast<int>();
      expect(visualPath, isNotEmpty);
      expect(visualPath.last, visualFor(gameState, utilityIndex));

      expect(player.position, utilityIndex);
      expect(find.byType(BuyPropertyDialog), findsNothing);
      expect(tester.takeException(), isNull);
      resetPlatformOverride();
    },
  );

  testWidgets(
    'Advance to GO flies without route markers and skips landing resolution',
    (tester) async {
      final screenState = await pumpBoard(tester);
      final gameState = screenState.gameState;
      final player = gameState.players.first;
      final chanceTile = tileOfType(gameState, TileType.chance);
      player.position = 7;
      final goBonus = gameState.getGoBonusForPlayer(player.id);
      final cashBefore = player.cash;

      final flow = screenState.drawCardForTesting(player, chanceTile);
      await tester.pump();

      screenState.handlePickedCardForTesting(
        const PickableCard(text: '🎲', effect: 'GO', action: 'advanceGo'),
      );
      await flow;
      await flushAudioTimers(tester);

      expectMovementCommandOrdering(expectFallbackSync: false);
      final payload = host.singleAnimatePayload;
      expect(payload['presentation'], GodotMovementPresentation.teleport);
      expect(payload['fromLogicalPosition'], 7);
      expect(payload['toLogicalPosition'], 0);
      // Flights carry an explicit destination and no route waypoints.
      expect(payload['spaces'], 0);
      expect(payload['visualPath'], isEmpty);
      expect(payload['toVisualPosition'], visualFor(gameState, 0));

      expect(player.position, 0);
      expect(player.cash, cashBefore + goBonus);
      expect(player.jailTurnsRemaining, 0);
      // resolveLanding is false for Advance to GO: no landing dialog and no
      // extra bridge traffic beyond the authoritative sync.
      expect(find.byType(BuyPropertyDialog), findsNothing);
      expect(host.recordedCalls, hasLength(2));
      expect(tester.takeException(), isNull);
      resetPlatformOverride();
    },
  );

  testWidgets(
    'Go To Jail flies the escort without route markers and skips landing resolution',
    (tester) async {
      final screenState = await pumpBoard(tester);
      final gameState = screenState.gameState;
      final player = gameState.players.first;
      final chanceTile = tileOfType(gameState, TileType.chance);
      player.position = 7;

      final flow = screenState.drawCardForTesting(player, chanceTile);
      await tester.pump();

      screenState.handlePickedCardForTesting(
        const PickableCard(text: '🎲', effect: '🔒', action: 'goToJail'),
      );
      await flow;
      await flushAudioTimers(tester);

      expectMovementCommandOrdering(expectFallbackSync: false);
      final payload = host.singleAnimatePayload;
      expect(payload['presentation'], GodotMovementPresentation.jail);
      expect(payload['fromLogicalPosition'], 7);
      expect(payload['toLogicalPosition'], GameConstants.jailPosition);
      expect(payload['spaces'], 0);
      expect(payload['visualPath'], isEmpty);
      expect(
        payload['toVisualPosition'],
        visualFor(gameState, GameConstants.jailPosition),
      );

      expect(player.position, GameConstants.jailPosition);
      expect(player.jailTurnsRemaining, 1);
      // resolveLanding is false for Go To Jail: visiting jail must not open
      // a landing dialog.
      expect(find.byType(BuyPropertyDialog), findsNothing);
      expect(host.recordedCalls, hasLength(2));
      expect(tester.takeException(), isNull);
      resetPlatformOverride();
    },
  );

  testWidgets(
    'landing resolution waits for movement completion',
    (tester) async {
      final screenState = await pumpBoard(tester);
      final gameState = screenState.gameState;
      final player = gameState.players.first;
      final chanceTile = tileOfType(gameState, TileType.chance);
      final tileCount = gameState.tiles.length;
      final railroadIndex = gameState.tiles.indexWhere(
        (tile) => tile.type == TileType.railroad,
      );
      // Leave the destination unowned: the landing must open the purchase
      // dialog, but only once the movement command has completed.
      player.position = (railroadIndex - 1 + tileCount) % tileCount;

      host.holdMovementComplete = true;
      // Intentionally unawaited: the flow stays parked on the purchase
      // decision dialog for the rest of the test.
      unawaited(screenState.drawCardForTesting(player, chanceTile));
      await tester.pump();
      screenState.handlePickedCardForTesting(
        const PickableCard(
          text: '🎲',
          effect: '🚂',
          action: 'nearestRailroad',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // The logical move is applied and the command is on the native board,
      // but nothing else has happened: no destination sync, no landing.
      expect(host.recordedCalls, ['syncState', 'animateRoll']);
      expect(host.sentStates, hasLength(1));
      expect(player.position, railroadIndex);
      expect(find.byType(BuyPropertyDialog), findsNothing);

      // The native scene completes the movement; only now may the landing
      // resolution run.
      host.holdMovementComplete = false;
      await host.completePendingMovement();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(BuyPropertyDialog), findsOneWidget);
      expect(host.recordedCalls, ['syncState', 'animateRoll']);
      expect(tester.takeException(), isNull);
      resetPlatformOverride();
      // Leave the dialog open on purpose: the flow is parked on the human
      // purchase decision, exactly like a real turn.
    },
  );

  testWidgets(
    'rejected movement falls back to the destination sync without stranding the turn',
    (tester) async {
      final screenState = await pumpBoard(tester);
      final gameState = screenState.gameState;
      final player = gameState.players.first;
      final chanceTile = tileOfType(gameState, TileType.chance);
      player.position = 7;

      host.rejectAnimateRoll = true;
      final flow = screenState.drawCardForTesting(player, chanceTile);
      await tester.pump();
      screenState.handlePickedCardForTesting(
        const PickableCard(text: '🎲', effect: 'GO', action: 'advanceGo'),
      );
      await flow;
      await flushAudioTimers(tester);

      // The board rejected the command; the pawn still reaches the
      // authoritative tile through the state sync.
      expectMovementCommandOrdering(expectFallbackSync: true);
      expect(player.position, 0);
      expect(screenState.waitingForCardPickForTesting, isFalse);
      expect(screenState.is3DBoardReadyForTesting, isTrue);
      expect(tester.takeException(), isNull);
      resetPlatformOverride();
    },
  );

  testWidgets(
    'movement completion timeout settles through the destination sync',
    (tester) async {
      final screenState = await pumpBoard(tester);
      final gameState = screenState.gameState;
      final player = gameState.players.first;
      final chanceTile = tileOfType(gameState, TileType.chance);
      player.position = 7;

      // Accept the command but never complete it: Godot cancels hosted
      // movements at 9.5 s and the bridge adds a short margin.
      host.holdMovementComplete = true;
      final flow = screenState.drawCardForTesting(player, chanceTile);
      await tester.pump();
      screenState.handlePickedCardForTesting(
        const PickableCard(text: '🎲', effect: 'GO', action: 'advanceGo'),
      );
      await tester.pump();
      expect(host.recordedCalls, ['syncState', 'animateRoll']);

      await tester.pump(const Duration(seconds: 10));
      await flow;
      await flushAudioTimers(tester);

      expectMovementCommandOrdering(expectFallbackSync: true);
      expect(player.position, 0);
      expect(screenState.waitingForCardPickForTesting, isFalse);
      expect(screenState.is3DBoardReadyForTesting, isTrue);
      expect(tester.takeException(), isNull);
      resetPlatformOverride();
    },
  );

  testWidgets(
    'completion arriving after the session was replaced is inert',
    (tester) async {
      final screenState = await pumpBoard(tester);
      final gameState = screenState.gameState;
      final player = gameState.players.first;
      final chanceTile = tileOfType(gameState, TileType.chance);
      player.position = gameState.tiles.length - 5;
      final originalSessionId = host.sentStates.last['sessionId'];

      host.holdMovementComplete = true;
      final flow = screenState.drawCardForTesting(player, chanceTile);
      await tester.pump();
      screenState.handlePickedCardForTesting(
        const PickableCard(text: '🎲', effect: '+5', action: 'forward5'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(host.recordedCalls, ['syncState', 'animateRoll']);

      // Replace the session: the board screen (and with it the controller)
      // is disposed while the movement is still in flight.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 900));
      await flow;
      expect(tester.takeException(), isNull);

      // The retained native engine reports the old command's completion.
      // It must not reach into the disposed session.
      await host.completePendingMovement();
      expect(tester.takeException(), isNull);

      // A replacement session reattaches, syncs its own fresh generation,
      // and reaches readiness without the stale command interfering.
      host.recordedCalls.clear();
      host.animatePayloads.clear();
      final replacement = await pumpBoard(tester);
      expect(host.recordedCalls, ['syncState']);
      expect(host.animatePayloads, isEmpty);
      expect(host.sentStates.last['stateGeneration'], 1);
      expect(host.sentStates.last['sessionId'], isNot(originalSessionId));
      expect(replacement.is3DBoardReadyForTesting, isTrue);
      // A late duplicate of the stale completion stays inert, too.
      await host.completePendingMovement();
      expect(tester.takeException(), isNull);
      expect(replacement.waitingForCardPickForTesting, isFalse);
      resetPlatformOverride();
    },
  );
}
