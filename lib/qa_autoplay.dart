// TEMPORARY, UNCOMMITTED QA HARNESS — do not ship.
//
// Opened a four-AI Atlantic City session directly through the normal
// AppNavigator so an automated physical-device pass can observe round-by-round
// gameplay without human taps. Enabled only when the launch environment sets
// PT_QA_AUTOPLAY=true and never in release builds.
//
// This build also exercises the real in-game SFX mute button: after the board
// initializes it dispatches a synthetic tap through the framework gesture
// pipeline at the button's center, verifies the icon flips to the muted
// state, then taps again to restore. Release-mode Dart prints never reach the
// flutter console, so every step is mirrored onto an on-screen QA banner that
// device screenshots can capture.
import 'package:flutter/gestures.dart';
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
  String _qaStatus = 'QA: waiting for board…';

  @override
  void initState() {
    super.initState();
    _prepareSession();
    // Physical-device QA: tap the REAL in-game sound-effects mute button once
    // the 3D board is up, verify the mute state, then restore.
    Future<void>.delayed(const Duration(seconds: 40), _runSfxButtonTest);
  }

  void _note(String message) {
    print('QA_SFX $message');
    if (mounted) {
      setState(() {
        _qaStatus = 'QA: $message';
      });
    }
  }

  /// Dispatches a synthetic press/release pair at the center of the first
  /// [IconButton] whose icon matches [icon]. The events go through the normal
  /// hit-testing and gesture-arena pipeline, so it presses the actual button.
  bool _tapIconButton(IconData icon) {
    final Offset? center = _findIconButtonCenter(icon);
    if (center == null) {
      _note('tap: button not found yet');
      return false;
    }
    _note('tap at (${center.dx.round()},${center.dy.round()})');
    GestureBinding.instance.handlePointerEvent(
      PointerDownEvent(position: center),
    );
    GestureBinding.instance.handlePointerEvent(
      PointerUpEvent(position: center),
    );
    return true;
  }

  Offset? _findIconButtonCenter(IconData icon) {
    final Element? rootElement = WidgetsBinding.instance.rootElement;
    if (rootElement == null) return null;
    Element? match;
    void visitor(Element element) {
      if (match != null) return;
      final Widget widget = element.widget;
      if (widget is IconButton &&
          widget.icon is Icon &&
          (widget.icon as Icon).icon == icon) {
        match = element;
        return;
      }
      element.visitChildElements(visitor);
    }

    rootElement.visitChildElements(visitor);
    if (match == null) return null;
    final RenderBox box = match!.findRenderObject()! as RenderBox;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  bool _iconVisible(IconData icon) =>
      _findIconButtonCenter(icon) != null;

  Future<void> _runSfxButtonTest() async {
    var tapped = false;
    for (var attempt = 1; attempt <= 8 && !tapped; attempt++) {
      tapped = _tapIconButton(Icons.volume_up_rounded);
      if (!tapped) {
        await Future<void>.delayed(const Duration(seconds: 8));
      }
    }
    if (!tapped || !mounted) {
      _note('FAILED: mute button never found');
      return;
    }
    await Future<void>.delayed(const Duration(seconds: 4));
    _note(
      'muted-after-tap: ${_iconVisible(Icons.volume_off_rounded)}',
    );
    await Future<void>.delayed(const Duration(seconds: 3));
    _tapIconButton(Icons.volume_off_rounded);
    await Future<void>.delayed(const Duration(seconds: 4));
    _note(
      'restored-after-tap: ${_iconVisible(Icons.volume_up_rounded)}',
    );
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
          ? Stack(
              children: [
                AppNavigator(
                  key: const ValueKey('qaAutoplay'),
                  initialScreen: AppScreen.game,
                  initialGameSession: _session,
                  initialCityBoard: _board,
                ),
                Positioned(
                  left: 16,
                  bottom: 96,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xCC111A33),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE4B64E)),
                      ),
                      child: Text(
                        _qaStatus,
                        style: const TextStyle(
                          color: Color(0xFFFFE29A),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
