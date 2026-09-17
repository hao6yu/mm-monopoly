// TEMPORARY, UNCOMMITTED QA HARNESS — do not ship.
//
// Opened a four-AI Atlantic City session directly through the normal
// AppNavigator so an automated physical-device pass can observe round-by-round
// gameplay without human taps. Enabled only when the launch environment sets
// PT_QA_AUTOPLAY=1 and never in release builds.
import 'package:flutter/material.dart';

import 'app.dart';
import 'config/board_factory.dart';
import 'config/city_board_registry.dart';
import 'config/theme.dart';
import 'controllers/game_session_controller.dart';
import 'l10n/app_localizations.dart';
import 'models/city_board.dart';
import 'models/country.dart';
import 'models/game_state.dart';
import 'models/player.dart';
import 'services/locale_service.dart';

class QaAutoplayApp extends StatefulWidget {
  const QaAutoplayApp({super.key});

  @override
  State<QaAutoplayApp> createState() => _QaAutoplayAppState();
}

class _QaAutoplayAppState extends State<QaAutoplayApp> {
  GameSessionController? _session;
  CityBoard? _board;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _prepareSession();
  }

  Future<void> _prepareSession() async {
    try {
      final board = CityBoardRegistry.defaultForCountry(Country.usa);
      final locale = LocaleService.instance.currentLocale;
      final tiles = await BoardFactory.generateLocalizedTiles(board, locale);
      final players = List<Player>.generate(4, (index) {
        return Player(
          id: 'player_$index',
          name: 'Player ${index + 1}',
          color: const [
            Color(0xFFFF4F5E),
            Color(0xFF36C5B9),
            Color(0xFFFFC53D),
            Color(0xFF8B5CF6),
          ][index],
          icon: PlayerIcon.values[index],
          isAI: true, // Every player is AI so rounds play out hands-free.
          cash: 2000,
        );
      });
      if (!mounted) return;
      setState(() {
        _board = board;
        _session = GameSessionController(
          GameState.initial(
            players: players,
            tiles: tiles,
            startingCash: 2000,
            diceCount: 2,
            cityBoardId: board.boardId,
          ),
        );
      });
    } catch (error) {
      if (mounted) setState(() { _error = error; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M&M Property Tycoon QA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      locale: LocaleService.instance.currentLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: _session != null && _board != null
          ? AppNavigator(
              key: const ValueKey('qaAutoplay'),
              initialScreen: AppScreen.game,
              initialGameSession: _session,
              initialCityBoard: _board,
            )
          : Scaffold(
              body: Center(
                child: _error != null
                    ? Text('QA setup failed: $_error')
                    : const CircularProgressIndicator(),
              ),
            ),
    );
  }
}
