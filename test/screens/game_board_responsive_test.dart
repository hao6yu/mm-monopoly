import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/config/board_factory.dart';
import 'package:property_tycoon/config/city_board_registry.dart';
import 'package:property_tycoon/l10n/app_localizations.dart';
import 'package:property_tycoon/models/game_state.dart';
import 'package:property_tycoon/models/player.dart';
import 'package:property_tycoon/screens/game_board_screen.dart';
import 'package:property_tycoon/services/save_service.dart';
import 'package:property_tycoon/widgets/dice/dice_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
            gameState: state,
            cityBoard: city,
            boardTheme: BoardFactory.getThemeForCityBoard(city),
            onQuit: () {},
            onRestart: () {},
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
          gameState: state,
          cityBoard: city,
          boardTheme: BoardFactory.getThemeForCityBoard(city),
          onQuit: () {},
          onRestart: () {},
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
}
