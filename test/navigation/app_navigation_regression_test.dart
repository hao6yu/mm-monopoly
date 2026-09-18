import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/app.dart';
import 'package:property_tycoon/config/board_factory.dart';
import 'package:property_tycoon/config/city_board_registry.dart';
import 'package:property_tycoon/controllers/game_session_controller.dart';
import 'package:property_tycoon/l10n/app_localizations.dart';
import 'package:property_tycoon/models/game_result.dart';
import 'package:property_tycoon/models/game_state.dart';
import 'package:property_tycoon/models/player.dart';
import 'package:property_tycoon/screens/game_board_screen.dart';
import 'package:property_tycoon/screens/how_to_play_screen.dart';
import 'package:property_tycoon/screens/main_menu_screen.dart';
import 'package:property_tycoon/screens/victory_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const godotChannel = MethodChannel('property_tycoon/godot_board_bridge');

  late GameSessionController session;
  late GameResult result;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(godotChannel, (call) async {
          if (call.method == 'isAvailable') return false;
          return null;
        });
    final city = CityBoardRegistry.byBoardId('usa_new_york')!;
    final players = <Player>[
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
    ];
    final state = GameState.initial(
      players: players,
      tiles: BoardFactory.generateTiles(city),
      cityBoardId: city.boardId,
    );
    session = GameSessionController(state);
    result = GameResult(winner: players.first, players: players, turns: 12);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(godotChannel, null);
  });

  Widget navigationApp({required AppScreen screen, GameResult? gameResult}) {
    final city = CityBoardRegistry.byBoardId('usa_new_york')!;
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AppNavigator(
        initialScreen: screen,
        initialGameSession: session,
        initialCityBoard: city,
        initialGameResult: gameResult,
      ),
    );
  }

  testWidgets('in-game help preserves the live board and latest state', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(navigationApp(screen: AppScreen.game));
    await tester.pump(const Duration(milliseconds: 250));
    // The board now renders an intentional startup state while native 3D
    // availability is resolved. Pump the frame scheduled by that async
    // result before interacting with the 2D fallback controls.
    await tester.pump();
    final boardStateBefore = tester.state(find.byType(GameBoardScreen));

    final progressedState = session.state.copyWith(
      currentPlayerIndex: 1,
      die1Value: 2,
      die2Value: 3,
      lastDiceRoll: 5,
      roundNumber: 4,
    );
    session.replace(progressedState);

    await tester.tap(find.byKey(const Key('compact-menu-button')));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('How to Play'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(HowToPlayScreen), findsOneWidget);
    expect(find.byType(GameBoardScreen, skipOffstage: false), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(HowToPlayScreen), findsNothing);
    expect(find.byType(GameBoardScreen), findsOneWidget);
    expect(tester.state(find.byType(GameBoardScreen)), same(boardStateBefore));
    expect(session.state, same(progressedState));
    expect(session.state.currentPlayerIndex, 1);
    expect(session.state.lastDiceRoll, 5);
    expect(session.state.roundNumber, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets('victory replay is handled by the live app navigator', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final oldSession = session;
    await tester.pumpWidget(
      navigationApp(screen: AppScreen.victory, gameResult: result),
    );
    await tester.pump(const Duration(milliseconds: 2200));
    expect(find.byType(VictoryScreen), findsOneWidget);

    final replay = find.byKey(const Key('victory-play-again-button'));
    await tester.ensureVisible(replay);
    await tester.pump();
    await tester.tap(replay);
    expect(oldSession.acceptsInput, isFalse);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(GameBoardScreen), findsOneWidget);
    final board = tester.widget<GameBoardScreen>(find.byType(GameBoardScreen));
    expect(board.session, isNot(same(oldSession)));
    expect(oldSession.isActive, isFalse);
    expect(board.session.state.currentPlayerIndex, 0);
    expect(board.session.state.roundNumber, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('victory home is handled by the live AppNavigator', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      navigationApp(screen: AppScreen.victory, gameResult: result),
    );
    await tester.pump(const Duration(milliseconds: 2200));
    final home = find.byKey(const Key('victory-home-button'));
    await tester.ensureVisible(home);
    await tester.pump();
    await tester.tap(home);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(MainMenuScreen), findsOneWidget);
    expect(find.byType(VictoryScreen), findsNothing);
    expect(session.isActive, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('system back asks before leaving a live game', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(navigationApp(screen: AppScreen.game));
    await tester.pump(const Duration(milliseconds: 250));

    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Quit Game?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byType(GameBoardScreen), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('Quit to Menu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(MainMenuScreen), findsOneWidget);
    expect(find.byType(GameBoardScreen), findsNothing);
    expect(session.isActive, isFalse);
    expect(tester.takeException(), isNull);
  });
}
