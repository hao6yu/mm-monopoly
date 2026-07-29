import 'package:flutter/material.dart';
import 'avatar.dart';
import 'tile.dart';
import 'serialization/serialization_helpers.dart';

/// Player status in the game
enum PlayerStatus { active, bankrupt, skipped }

/// Icons available for player selection during game setup
enum PlayerIcon {
  // Animals
  dog,
  cat,
  bunny,
  fox,
  panda,
  lion,
  // Vehicles
  car,
  rocket,
  plane,
  ship,
  train,
  // Objects
  crown,
  star,
  diamond,
  hat,
  guitar,
}

/// Extension to get display properties for PlayerIcon
extension PlayerIconExt on PlayerIcon {
  IconData get iconData {
    switch (this) {
      case PlayerIcon.dog:
        return Icons.pets;
      case PlayerIcon.cat:
        return Icons.emoji_nature;
      case PlayerIcon.bunny:
        return Icons.cruelty_free;
      case PlayerIcon.fox:
        return Icons.pets_outlined;
      case PlayerIcon.panda:
        return Icons.face;
      case PlayerIcon.lion:
        return Icons.sentiment_very_satisfied;
      case PlayerIcon.car:
        return Icons.directions_car;
      case PlayerIcon.rocket:
        return Icons.rocket_launch;
      case PlayerIcon.plane:
        return Icons.flight;
      case PlayerIcon.ship:
        return Icons.directions_boat;
      case PlayerIcon.train:
        return Icons.train;
      case PlayerIcon.crown:
        return Icons.workspace_premium;
      case PlayerIcon.star:
        return Icons.star;
      case PlayerIcon.diamond:
        return Icons.diamond;
      case PlayerIcon.hat:
        return Icons.checkroom;
      case PlayerIcon.guitar:
        return Icons.music_note;
    }
  }

  String get displayName {
    switch (this) {
      case PlayerIcon.dog:
        return 'Puppy';
      case PlayerIcon.cat:
        return 'Kitty';
      case PlayerIcon.bunny:
        return 'Bunny';
      case PlayerIcon.fox:
        return 'Fox';
      case PlayerIcon.panda:
        return 'Panda';
      case PlayerIcon.lion:
        return 'Lion';
      case PlayerIcon.car:
        return 'Race Car';
      case PlayerIcon.rocket:
        return 'Rocket';
      case PlayerIcon.plane:
        return 'Airplane';
      case PlayerIcon.ship:
        return 'Ship';
      case PlayerIcon.train:
        return 'Train';
      case PlayerIcon.crown:
        return 'Crown';
      case PlayerIcon.star:
        return 'Star';
      case PlayerIcon.diamond:
        return 'Diamond';
      case PlayerIcon.hat:
        return 'Top Hat';
      case PlayerIcon.guitar:
        return 'Guitar';
    }
  }
}

/// Represents a player in the game
class Player {
  final String id;
  String name;
  final PlayerIcon icon;
  final Color color;
  final Avatar? avatar; // Custom avatar (Phase 3)

  int cash;
  int position; // Logical tile index for the selected board.
  List<String> propertyIds; // owned property IDs

  PlayerStatus status;
  int skipTurnsRemaining;
  int jailTurnsRemaining;

  bool isAI;
  // AIStrategy? aiStrategy; // Phase 2

  Player({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.avatar,
    this.cash = 1500,
    this.position = 0,
    List<String>? propertyIds,
    this.status = PlayerStatus.active,
    this.skipTurnsRemaining = 0,
    this.jailTurnsRemaining = 0,
    this.isAI = false,
  }) : propertyIds = propertyIds ?? [];

  /// Get the avatar or a default based on player index
  Avatar get effectiveAvatar =>
      avatar ??
      Avatars.forPlayerIndex(int.tryParse(id.replaceAll('player_', '')) ?? 0);

  /// Calculate net worth (cash + property values)
  /// Note: This is a simple getter for backwards compatibility.
  /// For accurate net worth, use calculateNetWorth(tiles) instead.
  @Deprecated('Use calculateNetWorth(tiles) for accurate net worth calculation')
  int get netWorth => cash; // TODO: Add property values when implemented

  /// Calculate accurate net worth including all property values
  /// Mortgaged properties reduce net worth by their mortgage value
  /// Upgraded properties add their upgrade costs
  int calculateNetWorth(List<TileData> tiles) {
    int total = cash;

    for (final tile in tiles) {
      if (tile is PropertyTileData && tile.ownerId == id) {
        if (tile.isMortgaged) {
          total -= tile.mortgageValue;
        } else {
          total += tile.price;
          total += (tile.upgradeLevel * tile.upgradeCost);
        }
      } else if (tile is RailroadTileData && tile.ownerId == id) {
        total += tile.isMortgaged ? -tile.mortgageValue : tile.price;
      } else if (tile is UtilityTileData && tile.ownerId == id) {
        total += tile.isMortgaged ? -tile.mortgageValue : tile.price;
      }
    }

    return total;
  }

  /// Check if player is still in the game
  bool get isPlaying => status == PlayerStatus.active;

  /// Check if player can take their turn
  bool get canTakeTurn => isPlaying && skipTurnsRemaining == 0;

  /// Create a copy with updated fields
  Player copyWith({
    String? id,
    String? name,
    PlayerIcon? icon,
    Color? color,
    Avatar? avatar,
    int? cash,
    int? position,
    List<String>? propertyIds,
    PlayerStatus? status,
    int? skipTurnsRemaining,
    int? jailTurnsRemaining,
    bool? isAI,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      avatar: avatar ?? this.avatar,
      cash: cash ?? this.cash,
      position: position ?? this.position,
      propertyIds: propertyIds ?? List.from(this.propertyIds),
      status: status ?? this.status,
      skipTurnsRemaining: skipTurnsRemaining ?? this.skipTurnsRemaining,
      jailTurnsRemaining: jailTurnsRemaining ?? this.jailTurnsRemaining,
      isAI: isAI ?? this.isAI,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': enumToJson(icon),
      'color': colorToJson(color),
      'avatar': avatarToJson(avatar),
      'cash': cash,
      'position': position,
      'propertyIds': propertyIds,
      'status': enumToJson(status),
      'skipTurnsRemaining': skipTurnsRemaining,
      'jailTurnsRemaining': jailTurnsRemaining,
      'isAI': isAI,
    };
  }

  /// Deserialize from JSON
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: enumFromJson(json['icon'] as String, PlayerIcon.values),
      color: colorFromJson(json['color'] as Map<String, dynamic>),
      avatar: avatarFromJson(json['avatar'] as Map<String, dynamic>?),
      cash: json['cash'] as int,
      position: json['position'] as int,
      propertyIds: List<String>.from(json['propertyIds'] as List),
      status: enumFromJson(json['status'] as String, PlayerStatus.values),
      skipTurnsRemaining: json['skipTurnsRemaining'] as int,
      jailTurnsRemaining: json['jailTurnsRemaining'] as int,
      isAI: json['isAI'] as bool,
    );
  }
}

/// Default player colors
class PlayerColors {
  static const Color player1 = Color(0xFFE53935); // Red
  static const Color player2 = Color(0xFF1E88E5); // Blue
  static const Color player3 = Color(0xFF43A047); // Green
  static const Color player4 = Color(0xFFFB8C00); // Orange

  static const List<Color> all = [player1, player2, player3, player4];

  static Color forIndex(int index) => all[index % all.length];
}
