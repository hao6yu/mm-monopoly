import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/models/avatar.dart';
import 'package:property_tycoon/models/game_state.dart';
import 'package:property_tycoon/models/player.dart';
import 'package:property_tycoon/models/tile.dart';

/// The twelve-sided dice option must survive serialization and default to the
/// classic cube for saves created before the option existed.
void main() {
  List<Player> players() => [
    Player(
      id: 'p1',
      name: 'One',
      icon: PlayerIcon.dog,
      color: Colors.red,
      avatar: Avatars.forPlayerIndex(0),
    ),
    Player(
      id: 'p2',
      name: 'Two',
      icon: PlayerIcon.cat,
      color: Colors.teal,
      avatar: Avatars.forPlayerIndex(1),
    ),
  ];

  List<TileData> tiles() => List<TileData>.generate(
    40,
    (index) => TileData(
      index: index,
      name: 'TILE $index',
      type: TileType.start,
      color: Colors.blue,
    ),
  );

  test('initial state carries the configured dice sides', () {
    final dodecahedronGame = GameState.initial(
      players: players(),
      tiles: tiles(),
      diceSides: 12,
    );
    expect(dodecahedronGame.diceSides, 12);

    final classicGame = GameState.initial(players: players(), tiles: tiles());
    expect(classicGame.diceSides, 6);
  });

  test('dice sides survive a JSON round trip', () {
    final state = GameState.initial(
      players: players(),
      tiles: tiles(),
      diceSides: 12,
    );
    final restored = GameState.fromJson(state.toJson());
    expect(restored.diceSides, 12);

    final switchedBack = restored.copyWith(diceSides: 6);
    expect(switchedBack.diceSides, 6);
  });

  test('legacy saves without diceSides fall back to six', () {
    final state = GameState.initial(players: players(), tiles: tiles());
    final legacyJson = state.toJson()..remove('diceSides');
    final restored = GameState.fromJson(legacyJson);
    expect(restored.diceSides, 6);
  });
}
