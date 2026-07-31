import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/l10n/app_localizations.dart';
import 'package:property_tycoon/screens/splash_screen.dart';

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
    testWidgets('splash fits at ${size.width}x${size.height}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var completed = false;
      await tester.pumpWidget(
        localizedApp(SplashScreen(onComplete: () => completed = true)),
      );
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('PROPERTY TYCOON'), findsOneWidget);
      expect(completed, isFalse);
      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(milliseconds: 850));
      expect(completed, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('splash handles ${locale.languageCode}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(844, 390);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        localizedApp(SplashScreen(onComplete: () {}), locale: locale),
      );
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
