import '../models/game_state.dart';

/// Owns the authoritative state for one running game.
///
/// [GameState] currently contains both immutable snapshots and mutable game
/// objects. Keeping the latest snapshot in this stable session object prevents
/// navigation from accidentally rebuilding a board from an older snapshot.
class GameSessionController {
  GameSessionController(GameState initialState) : _state = initialState;

  GameState _state;
  bool _isActive = true;
  bool _isSuspended = false;
  int _workGeneration = 0;

  GameState get state => _state;

  String get id => _state.id;

  bool get isActive => _isActive;

  bool get acceptsInput => _isActive && !_isSuspended;

  int get workGeneration => _workGeneration;

  /// Replaces the current snapshot while preserving this controller identity.
  ///
  /// The ID can change when the player loads another saved game into the
  /// current board host.
  void replace(GameState nextState) {
    _state = nextState;
  }

  /// Cancels callbacks captured before a load or other state replacement.
  void invalidatePendingWork() {
    _workGeneration++;
  }

  /// Temporarily blocks input while an async replacement is prepared.
  void suspend() {
    if (!_isActive || _isSuspended) return;
    _isSuspended = true;
    _workGeneration++;
  }

  void resume() {
    if (!_isActive || !_isSuspended) return;
    _isSuspended = false;
    _workGeneration++;
  }

  /// Invalidates async work still owned by a board that is leaving the tree.
  void deactivate() {
    if (!_isActive) return;
    _isActive = false;
    _isSuspended = true;
    _workGeneration++;
  }
}
