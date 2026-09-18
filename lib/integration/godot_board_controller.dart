import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/game_state.dart';
import '../models/player.dart';
import '../models/tile.dart';
import 'godot_board_contract.dart';

enum GodotBoardStateApplyError {
  rejected,
  deliveryFailed,
  connectionUnavailable,
  timedOut,
}

final class _PendingStateDelivery {
  _PendingStateDelivery(this.state);

  final GodotBoardSceneState state;
  final Completer<void> cancelled = Completer<void>();

  void cancel() {
    if (!cancelled.isCompleted) cancelled.complete();
  }
}

class GodotBoardController extends ChangeNotifier {
  static const _channel = MethodChannel('property_tycoon/godot_board_bridge');
  static const defaultStateApplyTimeout = Duration(seconds: 15);
  static GodotBoardController? _channelOwner;

  GodotBoardController({Duration stateApplyTimeout = defaultStateApplyTimeout})
    : _stateApplyTimeout = stateApplyTimeout;

  /// Optional listener for per-waypoint movement progress emitted by the
  /// native scene. Used for footstep audio; movement completion remains the
  /// only authoritative gameplay signal.
  void Function(GodotMovementStep step)? onMovementStep;

  final Map<String, Completer<GodotMovementComplete>> _pendingMoves = {};
  final Map<String, int> _lastStepIndexByCommand = {};
  String? _lastCompletedCommandId;
  final Set<_PendingStateDelivery> _pendingStateDeliveries = {};
  final StreamController<GodotBoardSelection> _selections =
      StreamController<GodotBoardSelection>.broadcast();
  final Duration _stateApplyTimeout;
  GodotBoardSceneState? _latestState;
  bool _isAvailable = false;
  bool _isSceneReady = false;
  bool _viewCreated = false;
  bool _use2DFallback = false;
  bool _disposed = false;
  int _nextStateGeneration = 0;
  String? _appliedSessionId;
  int? _appliedStateGeneration;
  String? _appliedBoardId;
  GodotBoardStateApplyError? _stateApplyError;
  Timer? _stateApplyWatchdog;

  bool get isAvailable => _isAvailable;
  bool get isSceneReady => _isSceneReady;
  bool get isBoardReady {
    final state = _latestState;
    return !_use2DFallback &&
        _isAvailable &&
        _viewCreated &&
        _isSceneReady &&
        state != null &&
        _appliedSessionId == state.sessionId &&
        _appliedStateGeneration == state.stateGeneration &&
        _appliedBoardId == state.boardId;
  }

  bool get isSynchronizing => _isAvailable && !_use2DFallback && !isBoardReady;

  /// Whether the native board must be fully covered. Routine generations for
  /// an already-visible session stay visible to avoid a full-screen flash;
  /// unsafe gameplay remains gated by [isBoardReady].
  bool get isLoading {
    if (!isSynchronizing) return false;
    final state = _latestState;
    return _stateApplyError != null ||
        !_viewCreated ||
        !_isSceneReady ||
        state == null ||
        _appliedSessionId == null ||
        _appliedSessionId != state.sessionId ||
        _appliedBoardId != state.boardId;
  }

  GodotBoardStateApplyError? get stateApplyError => _stateApplyError;
  Stream<GodotBoardSelection> get selections => _selections.stream;

  /// Whether this controller was parked on the deterministic Flutter board
  /// after a failed or timed-out 3D preparation. The choice lasts for the
  /// current board session only; a new session resets it.
  bool get is2DFallback => _use2DFallback;

  /// Prepares the controller for a brand-new board session.
  ///
  /// The "Use 2D board" choice and any preparation error belong to the
  /// session that made them; a fresh session (Continue, New Game, Replay)
  /// starts clean so a past failure cannot pin the app to 2D forever.
  void resetForNewSession({bool notifyListeners = true}) {
    if (_disposed) return;
    _use2DFallback = false;
    _stateApplyError = null;
    if (notifyListeners) {
      _notifyListeners();
    }
  }

  /// Pauses or resumes native board rendering while the platform view stays
  /// attached. The app keeps one board for the whole process (the bundled
  /// Android runtime destroys its engine when the render view leaves the
  /// window, and re-initializing in place crashes), so a hidden board must be
  /// paused instead of torn down: paused boards render nothing, run no
  /// gameplay, and receive no input.
  Future<void> setBoardVisible({required bool visible}) async {
    if (_disposed || !_isAvailable || _use2DFallback) return;
    try {
      await _channel.invokeMethod<bool>(
        'setBoardVisible',
        jsonEncode({'visible': visible}),
      );
    } on PlatformException {
      // A dropped visibility toggle only affects background rendering cost;
      // the next transition re-asserts the desired state.
    } on MissingPluginException {
      // Hosts without native pausing keep the previous behavior.
    }
  }


  bool get canUseNativeBoard =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> initialize() async {
    if (_disposed) return;
    _channelOwner = this;
    _channel.setMethodCallHandler(_dispatchNativeCall);
    if (!canUseNativeBoard) {
      _isAvailable = false;
      _notifyListeners();
      return;
    }

    var available = false;
    try {
      available =
          await _channel
              .invokeMethod<bool>('isAvailable')
              .timeout(_stateApplyTimeout) ??
          false;
    } on TimeoutException {
      available = false;
    } on PlatformException {
      available = false;
    } on MissingPluginException {
      available = false;
    }
    if (_disposed || !identical(_channelOwner, this)) return;
    _isAvailable = available;
    _notifyListeners();
  }

  static Future<Object?> _dispatchNativeCall(MethodCall call) async {
    final owner = _channelOwner;
    if (owner == null || owner._disposed) return false;
    return owner._handleNativeCall(call);
  }

  void markViewCreated() {
    if (_disposed) return;
    _viewCreated = true;
    _completeReadinessIfPossible();
    _notifyListeners();
  }

  GodotBoardSceneState sceneStateFrom(
    GameState gameState, {
    required String boardId,
    int visualSpotCount = GodotBoardProtocol.cityVisualSpotCount,
    int stateGeneration = 0,
  }) {
    final logicalTileCount = gameState.tiles.length;
    final playersById = {
      for (final player in gameState.players) player.id: player,
    };
    final completedGroupOwners = _completedColorGroupOwners(gameState.tiles);
    return GodotBoardSceneState(
      sessionId: gameState.id,
      stateGeneration: stateGeneration,
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
            completedGroupOwners: completedGroupOwners,
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
            avatarId: player.effectiveAvatar.id,
            avatarIsPhoto: player.effectiveAvatar.isCustom,
          ),
      ],
    );
  }

  GodotBoardTileState _tileStateFrom(
    TileData tile, {
    required Map<String, Player> playersById,
    required Map<String, String> completedGroupOwners,
    required int logicalTileCount,
    required int visualSpotCount,
  }) {
    String? ownerId;
    var price = 0;
    var upgradeLevel = 0;
    var isMortgaged = false;
    String? groupId;
    var hasCompleteColorGroup = false;
    if (tile is PropertyTileData) {
      ownerId = tile.ownerId;
      price = tile.price;
      upgradeLevel = tile.upgradeLevel;
      isMortgaged = tile.isMortgaged;
      groupId = tile.groupId;
      hasCompleteColorGroup =
          ownerId != null && completedGroupOwners[tile.groupId] == ownerId;
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
      groupId: groupId,
      hasCompleteColorGroup: hasCompleteColorGroup,
    );
  }

  Map<String, String> _completedColorGroupOwners(List<TileData> tiles) {
    final propertiesByGroup = <String, List<PropertyTileData>>{};
    for (final property in tiles.whereType<PropertyTileData>()) {
      propertiesByGroup.putIfAbsent(property.groupId, () => []).add(property);
    }

    final completedOwners = <String, String>{};
    for (final entry in propertiesByGroup.entries) {
      final properties = entry.value;
      if (properties.isEmpty) continue;
      final ownerId = properties.first.ownerId;
      if (ownerId == null) continue;
      if (properties.every((property) => property.ownerId == ownerId)) {
        completedOwners[entry.key] = ownerId;
      }
    }
    return completedOwners;
  }

  Future<void> syncGameState(
    GameState gameState, {
    required String boardId,
  }) async {
    if (_disposed || _use2DFallback) return;
    _cancelPendingStateDeliveries();
    // A fresh authoritative generation invalidates any in-flight movement's
    // progress history; Godot cancels hosted rolls on state application too.
    _lastStepIndexByCommand.clear();
    _latestState = sceneStateFrom(
      gameState,
      boardId: boardId,
      stateGeneration: ++_nextStateGeneration,
    );
    _stateApplyError = null;
    _notifyListeners();
    await _sendLatestState();
  }

  /// Retries the exact latest state generation. Native hosts may reannounce
  /// scene readiness only when they have observed it from Godot itself.
  Future<void> retryStateApplication() async {
    if (_disposed || _use2DFallback || !_isAvailable) return;
    _cancelPendingStateDeliveries();
    _appliedSessionId = null;
    _appliedStateGeneration = null;
    _appliedBoardId = null;
    _stateApplyError = null;
    _armStateApplyWatchdog();
    _notifyListeners();

    var replayedSceneReady = false;
    try {
      replayedSceneReady =
          await _channel
              .invokeMethod<bool>('retryScene')
              .timeout(_stateApplyTimeout) ??
          false;
    } on TimeoutException {
      if (!isBoardReady) {
        _setStateApplyError(GodotBoardStateApplyError.timedOut);
      }
      return;
    } on PlatformException {
      // Resending the cached state remains useful if the native host does not
      // yet support an explicit readiness replay.
    } on MissingPluginException {
      // The watchdog will offer the persistent 2D recovery again.
    }

    if (!replayedSceneReady) {
      await _sendLatestState();
    }
  }

  /// Stops native startup work for this board-screen session after the player
  /// explicitly chooses the deterministic Flutter renderer.
  void continueIn2D() {
    if (_disposed) return;
    _use2DFallback = true;
    _cancelPendingStateDeliveries();
    _cancelStateApplyWatchdog();
    _stateApplyError = null;
    _notifyListeners();
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
      sessionId: gameState.id,
      commandId: '${DateTime.now().microsecondsSinceEpoch}_${player.id}',
      playerId: player.id,
      playerIndex: playerIndex,
      die1: die1,
      die2: die2,
      fromLogicalPosition: player.position,
      toLogicalPosition: (player.position + spaces) % logicalTileCount,
      toVisualPosition: GodotBoardProtocol.toVisualPosition(
        logicalPosition: (player.position + spaces) % logicalTileCount,
        logicalTileCount: logicalTileCount,
        visualSpotCount: visualSpotCount,
      ),
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

  /// Builds a scoped movement command for a non-dice board movement such as
  /// jail, card, or teleport-prize relocation.
  ///
  /// [presentation] selects how Godot stages the movement (see
  /// [GodotMovementPresentation]). Walk and reverse presentations receive the
  /// complete visual waypoint path; teleport and jail flights only need the
  /// mapped destination visual position.
  GodotRollCommand createSpecialMoveCommand({
    required GameState gameState,
    required int playerIndex,
    required int fromLogicalPosition,
    required int toLogicalPosition,
    required String presentation,
  }) {
    assert(
      GodotMovementPresentation.supportedValues.contains(presentation),
      'Unsupported 3D movement presentation: $presentation',
    );
    assert(presentation != GodotMovementPresentation.standard,
        'Dice rolls must use createRollCommand.');
    final player = gameState.players[playerIndex];
    final logicalTileCount = gameState.tiles.length;
    const visualSpotCount = GodotBoardProtocol.cityVisualSpotCount;
    final forwardDelta =
        (toLogicalPosition - fromLogicalPosition) % logicalTileCount;
    final isReverse = presentation == GodotMovementPresentation.reverse;
    final signedDelta = isReverse
        ? -((fromLogicalPosition - toLogicalPosition) % logicalTileCount)
        : forwardDelta;
    final walksRoute =
        presentation == GodotMovementPresentation.walk || isReverse;
    return GodotRollCommand(
      sessionId: gameState.id,
      commandId: '${DateTime.now().microsecondsSinceEpoch}_${player.id}',
      playerId: player.id,
      playerIndex: playerIndex,
      fromLogicalPosition: fromLogicalPosition,
      toLogicalPosition: toLogicalPosition,
      toVisualPosition: GodotBoardProtocol.toVisualPosition(
        logicalPosition: toLogicalPosition,
        logicalTileCount: logicalTileCount,
        visualSpotCount: visualSpotCount,
      ),
      logicalTileCount: logicalTileCount,
      visualSpotCount: visualSpotCount,
      spaces: walksRoute ? signedDelta.abs() : 0,
      visualPath: walksRoute
          ? GodotBoardProtocol.visualPath(
              fromLogicalPosition: fromLogicalPosition,
              spaces: signedDelta,
              logicalTileCount: logicalTileCount,
              visualSpotCount: visualSpotCount,
            )
          : const [],
      presentation: presentation,
    );
  }

  Future<GodotMovementComplete> animateRoll(GodotRollCommand command) async {
    final completer = Completer<GodotMovementComplete>();
    _pendingMoves[command.commandId] = completer;
    try {
      final accepted = await _channel.invokeMethod<bool>(
        'animateRoll',
        jsonEncode(command.toJson()),
      );
      if (accepted != true) {
        throw StateError('The 3D board rejected the movement command.');
      }
      // Godot cancels a hosted roll at 9.5 seconds. Give that cancellation a
      // short bridge margin, then reveal the animated 2D recovery promptly.
      return await completer.future.timeout(const Duration(seconds: 10));
    } finally {
      _pendingMoves.remove(command.commandId);
    }
  }

  Future<void> updateCameraGesture({
    double orbitDeltaX = 0,
    double orbitDeltaY = 0,
    double panDeltaX = 0,
    double panDeltaY = 0,
    double zoomScale = 1,
  }) async {
    if (!_isAvailable || !isBoardReady) return;
    if (orbitDeltaX == 0 &&
        orbitDeltaY == 0 &&
        panDeltaX == 0 &&
        panDeltaY == 0 &&
        zoomScale == 1) {
      return;
    }

    try {
      await _channel.invokeMethod<bool>(
        'cameraGesture',
        jsonEncode({
          'orbitDeltaX': orbitDeltaX,
          'orbitDeltaY': orbitDeltaY,
          'panDeltaX': panDeltaX,
          'panDeltaY': panDeltaY,
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
    if (!_isAvailable || !isBoardReady) return;
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

  /// Toggles the optional token-follow camera (3D-09). When enabled, the
  /// native scene damps its ground target toward the active pawn during
  /// movements; manual gestures always win until the next movement.
  Future<void> setCameraFollow({required bool enabled}) async {
    if (!_isAvailable || !isBoardReady) return;
    try {
      await _channel.invokeMethod<bool>(
        'setCameraFollow',
        jsonEncode({'enabled': enabled}),
      );
    } on PlatformException {
      // A dropped toggle leaves the previous mode; the button reflects the
      // last acknowledged intent and can be tapped again.
    } on MissingPluginException {
      // The 2D fallback has no follow mode.
    }
  }

  /// Applies a render-quality tier (3D-21: high/medium/low) to the native
  /// scene. Silently skipped when the board is not ready; the caller re-sends
  /// it after the next board-ready transition.
  Future<void> setGraphicsQuality({required String quality}) async {
    if (!_isAvailable || !isBoardReady) return;
    try {
      await _channel.invokeMethod<bool>(
        'setGraphicsQuality',
        jsonEncode({'quality': quality}),
      );
    } on PlatformException {
      // A dropped tier application keeps the previous budget.
    } on MissingPluginException {
      // The 2D fallback has no 3D render budget.
    }
  }

  Future<void> pickBoardObject({
    required double normalizedX,
    required double normalizedY,
  }) async {
    if (!_isAvailable || !isBoardReady) return;
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
    if (_disposed || !_isAvailable || _latestState == null || _use2DFallback) {
      return;
    }
    final state = _latestState!;
    final delivery = _PendingStateDelivery(state);
    _pendingStateDeliveries.add(delivery);
    _armStateApplyWatchdog();
    try {
      final accepted = await Future.any<bool?>([
        _channel.invokeMethod<bool>('syncState', jsonEncode(state.toJson())),
        delivery.cancelled.future.then<bool?>((_) => null),
      ]).timeout(_stateApplyTimeout);
      if (delivery.cancelled.isCompleted || _use2DFallback || _disposed) return;
      if (accepted == false &&
          identical(state, _latestState) &&
          !isBoardReady) {
        _setStateApplyError(GodotBoardStateApplyError.rejected);
      }
    } on TimeoutException {
      if (identical(state, _latestState) && !isBoardReady) {
        _setStateApplyError(GodotBoardStateApplyError.timedOut);
      }
    } on PlatformException {
      // State remains cached for Retry and for the next native ready event.
      if (identical(state, _latestState) && !isBoardReady) {
        _setStateApplyError(GodotBoardStateApplyError.deliveryFailed);
      }
    } on MissingPluginException {
      if (identical(state, _latestState) && !isBoardReady) {
        _setStateApplyError(GodotBoardStateApplyError.connectionUnavailable);
      }
    } finally {
      delivery.cancel();
      _pendingStateDeliveries.remove(delivery);
    }
  }

  void _armStateApplyWatchdog() {
    _cancelStateApplyWatchdog();
    final state = _latestState;
    if (_disposed ||
        _use2DFallback ||
        !_isAvailable ||
        state == null ||
        isBoardReady) {
      return;
    }
    final sessionId = state.sessionId;
    final generation = state.stateGeneration;
    _stateApplyWatchdog = Timer(_stateApplyTimeout, () {
      final latest = _latestState;
      if (_disposed ||
          _use2DFallback ||
          latest == null ||
          latest.sessionId != sessionId ||
          latest.stateGeneration != generation ||
          isBoardReady) {
        return;
      }
      _setStateApplyError(GodotBoardStateApplyError.timedOut);
    });
  }

  void _setStateApplyError(GodotBoardStateApplyError error) {
    _cancelStateApplyWatchdog();
    _cancelPendingStateDeliveries(state: _latestState);
    if (_stateApplyError == error) return;
    _stateApplyError = error;
    _notifyListeners();
  }

  void _notifyListeners() {
    if (!_disposed) notifyListeners();
  }

  void _cancelStateApplyWatchdog() {
    _stateApplyWatchdog?.cancel();
    _stateApplyWatchdog = null;
  }

  void _cancelPendingStateDeliveries({GodotBoardSceneState? state}) {
    for (final delivery in _pendingStateDeliveries.toList(growable: false)) {
      if (state == null || identical(delivery.state, state)) delivery.cancel();
    }
  }

  void _completeReadinessIfPossible() {
    if (!isBoardReady) return;
    _cancelStateApplyWatchdog();
    _stateApplyError = null;
  }

  Future<Object?> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'boardReady':
        _isSceneReady = true;
        _completeReadinessIfPossible();
        _notifyListeners();
        // Native hosts own ready-time delivery of their cached generation.
        // Sending again here races that delivery and applies the same state
        // twice, which also cancels any roll Godot just began.
        return true;
      case 'stateApplied':
        final raw = call.arguments;
        if (raw is! Map || _use2DFallback) return false;
        final event = GodotBoardStateApplied.fromMap(
          raw.cast<Object?, Object?>(),
        );
        final latest = _latestState;
        if (latest == null ||
            event.sessionId != latest.sessionId ||
            event.stateGeneration != latest.stateGeneration ||
            event.boardId != latest.boardId) {
          return false;
        }
        _appliedSessionId = event.sessionId;
        _appliedStateGeneration = event.stateGeneration;
        _appliedBoardId = event.boardId;
        _cancelPendingStateDeliveries(state: latest);
        // An acknowledgement can legitimately arrive before the platform view
        // callback or boardReady. Keep any timeout/recovery visible until every
        // readiness predicate is satisfied.
        _completeReadinessIfPossible();
        _notifyListeners();
        return true;
      case 'movementComplete':
        final raw = call.arguments;
        if (raw is! Map) return false;
        final event = GodotMovementComplete.fromMap(
          raw.cast<Object?, Object?>(),
        );
        _pendingMoves[event.commandId]?.complete(event);
        _lastCompletedCommandId = event.commandId;
        _lastStepIndexByCommand.remove(event.commandId);
        return true;
      case 'movementStep':
        final raw = call.arguments;
        if (raw is! Map) return false;
        final step = GodotMovementStep.fromMap(raw.cast<Object?, Object?>());
        // Monotonic per-command guard: retried or out-of-order host events
        // must not double-fire footstep cues for the same waypoint. Events
        // trailing a completed command are dropped entirely.
        final lastStep = _lastStepIndexByCommand[step.commandId] ?? -1;
        if (step.stepIndex <= lastStep) return true;
        if (step.commandId == _lastCompletedCommandId) return true;
        _lastStepIndexByCommand[step.commandId] = step.stepIndex;
        onMovementStep?.call(step);
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
    _cancelPendingStateDeliveries();
    _cancelStateApplyWatchdog();
    for (final move in _pendingMoves.values) {
      if (!move.isCompleted) {
        move.completeError(StateError('The 3D board was closed.'));
      }
    }
    _pendingMoves.clear();
    _selections.close();
    if (identical(_channelOwner, this)) {
      _channelOwner = null;
      _channel.setMethodCallHandler(null);
    }
    super.dispose();
  }
}
