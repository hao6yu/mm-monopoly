import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/config/city_board_registry.dart';
import 'package:property_tycoon/integration/godot_board_contract.dart';

void main() {
  group('GodotBoardProtocol', () {
    test('registers every playable city for the 3D renderer', () {
      expect(
        GodotBoardProtocol.supportedBoardIds,
        CityBoardRegistry.all.map((board) => board.boardId).toSet(),
      );
    });

    test('maps the 40 logical tiles across all 52 city spots', () {
      final positions = [
        for (var tile = 0; tile < 40; tile++)
          GodotBoardProtocol.toVisualPosition(
            logicalPosition: tile,
            logicalTileCount: 40,
            visualSpotCount: 52,
          ),
      ];

      expect(positions.first, 0);
      expect(positions.last, 51);
      expect(positions.toSet(), hasLength(40));
      expect(positions, orderedEquals([...positions]..sort()));
    });

    test('expands logical dice steps into every forward visual waypoint', () {
      final path = GodotBoardProtocol.visualPath(
        fromLogicalPosition: 37,
        spaces: 6,
        logicalTileCount: 40,
        visualSpotCount: 52,
      );

      expect(path, orderedEquals([49, 50, 51, 0, 1, 2, 3, 4]));
    });

    test('a full forward lap visits every visual route spot in order', () {
      final path = GodotBoardProtocol.visualPath(
        fromLogicalPosition: 0,
        spaces: 40,
        logicalTileCount: 40,
        visualSpotCount: 52,
      );

      expect(
        path,
        orderedEquals([for (var spot = 1; spot < 52; spot++) spot, 0]),
      );
      expect(path.toSet(), hasLength(52));
    });

    test('reverse movement includes intermediate spots and wraps past GO', () {
      final path = GodotBoardProtocol.visualPath(
        fromLogicalPosition: 2,
        spaces: -4,
        logicalTileCount: 40,
        visualSpotCount: 52,
      );

      expect(path, orderedEquals([2, 1, 0, 51, 50, 49]));
    });

    test('a full reverse lap preserves route continuity', () {
      final path = GodotBoardProtocol.visualPath(
        fromLogicalPosition: 0,
        spaces: -40,
        logicalTileCount: 40,
        visualSpotCount: 52,
      );

      expect(
        path,
        orderedEquals([for (var spot = 51; spot >= 0; spot--) spot]),
      );
      expect(path.toSet(), hasLength(52));
    });

    test('serializes logical tile type and visual position for 3D parity', () {
      const tile = GodotBoardTileState(
        logicalIndex: 30,
        visualPosition: 39,
        name: 'GO TO JAIL',
        type: 'goToJail',
        colorArgb: 0xFFFF5252,
      );

      expect(tile.toJson(), {
        'logicalIndex': 30,
        'visualPosition': 39,
        'name': 'GO TO JAIL',
        'type': 'goToJail',
        'colorArgb': 0xFFFF5252,
        'price': 0,
        'ownerId': null,
        'ownerName': null,
        'ownerColorArgb': 0,
        'upgradeLevel': 0,
        'isMortgaged': false,
        'groupId': null,
        'hasCompleteColorGroup': false,
      });
    });

    test('deserializes all interactive 3D selection kinds', () {
      final selection = GodotBoardSelection.fromMap({
        'kind': 'tile',
        'logicalIndex': 7,
        'visualIndex': 9,
        'title': 'Chance',
      });

      expect(selection.kind, 'tile');
      expect(selection.logicalIndex, 7);
      expect(selection.visualIndex, 9);
      expect(selection.title, 'Chance');
    });

    test('deserializes an exact scene-state application acknowledgement', () {
      final applied = GodotBoardStateApplied.fromMap({
        'sessionId': 'game-9',
        'stateGeneration': 4,
        'boardId': 'usa',
      });

      expect(applied.sessionId, 'game-9');
      expect(applied.stateGeneration, 4);
      expect(applied.boardId, 'usa');
    });
  });

  group('movement presentations', () {
    test('card actions map onto intentional 3D movement presentations', () {
      expect(
        GodotMovementPresentation.forCardAction('goToJail'),
        GodotMovementPresentation.jail,
      );
      expect(
        GodotMovementPresentation.forCardAction('advanceGo'),
        GodotMovementPresentation.teleport,
      );
      expect(
        GodotMovementPresentation.forCardAction('back3'),
        GodotMovementPresentation.reverse,
      );
      expect(
        GodotMovementPresentation.forCardAction('back5'),
        GodotMovementPresentation.reverse,
      );
      expect(
        GodotMovementPresentation.forCardAction('forward5'),
        GodotMovementPresentation.walk,
      );
      expect(
        GodotMovementPresentation.forCardAction('nearestRailroad'),
        GodotMovementPresentation.walk,
      );
      expect(
        GodotMovementPresentation.forCardAction('nearestUtility'),
        GodotMovementPresentation.walk,
      );
    });

    test('non-relocating card actions never request a movement', () {
      for (final action in [
        'collect100',
        'pay25',
        'collect20FromEach',
        'pay20Each',
        'propertyBonus25',
        'repairs25',
        'freeUpgrade',
      ]) {
        expect(
          GodotMovementPresentation.forCardAction(action),
          isNull,
          reason: '$action must not move the pawn',
        );
      }
    });
  });
}
