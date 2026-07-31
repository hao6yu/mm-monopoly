import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/config/board_factory.dart';
import 'package:property_tycoon/config/city_board_registry.dart';
import 'package:property_tycoon/models/game_state.dart';
import 'package:property_tycoon/models/player.dart';
import 'package:property_tycoon/services/save_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SaveService.instance.init();
  });

  GameState createState() {
    final city = CityBoardRegistry.byBoardId('usa_new_york')!;
    return GameState.initial(
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
  }

  test('loading a game keeps the save available', () async {
    final state = createState();
    state.players.first.cash = 1725;

    expect(await SaveService.instance.saveGame(state), isTrue);
    expect(SaveService.instance.hasSavedGame(), isTrue);

    final loaded = await SaveService.instance.loadGame();

    expect(loaded, isNotNull);
    expect(loaded!.players.first.cash, 1725);
    expect(SaveService.instance.hasSavedGame(), isTrue);
    expect(await SaveService.instance.loadGame(), isNotNull);
  });
}
