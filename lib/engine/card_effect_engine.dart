import 'dart:math';

import '../models/game_state.dart';
import '../models/player.dart';
import '../models/tile.dart';
import 'game_engine.dart';

/// The outcome of applying a Chance or Community Chest card.
class CardEffectResult {
  const CardEffectResult({
    this.landingPosition,
    this.resolveLanding = false,
    this.passedGo = false,
    this.bankruptcy = false,
  });

  /// The player's new position when the card moved their token.
  final int? landingPosition;

  /// Whether the destination tile should be resolved after the card finishes.
  final bool resolveLanding;

  /// Whether forward movement crossed GO and awarded the configured GO bonus.
  final bool passedGo;

  /// Whether a payment caused the player to go bankrupt.
  final bool bankruptcy;
}

/// Applies data-driven card actions to the game state.
///
/// Amount-based actions intentionally use an action grammar (for example,
/// `collect75`, `forward5`, or `repairs25`) so new card amounts can be added to
/// localized JSON without adding another switch case.
class CardEffectEngine {
  CardEffectEngine(this.state, {GameEngine? gameEngine, Random? random})
    : _gameEngine = gameEngine ?? GameEngine(state),
      _random = random ?? Random.secure();

  final GameState state;
  final GameEngine _gameEngine;
  final Random _random;

  static final RegExp _collectPattern = RegExp(r'^collect(\d+)$');
  static final RegExp _payPattern = RegExp(r'^pay(\d+)$');
  static final RegExp _forwardPattern = RegExp(r'^forward(\d+)$');
  static final RegExp _backPattern = RegExp(r'^back(\d+)$');
  static final RegExp _collectFromEachPattern = RegExp(
    r'^collect(\d+)FromEach$',
  );
  static final RegExp _payEachPattern = RegExp(r'^pay(\d+)Each$');
  static final RegExp _propertyBonusPattern = RegExp(r'^propertyBonus(\d+)$');
  static final RegExp _repairsPattern = RegExp(r'^repairs(\d+)$');

  static const Set<String> _fixedActions = {
    'advanceGo',
    'nearestRailroad',
    'nearestUtility',
    'goToJail',
    'freeUpgrade',
  };

  /// Returns whether an action from card JSON can be executed by this engine.
  static bool supportsAction(String action) {
    if (_fixedActions.contains(action)) return true;
    return _amountFrom(_collectPattern, action) != null ||
        _amountFrom(_payPattern, action) != null ||
        _amountFrom(_forwardPattern, action) != null ||
        _amountFrom(_backPattern, action) != null ||
        _amountFrom(_collectFromEachPattern, action) != null ||
        _amountFrom(_payEachPattern, action) != null ||
        _amountFrom(_propertyBonusPattern, action) != null ||
        _amountFrom(_repairsPattern, action) != null;
  }

  CardEffectResult apply(Player player, String action) {
    final collectAmount = _amountFrom(_collectPattern, action);
    if (collectAmount != null) {
      player.cash += collectAmount;
      return const CardEffectResult();
    }

    final payAmount = _amountFrom(_payPattern, action);
    if (payAmount != null) {
      return _payBank(player, payAmount);
    }

    final forwardSpaces = _amountFrom(_forwardPattern, action);
    if (forwardSpaces != null) {
      return _moveForward(player, forwardSpaces);
    }

    final backSpaces = _amountFrom(_backPattern, action);
    if (backSpaces != null) {
      final tileCount = state.tiles.length;
      player.position = (player.position - backSpaces) % tileCount;
      return CardEffectResult(
        landingPosition: player.position,
        resolveLanding: true,
      );
    }

    final collectFromEach = _amountFrom(_collectFromEachPattern, action);
    if (collectFromEach != null) {
      for (final other in _otherActivePlayers(player)) {
        final transferred = min(collectFromEach, other.cash);
        other.cash -= transferred;
        player.cash += transferred;
      }
      return const CardEffectResult();
    }

    final payEach = _amountFrom(_payEachPattern, action);
    if (payEach != null) {
      for (final other in _otherActivePlayers(player)) {
        final transferred = min(payEach, player.cash);
        player.cash -= transferred;
        other.cash += transferred;
        if (player.cash == 0) break;
      }
      return const CardEffectResult();
    }

    final propertyBonus = _amountFrom(_propertyBonusPattern, action);
    if (propertyBonus != null) {
      final ownedDeeds =
          state.tiles.where((tile) {
            return switch (tile) {
              PropertyTileData property => property.ownerId == player.id,
              RailroadTileData railroad => railroad.ownerId == player.id,
              UtilityTileData utility => utility.ownerId == player.id,
              _ => false,
            };
          }).length;
      player.cash += ownedDeeds * propertyBonus;
      return const CardEffectResult();
    }

    final repairRate = _amountFrom(_repairsPattern, action);
    if (repairRate != null) {
      final upgradeCount = state.tiles
          .whereType<PropertyTileData>()
          .where((property) => property.ownerId == player.id)
          .fold<int>(0, (total, property) => total + property.upgradeLevel);
      return _payBank(player, upgradeCount * repairRate);
    }

    switch (action) {
      case 'advanceGo':
        player.position = 0;
        player.cash += state.getGoBonusForPlayer(player.id);
        return const CardEffectResult(landingPosition: 0, passedGo: true);
      case 'nearestRailroad':
        return _moveToNearestType(player, TileType.railroad);
      case 'nearestUtility':
        return _moveToNearestType(player, TileType.utility);
      case 'goToJail':
        _gameEngine.sendToJail(player);
        return CardEffectResult(landingPosition: player.position);
      case 'freeUpgrade':
        final eligibleProperties =
            state.tiles
                .whereType<PropertyTileData>()
                .where(
                  (property) =>
                      property.ownerId == player.id && property.canUpgrade,
                )
                .toList();
        if (eligibleProperties.isNotEmpty) {
          eligibleProperties[_random.nextInt(eligibleProperties.length)]
              .upgradeLevel++;
        }
        return const CardEffectResult();
      default:
        throw ArgumentError.value(action, 'action', 'Unsupported card action');
    }
  }

  CardEffectResult _payBank(Player player, int amount) {
    if (amount == 0) return const CardEffectResult();
    final payment = _gameEngine.payTax(player, amount);
    return CardEffectResult(bankruptcy: payment.bankruptcy);
  }

  CardEffectResult _moveForward(Player player, int spaces) {
    final tileCount = state.tiles.length;
    final passedGo = player.position + spaces >= tileCount;
    player.position = (player.position + spaces) % tileCount;
    if (passedGo) {
      player.cash += state.getGoBonusForPlayer(player.id);
    }
    return CardEffectResult(
      landingPosition: player.position,
      resolveLanding: true,
      passedGo: passedGo,
    );
  }

  CardEffectResult _moveToNearestType(Player player, TileType type) {
    final tileCount = state.tiles.length;
    for (var spaces = 1; spaces < tileCount; spaces++) {
      final destination = (player.position + spaces) % tileCount;
      if (state.tiles[destination].type == type) {
        return _moveForward(player, spaces);
      }
    }
    return const CardEffectResult();
  }

  Iterable<Player> _otherActivePlayers(Player player) =>
      state.activePlayers.where((other) => other.id != player.id);

  static int? _amountFrom(RegExp pattern, String action) {
    final match = pattern.firstMatch(action);
    return match == null ? null : int.parse(match.group(1)!);
  }
}
