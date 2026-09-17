import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/config/board_factory.dart';
import 'package:property_tycoon/config/city_board_registry.dart';
import 'package:property_tycoon/integration/godot_board_controller.dart';
import 'package:property_tycoon/l10n/app_localizations.dart';
import 'package:property_tycoon/models/avatar.dart';
import 'package:property_tycoon/models/game_state.dart';
import 'package:property_tycoon/models/player.dart';
import 'package:property_tycoon/widgets/player/game_status_rail.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('3D-05 appearance contract', () {
    test('scene state carries the effective avatar identity', () {
      final customAvatar = Avatar.custom(
        id: 'custom-photo-1',
        name: 'Custom',
        imagePath: '/tmp/not-used-here.png',
      );
      final player = Player(
        id: 'player_0',
        name: 'Player 1',
        icon: PlayerIcon.dog,
        color: Colors.red,
        avatar: customAvatar,
      );
      final state = GameState.initial(
        players: [player],
        tiles: BoardFactory.generateTiles(CityBoardRegistry.all.first),
      );

      final controller = GodotBoardController();
      addTearDown(controller.dispose);
      final sceneState = controller.sceneStateFrom(
        state,
        boardId: CityBoardRegistry.all.first.boardId,
        stateGeneration: 1,
      );

      expect(sceneState.players.first.avatarId, 'custom-photo-1');
      expect(sceneState.players.first.avatarIsPhoto, isTrue);
      final json = sceneState.toJson();
      expect(
        (json['players'] as List<Object?>).first,
        containsPair('avatarId', 'custom-photo-1'),
      );
      expect(
        (json['players'] as List<Object?>).first,
        containsPair('avatarIsPhoto', true),
      );
    });

    test('default avatars fall back to the seat catalog identity', () {
      final player = Player(
        id: 'player_0',
        name: 'Player 1',
        icon: PlayerIcon.dog,
        color: Colors.red,
      );
      final state = GameState.initial(
        players: [player],
        tiles: BoardFactory.generateTiles(CityBoardRegistry.all.first),
      );

      final controller = GodotBoardController();
      addTearDown(controller.dispose);
      final sceneState = controller.sceneStateFrom(
        state,
        boardId: CityBoardRegistry.all.first.boardId,
        stateGeneration: 1,
      );

      expect(sceneState.players.first.avatarId, player.effectiveAvatar.id);
      expect(player.effectiveAvatar.isCustom, isFalse);
      expect(player.effectiveAvatar.emoji, isNotEmpty);
    });
  });

  group('3D-05 rail identity', () {
    // 1x1 transparent PNG so Image.file has decodable bytes in the test env.
    const pixelPngBase64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

    List<Player> players({Avatar? playerOneAvatar}) {
      return [
        Player(
          id: 'player_0',
          name: 'Mia',
          icon: PlayerIcon.dog,
          color: Colors.red,
          avatar: playerOneAvatar,
        ),
        Player(
          id: 'player_1',
          name: 'Noah',
          icon: PlayerIcon.car,
          color: Colors.blue,
        ),
        Player(
          id: 'player_2',
          name: 'Cora',
          icon: PlayerIcon.crown,
          color: Colors.amber,
          isAI: true,
        ),
        Player(
          id: 'player_3',
          name: 'Max',
          icon: PlayerIcon.rocket,
          color: Colors.green,
          isAI: true,
        ),
      ];
    }

    GameState stateFrom(List<Player> players) => GameState(
      id: 'hud-test',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      players: players,
      tiles: const [],
      currentPlayerIndex: 0,
      roundNumber: 1,
    );

    Widget app(GameState state) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: GameStatusRail(
              gameState: state,
              boardReady: true,
              isProcessingTurn: false,
              interactionsEnabled: false,
            ),
          ),
        ),
      );
    }

    test('custom-photo players resolve to their photo path', () {
      final directory = Directory.systemTemp.createTempSync('rail_avatar');
      addTearDown(() => directory.deleteSync(recursive: true));
      final photoPath = '${directory.path}/me.png';
      File(photoPath).writeAsBytesSync(base64Decode(pixelPngBase64));

      final customPlayer = players(
        playerOneAvatar: Avatar.custom(
          id: 'custom-photo-1',
          name: 'Custom',
          imagePath: photoPath,
        ),
      ).first;
      final defaultPlayer = players().first;

      // Image.file pixel rendering hangs in the widget-test frame, so the
      // photo decision is asserted on the extracted helper instead.
      expect(railAvatarPhotoPath(customPlayer), photoPath);
      expect(railAvatarPhotoPath(defaultPlayer), isNull);
    });

    testWidgets('default players show their avatar emoji, not the icon', (
      tester,
    ) async {
      final gameState = stateFrom(players());
      final playerEmoji = gameState.players.first.effectiveAvatar.emoji;

      await tester.pumpWidget(app(gameState));
      await tester.pump(const Duration(milliseconds: 300));

      expect(playerEmoji, isNotEmpty);
      expect(find.text(playerEmoji), findsOneWidget);
    });
  });
}
