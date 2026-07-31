import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/l10n/app_localizations.dart';
import 'package:property_tycoon/screens/how_to_play_screen.dart';

void main() {
  Widget localizedApp(Widget home, {Locale? locale}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }

  final sizes = <Size>[
    const Size(390, 844),
    const Size(844, 390),
    const Size(768, 1024),
    const Size(1440, 900),
  ];

  for (final size in sizes) {
    testWidgets(
      'how to play fits and navigates at ${size.width}x${size.height}',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(localizedApp(HowToPlayScreen(onBack: () {})));
        await tester.pump(const Duration(milliseconds: 250));

        expect(find.text('How to Play'), findsWidgets);
        expect(find.byKey(const Key('tutorial-page-view')), findsOneWidget);
        expect(find.byKey(const Key('tutorial-next-button')), findsOneWidget);
        expect(tester.takeException(), isNull);

        for (var index = 0; index < 4; index++) {
          await tester.tap(find.byKey(const Key('tutorial-next-button')));
          await tester.pump(const Duration(milliseconds: 380));
        }

        expect(find.byKey(const Key('tutorial-finish-button')), findsOneWidget);
        expect(find.text("Let's Play!"), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('how to play handles ${locale.languageCode}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(844, 390);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        localizedApp(HowToPlayScreen(onBack: () {}), locale: locale),
      );
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byType(HowToPlayScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
