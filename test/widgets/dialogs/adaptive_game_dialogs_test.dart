import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/config/board_factory.dart';
import 'package:property_tycoon/config/city_board_registry.dart';
import 'package:property_tycoon/l10n/app_localizations.dart';
import 'package:property_tycoon/models/player.dart';
import 'package:property_tycoon/models/tile.dart';
import 'package:property_tycoon/widgets/dialogs/auction_dialog.dart';
import 'package:property_tycoon/widgets/dialogs/buy_property_dialog.dart';
import 'package:property_tycoon/widgets/dialogs/card_pick_dialog.dart';
import 'package:property_tycoon/widgets/dialogs/spin_wheel_dialog.dart';

void main() {
  Future<void> setSurface(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget localizedApp(Widget home, {double textScale = 1}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(body: home),
    );
  }

  testWidgets('buy property dialog is scroll-safe in compact landscape', (
    tester,
  ) async {
    await setSurface(tester, const Size(844, 390));
    final city = CityBoardRegistry.byBoardId('usa_new_york')!;
    final property = BoardFactory.generateTiles(
      city,
    ).whereType<PropertyTileData>().first;

    await tester.pumpWidget(
      localizedApp(
        BuyPropertyDialog(tile: property, playerCash: 1500),
        textScale: 1.3,
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.byKey(const Key('buy-property-content-scroll')),
      findsOneWidget,
    );
    expect(find.text('Skip'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('buy property dialog returns the skip decision', (tester) async {
    await setSurface(tester, const Size(390, 844));
    final city = CityBoardRegistry.byBoardId('usa_new_york')!;
    final property = BoardFactory.generateTiles(
      city,
    ).whereType<PropertyTileData>().first;
    BuyPropertyDecision? decision;

    await tester.pumpWidget(
      localizedApp(
        Builder(
          builder: (context) => FilledButton(
            onPressed: () async {
              decision = await showBuyPropertyDialog(
                context: context,
                tile: property,
                playerCash: 1500,
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(decision, BuyPropertyDecision.skip);
    expect(tester.takeException(), isNull);
  });

  testWidgets('spin wheel dialog is scroll-safe in compact landscape', (
    tester,
  ) async {
    await setSurface(tester, const Size(844, 390));

    await tester.pumpWidget(
      localizedApp(
        SpinWheelDialog(playerName: 'Mia', onPrizeWon: (_) async {}),
        textScale: 1.3,
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('spin-wheel-content-scroll')), findsOneWidget);
    expect(find.text('LUCKY SPIN!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('spin wheel and prize collection are single-flight', (
    tester,
  ) async {
    await setSurface(tester, const Size(390, 844));
    final collectionCompleter = Completer<void>();
    var collectionCount = 0;

    await tester.pumpWidget(
      localizedApp(
        SpinWheelDialog(
          playerName: 'Mia',
          onPrizeWon: (_) {
            collectionCount++;
            return collectionCompleter.future;
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('spin-wheel-center')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));
    expect(find.byKey(const Key('spin-wheel-collect')), findsOneWidget);

    // The center stays disabled once a result exists.
    await tester.tap(find.byKey(const Key('spin-wheel-center')));
    await tester.pump(const Duration(seconds: 6));
    expect(find.byKey(const Key('spin-wheel-collect')), findsOneWidget);

    await tester.tap(find.byKey(const Key('spin-wheel-collect')));
    await tester.tap(find.byKey(const Key('spin-wheel-collect')));
    await tester.pump();
    expect(collectionCount, 1);

    collectionCompleter.complete();
    await tester.pumpAndSettle();
    expect(collectionCount, 1);
  });

  testWidgets('card pick dialog is scroll-safe in compact landscape', (
    tester,
  ) async {
    await setSurface(tester, const Size(844, 390));

    await tester.pumpWidget(
      localizedApp(
        CardPickDialog(
          isChance: true,
          cards: const [
            PickableCard(text: 'Advance to GO', effect: r'+$200', action: 'go'),
            PickableCard(
              text: 'Pay a small repair bill',
              effect: r'-$50',
              action: 'pay',
            ),
            PickableCard(
              text: 'Move back three spaces',
              effect: '-3',
              action: 'move',
            ),
          ],
          onCardPicked: (_) {},
        ),
        textScale: 1.3,
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('card-pick-content-scroll')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('auction dialog is scroll-safe in compact landscape', (
    tester,
  ) async {
    await setSurface(tester, const Size(844, 390));
    final city = CityBoardRegistry.byBoardId('usa_new_york')!;
    final property = BoardFactory.generateTiles(
      city,
    ).whereType<PropertyTileData>().first;
    final players = [
      Player(
        id: 'player_0',
        name: 'Mia',
        icon: PlayerIcon.dog,
        color: Colors.red,
      ),
      Player(
        id: 'player_1',
        name: 'Noah',
        icon: PlayerIcon.car,
        color: Colors.blue,
      ),
    ];

    await tester.pumpWidget(
      localizedApp(
        AuctionDialog(
          property: property,
          participants: players,
          onAuctionComplete: (_, _) {},
          onNoWinner: () {},
        ),
        textScale: 1.3,
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('auction-content-scroll')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
