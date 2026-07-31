import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_tycoon/l10n/app_localizations.dart';
import 'package:property_tycoon/models/city_board.dart';
import 'package:property_tycoon/models/country.dart';
import 'package:property_tycoon/screens/game_setup_screen.dart';
import 'package:property_tycoon/screens/main_menu_screen.dart';
import 'package:property_tycoon/widgets/city_theme/city_theme.dart';

void main() {
  final sizes = <Size>[
    const Size(390, 844),
    const Size(844, 390),
    const Size(768, 1024),
    const Size(1440, 900),
  ];

  Widget localizedApp(Widget home, {Locale? locale}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }

  for (final size in sizes) {
    testWidgets('3D city menu fits ${size.width}x${size.height}', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        localizedApp(
          MainMenuScreen(
            onNewGame: () {},
            onHowToPlay: () {},
            onSettings: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 950));

      expect(find.byType(CityThemeBackground), findsOneWidget);
      expect(find.text('NEW GAME'), findsOneWidget);
    });

    testWidgets(
      '3D city setup fits both steps at ${size.width}x${size.height}',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          localizedApp(
            GameSetupScreen(
              onBack: () {},
              onStartGame:
                  (
                    _, {
                    diceCount = 2,
                    cityBoard = const CityBoard(
                      country: Country.usa,
                      cityId: 'atlantic_city',
                      displayName: 'Atlantic City',
                      nativeName: 'Atlantic City',
                      emoji: '🎰',
                      isDefault: true,
                    ),
                  }) {},
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 250));

        expect(find.byType(CityThemeBackground), findsOneWidget);
        expect(find.text('Create Your Game'), findsOneWidget);
        expect(
          find.byKey(const Key('setup-destination-panel')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('setup-rules-panel')), findsOneWidget);
        expect(find.byKey(const Key('setup-summary')), findsOneWidget);
        if (size.width < 700 && size.height > size.width) {
          expect(find.byType(Scrollbar), findsOneWidget);
          expect(find.text('One Die'), findsOneWidget);
          expect(find.text('Classic style'), findsOneWidget);
        }

        await tester.tap(find.text('Next'));
        await tester.pump(const Duration(milliseconds: 250));

        expect(tester.takeException(), isNull);
        expect(find.text('Player Setup'), findsWidgets);
      },
    );
  }

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      'city shell handles ${locale.languageCode} in compact landscape',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(844, 390);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          localizedApp(
            MainMenuScreen(
              onNewGame: () {},
              onHowToPlay: () {},
              onSettings: () {},
            ),
            locale: locale,
          ),
        );
        await tester.pump(const Duration(milliseconds: 950));
        expect(find.byType(MainMenuScreen), findsOneWidget);

        await tester.pumpWidget(
          localizedApp(
            GameSetupScreen(
              onBack: () {},
              onStartGame:
                  (
                    _, {
                    diceCount = 2,
                    cityBoard = const CityBoard(
                      country: Country.usa,
                      cityId: 'atlantic_city',
                      displayName: 'Atlantic City',
                      nativeName: 'Atlantic City',
                      emoji: '🎰',
                      isDefault: true,
                    ),
                  }) {},
            ),
            locale: locale,
          ),
        );
        await tester.pump(const Duration(milliseconds: 250));
        expect(find.byType(GameSetupScreen), findsOneWidget);
      },
    );
  }
}
