import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../engine/card_effect_engine.dart';

/// Service for loading localized game content (board tiles, cards) from JSON assets
class GameContentLoader {
  static final GameContentLoader instance = GameContentLoader._();
  GameContentLoader._();

  /// Cache for loaded board data: key = "locale_board" e.g. "en_usa"
  final Map<String, List<Map<String, dynamic>>> _boardCache = {};

  /// Cache for loaded card data: key = locale code
  final Map<String, Map<String, List<Map<String, dynamic>>>> _cardCache = {};

  /// Load localized tile text overlays for a board
  /// Returns list of {index, name, subtext, funFact} maps
  Future<List<Map<String, dynamic>>> loadBoardTiles(
    String boardId,
    Locale locale,
  ) async {
    final lang = locale.languageCode;
    final cacheKey = '${lang}_$boardId';

    if (_boardCache.containsKey(cacheKey)) {
      return _boardCache[cacheKey]!;
    }

    try {
      final jsonStr = await rootBundle.loadString(
        'assets/l10n/boards/$lang/$boardId.json',
      );
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final tiles = (data['tiles'] as List).cast<Map<String, dynamic>>();
      _boardCache[cacheKey] = tiles;
      return tiles;
    } catch (_) {
      // Fallback to English
      if (lang != 'en') {
        return loadBoardTiles(boardId, const Locale('en'));
      }
      return [];
    }
  }

  /// Load localized chance and community chest cards
  /// Returns {"chance": [...], "communityChest": [...]}
  Future<Map<String, List<Map<String, dynamic>>>> loadCards(
    Locale locale,
  ) async {
    final lang = locale.languageCode;

    if (_cardCache.containsKey(lang)) {
      return _cardCache[lang]!;
    }

    try {
      final jsonStr = await rootBundle.loadString(
        'assets/l10n/cards/$lang.json',
      );
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final result = <String, List<Map<String, dynamic>>>{
        'chance': _validatedCardDeck(data['chance']),
        'communityChest': _validatedCardDeck(data['communityChest']),
      };
      if (result['chance']!.isEmpty || result['communityChest']!.isEmpty) {
        throw const FormatException('Card decks must not be empty');
      }
      _cardCache[lang] = result;
      return result;
    } catch (_) {
      // Fallback to English
      if (lang != 'en') {
        return loadCards(const Locale('en'));
      }
      return {'chance': [], 'communityChest': []};
    }
  }

  /// Clear all caches (e.g. when language changes)
  void clearCache() {
    _boardCache.clear();
    _cardCache.clear();
  }

  static List<Map<String, dynamic>> _validatedCardDeck(Object? rawDeck) {
    if (rawDeck is! List) return [];

    return rawDeck
        .whereType<Map<String, dynamic>>()
        .where((card) {
          final text = card['text'];
          final effect = card['effect'];
          final action = card['action'];
          return text is String &&
              text.isNotEmpty &&
              effect is String &&
              effect.isNotEmpty &&
              action is String &&
              CardEffectEngine.supportsAction(action);
        })
        .toList(growable: false);
  }
}
