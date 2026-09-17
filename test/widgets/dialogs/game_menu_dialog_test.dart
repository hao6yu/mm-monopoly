import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/l10n/app_localizations.dart';
import 'package:property_tycoon/widgets/dialogs/game_menu_dialog.dart';

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
      home: home,
    );
  }

  testWidgets('menu fits compact landscape with every action', (tester) async {
    await setSurface(tester, const Size(844, 390));
    await tester.pumpWidget(
      localizedApp(
        const Scaffold(
          body: GameMenuDialog(
            canSave: true,
            canLoad: true,
            canShowRules: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('game-menu-grid')), findsOneWidget);
    expect(find.text('Back to Game'), findsOneWidget);
    expect(find.text('Save Game'), findsOneWidget);
    expect(find.text('Load Game'), findsOneWidget);
    expect(find.text('How to Play'), findsOneWidget);
    expect(find.text('Restart Game'), findsOneWidget);
    expect(find.text('Quit to Menu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text uses a scroll-safe list', (tester) async {
    await setSurface(tester, const Size(844, 390));
    await tester.pumpWidget(
      localizedApp(
        const Scaffold(
          body: GameMenuDialog(
            canSave: true,
            canLoad: true,
            canShowRules: true,
          ),
        ),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('game-menu-list')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelling a nested confirmation keeps the game paused', (
    tester,
  ) async {
    await setSurface(tester, const Size(390, 844));
    var closeCount = 0;
    var restartCount = 0;

    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => showGameMenuDialog(
                context: context,
                onClose: () => closeCount++,
                onRestart: () => restartCount++,
                onQuit: () {},
              ),
              child: const Text('Open menu'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restart Game'));
    await tester.pumpAndSettle();

    expect(find.text('Restart Game?'), findsOneWidget);
    expect(closeCount, 0);
    expect(restartCount, 0);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Game Menu'), findsOneWidget);
    expect(closeCount, 0);
    expect(restartCount, 0);

    await tester.tap(find.text('Restart Game'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('Game Menu'), findsNothing);
    expect(restartCount, 1);
    expect(closeCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('save completes before gameplay resumes', (tester) async {
    await setSurface(tester, const Size(390, 844));
    final events = <String>[];
    final saveCompleter = Completer<void>();

    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => showGameMenuDialog(
                context: context,
                onClose: () => events.add('resume'),
                onRestart: () {},
                onQuit: () {},
                onSave: () async {
                  events.add('save-start');
                  await saveCompleter.future;
                  events.add('save-done');
                },
              ),
              child: const Text('Open menu'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Game'));
    await tester.pump();

    expect(events, ['save-start']);
    saveCompleter.complete();
    await tester.pumpAndSettle();

    expect(events, ['save-start', 'save-done', 'resume']);
    expect(tester.takeException(), isNull);
  });
}
