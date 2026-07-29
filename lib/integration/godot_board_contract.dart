/// First version of the Flutter <-> Godot board protocol.
///
/// Flutter positions always refer to logical game tiles. Godot positions refer
/// to the richer visual route, which can contain a different number of spots.
abstract final class GodotBoardProtocol {
  static const int schemaVersion = 1;
  static const int cityVisualSpotCount = 52;
  static const Set<String> supportedBoardIds = {
    'usa',
    'usa_new_york',
    'usa_los_angeles',
    'uk',
    'uk_edinburgh',
    'uk_manchester',
    'france',
    'france_lyon',
    'france_marseille',
    'japan',
    'japan_osaka',
    'japan_kyoto',
    'china',
    'china_shanghai',
    'china_hong_kong',
    'mexico',
    'mexico_guadalajara',
    'mexico_cancun',
  };

  /// Kept as a source-compatible alias for older tests and saved prototypes.
  static const int manhattanVisualSpotCount = cityVisualSpotCount;

  static int toVisualPosition({
    required int logicalPosition,
    required int logicalTileCount,
    required int visualSpotCount,
  }) {
    if (logicalTileCount <= 0 || visualSpotCount <= 0) return 0;
    final normalized = logicalPosition % logicalTileCount;
    return ((normalized * visualSpotCount) / logicalTileCount).round() %
        visualSpotCount;
  }

  static List<int> visualPath({
    required int fromLogicalPosition,
    required int spaces,
    required int logicalTileCount,
    required int visualSpotCount,
  }) {
    if (logicalTileCount <= 0 || visualSpotCount <= 0 || spaces <= 0) {
      return const [];
    }
    return List<int>.generate(spaces, (index) {
      final logicalPosition =
          (fromLogicalPosition + index + 1) % logicalTileCount;
      return toVisualPosition(
        logicalPosition: logicalPosition,
        logicalTileCount: logicalTileCount,
        visualSpotCount: visualSpotCount,
      );
    });
  }
}

class GodotBoardPlayerState {
  const GodotBoardPlayerState({
    required this.id,
    required this.name,
    required this.colorArgb,
    required this.cash,
    required this.logicalPosition,
    required this.visualPosition,
    required this.isActive,
  });

  final String id;
  final String name;
  final int colorArgb;
  final int cash;
  final int logicalPosition;
  final int visualPosition;
  final bool isActive;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'colorArgb': colorArgb,
    'cash': cash,
    'logicalPosition': logicalPosition,
    'visualPosition': visualPosition,
    'isActive': isActive,
  };
}

class GodotBoardSceneState {
  const GodotBoardSceneState({
    required this.boardId,
    required this.logicalTileCount,
    required this.visualSpotCount,
    required this.currentPlayerIndex,
    required this.roundNumber,
    required this.die1,
    required this.die2,
    required this.tileNames,
    required this.players,
  });

  final String boardId;
  final int logicalTileCount;
  final int visualSpotCount;
  final int currentPlayerIndex;
  final int roundNumber;
  final int die1;
  final int die2;
  final List<String> tileNames;
  final List<GodotBoardPlayerState> players;

  Map<String, Object?> toJson() => {
    'schemaVersion': GodotBoardProtocol.schemaVersion,
    'type': 'scene_state',
    'boardId': boardId,
    'logicalTileCount': logicalTileCount,
    'visualSpotCount': visualSpotCount,
    'currentPlayerIndex': currentPlayerIndex,
    'roundNumber': roundNumber,
    'die1': die1,
    'die2': die2,
    'tileNames': tileNames,
    'players': players.map((player) => player.toJson()).toList(),
  };
}

class GodotRollCommand {
  const GodotRollCommand({
    required this.commandId,
    required this.playerId,
    required this.playerIndex,
    required this.die1,
    required this.die2,
    required this.fromLogicalPosition,
    required this.toLogicalPosition,
    required this.logicalTileCount,
    required this.visualSpotCount,
    required this.visualPath,
  });

  final String commandId;
  final String playerId;
  final int playerIndex;
  final int die1;
  final int die2;
  final int fromLogicalPosition;
  final int toLogicalPosition;
  final int logicalTileCount;
  final int visualSpotCount;
  final List<int> visualPath;

  int get spaces => die1 + die2;

  Map<String, Object?> toJson() => {
    'schemaVersion': GodotBoardProtocol.schemaVersion,
    'type': 'animate_roll',
    'commandId': commandId,
    'playerId': playerId,
    'playerIndex': playerIndex,
    'die1': die1,
    'die2': die2,
    'spaces': spaces,
    'fromLogicalPosition': fromLogicalPosition,
    'toLogicalPosition': toLogicalPosition,
    'logicalTileCount': logicalTileCount,
    'visualSpotCount': visualSpotCount,
    'visualPath': visualPath,
  };
}

class GodotMovementComplete {
  const GodotMovementComplete({
    required this.commandId,
    required this.playerId,
    required this.logicalPosition,
    required this.visualPosition,
  });

  final String commandId;
  final String playerId;
  final int logicalPosition;
  final int visualPosition;

  factory GodotMovementComplete.fromMap(Map<Object?, Object?> map) {
    return GodotMovementComplete(
      commandId: map['commandId'] as String? ?? '',
      playerId: map['playerId'] as String? ?? '',
      logicalPosition: (map['logicalPosition'] as num?)?.toInt() ?? 0,
      visualPosition: (map['visualPosition'] as num?)?.toInt() ?? 0,
    );
  }
}
