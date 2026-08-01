import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/engine/card_effect_engine.dart';
import 'package:property_tycoon/services/game_content_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'every locale has matching expanded card decks and valid actions',
    () async {
      List<String>? expectedChanceActions;
      List<String>? expectedChestActions;

      for (final language in ['en', 'es', 'fr', 'ja', 'zh']) {
        GameContentLoader.instance.clearCache();
        final cards = await GameContentLoader.instance.loadCards(
          Locale(language),
        );
        final chance = cards['chance']!;
        final chest = cards['communityChest']!;

        expect(chance, hasLength(30), reason: '$language Chance deck');
        expect(chest, hasLength(30), reason: '$language Community Chest deck');

        final chanceActions =
            chance.map((card) => card['action']! as String).toList();
        final chestActions =
            chest.map((card) => card['action']! as String).toList();
        expect(
          [
            ...chanceActions,
            ...chestActions,
          ].every(CardEffectEngine.supportsAction),
          isTrue,
          reason: '$language contains an unsupported action',
        );
        expect(
          {...chanceActions, ...chestActions},
          hasLength(greaterThanOrEqualTo(20)),
          reason: '$language should keep meaningful effect variety',
        );

        expectedChanceActions ??= chanceActions;
        expectedChestActions ??= chestActions;
        expect(chanceActions, expectedChanceActions, reason: language);
        expect(chestActions, expectedChestActions, reason: language);
      }
    },
  );
}
