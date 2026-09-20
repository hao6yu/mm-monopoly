import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/l10n/app_localizations.dart';
import 'package:property_tycoon/models/city_board.dart';
import 'package:property_tycoon/screens/game_setup_screen.dart';

FutureOr<void> _noopStartGame(
  List<PlayerConfig> _, {
  int diceCount = 2,
  int diceSides = 6,
  required CityBoard cityBoard,
}) {}

/// Regression coverage for the iPhone QA report: setup-screen labels used to
/// ellipsize ("Create Your G...", "Atlantic C...", "Two Di...", "Standard
/// r..."). Every visible label must lay out without truncation, and the
/// twelve-sided dice option must wire through to the start callback.
void main() {
  Widget localizedApp(Widget home, {Locale? locale}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }

  /// Reproduces each Text's real layout: a label truncates only when its
  /// content needs more lines than the widget allows at the laid-out width,
  /// or when a single-line label is wider than its box.
  bool rendersWithoutTruncation(String text) {
    final matches = find.text(text).evaluate();
    if (matches.isEmpty) return false;
    for (final element in matches) {
      final widget = element.widget as Text;
      final renderObject = element.findRenderObject();
      if (renderObject is! RenderParagraph) continue;
      final effectiveMaxLines = widget.maxLines;
      if (effectiveMaxLines == null) continue;
      final style = DefaultTextStyle.of(element).style.merge(widget.style);
      final boxWidth = renderObject.size.width;

      final unconstrained = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      if (effectiveMaxLines == 1 && unconstrained.width > boxWidth + 0.5) {
        return false;
      }

      final probe = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        maxLines: effectiveMaxLines + 8,
      )..layout(maxWidth: boxWidth);
      final linesNeeded = probe.computeLineMetrics().length;
      if (linesNeeded > effectiveMaxLines) {
        return false;
      }
    }
    return true;
  }

  testWidgets('setup labels show fully at iPhone portrait size', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 874);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(localizedApp(GameSetupScreen(
      onBack: () {},
      onStartGame: _noopStartGame,
    )));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Create Your Game'), findsOneWidget);
    expect(
      rendersWithoutTruncation('Create Your Game'),
      isTrue,
      reason: 'Header title must not ellipsize.',
    );
    expect(
      rendersWithoutTruncation('Choose a city, game size, and movement style.'),
      isTrue,
      reason: 'Header subtitle must not ellipsize.',
    );
    expect(
      rendersWithoutTruncation('Atlantic City'),
      isTrue,
      reason: 'Selected city chip must show the complete city name.',
    );
    expect(
      rendersWithoutTruncation('Two Dice'),
      isTrue,
      reason: 'Dice count card label must not ellipsize.',
    );
    expect(
      rendersWithoutTruncation('Standard rules'),
      isTrue,
      reason: 'Dice count card subtitle must not ellipsize.',
    );
    expect(
      rendersWithoutTruncation('Twelve-Sided D12'),
      isTrue,
      reason: 'Dice type card label must not ellipsize.',
    );
    expect(
      rendersWithoutTruncation('Rolls 1–12'),
      isTrue,
      reason: 'Dice type card subtitle must not ellipsize.',
    );
  });

  testWidgets('choosing the D12 dice type is reported to onStartGame', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 874);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    int? reportedDiceCount;
    int? reportedDiceSides;
    await tester.pumpWidget(localizedApp(GameSetupScreen(
      onBack: () {},
      onStartGame: (_, {diceCount = 2, diceSides = 6, required cityBoard}) {
        reportedDiceCount = diceCount;
        reportedDiceSides = diceSides;
      },
    )));
    await tester.pump(const Duration(milliseconds: 250));

    await tester.scrollUntilVisible(
      find.byKey(const Key('setup-dice-sides-12')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('setup-dice-sides-12')));
    await tester.pump(const Duration(milliseconds: 300));

    // The summary line should advertise the twelve-sided dice.
    expect(find.textContaining('D12'), findsWidgets);

    // Advancing to the player step keeps the selection; starting reports it.
    await tester.tap(find.text('Next'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.byKey(const Key('setup-primary-action')));
    await tester.pump(const Duration(milliseconds: 250));

    expect(reportedDiceCount, 2);
    expect(reportedDiceSides, 12);
  });
}
