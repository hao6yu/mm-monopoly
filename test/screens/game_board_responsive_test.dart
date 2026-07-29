import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/config/board_factory.dart';
import 'package:property_tycoon/config/city_board_registry.dart';
import 'package:property_tycoon/l10n/app_localizations.dart';
import 'package:property_tycoon/models/game_state.dart';
import 'package:property_tycoon/models/player.dart';
import 'package:property_tycoon/screens/game_board_screen.dart';

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
    });
  }
}
