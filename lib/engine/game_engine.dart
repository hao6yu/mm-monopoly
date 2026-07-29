import 'package:flutter/material.dart' show Color;
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/tile.dart';
import '../models/power_up_card.dart';
import '../models/event_card.dart';
import '../models/spin_prize.dart';
import '../config/constants.dart';

/// Result of resolving a tile landing
class TileResolutionResult {
  final TileActionType actionType;
  final String? message;
  final int? amount;
  final String? targetPlayerId;
  final TileData? tile;

  const TileResolutionResult({
    required this.actionType,
    this.message,
    this.amount,
    this.targetPlayerId,
    this.tile,
  });
}

/// Types of actions that can result from landing on a tile
enum TileActionType {
  nothing, // Free Parking, Just Visiting
  buyProperty, // Unowned property
  payRent, // Owned property
  payTax, // Tax tile
  drawCard, // Chance/Community Chest
  goToJail, // Go To Jail corner
  collectGo, // Passed or landed on GO
  upgradeProperty, // Player landed on own property and can upgrade
  spinWheel, // Phase 3: Lucky spin wheel on Free Parking
  miniGame, // Phase 3: Mini-game on Chance/Community Chest
}

/// Main game engine that handles all game logic
class GameEngine {
  final GameState state;

  GameEngine(this.state);

  /// Resolve what happens when a player lands on a tile
  TileResolutionResult resolveTileLanding(Player player, int tileIndex) {
    final tile = state.tiles[tileIndex];

    switch (tile.type) {
      case TileType.start:
        // Landing on GO - already collected $200 when passing
        return const TileResolutionResult(
          actionType: TileActionType.nothing,
          message: 'Welcome to GO!',
        );

      case TileType.property:
        return _resolveProperty(player, tile as PropertyTileData);

      case TileType.railroad:
        return _resolveRailroad(player, tile as RailroadTileData);

      case TileType.utility:
        return _resolveUtility(player, tile as UtilityTileData);

      case TileType.tax:
        return _resolveTax(tile as TaxTileData);

      case TileType.chance:
      case TileType.communityChest:
        return TileResolutionResult(
          actionType: TileActionType.drawCard,
          message:
              tile.type == TileType.chance
                  ? 'Draw a Chance card!'
                  : 'Draw a Comm Chest card!',
          tile: tile,
        );

      case TileType.jail:
        // Just visiting
        return const TileResolutionResult(
          actionType: TileActionType.nothing,
          message: 'Just visiting!',
        );

      case TileType.goToJail:
        return const TileResolutionResult(
          actionType: TileActionType.goToJail,
          message: 'Go to Jail!',
        );

      case TileType.freeParking:
        // Phase 3: Free Parking triggers the spin wheel
        return const TileResolutionResult(
          actionType: TileActionType.spinWheel,
          message: 'Lucky Spin! Spin the wheel for a prize!',
        );
    }
  }

  TileResolutionResult _resolveProperty(
    Player player,
    PropertyTileData property,
  ) {
    if (property.ownerId == null) {
      // Unowned - can buy
      final price = getPurchasePrice(player, property);
      return TileResolutionResult(
        actionType: TileActionType.buyProperty,
        message:
            price < property.price
                ? 'Sale! Buy ${property.name} for \$$price (was \$${property.price})?'
                : 'Would you like to buy ${property.name}?',
        amount: price,
        tile: property,
      );
    } else if (property.ownerId == player.id) {
      // Own property - offer upgrade if possible
      if (property.canUpgrade) {
        return TileResolutionResult(
          actionType: TileActionType.upgradeProperty,
          message: 'Upgrade ${property.name}?',
          amount: property.upgradeCost,
          tile: property,
        );
      }
      return TileResolutionResult(
        actionType: TileActionType.nothing,
        message: 'Welcome home to ${property.name}!',
      );
    } else if (property.isMortgaged) {
      // No rent on mortgaged properties
      return TileResolutionResult(
        actionType: TileActionType.nothing,
        message: '${property.name} is mortgaged - no rent due!',
      );
    } else {
      // Pay rent (with Phase 3 modifiers)
      int rent = property.currentRent;

      // Apply event modifiers (rent strike, market boom)
      rent = (rent * state.getRentModifier()).round();

      // Apply owner's double rent power-up
      if (state.hasDoubleRent(property.ownerId!)) {
        rent *= 2;
      }

      // Apply payer's rent reducer power-up
      if (state.hasActivePowerUp(player.id, PowerUpType.rentReducer)) {
        rent = (rent * 0.5).round();
      }

      return TileResolutionResult(
        actionType: TileActionType.payRent,
        message: 'Pay \$$rent rent to ${_getPlayerName(property.ownerId!)}',
        amount: rent,
        targetPlayerId: property.ownerId,
        tile: property,
      );
    }
  }

  TileResolutionResult _resolveRailroad(
    Player player,
    RailroadTileData railroad,
  ) {
    if (railroad.ownerId == null) {
      final price = getPurchasePrice(player, railroad);
      return TileResolutionResult(
        actionType: TileActionType.buyProperty,
        message:
            price < railroad.price
                ? 'Sale! Buy ${railroad.name} for \$$price (was \$${railroad.price})?'
                : 'Would you like to buy ${railroad.name}?',
        amount: price,
        tile: railroad,
      );
    } else if (railroad.ownerId == player.id) {
      return TileResolutionResult(
        actionType: TileActionType.nothing,
        message: 'Welcome to your railroad!',
      );
    } else if (railroad.isMortgaged) {
      // No rent on mortgaged properties
      return TileResolutionResult(
        actionType: TileActionType.nothing,
        message: '${railroad.name} is mortgaged - no rent due!',
      );
    } else {
      final ownedCount = _countOwnedRailroads(railroad.ownerId!);
      int rent = railroad.getRent(ownedCount);

      // Apply event modifiers
      rent = (rent * state.getRentModifier()).round();

      // Apply owner's double rent power-up
      if (state.hasDoubleRent(railroad.ownerId!)) {
        rent *= 2;
      }

      // Apply payer's rent reducer power-up
      if (state.hasActivePowerUp(player.id, PowerUpType.rentReducer)) {
        rent = (rent * 0.5).round();
      }

      return TileResolutionResult(
        actionType: TileActionType.payRent,
        message: 'Pay \$$rent to ${_getPlayerName(railroad.ownerId!)}',
        amount: rent,
        targetPlayerId: railroad.ownerId,
        tile: railroad,
      );
    }
  }

  TileResolutionResult _resolveUtility(Player player, UtilityTileData utility) {
    if (utility.ownerId == null) {
      final price = getPurchasePrice(player, utility);
      return TileResolutionResult(
        actionType: TileActionType.buyProperty,
        message:
            price < utility.price
                ? 'Sale! Buy ${utility.name} for \$$price (was \$${utility.price})?'
                : 'Would you like to buy ${utility.name}?',
        amount: price,
        tile: utility,
      );
    } else if (utility.ownerId == player.id) {
      return TileResolutionResult(
        actionType: TileActionType.nothing,
        message: 'Welcome to your utility!',
      );
    } else if (utility.isMortgaged) {
      // No rent on mortgaged properties
      return TileResolutionResult(
        actionType: TileActionType.nothing,
        message: '${utility.name} is mortgaged - no rent due!',
      );
    } else {
      final ownedCount = _countOwnedUtilities(utility.ownerId!);
      int rent = utility.getRent(state.lastDiceRoll, ownedCount);

      // Apply event modifiers
      rent = (rent * state.getRentModifier()).round();

      // Apply owner's double rent power-up
      if (state.hasDoubleRent(utility.ownerId!)) {
        rent *= 2;
      }

      // Apply payer's rent reducer power-up
      if (state.hasActivePowerUp(player.id, PowerUpType.rentReducer)) {
        rent = (rent * 0.5).round();
      }

      return TileResolutionResult(
        actionType: TileActionType.payRent,
        message: 'Pay \$$rent to ${_getPlayerName(utility.ownerId!)}',
        amount: rent,
        targetPlayerId: utility.ownerId,
        tile: utility,
      );
    }
  }

  TileResolutionResult _resolveTax(TaxTileData tax) {
    // Phase 3: Check for tax holiday event
    if (state.isTaxHoliday) {
      return const TileResolutionResult(
        actionType: TileActionType.nothing,
        message: 'Tax Holiday! No taxes today!',
      );
    }
    return TileResolutionResult(
      actionType: TileActionType.payTax,
      message: 'Pay \$${tax.amount} tax',
      amount: tax.amount,
      tile: tax,
    );
  }

  /// Buy a property for the current player
  bool buyProperty(Player player, TileData tile) {
    if (tile is PropertyTileData) {
      if (tile.ownerId != null) return false;
      final price = getPurchasePrice(player, tile);
      if (player.cash < price) return false;

      player.cash -= price;
      tile.ownerId = player.id;
      player.propertyIds.add(tile.index.toString());
      return true;
    } else if (tile is RailroadTileData) {
      if (tile.ownerId != null) return false;
      final price = getPurchasePrice(player, tile);
      if (player.cash < price) return false;

      player.cash -= price;
      tile.ownerId = player.id;
      player.propertyIds.add(tile.index.toString());
      return true;
    } else if (tile is UtilityTileData) {
      if (tile.ownerId != null) return false;
      final price = getPurchasePrice(player, tile);
      if (player.cash < price) return false;

      player.cash -= price;
      tile.ownerId = player.id;
      player.propertyIds.add(tile.index.toString());
      return true;
    }

    return false;
  }

  /// Pay rent to another player
  PaymentResult payRent(Player payer, String receiverId, int amount) {
    // Phase 3: Check for shield (blocks rent payment)
    if (state.hasShield(payer.id)) {
      state.playerShields[payer.id] = false; // Use the shield
      return PaymentResult(success: true, paidAmount: 0, shieldUsed: true);
    }

    final receiver = state.players.firstWhere((p) => p.id == receiverId);

    // Clear owner's double rent after use
    state.playerDoubleRent[receiverId] = false;

    if (payer.cash >= amount) {
      payer.cash -= amount;
      receiver.cash += amount;
      return PaymentResult(success: true, paidAmount: amount);
    } else {
      // Bankruptcy - pay what they have
      final paidAmount = payer.cash;
      receiver.cash += paidAmount;
      payer.cash = 0;
      payer.status = PlayerStatus.bankrupt;

      // Transfer all properties to receiver (or bank)
      _transferProperties(payer, receiver);

      return PaymentResult(
        success: false,
        paidAmount: paidAmount,
        bankruptcy: true,
      );
    }
  }

  /// Pay tax to the bank
  PaymentResult payTax(Player player, int amount) {
    if (player.cash >= amount) {
      player.cash -= amount;
      return PaymentResult(success: true, paidAmount: amount);
    } else {
      // Bankruptcy
      final paidAmount = player.cash;
      player.cash = 0;
      player.status = PlayerStatus.bankrupt;
      _returnPropertiesToBank(player);

      return PaymentResult(
        success: false,
        paidAmount: paidAmount,
        bankruptcy: true,
      );
    }
  }

  /// Send player to jail
  void sendToJail(Player player) {
    player.position = GameConstants.jailPosition;
    player.jailTurnsRemaining = 1; // Simplified: 1 turn in jail
  }

  /// Pay to get out of jail
  bool payJailBail(Player player) {
    if (player.cash >= GameConstants.jailBailAmount) {
      player.cash -= GameConstants.jailBailAmount;
      player.jailTurnsRemaining = 0;
      return true;
    }
    return false;
  }

  /// Upgrade a property (buy a house or hotel)
  bool upgradeProperty(Player player, PropertyTileData property) {
    if (property.ownerId != player.id) return false;
    if (!property.canUpgrade) return false;

    final cost = property.upgradeCost;
    if (player.cash < cost) return false;

    player.cash -= cost;
    property.upgradeLevel++;
    return true;
  }

  /// Mortgage a property to receive cash
  bool mortgageProperty(Player player, TileData tile) {
    int mortgageValue = 0;

    if (tile is PropertyTileData) {
      if (tile.ownerId != player.id || !tile.canMortgage) return false;
      mortgageValue = tile.mortgageValue;
      tile.isMortgaged = true;
    } else if (tile is RailroadTileData) {
      if (tile.ownerId != player.id || !tile.canMortgage) return false;
      mortgageValue = tile.mortgageValue;
      tile.isMortgaged = true;
    } else if (tile is UtilityTileData) {
      if (tile.ownerId != player.id || !tile.canMortgage) return false;
      mortgageValue = tile.mortgageValue;
      tile.isMortgaged = true;
    } else {
      return false;
    }

    player.cash += mortgageValue;
    return true;
  }

  /// Unmortgage a property by paying the mortgage cost + 10% interest
  bool unmortgageProperty(Player player, TileData tile) {
    int unmortgageCost = 0;

    if (tile is PropertyTileData) {
      if (tile.ownerId != player.id || !tile.canUnmortgage) return false;
      unmortgageCost = tile.unmortgageCost;
      if (player.cash < unmortgageCost) return false;
      tile.isMortgaged = false;
    } else if (tile is RailroadTileData) {
      if (tile.ownerId != player.id || !tile.canUnmortgage) return false;
      unmortgageCost = tile.unmortgageCost;
      if (player.cash < unmortgageCost) return false;
      tile.isMortgaged = false;
    } else if (tile is UtilityTileData) {
      if (tile.ownerId != player.id || !tile.canUnmortgage) return false;
      unmortgageCost = tile.unmortgageCost;
      if (player.cash < unmortgageCost) return false;
      tile.isMortgaged = false;
    } else {
      return false;
    }

    player.cash -= unmortgageCost;
    return true;
  }

  /// Get all properties owned by a player that can be mortgaged
  List<TileData> getMortgageableProperties(Player player) {
    final result = <TileData>[];
    for (final tile in state.tiles) {
      if (tile is PropertyTileData &&
          tile.ownerId == player.id &&
          tile.canMortgage) {
        result.add(tile);
      } else if (tile is RailroadTileData &&
          tile.ownerId == player.id &&
          tile.canMortgage) {
        result.add(tile);
      } else if (tile is UtilityTileData &&
          tile.ownerId == player.id &&
          tile.canMortgage) {
        result.add(tile);
      }
    }
    return result;
  }

  /// Get all mortgaged properties owned by a player
  List<TileData> getMortgagedProperties(Player player) {
    final result = <TileData>[];
    for (final tile in state.tiles) {
      if (tile is PropertyTileData &&
          tile.ownerId == player.id &&
          tile.isMortgaged) {
        result.add(tile);
      } else if (tile is RailroadTileData &&
          tile.ownerId == player.id &&
          tile.isMortgaged) {
        result.add(tile);
      } else if (tile is UtilityTileData &&
          tile.ownerId == player.id &&
          tile.isMortgaged) {
        result.add(tile);
      }
    }
    return result;
  }

  /// Process passing GO (collect $200)
  void processPassGo(Player player) {
    player.cash += state.getGoBonusForPlayer(player.id);
  }

  /// Check if player passed GO during movement
  bool didPassGo(int startPosition, int endPosition, int steps) {
    // If we moved forward and crossed position 0
    return startPosition + steps >= state.tiles.length;
  }

  // Helper methods

  String _getPlayerName(String playerId) {
    return state.players.firstWhere((p) => p.id == playerId).name;
  }

  int _countOwnedRailroads(String ownerId) {
    return state.tiles
        .whereType<RailroadTileData>()
        .where((r) => r.ownerId == ownerId)
        .length;
  }

  int _countOwnedUtilities(String ownerId) {
    return state.tiles
        .whereType<UtilityTileData>()
        .where((u) => u.ownerId == ownerId)
        .length;
  }

  /// Get accurate net worth for a player including all property values
  int getPlayerNetWorth(Player player) {
    return player.calculateNetWorth(state.tiles);
  }

  /// Get adjusted purchase price for a property-like tile based on active modifiers
  int getPurchasePrice(Player player, TileData tile) {
    final basePrice = _getBaseTilePrice(tile);
    if (basePrice == null) return 0;

    double modifier = state.getPropertyPriceModifier();
    if (state.hasActivePowerUp(player.id, PowerUpType.priceFreeze)) {
      modifier *= 0.75;
    }
    return (basePrice * modifier).round();
  }

  void _transferProperties(Player from, Player to) {
    for (final tile in state.tiles) {
      if (tile is PropertyTileData && tile.ownerId == from.id) {
        tile.ownerId = to.id;
        to.propertyIds.add(tile.index.toString());
      } else if (tile is RailroadTileData && tile.ownerId == from.id) {
        tile.ownerId = to.id;
        to.propertyIds.add(tile.index.toString());
      } else if (tile is UtilityTileData && tile.ownerId == from.id) {
        tile.ownerId = to.id;
        to.propertyIds.add(tile.index.toString());
      }
    }
    from.propertyIds.clear();
  }

  void _returnPropertiesToBank(Player player) {
    for (final tile in state.tiles) {
      if (tile is PropertyTileData && tile.ownerId == player.id) {
        tile.ownerId = null;
      } else if (tile is RailroadTileData && tile.ownerId == player.id) {
        tile.ownerId = null;
      } else if (tile is UtilityTileData && tile.ownerId == player.id) {
        tile.ownerId = null;
      }
    }
    player.propertyIds.clear();
  }

  int? _getBaseTilePrice(TileData tile) {
    if (tile is PropertyTileData) return tile.price;
    if (tile is RailroadTileData) return tile.price;
    if (tile is UtilityTileData) return tile.price;
    return null;
  }

  /// Get property info for display
  PropertyInfo? getPropertyInfo(int tileIndex) {
    final tile = state.tiles[tileIndex];

    if (tile is PropertyTileData) {
      return PropertyInfo(
        name: tile.name,
        price: tile.price,
        rent: tile.currentRent,
        color: tile.groupColor,
        ownerId: tile.ownerId,
        ownerName: tile.ownerId != null ? _getPlayerName(tile.ownerId!) : null,
      );
    } else if (tile is RailroadTileData) {
      final ownedCount =
          tile.ownerId != null ? _countOwnedRailroads(tile.ownerId!) : 0;
      return PropertyInfo(
        name: tile.name,
        price: tile.price,
        rent: ownedCount > 0 ? tile.getRent(ownedCount) : 25,
        ownerId: tile.ownerId,
        ownerName: tile.ownerId != null ? _getPlayerName(tile.ownerId!) : null,
      );
    } else if (tile is UtilityTileData) {
      return PropertyInfo(
        name: tile.name,
        price: tile.price,
        rent: 0, // Utility rent depends on dice roll
        ownerId: tile.ownerId,
        ownerName: tile.ownerId != null ? _getPlayerName(tile.ownerId!) : null,
      );
    }

    return null;
  }
}

/// Result of a payment attempt
class PaymentResult {
  final bool success;
  final int paidAmount;
  final bool bankruptcy;
  final bool shieldUsed; // Phase 3: Shield blocked rent

  const PaymentResult({
    required this.success,
    required this.paidAmount,
    this.bankruptcy = false,
    this.shieldUsed = false,
  });
}

/// Property information for display
class PropertyInfo {
  final String name;
  final int price;
  final int rent;
  final Color? color;
  final String? ownerId;
  final String? ownerName;

  const PropertyInfo({
    required this.name,
    required this.price,
    required this.rent,
    this.color,
    this.ownerId,
    this.ownerName,
  });

  bool get isOwned => ownerId != null;
}

// ============================================================================
// Phase 3: Power-Up, Event, and Spin Prize Logic
// ============================================================================

/// Apply a spin wheel prize to a player
void applySpinPrize(Player player, SpinPrize prize, GameState state) {
  switch (prize.type) {
    case SpinPrizeType.cash:
    case SpinPrizeType.jackpot:
      player.cash += prize.value ?? 0;
      break;

    case SpinPrizeType.freeHouse:
      // Store as a spin prize for later use
      state.playerSpinPrizes[player.id] ??= [];
      state.playerSpinPrizes[player.id]!.add(prize);
      break;

    case SpinPrizeType.doubleRent:
      state.playerDoubleRent[player.id] = true;
      break;

    case SpinPrizeType.shield:
      state.playerShields[player.id] = true;
      break;

    case SpinPrizeType.teleport:
      // Store for player to choose tile
      state.playerSpinPrizes[player.id] ??= [];
      state.playerSpinPrizes[player.id]!.add(prize);
      break;
  }
}

/// Apply an event effect to all players
void applyEventEffect(EventCard event, GameState state) {
  switch (event.effectType) {
    case EventEffectType.luckyDay:
      // Everyone gets cash
      for (final player in state.activePlayers) {
        player.cash += event.value ?? 50;
      }
      break;

    case EventEffectType.birthdayParty:
      // Current player collects from others
      final currentPlayer = state.currentPlayer;
      final otherPlayers = state.activePlayers.where(
        (p) => p.id != currentPlayer.id,
      );
      for (final player in otherPlayers) {
        final amount = event.value ?? 25;
        if (player.cash >= amount) {
          player.cash -= amount;
          currentPlayer.cash += amount;
        } else {
          currentPlayer.cash += player.cash;
          player.cash = 0;
        }
      }
      break;

    case EventEffectType.stockDividend:
      // Cash per property
      for (final player in state.activePlayers) {
        player.cash += player.propertyIds.length * (event.value ?? 10);
      }
      break;

    case EventEffectType.meteorShower:
      // Random player loses cash
      final randomPlayer =
          state.activePlayers[DateTime.now().millisecondsSinceEpoch %
              state.activePlayers.length];
      randomPlayer.cash -= (event.value ?? 100).clamp(0, randomPlayer.cash);
      break;

    case EventEffectType.bankError:
      // Random player gets cash
      final luckyPlayer =
          state.activePlayers[DateTime.now().millisecond %
              state.activePlayers.length];
      luckyPlayer.cash += event.value ?? 200;
      break;

    case EventEffectType.communityCleanup:
      // Pay per house
      for (final player in state.activePlayers) {
        int houseCount = 0;
        for (final tile in state.tiles) {
          if (tile is PropertyTileData && tile.ownerId == player.id) {
            houseCount += tile.upgradeLevel;
          }
        }
        player.cash -= (houseCount * (event.value ?? 25)).clamp(0, player.cash);
      }
      break;

    case EventEffectType.housingBoom:
      // Free upgrade on a random owned property
      for (final player in state.activePlayers) {
        final ownedProps =
            state.tiles
                .whereType<PropertyTileData>()
                .where((t) => t.ownerId == player.id && t.canUpgrade)
                .toList();
        if (ownedProps.isNotEmpty) {
          final prop =
              ownedProps[DateTime.now().millisecond % ownedProps.length];
          prop.upgradeLevel++;
        }
      }
      break;

    // Timed events (handled by game state modifiers)
    case EventEffectType.marketBoom:
    case EventEffectType.taxHoliday:
    case EventEffectType.goldRush:
    case EventEffectType.propertySale:
    case EventEffectType.rentStrike:
    case EventEffectType.marketCrash:
      // These are handled through state.hasActiveEvent() checks
      if (event.duration != null) {
        state.activeEvents.add(
          ActiveEvent(event: event, remainingRounds: event.duration!),
        );
      }
      break;
  }
}

/// Apply a power-up card effect
void applyPowerUpCard(Player player, PowerUpCard card, GameState state) {
  switch (card.type) {
    case PowerUpType.rentReducer:
      state.activePowerUps.add(
        ActivePowerUp(card: card, playerId: player.id, remainingTurns: 1),
      );
      break;

    case PowerUpType.speedBoost:
      state.hasExtraTurn = true;
      break;

    case PowerUpType.propertyScout:
      // UI handles showing property info
      break;

    case PowerUpType.rentCollector:
      // Collect from all players
      for (final other in state.activePlayers) {
        if (other.id != player.id) {
          final amount = 50.clamp(0, other.cash);
          other.cash -= amount;
          player.cash += amount;
        }
      }
      break;

    case PowerUpType.priceFreeze:
      state.activePowerUps.add(
        ActivePowerUp(card: card, playerId: player.id, remainingTurns: 1),
      );
      break;

    case PowerUpType.teleporter:
      // UI handles tile selection
      break;

    case PowerUpType.shield:
      state.playerShields[player.id] = true;
      break;

    case PowerUpType.doubleDice:
      state.activePowerUps.add(
        ActivePowerUp(card: card, playerId: player.id, remainingTurns: 1),
      );
      break;

    case PowerUpType.moneyMagnet:
      state.activePowerUps.add(
        ActivePowerUp(
          card: card,
          playerId: player.id,
          remainingTurns: card.duration ?? 3,
        ),
      );
      break;

    case PowerUpType.monopolyMaster:
      // Free house on all owned properties
      for (final tile in state.tiles) {
        if (tile is PropertyTileData &&
            tile.ownerId == player.id &&
            tile.canUpgrade) {
          tile.upgradeLevel++;
        }
      }
      break;
  }

  // Remove from player's hand
  state.removePowerUp(player.id, card.id);
}

/// Award a power-up card to a player (chance/community chest mini-game win)
void awardPowerUpCard(
  Player player,
  GameState state, {
  bool guaranteeRare = false,
}) {
  final card = PowerUpCards.getRandomCard(guaranteeRare: guaranteeRare);
  state.addPowerUp(player.id, card);
}
