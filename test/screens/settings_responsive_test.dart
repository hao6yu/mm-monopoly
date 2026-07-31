import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/l10n/app_localizations.dart';
import 'package:property_tycoon/screens/settings_screen.dart';

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
    testWidgets('settings fits at ${size.width}x${size.height}', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        localizedApp(
          SettingsScreen(
            onBack: () {},
            settings: const GameSettings(),
            onSettingsChanged: (_) {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Settings'), findsOneWidget);
      expect(
        find.byKey(const Key('settings-starting-cash-slider')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('settings-language-dropdown')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('settings-reset-button')), findsOneWidget);
      expect(find.byKey(const Key('settings-done-button')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('settings toggles and resets game options', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var latestSettings = const GameSettings();
    await tester.pumpWidget(
      localizedApp(
        SettingsScreen(
          onBack: () {},
          settings: latestSettings,
          onSettingsChanged: (settings) => latestSettings = settings,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.byKey(const Key('settings-trading-switch')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(latestSettings.tradingEnabled, isTrue);

    await tester.tap(find.byKey(const Key('settings-reset-button')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(latestSettings.tradingEnabled, isFalse);
    expect(latestSettings.startingCash, 2000);
    expect(tester.takeException(), isNull);
  });

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('settings handles ${locale.languageCode}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(844, 390);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        localizedApp(
          SettingsScreen(
            onBack: () {},
            settings: const GameSettings(),
            onSettingsChanged: (_) {},
          ),
          locale: locale,
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
