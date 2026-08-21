import 'player.dart';

/// Immutable navigation payload shown after a game has finished.
class GameResult {
  const GameResult({
    required this.winner,
    required this.players,
    required this.turns,
  });

  final Player winner;
  final List<Player> players;
  final int turns;
}
