import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/config/board_factory.dart';
import 'package:property_tycoon/config/city_board_registry.dart';
import 'package:property_tycoon/engine/game_engine.dart';
import 'package:property_tycoon/integration/godot_board_controller.dart';
import 'package:property_tycoon/models/game_state.dart';
import 'package:property_tycoon/models/player.dart';
import 'package:property_tycoon/models/tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('2D and 3D game mode parity', () {
    for (final city in CityBoardRegistry.all) {
      test('${city.boardId} keeps every special logical space', () {
        final tiles = BoardFactory.generateTiles(city);

        expect(tiles, hasLength(40));
        expect(tiles[0].type, TileType.start);
        expect(tiles[2].type, TileType.communityChest);
        expect(tiles[7].type, TileType.chance);
        expect(tiles[10].type, TileType.jail);
        expect(tiles[20].type, TileType.freeParking);
        expect(tiles[30].type, TileType.goToJail);
        expect(tiles[33].type, TileType.communityChest);
        expect(tiles[36].type, TileType.chance);
      });
    }

    test('special spaces resolve through the shared Flutter game engine', () {
      final tiles = BoardFactory.generateTiles(CityBoardRegistry.all.first);
      final player = Player(
        id: 'player_0',
        name: 'Player 1',
        icon: PlayerIcon.dog,
        color: Colors.red,
      );
      final state = GameState.initial(players: [player], tiles: tiles);
      final engine = GameEngine(state);

      expect(
        engine.resolveTileLanding(player, 7).actionType,
        TileActionType.drawCard,
      );
      expect(
        engine.resolveTileLanding(player, 33).actionType,
        TileActionType.drawCard,
      );
      expect(
        engine.resolveTileLanding(player, 30).actionType,
        TileActionType.goToJail,
      );
      expect(
        engine.resolveTileLanding(player, 10).actionType,
        TileActionType.nothing,
      );
      expect(
        engine.resolveTileLanding(player, 20).actionType,
        TileActionType.spinWheel,
      );
      expect(
        engine.resolveTileLanding(player, 4).actionType,
        TileActionType.payTax,
      );
      expect(
        engine.resolveTileLanding(player, 0).actionType,
        TileActionType.nothing,
      );
    });

    test('3D scene mirrors ownership, upgrades, mortgage, and prices', () {
      final tiles = BoardFactory.generateTiles(CityBoardRegistry.all.first);
      final player = Player(
        id: 'player_0',
        name: 'Player 1',
        icon: PlayerIcon.dog,
        color: Colors.red,
      );
      final property = tiles[1] as PropertyTileData;
      property.ownerId = player.id;
      property.upgradeLevel = 3;
      property.isMortgaged = true;
      final state = GameState.initial(players: [player], tiles: tiles);
      final controller = GodotBoardController();
      addTearDown(controller.dispose);

      final scene = controller.sceneStateFrom(
        state,
        boardId: CityBoardRegistry.all.first.boardId,
      );
      final mirroredProperty = scene.tiles[1];

      expect(mirroredProperty.price, property.price);
      expect(mirroredProperty.ownerId, player.id);
      expect(mirroredProperty.ownerName, player.name);
      expect(mirroredProperty.ownerColorArgb, player.color.toARGB32());
      expect(mirroredProperty.upgradeLevel, 3);
      expect(mirroredProperty.isMortgaged, isTrue);
      expect(mirroredProperty.groupId, property.groupId);
    });

    test('3D scene identifies a completed color group', () {
      final tiles = BoardFactory.generateTiles(CityBoardRegistry.all.first);
      final player = Player(
        id: 'player_0',
        name: 'Player 1',
        icon: PlayerIcon.dog,
        color: Colors.red,
      );
      final target = tiles.whereType<PropertyTileData>().first;
      final group =
          tiles
              .whereType<PropertyTileData>()
              .where((property) => property.groupId == target.groupId)
              .toList();
      for (final property in group) {
        property.ownerId = player.id;
      }
      final state = GameState.initial(players: [player], tiles: tiles);
      final controller = GodotBoardController();
      addTearDown(controller.dispose);

      final scene = controller.sceneStateFrom(
        state,
        boardId: CityBoardRegistry.all.first.boardId,
      );

      for (final property in group) {
        expect(scene.tiles[property.index].hasCompleteColorGroup, isTrue);
      }
    });
  });
}
