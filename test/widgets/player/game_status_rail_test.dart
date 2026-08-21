import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/l10n/app_localizations.dart';
import 'package:property_tycoon/models/game_state.dart';
import 'package:property_tycoon/models/player.dart';
import 'package:property_tycoon/widgets/player/game_status_rail.dart';

void main() {
  List<Player> players() => [
    Player(
      id: 'player_0',
      name: 'Mia',
      icon: PlayerIcon.dog,
      color: Colors.red,
      cash: 1420,
    ),
    Player(
      id: 'player_1',
      name: 'Noah',
      icon: PlayerIcon.car,
      color: Colors.blue,
      cash: 980,
    ),
    Player(
      id: 'player_2',
      name: 'Cora',
      icon: PlayerIcon.crown,
      color: Colors.amber,
      cash: 1735,
      isAI: true,
    ),
    Player(
      id: 'player_3',
      name: 'Bot Max',
      icon: PlayerIcon.rocket,
      color: Colors.green,
      cash: 0,
      status: PlayerStatus.bankrupt,
      isAI: true,
    ),
  ];

  GameState state({int currentPlayerIndex = 0}) => GameState(
    id: 'hud-test',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    players: players(),
    tiles: const [],
    currentPlayerIndex: currentPlayerIndex,
    roundNumber: 7,
  );

  Widget app(
    GameState state, {
    bool boardReady = true,
    bool isProcessingTurn = false,
    bool interactionsEnabled = true,
    ValueChanged<Player>? onPlayerTap,
    double textScale = 1,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: GameStatusRail(
            gameState: state,
            boardReady: boardReady,
            isProcessingTurn: isProcessingTurn,
            interactionsEnabled: interactionsEnabled,
            onPlayerTap: onPlayerTap,
          ),
        ),
      ),
    );
  }

  testWidgets('shows four players, identities, cash, status, and one round', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1180, 820);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final gameState = state();
    String? inspectedPlayerId;
    await tester.pumpWidget(
      app(
        gameState,
        interactionsEnabled: false,
        onPlayerTap: (player) => inspectedPlayerId = player.id,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('3d-player-status-rail')), findsOneWidget);
    expect(find.text('Pass to Mia • Your turn'), findsOneWidget);
    expect(find.text('Round 7'), findsOneWidget);
    expect(find.byKey(const Key('3d-round-label')), findsOneWidget);
    for (final player in gameState.players) {
      expect(find.byKey(Key('3d-status-player-${player.id}')), findsOneWidget);
    }
    expect(find.text('Human'), findsNWidgets(2));
    expect(find.text('AI'), findsNWidgets(2));
    expect(find.text(r'$1420'), findsOneWidget);
    expect(find.text(r'$1735'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Waiting'), findsNWidgets(2));
    expect(find.text('BANKRUPTCY!'), findsOneWidget);

    final gatedCard = tester.widget<InkWell>(
      find.byKey(const Key('3d-status-player-player_1')),
    );
    expect(gatedCard.onTap, isNull);
    await tester.tap(
      find.byKey(const Key('3d-status-player-player_1')),
      warnIfMissed: false,
    );
    expect(inspectedPlayerId, isNull);

    await tester.pumpWidget(
      app(gameState, onPlayerTap: (player) => inspectedPlayerId = player.id),
    );
    await tester.tap(find.byKey(const Key('3d-status-player-player_1')));
    expect(inspectedPlayerId, 'player_1');
    expect(tester.takeException(), isNull);
  });

  testWidgets('announces AI thinking, rolling, moving, and resolving phases', (
    tester,
  ) async {
    final gameState = state(currentPlayerIndex: 2);

    await tester.pumpWidget(app(gameState, boardReady: false));
    expect(find.text('Preparing game…'), findsOneWidget);

    await tester.pumpWidget(app(gameState));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Cora is thinking…'), findsOneWidget);

    gameState.animationState = TurnAnimationState.rollingDice;
    await tester.pumpWidget(app(gameState));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Cora is rolling…'), findsOneWidget);

    gameState.animationState = TurnAnimationState.movingToken;
    await tester.pumpWidget(app(gameState));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Cora is moving…'), findsOneWidget);

    gameState.animationState = TurnAnimationState.processingEffect;
    gameState.logicPhase = TurnLogicPhase.tileResolution;
    await tester.pumpWidget(app(gameState, isProcessingTurn: true));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Cora is resolving…'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow large-text rail scrolls and can collapse', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(app(state(), textScale: 2));
    await tester.pumpAndSettle();

    final rail = find.byKey(const Key('3d-player-status-rail'));
    expect(rail, findsOneWidget);
    expect(find.byKey(const Key('3d-player-status-list')), findsOneWidget);
    expect(find.text('Round 7'), findsOneWidget);
    expect(find.byTooltip('Hide player status'), findsOneWidget);
    expect(tester.getSize(rail).width, lessThanOrEqualTo(390));
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('3d-player-status-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('3d-player-status-list')), findsNothing);
    expect(find.text('Pass to Mia • Your turn'), findsOneWidget);
    expect(find.text('Round 7'), findsOneWidget);
    expect(find.byTooltip('Show player status'), findsOneWidget);

    await tester.tap(find.byKey(const Key('3d-player-status-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('3d-player-status-list')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('four-player landscape rail remains a compact single row', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(844, 390);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(app(state(), textScale: 1.6));
    await tester.pumpAndSettle();

    final rail = find.byKey(const Key('3d-player-status-rail'));
    expect(rail, findsOneWidget);
    expect(find.byKey(const Key('3d-player-status-list')), findsNothing);
    expect(tester.getSize(rail).height, lessThan(110));
    expect(find.text('Round 7'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ordinary human names fit in the four-player iPad rail', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final gameState = state();
    gameState.players[0].name = 'Human One';
    gameState.players[1].name = 'Human Two';

    for (final size in [const Size(1366, 1024), const Size(1024, 1366)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(app(gameState));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('3d-player-status-list')), findsNothing);
      for (final playerId in ['player_0', 'player_1']) {
        final name = find.byKey(Key('3d-status-player-name-$playerId'));
        final paragraph = tester.renderObject<RenderParagraph>(name);
        expect(
          paragraph.didExceedMaxLines,
          isFalse,
          reason: '$playerId should not be ellipsized at iPad size $size',
        );
        expect(
          find.byKey(Key('3d-status-player-identity-$playerId')),
          findsOneWidget,
        );
      }
      expect(find.text('Human'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    }
  });
}
