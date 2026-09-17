import 'package:flutter/material.dart';
import '../models/tile.dart';
import '../models/country.dart';
import '../models/city_board.dart';
import '../models/board_theme.dart';
import '../services/game_content_loader.dart';
import 'board_configs/classic_board.dart';
import 'board_configs/uk_board.dart';
import 'board_configs/japan_board.dart';
import 'board_configs/france_board.dart';
import 'board_configs/china_board.dart';
import 'board_configs/mexico_board.dart';
import 'board_configs/new_york_board.dart';
import 'board_configs/los_angeles_board.dart';
import 'board_configs/edinburgh_board.dart';
import 'board_configs/manchester_board.dart';
import 'board_configs/lyon_board.dart';
import 'board_configs/marseille_board.dart';
import 'board_configs/osaka_board.dart';
import 'board_configs/kyoto_board.dart';
import 'board_configs/shanghai_board.dart';
import 'board_configs/hong_kong_board.dart';
import 'board_configs/guadalajara_board.dart';
import 'board_configs/cancun_board.dart';

/// Factory class to generate board tiles and themes based on selected city board
class BoardFactory {
  /// Generate tiles for the specified city board (sync, uses default English text)
  static List<TileData> generateTiles(CityBoard cityBoard) {
    switch (cityBoard.boardId) {
      // Existing defaults
      case 'usa':
        return ClassicBoard.generateTiles();
      case 'uk':
        return UKBoard.generateTiles();
      case 'japan':
        return JapanBoard.generateTiles();
      case 'france':
        return FranceBoard.generateTiles();
      case 'china':
        return ChinaBoard.generateTiles();
      case 'mexico':
        return MexicoBoard.generateTiles();
      // New city boards
      case 'usa_new_york':
        return NewYorkBoard.generateTiles();
      case 'usa_los_angeles':
        return LosAngelesBoard.generateTiles();
      case 'uk_edinburgh':
        return EdinburghBoard.generateTiles();
      case 'uk_manchester':
        return ManchesterBoard.generateTiles();
      case 'france_lyon':
        return LyonBoard.generateTiles();
      case 'france_marseille':
        return MarseilleBoard.generateTiles();
      case 'japan_osaka':
        return OsakaBoard.generateTiles();
      case 'japan_kyoto':
        return KyotoBoard.generateTiles();
      case 'china_shanghai':
        return ShanghaiBoard.generateTiles();
      case 'china_hong_kong':
        return HongKongBoard.generateTiles();
      case 'mexico_guadalajara':
        return GuadalajaraBoard.generateTiles();
      case 'mexico_cancun':
        return CancunBoard.generateTiles();
      default:
        return ClassicBoard.generateTiles();
    }
  }

  /// Generate tiles with localized text overlays from JSON
  static Future<List<TileData>> generateLocalizedTiles(
    CityBoard cityBoard,
    Locale locale,
  ) async {
    // Get the base tiles (structural data: prices, rents, colors)
    final tiles = generateTiles(cityBoard);

    // Load localized text overlays using the boardId
    final overlays = await GameContentLoader.instance.loadBoardTiles(
      cityBoard.boardId,
      locale,
    );

    if (overlays.isEmpty) return tiles;

    // Build lookup map by index
    final overlayMap = <int, Map<String, dynamic>>{};
    for (final overlay in overlays) {
      overlayMap[overlay['index'] as int] = overlay;
    }

    // Apply text overlays to tiles
    return tiles.map((tile) {
      final overlay = overlayMap[tile.index];
      if (overlay == null) return tile;

      final name = overlay['name'] as String? ?? tile.name;
      final subtext = overlay['subtext'] as String? ?? tile.subtext;
      final funFact = overlay['funFact'] as String? ?? tile.funFact;

      return _applyTextOverlay(tile, name, subtext, funFact);
    }).toList();
  }

  /// Apply localized text to a tile, returning a new tile of the same type
  static TileData _applyTextOverlay(
    TileData tile,
    String name,
    String? subtext,
    String? funFact,
  ) {
    if (tile is PropertyTileData) {
      return PropertyTileData(
        index: tile.index,
        name: name,
        groupId: tile.groupId,
        groupColor: tile.groupColor,
        price: tile.price,
        rentLevels: tile.rentLevels,
        funFact: funFact,
        subtext: subtext,
      );
    } else if (tile is RailroadTileData) {
      return RailroadTileData(
        index: tile.index,
        name: name,
        price: tile.price,
        funFact: funFact,
        subtext: subtext,
      );
    } else if (tile is UtilityTileData) {
      return UtilityTileData(
        index: tile.index,
        name: name,
        isElectric: tile.isElectric,
        price: tile.price,
        subtext: subtext,
        funFact: funFact,
      );
    } else if (tile is TaxTileData) {
      return TaxTileData(
        index: tile.index,
        name: name,
        amount: tile.amount,
        percentage: tile.percentage,
      );
    } else if (tile is CardTileData) {
      return CardTileData(
        index: tile.index,
        name: name,
        isChance: tile.isChance,
      );
    } else if (tile is CornerTileData) {
      return CornerTileData(
        index: tile.index,
        name: name,
        type: tile.type,
        color: tile.color,
        subtext: subtext,
      );
    }
    return tile;
  }

  /// Get property groups for the specified city board
  static Map<String, List<int>> getPropertyGroups(CityBoard cityBoard) {
    switch (cityBoard.boardId) {
      case 'usa':
        return ClassicBoard.propertyGroups;
      case 'uk':
        return UKBoard.propertyGroups;
      case 'japan':
        return JapanBoard.propertyGroups;
      case 'france':
        return FranceBoard.propertyGroups;
      case 'china':
        return ChinaBoard.propertyGroups;
      case 'mexico':
        return MexicoBoard.propertyGroups;
      case 'usa_new_york':
        return NewYorkBoard.propertyGroups;
      case 'usa_los_angeles':
        return LosAngelesBoard.propertyGroups;
      case 'uk_edinburgh':
        return EdinburghBoard.propertyGroups;
      case 'uk_manchester':
        return ManchesterBoard.propertyGroups;
      case 'france_lyon':
        return LyonBoard.propertyGroups;
      case 'france_marseille':
        return MarseilleBoard.propertyGroups;
      case 'japan_osaka':
        return OsakaBoard.propertyGroups;
      case 'japan_kyoto':
        return KyotoBoard.propertyGroups;
      case 'china_shanghai':
        return ShanghaiBoard.propertyGroups;
      case 'china_hong_kong':
        return HongKongBoard.propertyGroups;
      case 'mexico_guadalajara':
        return GuadalajaraBoard.propertyGroups;
      case 'mexico_cancun':
        return CancunBoard.propertyGroups;
      default:
        return ClassicBoard.propertyGroups;
    }
  }

  /// Get railroad positions for the specified city board
  static List<int> getRailroadPositions(CityBoard cityBoard) {
    switch (cityBoard.boardId) {
      case 'usa':
        return ClassicBoard.railroadPositions;
      case 'uk':
        return UKBoard.railroadPositions;
      case 'japan':
        return JapanBoard.railroadPositions;
      case 'france':
        return FranceBoard.railroadPositions;
      case 'china':
        return ChinaBoard.railroadPositions;
      case 'mexico':
        return MexicoBoard.railroadPositions;
      case 'usa_new_york':
        return NewYorkBoard.railroadPositions;
      case 'usa_los_angeles':
        return LosAngelesBoard.railroadPositions;
      case 'uk_edinburgh':
        return EdinburghBoard.railroadPositions;
      case 'uk_manchester':
        return ManchesterBoard.railroadPositions;
      case 'france_lyon':
        return LyonBoard.railroadPositions;
      case 'france_marseille':
        return MarseilleBoard.railroadPositions;
      case 'japan_osaka':
        return OsakaBoard.railroadPositions;
      case 'japan_kyoto':
        return KyotoBoard.railroadPositions;
      case 'china_shanghai':
        return ShanghaiBoard.railroadPositions;
      case 'china_hong_kong':
        return HongKongBoard.railroadPositions;
      case 'mexico_guadalajara':
        return GuadalajaraBoard.railroadPositions;
      case 'mexico_cancun':
        return CancunBoard.railroadPositions;
      default:
        return ClassicBoard.railroadPositions;
    }
  }

  /// Get board theme for the specified city board (cities share country theme)
  static BoardTheme getThemeForCityBoard(CityBoard cityBoard) {
    return _getCountryTheme(cityBoard.country);
  }

  /// Get board theme for the specified country
  static BoardTheme _getCountryTheme(Country country) {
    switch (country) {
      case Country.usa:
        return BoardThemes.usa;
      case Country.uk:
        return BoardThemes.uk;
      case Country.japan:
        return BoardThemes.japan;
      case Country.france:
        return BoardThemes.france;
      case Country.china:
        return BoardThemes.china;
      case Country.mexico:
        return BoardThemes.mexico;
    }
  }
}
