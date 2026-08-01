import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/config/board_factory.dart';
import 'package:property_tycoon/config/city_board_registry.dart';
import 'package:property_tycoon/engine/card_effect_engine.dart';
import 'package:property_tycoon/models/game_state.dart';
import 'package:property_tycoon/models/player.dart';
import 'package:property_tycoon/models/tile.dart';

void main() {
  GameState createState({int playerCount = 3}) {
    final city = CityBoardRegistry.byBoardId('usa_new_york')!;
    final players = List.generate(
      playerCount,
      (index) => Player(
        id: 'player_$index',
        name: 'Player ${index + 1}',
        icon: PlayerIcon.values[index],
        color: PlayerColors.forIndex(index),
      ),
    );
    return GameState.initial(
      players: players,
      tiles: BoardFactory.generateTiles(city),
      cityBoardId: city.boardId,
    );
  }

  test('recognizes data-driven and fixed card actions', () {
    for (final action in [
      'collect75',
      'pay25',
      'forward5',
      'back3',
      'collect20FromEach',
      'pay20Each',
      'propertyBonus25',
      'repairs25',
      'advanceGo',
      'nearestRailroad',
      'nearestUtility',
      'goToJail',
      'freeUpgrade',
    ]) {
      expect(CardEffectEngine.supportsAction(action), isTrue, reason: action);
    }
    expect(CardEffectEngine.supportsAction('mysteryAction'), isFalse);
  });

  test('applies variable cash rewards and bank payments', () {
    final state = createState();
    final player = state.players.first;
    final effects = CardEffectEngine(state);

    effects.apply(player, 'collect75');
    expect(player.cash, 1575);

    final payment = effects.apply(player, 'pay25');
    expect(player.cash, 1550);
    expect(payment.bankruptcy, isFalse);
  });

  test('moves forward, backward, and to the nearest matching tile', () {
    final state = createState();
    final player = state.players.first;
    final effects = CardEffectEngine(state);

    player.position = 38;
    final forward = effects.apply(player, 'forward5');
    expect(player.position, 3);
    expect(player.cash, 1700);
    expect(forward.passedGo, isTrue);
    expect(forward.resolveLanding, isTrue);

    final backward = effects.apply(player, 'back5');
    expect(player.position, 38);
    expect(backward.resolveLanding, isTrue);

    final railroad = effects.apply(player, 'nearestRailroad');
    expect(state.tiles[player.position].type, TileType.railroad);
    expect(railroad.resolveLanding, isTrue);
    expect(railroad.passedGo, isTrue);
    expect(player.cash, 1900);
  });

  test('moves to jail without resolving it as a visiting landing', () {
    final state = createState();
    final player = state.players.first;

    final result = CardEffectEngine(state).apply(player, 'goToJail');

    expect(player.position, 10);
    expect(player.jailTurnsRemaining, 1);
    expect(result.resolveLanding, isFalse);
  });

  test('transfers cash between all active players without going negative', () {
    final state = createState();
    final collector = state.players[0];
    final lowCashPlayer = state.players[1]..cash = 5;
    final otherPlayer = state.players[2];
    final effects = CardEffectEngine(state);

    effects.apply(collector, 'collect20FromEach');
    expect(collector.cash, 1525);
    expect(lowCashPlayer.cash, 0);
    expect(otherPlayer.cash, 1480);

    collector.cash = 25;
    effects.apply(collector, 'pay20Each');
    expect(collector.cash, 0);
    expect(lowCashPlayer.cash, 20);
    expect(otherPlayer.cash, 1485);
  });

  test(
    'calculates deed bonuses, repairs, and free upgrades from ownership',
    () {
      final state = createState();
      final player = state.players.first;
      final ownedProperties = state.tiles.whereType<PropertyTileData>().take(2);
      for (final property in ownedProperties) {
        property.ownerId = player.id;
      }
      final firstProperty = ownedProperties.first..upgradeLevel = 2;
      final secondProperty = ownedProperties.last..upgradeLevel = 1;
      final effects = CardEffectEngine(state, random: Random(1));

      effects.apply(player, 'propertyBonus25');
      expect(player.cash, 1550);

      effects.apply(player, 'repairs25');
      expect(player.cash, 1475);

      effects.apply(player, 'freeUpgrade');
      expect(firstProperty.upgradeLevel + secondProperty.upgradeLevel, 4);
    },
  );
}
