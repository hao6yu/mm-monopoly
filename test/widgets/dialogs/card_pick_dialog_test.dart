import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/l10n/app_localizations.dart';
import 'package:property_tycoon/widgets/dialogs/card_pick_dialog.dart';

/// Exercises the real card pick dialog: fanned face-down cards are tapped by
/// their accessibility label, the flip reveals the picked card, and closing
/// invokes the callback with exactly that card.
void main() {
  const cards = [
    PickableCard(text: '🎲', effect: '+\$25', action: 'collect25'),
    PickableCard(text: '🎲', effect: '-5', action: 'back5'),
    PickableCard(text: '🎲', effect: 'GO', action: 'advanceGo'),
    PickableCard(text: '🎲', effect: '🔒', action: 'goToJail'),
    PickableCard(text: '🎲', effect: '🚂', action: 'nearestRailroad'),
  ];

  Future<void> pumpDialog(
    WidgetTester tester,
    ValueChanged<PickableCard> onCardPicked,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showCardPickDialog(
                  context: context,
                  isChance: true,
                  cards: cards,
                  onCardPicked: onCardPicked,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  /// Runs the pick sequence with generous fake-time advancement: the move
  /// delay (300 ms) and the close-enable delay (300 ms) are timers, while
  /// the flip controller ticks frame-by-frame, so its 600 ms only progress
  /// as frames are pumped. The surplus keeps every timer from staying
  /// pending at test end.
  Future<void> playPickSequence(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 1000));
  }

  testWidgets('tapping a card and closing picks exactly that card',
      (tester) async {
    PickableCard? picked;
    final semantics = tester.ensureSemantics();

    await pumpDialog(tester, (card) => picked = card);

    // The fanned cards overlap visually, so a tap at a card's center hits
    // the topmost painted card: the rightmost one (CHANCE 5). It must pick
    // exactly the card that the flip reveals.
    await tester.tap(find.bySemanticsLabel('CHANCE 5'));
    await tester.pump();
    await playPickSequence(tester);

    // The flip reveals the picked card's effect text.
    expect(find.text('🚂'), findsOneWidget);

    // Tapping the revealed card closes the dialog and confirms the pick.
    await tester.tap(find.text('🚂'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));

    // Dispose before the framework's end-of-test verification.
    semantics.dispose();

    expect(picked, isNotNull);
    expect(picked!.action, 'nearestRailroad');
  });

  testWidgets('tapping a second card during the first flip is ignored',
      (tester) async {
    var pickCount = 0;
    final semantics = tester.ensureSemantics();

    await pumpDialog(tester, (_) => pickCount++);

    await tester.tap(find.bySemanticsLabel('CHANCE 2'));
    await tester.pump(const Duration(milliseconds: 50));

    // The first card is selected but its flip is still running: card taps
    // are disabled and the dialog is not closable yet, so this second tap
    // must be ignored entirely.
    await tester.tap(find.bySemanticsLabel('CHANCE 5'), warnIfMissed: false);
    await playPickSequence(tester);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));

    // Dispose before the framework's end-of-test verification.
    semantics.dispose();

    expect(pickCount, 0);
  });
}
