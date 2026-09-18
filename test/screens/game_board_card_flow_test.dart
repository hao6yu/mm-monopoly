import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/config/board_factory.dart';
import 'package:property_tycoon/config/city_board_registry.dart';
import 'package:property_tycoon/config/constants.dart';
import 'package:property_tycoon/controllers/game_session_controller.dart';
import 'package:property_tycoon/l10n/app_localizations.dart';
import 'package:property_tycoon/models/game_state.dart';
import 'package:property_tycoon/models/player.dart';
import 'package:property_tycoon/models/tile.dart';
import 'package:property_tycoon/screens/game_board_screen.dart';
import 'package:property_tycoon/widgets/dialogs/card_pick_dialog.dart';

/// Drives real Chance/Community Chest card selection through
/// [GameBoardScreen] for every movement family: amount cards, forward,
/// backward, nearest-railroad, Advance to GO, and Go To Jail.
///
/// The 3D board is unavailable in the test harness (2D fallback), so the
/// presentation attempt deterministically falls back to the state sync and
/// these tests assert the logical outcomes and the waiting-state lifecycle.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const godotChannel = MethodChannel('property_tycoon/godot_board_bridge');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(godotChannel, (call) async {
          if (call.method == 'isAvailable') return false;
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(godotChannel, null);
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
    await tester.pump(const Duration(milliseconds: 250));

    return tester.state<GameBoardScreenState>(
      find.byType(GameBoardScreen),
    );
  }

  /// The flow's audio ducking schedules an 800 ms timer; expire it so the
  /// test ends without pending timers.
  Future<void> flushAudioTimers(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 900));
  }

  TileData tileOfType(GameState state, TileType type) {
    return state.tiles.firstWhere((tile) => tile.type == type);
  }

  testWidgets(
    'amount card moves nobody and pays out through the screen',
    (tester) async {
      final screenState = await pumpBoard(tester);
      final gameState = screenState.gameState;
      final player = gameState.players.first;
      final chanceTile = tileOfType(gameState, TileType.chance);
      final cashBefore = player.cash;

      final flow = screenState.drawCardForTesting(player, chanceTile);
      await tester.pump();
      expect(screenState.waitingForCardPickForTesting, isTrue);

      screenState.handlePickedCardForTesting(
        const PickableCard(text: '🎲', effect: '+\$25', action: 'collect25'),
      );
      await flow;
      await flushAudioTimers(tester);

      expect(player.position, 0);
      expect(player.cash, cashBefore + 25);
      expect(screenState.waitingForCardPickForTesting, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'forward card crosses GO, awards the bonus, and resolves the landing',
    (tester) async {
      final screenState = await pumpBoard(tester);
      final gameState = screenState.gameState;
      final player = gameState.players.first;
      final chanceTile = tileOfType(gameState, TileType.chance);
      final tileCount = gameState.tiles.length;
      // Five steps forward from here lands exactly on GO.
      player.position = tileCount - 5;
      final goBonus = gameState.getGoBonusForPlayer(player.id);
      final cashBefore = player.cash;

      final flow = screenState.drawCardForTesting(player, chanceTile);
      await tester.pump();

      screenState.handlePickedCardForTesting(
        const PickableCard(text: '🎲', effect: '+5', action: 'forward5'),
      );
      await flow;
      await flushAudioTimers(tester);

      expect(player.position, 0);
      expect(player.cash, cashBefore + goBonus);
      expect(screenState.waitingForCardPickForTesting, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'backward card walks back without a GO bonus and resolves the landing',
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

      expect(player.position, 0);
      expect(player.cash, cashBefore);
      expect(screenState.waitingForCardPickForTesting, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Advance to GO relocates the player and awards the bonus without landing resolution',
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

      expect(player.position, 0);
      expect(player.cash, cashBefore + goBonus);
      expect(player.jailTurnsRemaining, 0);
      expect(screenState.waitingForCardPickForTesting, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Go To Jail card relocates the player to jail without landing resolution',
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

      expect(player.position, GameConstants.jailPosition);
      expect(player.jailTurnsRemaining, 1);
      expect(screenState.waitingForCardPickForTesting, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'nearest railroad card walks to the railroad the player owns and resolves it',
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
      // Own the destination so the landing resolves to nothing instead of
      // opening the purchase dialog.
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

      expect(player.position, railroadIndex);
      expect(screenState.waitingForCardPickForTesting, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
