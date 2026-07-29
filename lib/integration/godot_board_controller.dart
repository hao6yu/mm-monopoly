import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/game_state.dart';
import '../models/player.dart';
import '../models/tile.dart';
import 'godot_board_contract.dart';

class GodotBoardController extends ChangeNotifier {
  static const _channel = MethodChannel('property_tycoon/godot_board_bridge');

  final Map<String, Completer<GodotMovementComplete>> _pendingMoves = {};
  final StreamController<GodotBoardSelection> _selections =
      StreamController<GodotBoardSelection>.broadcast();
  GodotBoardSceneState? _latestState;
  bool _isAvailable = false;
  bool _isBoardReady = false;
  bool _viewCreated = false;
  bool _disposed = false;

  bool get isAvailable => _isAvailable;
  bool get isBoardReady => _isBoardReady;
  bool get isLoading => _isAvailable && (!_viewCreated || !_isBoardReady);
  Stream<GodotBoardSelection> get selections => _selections.stream;

  bool get canUseNativeBoard =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleNativeCall);
    if (!canUseNativeBoard) {
      _isAvailable = false;
      notifyListeners();
      return;
    }

    try {
      _isAvailable = await _channel.invokeMethod<bool>('isAvailable') ?? false;
    } on PlatformException {
      _isAvailable = false;
    } on MissingPluginException {
      _isAvailable = false;
    }
    if (!_disposed) notifyListeners();
  }

  void markViewCreated() {
    _viewCreated = true;
    notifyListeners();
    _sendLatestState();
  }

  GodotBoardSceneState sceneStateFrom(
    GameState gameState, {
    required String boardId,
    int visualSpotCount = GodotBoardProtocol.cityVisualSpotCount,
  }) {
    final logicalTileCount = gameState.tiles.length;
    final playersById = {
      for (final player in gameState.players) player.id: player,
    };
    return GodotBoardSceneState(
      boardId: boardId,
      logicalTileCount: logicalTileCount,
      visualSpotCount: visualSpotCount,
      currentPlayerIndex: gameState.currentPlayerIndex,
      roundNumber: gameState.roundNumber,
      die1: gameState.die1Value,
      die2: gameState.die2Value,
      tileNames: [for (final tile in gameState.tiles) tile.name],
      tiles: [
        for (final tile in gameState.tiles)
          _tileStateFrom(
            tile,
            playersById: playersById,
            logicalTileCount: logicalTileCount,
            visualSpotCount: visualSpotCount,
          ),
      ],
      players: [
        for (final player in gameState.players)
          GodotBoardPlayerState(
            id: player.id,
            name: player.name,
            colorArgb: player.color.toARGB32(),
            cash: player.cash,
            logicalPosition: player.position,
            visualPosition: GodotBoardProtocol.toVisualPosition(
              logicalPosition: player.position,
              logicalTileCount: logicalTileCount,
              visualSpotCount: visualSpotCount,
            ),
            isActive: player.status == PlayerStatus.active,
          ),
      ],
    );
  }

  GodotBoardTileState _tileStateFrom(
    TileData tile, {
    required Map<String, Player> playersById,
    required int logicalTileCount,
    required int visualSpotCount,
  }) {
    String? ownerId;
    var price = 0;
    var upgradeLevel = 0;
    var isMortgaged = false;
    if (tile is PropertyTileData) {
      ownerId = tile.ownerId;
      price = tile.price;
      upgradeLevel = tile.upgradeLevel;
      isMortgaged = tile.isMortgaged;
    } else if (tile is RailroadTileData) {
      ownerId = tile.ownerId;
      price = tile.price;
      isMortgaged = tile.isMortgaged;
    } else if (tile is UtilityTileData) {
      ownerId = tile.ownerId;
      price = tile.price;
      isMortgaged = tile.isMortgaged;
    }
    final owner = ownerId == null ? null : playersById[ownerId];

    return GodotBoardTileState(
      logicalIndex: tile.index,
      visualPosition: GodotBoardProtocol.toVisualPosition(
        logicalPosition: tile.index,
        logicalTileCount: logicalTileCount,
        visualSpotCount: visualSpotCount,
      ),
      name: tile.name,
      type: tile.type.name,
      colorArgb: tile.color.toARGB32(),
      price: price,
      ownerId: ownerId,
      ownerName: owner?.name,
      ownerColorArgb: owner?.color.toARGB32() ?? 0,
      upgradeLevel: upgradeLevel,
      isMortgaged: isMortgaged,
    );
  }

  Future<void> syncGameState(
    GameState gameState, {
    required String boardId,
  }) async {
    _latestState = sceneStateFrom(gameState, boardId: boardId);
    await _sendLatestState();
  }

  GodotRollCommand createRollCommand({
    required GameState gameState,
    required int playerIndex,
    required int die1,
    required int die2,
  }) {
    final player = gameState.players[playerIndex];
    final logicalTileCount = gameState.tiles.length;
    const visualSpotCount = GodotBoardProtocol.cityVisualSpotCount;
    final spaces = die1 + die2;
    return GodotRollCommand(
      commandId: '${DateTime.now().microsecondsSinceEpoch}_${player.id}',
      playerId: player.id,
      playerIndex: playerIndex,
      die1: die1,
      die2: die2,
      fromLogicalPosition: player.position,
      toLogicalPosition: (player.position + spaces) % logicalTileCount,
      logicalTileCount: logicalTileCount,
      visualSpotCount: visualSpotCount,
      visualPath: GodotBoardProtocol.visualPath(
        fromLogicalPosition: player.position,
        spaces: spaces,
        logicalTileCount: logicalTileCount,
        visualSpotCount: visualSpotCount,
      ),
    );
  }

  Future<GodotMovementComplete> animateRoll(GodotRollCommand command) async {
    final completer = Completer<GodotMovementComplete>();
    _pendingMoves[command.commandId] = completer;
    try {
      await _channel.invokeMethod<bool>(
        'animateRoll',
        jsonEncode(command.toJson()),
      );
      return await completer.future.timeout(const Duration(seconds: 12));
    } finally {
      _pendingMoves.remove(command.commandId);
    }
  }

  Future<void> updateCameraGesture({
    double orbitDeltaX = 0,
    double orbitDeltaY = 0,
    double zoomScale = 1,
  }) async {
    if (!_isAvailable || !_isBoardReady) return;
    if (orbitDeltaX == 0 && orbitDeltaY == 0 && zoomScale == 1) return;

    try {
      await _channel.invokeMethod<bool>(
        'cameraGesture',
        jsonEncode({
          'orbitDeltaX': orbitDeltaX,
          'orbitDeltaY': orbitDeltaY,
          'zoomScale': zoomScale,
        }),
      );
    } on PlatformException {
      // A dropped camera frame is harmless; the next gesture update continues
      // from the camera's current position.
    } on MissingPluginException {
      // The 2D fallback remains usable when the native host is unavailable.
    }
  }

  Future<void> resetCamera() async {
    if (!_isAvailable || !_isBoardReady) return;
    try {
      await _channel.invokeMethod<bool>(
        'cameraGesture',
        jsonEncode({'reset': true}),
      );
    } on PlatformException {
      // The next camera gesture remains usable if a reset frame is dropped.
    } on MissingPluginException {
      // The 2D fallback remains usable when the native host is unavailable.
    }
  }

  Future<void> pickBoardObject({
    required double normalizedX,
    required double normalizedY,
  }) async {
    if (!_isAvailable || !_isBoardReady) return;
    try {
      await _channel.invokeMethod<bool>(
        'pickBoardObject',
        jsonEncode({
          'normalizedX': normalizedX.clamp(0.0, 1.0),
          'normalizedY': normalizedY.clamp(0.0, 1.0),
        }),
      );
    } on PlatformException {
      // Picking is informational; a missed tap must not interrupt gameplay.
    } on MissingPluginException {
      // The 2D fallback remains usable when the native host is unavailable.
    }
  }

  Future<void> _sendLatestState() async {
    if (!_isAvailable || _latestState == null) return;
    try {
      await _channel.invokeMethod<bool>(
        'syncState',
        jsonEncode(_latestState!.toJson()),
      );
    } on PlatformException {
      // State remains cached and is retried when the native board reports ready.
    }
  }

  Future<Object?> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'boardReady':
        _isBoardReady = true;
        if (!_disposed) notifyListeners();
        await _sendLatestState();
        return true;
      case 'movementComplete':
        final raw = call.arguments;
        if (raw is! Map) return false;
        final event = GodotMovementComplete.fromMap(
          raw.cast<Object?, Object?>(),
        );
        _pendingMoves[event.commandId]?.complete(event);
        return true;
      case 'boardObjectTapped':
        final raw = call.arguments;
        if (raw is! Map || _selections.isClosed) return false;
        _selections.add(
          GodotBoardSelection.fromMap(raw.cast<Object?, Object?>()),
        );
        return true;
      default:
        return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (final move in _pendingMoves.values) {
      if (!move.isCompleted) {
        move.completeError(StateError('The 3D board was closed.'));
      }
    }
    _pendingMoves.clear();
    _selections.close();
    _channel.setMethodCallHandler(null);
    super.dispose();
  }
}
