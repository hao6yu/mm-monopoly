import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/config/board_factory.dart';
import 'package:property_tycoon/config/city_board_registry.dart';
import 'package:property_tycoon/models/game_state.dart';
import 'package:property_tycoon/models/player.dart';
import 'package:property_tycoon/models/tile.dart';
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

  test(
    'a progressed game survives preference reload without state loss',
    () async {
      final state = createState();
      final property = state.tiles.whereType<PropertyTileData>().first;
      property.ownerId = state.players.first.id;
      state.players.first.propertyIds.add(property.index.toString());
      state.players.first.cash = 845;
      state.players.first.position = 7;
      state.players.last.position = 10;
      state.players.last.jailTurnsRemaining = 2;
      state.currentPlayerIndex = 1;
      state.roundNumber = 8;
      state.die1Value = 3;
      state.die2Value = 4;
      state.lastDiceRoll = 7;
      state.playerShields[state.players.first.id] = true;
      state.playerDoubleRent[state.players.last.id] = true;
      state.totalDiceRolls = 16;
      state.totalDiceSum = 99;
      final expected = state.toJson();
      expect(await SaveService.instance.saveGame(state), isTrue);

      // Drop the in-memory preference store, keeping only persisted JSON.
      final prefs = await SharedPreferences.getInstance();
      SharedPreferences.setMockInitialValues({
        'saved_game': prefs.getString('saved_game')!,
      });
      await SaveService.instance.init();
      final restored = await SaveService.instance.loadGame();
      expect(restored, isNotNull);
      expect(restored!.toJson(), expected);
      expect(restored.canRoll, isTrue);
      expect(SaveService.instance.hasSavedGame(), isTrue);
    },
  );

  test(
    'corrupt or future-version saves fail safely without deleting data',
    () async {
      final prefs = await SharedPreferences.getInstance();
      for (final contents in ['not JSON', '{"version":999}']) {
        await prefs.setString('saved_game', contents);
        expect(await SaveService.instance.loadGame(), isNull);
        expect(prefs.getString('saved_game'), contents);
      }
    },
  );
}
