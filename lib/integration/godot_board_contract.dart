/// Versioned Flutter <-> Godot board protocol.
///
/// Flutter positions always refer to logical game tiles. Godot positions refer
/// to the richer visual route, which can contain a different number of spots.
abstract final class GodotBoardProtocol {
  static const int schemaVersion = 2;
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
    if (logicalTileCount <= 0 || visualSpotCount <= 0 || spaces == 0) {
      return const [];
    }

    // A logical tile does not always map to the adjacent visual spot. Walk
    // every visual spot between logical landings so the native pawn follows
    // the perimeter instead of cutting diagonally across board corners.
    final direction = spaces.isNegative ? -1 : 1;
    final path = <int>[];
    var currentVisualPosition = toVisualPosition(
      logicalPosition: fromLogicalPosition,
      logicalTileCount: logicalTileCount,
      visualSpotCount: visualSpotCount,
    );

    for (var logicalStep = 1; logicalStep <= spaces.abs(); logicalStep++) {
      final nextLogicalPosition =
          (fromLogicalPosition + (logicalStep * direction)) % logicalTileCount;
      final nextVisualPosition = toVisualPosition(
        logicalPosition: nextLogicalPosition,
        logicalTileCount: logicalTileCount,
        visualSpotCount: visualSpotCount,
      );

      while (currentVisualPosition != nextVisualPosition) {
        currentVisualPosition =
            (currentVisualPosition + direction) % visualSpotCount;
        path.add(currentVisualPosition);
      }
    }

    return path;
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
    this.avatarId = '',
    this.avatarIsPhoto = false,
  });

  final String id;
  final String name;
  final int colorArgb;
  final int cash;
  final int logicalPosition;
  final int visualPosition;
  final bool isActive;

  /// Stable identity id of the effective avatar (3D-05). Empty for legacy
  /// senders; Godot derives pawn appearance tints from it deterministically.
  final String avatarId;

  /// Whether the effective avatar is a user photo (never rendered by Godot;
  /// photos stay a Flutter-side identity surface).
  final bool avatarIsPhoto;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'colorArgb': colorArgb,
    'cash': cash,
    'logicalPosition': logicalPosition,
    'visualPosition': visualPosition,
    'isActive': isActive,
    'avatarId': avatarId,
    'avatarIsPhoto': avatarIsPhoto,
  };
}

class GodotBoardTileState {
  const GodotBoardTileState({
    required this.logicalIndex,
    required this.visualPosition,
    required this.name,
    required this.type,
    required this.colorArgb,
    this.price = 0,
    this.ownerId,
    this.ownerName,
    this.ownerColorArgb = 0,
    this.upgradeLevel = 0,
    this.isMortgaged = false,
    this.groupId,
    this.hasCompleteColorGroup = false,
  });

  final int logicalIndex;
  final int visualPosition;
  final String name;
  final String type;
  final int colorArgb;
  final int price;
  final String? ownerId;
  final String? ownerName;
  final int ownerColorArgb;
  final int upgradeLevel;
  final bool isMortgaged;
  final String? groupId;
  final bool hasCompleteColorGroup;

  Map<String, Object?> toJson() => {
    'logicalIndex': logicalIndex,
    'visualPosition': visualPosition,
    'name': name,
    'type': type,
    'colorArgb': colorArgb,
    'price': price,
    'ownerId': ownerId,
    'ownerName': ownerName,
    'ownerColorArgb': ownerColorArgb,
    'upgradeLevel': upgradeLevel,
    'isMortgaged': isMortgaged,
    'groupId': groupId,
    'hasCompleteColorGroup': hasCompleteColorGroup,
  };
}

class GodotBoardSceneState {
  const GodotBoardSceneState({
    required this.sessionId,
    required this.stateGeneration,
    required this.boardId,
    required this.logicalTileCount,
    required this.visualSpotCount,
    required this.currentPlayerIndex,
    required this.roundNumber,
    required this.die1,
    required this.die2,
    required this.diceSides,
    required this.tileNames,
    required this.tiles,
    required this.players,
  });

  final String sessionId;
  final int stateGeneration;
  final String boardId;
  final int logicalTileCount;
  final int visualSpotCount;
  final int currentPlayerIndex;
  final int roundNumber;
  final int die1;
  final int die2;

  /// Faces per die: 6 (classic cube) or 12 (dodecahedron).
  final int diceSides;
  final List<String> tileNames;
  final List<GodotBoardTileState> tiles;
  final List<GodotBoardPlayerState> players;

  Map<String, Object?> toJson() => {
    'schemaVersion': GodotBoardProtocol.schemaVersion,
    'type': 'scene_state',
    'sessionId': sessionId,
    'stateGeneration': stateGeneration,
    'boardId': boardId,
    'logicalTileCount': logicalTileCount,
    'visualSpotCount': visualSpotCount,
    'currentPlayerIndex': currentPlayerIndex,
    'roundNumber': roundNumber,
    'die1': die1,
    'die2': die2,
    'diceSides': diceSides,
    'tileNames': tileNames,
    'tiles': tiles.map((tile) => tile.toJson()).toList(),
    'players': players.map((player) => player.toJson()).toList(),
  };
}

/// Acknowledgement emitted only after Godot has applied the requested scene
/// state, including any city rebuild and pawn placement.
class GodotBoardStateApplied {
  const GodotBoardStateApplied({
    required this.sessionId,
    required this.stateGeneration,
    required this.boardId,
  });

  final String sessionId;
  final int stateGeneration;
  final String boardId;

  factory GodotBoardStateApplied.fromMap(Map<Object?, Object?> map) {
    return GodotBoardStateApplied(
      sessionId: map['sessionId'] as String? ?? '',
      stateGeneration: (map['stateGeneration'] as num?)?.toInt() ?? -1,
      boardId: map['boardId'] as String? ?? '',
    );
  }
}

class GodotBoardSelection {
  const GodotBoardSelection({
    required this.kind,
    this.logicalIndex,
    this.visualIndex,
    this.playerIndex,
    this.playerId,
    this.title,
  });

  final String kind;
  final int? logicalIndex;
  final int? visualIndex;
  final int? playerIndex;
  final String? playerId;
  final String? title;

  factory GodotBoardSelection.fromMap(Map<Object?, Object?> map) {
    return GodotBoardSelection(
      kind: map['kind'] as String? ?? 'city',
      logicalIndex: (map['logicalIndex'] as num?)?.toInt(),
      visualIndex: (map['visualIndex'] as num?)?.toInt(),
      playerIndex: (map['playerIndex'] as num?)?.toInt(),
      playerId: map['playerId'] as String?,
      title: map['title'] as String?,
    );
  }
}

/// Movement presentation requested for an [GodotRollCommand].
///
/// Every non-dice board movement (jail, cards, teleport prizes) reuses the
/// dice-roll command channel so the native scene keeps a single scoped,
/// cancellable movement contract. The presentation tells Godot how to stage
/// the movement; missing values mean [standard] for backward compatibility.
abstract final class GodotMovementPresentation {
  static const String standard = 'standard';
  static const String walk = 'walk';
  static const String reverse = 'reverse';
  static const String teleport = 'teleport';
  static const String jail = 'jail';

  static const Set<String> supportedValues = {
    standard,
    walk,
    reverse,
    teleport,
    jail,
  };

  /// Maps a data-driven card action from the [CardEffectEngine] action
  /// grammar to the movement presentation that should animate it, or null
  /// when the card does not relocate the player.
  static String? forCardAction(String action) {
    if (action == 'goToJail') return jail;
    // "Advance to GO" can span most of the board, so it flies instead of
    // walking up to fifty visual waypoints.
    if (action == 'advanceGo') return teleport;
    if (action.startsWith('back')) return reverse;
    if (action.startsWith('forward') ||
        action == 'nearestRailroad' ||
        action == 'nearestUtility') {
      return walk;
    }
    return null;
  }
}

class GodotRollCommand {
  const GodotRollCommand({
    required this.sessionId,
    required this.commandId,
    required this.playerId,
    required this.playerIndex,
    this.die1 = 0,
    this.die2 = 0,
    int? spaces,
    required this.fromLogicalPosition,
    required this.toLogicalPosition,
    required this.toVisualPosition,
    required this.logicalTileCount,
    required this.visualSpotCount,
    required this.visualPath,
    this.presentation = GodotMovementPresentation.standard,
  }) : _spaces = spaces;

  final String sessionId;
  final String commandId;
  final String playerId;
  final int playerIndex;
  final int die1;
  final int die2;
  final int fromLogicalPosition;
  final int toLogicalPosition;
  final int toVisualPosition;
  final int logicalTileCount;
  final int visualSpotCount;
  final List<int> visualPath;
  final String presentation;

  /// Explicit step count for non-dice movements; dice rolls derive it from
  /// the two die values.
  final int? _spaces;

  int get spaces => _spaces ?? die1 + die2;

  Map<String, Object?> toJson() => {
    'schemaVersion': GodotBoardProtocol.schemaVersion,
    'type': 'animate_roll',
    'sessionId': sessionId,
    'commandId': commandId,
    'playerId': playerId,
    'playerIndex': playerIndex,
    'die1': die1,
    'die2': die2,
    'spaces': spaces,
    'presentation': presentation,
    'fromLogicalPosition': fromLogicalPosition,
    'toLogicalPosition': toLogicalPosition,
    'toVisualPosition': toVisualPosition,
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

/// A single arrived visual waypoint of an in-flight hosted movement. Purely
/// presentational (footstep audio/haptics); never gates gameplay logic.
class GodotMovementStep {
  const GodotMovementStep({
    required this.commandId,
    required this.playerId,
    required this.stepIndex,
    required this.totalSteps,
  });

  final String commandId;
  final String playerId;

  /// 1-based index of the arrived waypoint.
  final int stepIndex;
  final int totalSteps;

  factory GodotMovementStep.fromMap(Map<Object?, Object?> map) {
    return GodotMovementStep(
      commandId: map['commandId'] as String? ?? '',
      playerId: map['playerId'] as String? ?? '',
      stepIndex: (map['stepIndex'] as num?)?.toInt() ?? 0,
      totalSteps: (map['totalSteps'] as num?)?.toInt() ?? 0,
    );
  }
}
