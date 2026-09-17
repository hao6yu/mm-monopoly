import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/config/board_factory.dart';
import 'package:property_tycoon/config/city_board_registry.dart';
import 'package:property_tycoon/controllers/game_session_controller.dart';
import 'package:property_tycoon/l10n/app_localizations.dart';
import 'package:property_tycoon/models/game_state.dart';
import 'package:property_tycoon/models/player.dart';
import 'package:property_tycoon/models/tile.dart';
import 'package:property_tycoon/screens/game_board_screen.dart';
import 'package:property_tycoon/services/save_service.dart';
import 'package:property_tycoon/widgets/board/game_board.dart';
import 'package:property_tycoon/widgets/dice/dice_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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

  final sizes = <Size>[
    const Size(390, 844),
    const Size(844, 390),
    const Size(768, 1024),
    const Size(1440, 900),
  ];

  for (final size in sizes) {
    testWidgets('game board fits ${size.width}x${size.height}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final city = CityBoardRegistry.byBoardId('usa_new_york')!;
      final players = [
        Player(
          id: 'player_0',
          name: 'Mia',
          icon: PlayerIcon.dog,
          color: Colors.red,
        ),
        Player(
          id: 'player_1',
          name: 'Noah',
          icon: PlayerIcon.car,
          color: Colors.blue,
        ),
        Player(
          id: 'player_2',
          name: 'Luna',
          icon: PlayerIcon.crown,
          color: Colors.amber,
        ),
        Player(
          id: 'player_3',
          name: 'Max',
          icon: PlayerIcon.rocket,
          color: Colors.green,
        ),
      ];
      final state = GameState.initial(
        players: players,
        tiles: BoardFactory.generateTiles(city),
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

      expect(tester.takeException(), isNull);
      expect(find.byType(GameBoardScreen), findsOneWidget);
      if (size.width < 700 || size.height < 600) {
        expect(find.byKey(const Key('compact-2d-hud')), findsOneWidget);
        expect(find.byKey(const Key('compact-2d-board-zoom')), findsOneWidget);
        expect(find.byKey(const Key('compact-roll-button')), findsOneWidget);
        expect(find.text('Mia'), findsWidgets);
        expect(find.text('\$1500'), findsWidgets);
      }
    });
  }

  test('3D camera gesture maps one finger to pan and two fingers to orbit', () {
    final pan = deriveBoardCameraGestureDelta(
      pointerCount: 1,
      focalDelta: const ui.Offset(14, -9),
      scale: 1,
      previousScale: 1,
    );
    expect(pan.panDeltaX, 14);
    expect(pan.panDeltaY, -9);
    expect(pan.orbitDeltaX, 0);
    expect(pan.orbitDeltaY, 0);
    expect(pan.zoomScale, 1);

    final orbitAndZoom = deriveBoardCameraGestureDelta(
      pointerCount: 2,
      focalDelta: const ui.Offset(-11, 7),
      scale: 1.2,
      previousScale: 1.1,
    );
    expect(orbitAndZoom.orbitDeltaX, -11);
    expect(orbitAndZoom.orbitDeltaY, 7);
    expect(orbitAndZoom.panDeltaX, 0);
    expect(orbitAndZoom.panDeltaY, 0);
    expect(orbitAndZoom.zoomScale, closeTo(1.2 / 1.1, 0.0001));

    for (final pointerCount in [2, 1]) {
      final transition = deriveBoardCameraGestureDelta(
        pointerCount: pointerCount,
        focalDelta: const ui.Offset(180, -120),
        scale: 1.4,
        previousScale: 1,
        pointerCountChanged: true,
      );
      expect(transition.panDeltaX, 0);
      expect(transition.panDeltaY, 0);
      expect(transition.orbitDeltaX, 0);
      expect(transition.orbitDeltaY, 0);
      expect(transition.zoomScale, 1);
    }
  });

  test('new games start with an explicit unrolled dice state', () {
    final city = CityBoardRegistry.byBoardId('usa_new_york')!;
    final state = GameState.initial(
      players: [
        Player(
          id: 'player_0',
          name: 'Mia',
          icon: PlayerIcon.dog,
          color: Colors.red,
        ),
        Player(
          id: 'player_1',
          name: 'Noah',
          icon: PlayerIcon.car,
          color: Colors.blue,
        ),
      ],
      tiles: List.generate(
        40,
        (index) => CornerTileData(
          index: index,
          name: 'Safe $index',
          type: TileType.start,
        ),
      ),
      cityBoardId: city.boardId,
    );

    expect(state.lastDiceRoll, 0);
    expect(state.die1Value, 0);
    expect(state.die2Value, 0);
  });

  test(
    'camera gesture dispatch coalesces frames and serializes sends',
    () async {
      final callbacks = <int, void Function(Duration)>{};
      final cancelledCallbacks = <int>[];
      final sent = <BoardCameraGestureDelta>[];
      final completions = <Completer<void>>[];
      var nextCallbackId = 0;
      var activeSends = 0;
      var maxActiveSends = 0;

      final dispatcher = BoardCameraGestureDispatcher(
        scheduleFrame: (callback) {
          final id = ++nextCallbackId;
          callbacks[id] = callback;
          return id;
        },
        cancelFrame: (id) {
          cancelledCallbacks.add(id);
          callbacks.remove(id);
        },
        send: (delta) {
          sent.add(delta);
          activeSends++;
          if (activeSends > maxActiveSends) maxActiveSends = activeSends;
          final completion = Completer<void>();
          completions.add(completion);
          return completion.future.whenComplete(() => activeSends--);
        },
      );
      addTearDown(dispatcher.dispose);

      dispatcher.enqueue((
        orbitDeltaX: 0,
        orbitDeltaY: 0,
        panDeltaX: 5,
        panDeltaY: 2,
        zoomScale: 1,
      ));
      dispatcher.enqueue((
        orbitDeltaX: 0,
        orbitDeltaY: 0,
        panDeltaX: 3,
        panDeltaY: -1,
        zoomScale: 1,
      ));
      expect(callbacks, hasLength(1));

      callbacks.remove(1)!(Duration.zero);
      expect(sent, hasLength(1));
      expect(sent.single.panDeltaX, 8);
      expect(sent.single.panDeltaY, 1);

      dispatcher.enqueue((
        orbitDeltaX: 4,
        orbitDeltaY: -2,
        panDeltaX: 0,
        panDeltaY: 0,
        zoomScale: 1.1,
      ));
      expect(callbacks, isEmpty);
      completions.first.complete();
      await Future<void>.delayed(Duration.zero);
      expect(callbacks, hasLength(1));

      callbacks.remove(2)!(Duration.zero);
      expect(sent, hasLength(2));
      expect(sent.last.orbitDeltaX, 4);
      expect(maxActiveSends, 1);
      completions[1].complete();
      await Future<void>.delayed(Duration.zero);

      dispatcher.enqueue((
        orbitDeltaX: 1,
        orbitDeltaY: 1,
        panDeltaX: 0,
        panDeltaY: 0,
        zoomScale: 0.95,
      ));
      expect(callbacks, hasLength(1));
      final flush = dispatcher.flush();
      await Future<void>.delayed(Duration.zero);
      expect(cancelledCallbacks, contains(3));
      expect(sent, hasLength(3));
      expect(callbacks, isEmpty);
      completions[2].complete();
      await flush;
      expect(maxActiveSends, 1);
    },
  );

  testWidgets('AI-first game disables human roll and schedules one AI roll', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final city = CityBoardRegistry.byBoardId('usa_new_york')!;
    final state = GameState.initial(
      players: [
        Player(
          id: 'player_0',
          name: 'Bot',
          icon: PlayerIcon.car,
          color: Colors.blue,
          isAI: true,
        ),
        Player(
          id: 'player_1',
          name: 'Mia',
          icon: PlayerIcon.dog,
          color: Colors.red,
        ),
      ],
      tiles: List.generate(
        40,
        (index) => CornerTileData(
          index: index,
          name: 'Safe $index',
          type: TileType.start,
        ),
      ),
      cityBoardId: city.boardId,
    );
    final session = GameSessionController(state);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GameBoardScreen(
          session: session,
          cityBoard: city,
          boardTheme: BoardFactory.getThemeForCityBoard(city),
          onQuit: () {},
          onRestart: () {},
          onGameFinished: (_) {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    final rollFinder = find.byKey(const Key('compact-roll-button'));
    final rollButton = tester.widget<FilledButton>(rollFinder);
    expect(rollButton.onPressed, isNull);
    final l10n = AppLocalizations.of(tester.element(rollFinder))!;
    expect(find.text(l10n.aiThinking('Bot')), findsOneWidget);
    final menuFinder = find.byKey(const Key('compact-menu-button'));
    expect(tester.widget<IconButton>(menuFinder).onPressed, isNotNull);

    await tester.tap(menuFinder);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Game Menu'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(session.state.totalDiceRolls, 0);
    await tester.tap(find.text('Back to Game'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Game Menu'), findsNothing);

    await tester.tap(rollFinder, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 200));
    expect(session.state.totalDiceRolls, 0);
    expect(session.state.lastDiceRoll, 0);

    // Resuming queues exactly one replacement AI timer. The human-facing roll
    // stays disabled while that timer and the dice animation run.
    for (var tick = 0; tick < 10; tick++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (session.state.animationState == TurnAnimationState.rollingDice) break;
    }
    expect(session.state.animationState, TurnAnimationState.rollingDice);
    await tester.pump(const Duration(milliseconds: 800));
    expect(session.state.totalDiceRolls, 1);
    expect(session.state.lastDiceRoll, greaterThan(0));
    for (var tick = 0; tick < 50; tick++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (!session.state.currentPlayer.isAI && session.state.canRoll) break;
    }
    expect(session.state.totalDiceRolls, 1);
    expect(session.state.currentPlayer.isAI, isFalse);
    expect(tester.takeException(), isNull);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('crossing the player order advances authoritative round state', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final city = CityBoardRegistry.byBoardId('usa_new_york')!;
    final state =
        GameState.initial(
          players: [
            Player(
              id: 'player_0',
              name: 'Mia',
              icon: PlayerIcon.dog,
              color: Colors.red,
            ),
            Player(
              id: 'player_1',
              name: 'Noah',
              icon: PlayerIcon.car,
              color: Colors.blue,
            ),
          ],
          // GO-like tiles resolve without a decision dialog, making the complete
          // async turn deterministic even though the dice values remain random.
          tiles: List.generate(
            40,
            (index) => CornerTileData(
              index: index,
              name: 'Safe $index',
              type: TileType.start,
            ),
          ),
          cityBoardId: city.boardId,
        ).copyWith(
          currentPlayerIndex: 1,
          roundNumber: 4,
          // Force the event path so its delayed dialog is covered without relying
          // on the wall-clock-based random trigger.
          turnsSinceLastEvent: 9,
        );
    final session = GameSessionController(state);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GameBoardScreen(
          session: session,
          cityBoard: city,
          boardTheme: BoardFactory.getThemeForCityBoard(city),
          onQuit: () {},
          onRestart: () {},
          onGameFinished: (_) {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.byKey(const Key('compact-roll-button')));

    for (var tick = 0; tick < 70; tick++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (session.state.currentPlayerIndex == 0 && session.state.canRoll) break;
    }

    expect(session.state.currentPlayerIndex, 0);
    expect(session.state.roundNumber, 5);
    expect(session.state.turnsSinceLastEvent, 0);
    expect(tester.takeException(), isNull);

    // Disposing during the event-dialog grace period must synchronously cancel
    // its timer instead of leaving work tied to the former board context.
    await tester.pumpWidget(const SizedBox.shrink());
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('save and load actions only appear at a stable turn boundary', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    await SaveService.instance.init();
    final city = CityBoardRegistry.byBoardId('usa_new_york')!;
    final state = GameState.initial(
      players: [
        Player(
          id: 'player_0',
          name: 'Mia',
          icon: PlayerIcon.dog,
          color: Colors.red,
        ),
        Player(
          id: 'player_1',
          name: 'Noah',
          icon: PlayerIcon.car,
          color: Colors.blue,
        ),
      ],
      tiles: BoardFactory.generateTiles(city),
      cityBoardId: city.boardId,
    );
    await SaveService.instance.saveGame(state);

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

    await tester.tap(find.byKey(const Key('compact-menu-button')));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Save Game'), findsOneWidget);
    expect(find.text('Load Game'), findsOneWidget);

    await tester.tap(find.text('Back to Game'));
    await tester.pump(const Duration(milliseconds: 250));
    state.logicPhase = TurnLogicPhase.awaitingDecision;

    await tester.tap(find.byKey(const Key('compact-menu-button')));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Save Game'), findsNothing);
    expect(find.text('Load Game'), findsNothing);
  });

  testWidgets('menu stays disabled while a turn action is unresolved', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final city = CityBoardRegistry.byBoardId('usa_new_york')!;
    final state =
        GameState.initial(
            players: [
              Player(
                id: 'player_0',
                name: 'Mia',
                icon: PlayerIcon.dog,
                color: Colors.red,
              ),
              Player(
                id: 'player_1',
                name: 'Noah',
                icon: PlayerIcon.car,
                color: Colors.blue,
              ),
            ],
            tiles: BoardFactory.generateTiles(city),
            cityBoardId: city.boardId,
          )
          ..logicPhase = TurnLogicPhase.tileResolution
          ..animationState = TurnAnimationState.showingDialog;

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
          tradingEnabled: true,
          bankEnabled: true,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    final menu = tester.widget<IconButton>(
      find.byKey(const Key('compact-menu-button')),
    );
    expect(menu.onPressed, isNull);
    final moreActions = tester.widget<IconButton>(
      find.byKey(const Key('compact-more-actions-button')),
    );
    expect(moreActions.onPressed, isNull);
    final board = tester.widget<GameBoard>(find.byType(GameBoard));
    expect(board.onTileTap, isNull);
    expect(board.onTradeTap, isNull);
    expect(board.onBankTap, isNull);
    expect(board.onChanceTap, isNotNull);
    expect(board.onChestTap, isNotNull);
    final playerPill = tester.widget<InkWell>(
      find.byKey(const Key('compact-player-player_0')),
    );
    expect(playerPill.onTap, isNull);
    final cityBadge = tester.widget<InkWell>(
      find
          .ancestor(
            of: find.text('New York City • United States'),
            matching: find.byType(InkWell),
          )
          .first,
    );
    expect(cityBadge.onTap, isNull);
    expect(find.text('Game Menu'), findsNothing);
  });

  testWidgets('a pre-load AI timer cannot roll replacement human state', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    await SaveService.instance.init();
    final city = CityBoardRegistry.byBoardId('usa_new_york')!;
    final players = [
      Player(
        id: 'player_0',
        name: 'Mia',
        icon: PlayerIcon.dog,
        color: Colors.red,
      ),
      Player(
        id: 'player_1',
        name: 'Bot',
        icon: PlayerIcon.car,
        color: Colors.blue,
        isAI: true,
      ),
    ];
    final humanState = GameState.initial(
      players: players,
      tiles: BoardFactory.generateTiles(city),
      cityBoardId: city.boardId,
    );
    final aiState = humanState.copyWith(currentPlayerIndex: 1);
    await SaveService.instance.saveGame(aiState);
    final session = GameSessionController(humanState);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GameBoardScreen(
          session: session,
          cityBoard: city,
          boardTheme: BoardFactory.getThemeForCityBoard(city),
          onQuit: () {},
          onRestart: () {},
          onGameFinished: (_) {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.byKey(const Key('compact-menu-button')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Load Game'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Confirm'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(session.state.currentPlayer.isAI, isTrue);

    final replacement = humanState.copyWith(
      currentPlayerIndex: 0,
      lastDiceRoll: 0,
      animationState: TurnAnimationState.idle,
      logicPhase: TurnLogicPhase.preRoll,
    );
    session.invalidatePendingWork();
    session.replace(replacement);
    await tester.pump(const Duration(milliseconds: 1200));

    expect(session.state, same(replacement));
    expect(session.state.currentPlayer.isAI, isFalse);
    expect(session.state.lastDiceRoll, 0);
    expect(session.state.animationState, TurnAnimationState.idle);
    expect(tester.takeException(), isNull);
  });

  testWidgets('highlighted card deck fits with larger device text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: const Scaffold(
            body: Center(
              child: SizedBox(
                width: 90,
                height: 125,
                child: CardDeck(
                  label: 'COMMUNITY CHEST',
                  color: Colors.blue,
                  icon: Icons.inventory_2,
                  isHighlighted: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'city guide matches the active board mode without duplicate names',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final city = CityBoardRegistry.byBoardId('usa_new_york')!;
      final state = GameState.initial(
        players: [
          Player(
            id: 'player_0',
            name: 'Mia',
            icon: PlayerIcon.dog,
            color: Colors.red,
          ),
          Player(
            id: 'player_1',
            name: 'Noah',
            icon: PlayerIcon.car,
            color: Colors.blue,
          ),
        ],
        tiles: BoardFactory.generateTiles(city),
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

      await tester.tap(find.text('New York City • United States'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('New York City • United States • New York City'),
        findsNothing,
      );
      expect(find.textContaining('themed game board'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
