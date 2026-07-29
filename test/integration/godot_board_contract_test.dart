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

    test('creates one visual landing per logical dice step', () {
      final path = GodotBoardProtocol.visualPath(
        fromLogicalPosition: 37,
        spaces: 6,
        logicalTileCount: 40,
        visualSpotCount: 52,
      );

      expect(path, hasLength(6));
      expect(
        path.last,
        GodotBoardProtocol.toVisualPosition(
          logicalPosition: 3,
          logicalTileCount: 40,
          visualSpotCount: 52,
        ),
      );
    });
  });
}
