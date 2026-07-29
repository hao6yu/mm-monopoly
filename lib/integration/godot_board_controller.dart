import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/game_state.dart';
import '../models/player.dart';
import 'godot_board_contract.dart';

class GodotBoardController extends ChangeNotifier {
  static const _channel = MethodChannel('property_tycoon/godot_board_bridge');

  final Map<String, Completer<GodotMovementComplete>> _pendingMoves = {};
  GodotBoardSceneState? _latestState;
  bool _isAvailable = false;
  bool _isBoardReady = false;
  bool _viewCreated = false;
  bool _disposed = false;

  bool get isAvailable => _isAvailable;
  bool get isBoardReady => _isBoardReady;
  bool get isLoading => _isAvailable && (!_viewCreated || !_isBoardReady);

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
    return GodotBoardSceneState(
      boardId: boardId,
      logicalTileCount: logicalTileCount,
      visualSpotCount: visualSpotCount,
      currentPlayerIndex: gameState.currentPlayerIndex,
      roundNumber: gameState.roundNumber,
      die1: gameState.die1Value,
      die2: gameState.die2Value,
      tileNames: [for (final tile in gameState.tiles) tile.name],
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
    _channel.setMethodCallHandler(null);
    super.dispose();
  }
}
