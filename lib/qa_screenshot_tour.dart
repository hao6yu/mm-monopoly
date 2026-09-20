// TEMPORARY QA HARNESS — do not ship.
//
// Drives the real app flow hands-free for screenshot capture on a physical
// device: main menu → setup screen (selects the twelve-sided dice) → player
// setup → start → 3D board → repeated dice rolls. Reachable only through the
// dedicated lib/main_screenshot_tour.dart entrypoint; the store entrypoint
// never references this file, so it cannot ship in release artifacts.
//
// Every navigation step dispatches synthetic pointer events through the normal
// gesture pipeline, so it presses the real buttons. A small on-screen banner
// names the current stage so captured screenshots are self-describing.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'config/theme.dart';
import 'l10n/app_localizations.dart';
import 'services/locale_service.dart';
import 'widgets/dice/dice_widget.dart';

class QaScreenshotTourApp extends StatefulWidget {
  const QaScreenshotTourApp({super.key});

  @override
  State<QaScreenshotTourApp> createState() => _QaScreenshotTourAppState();
}

class _QaScreenshotTourAppState extends State<QaScreenshotTourApp> {
  String _stage = 'booting';

  @override
  void initState() {
    super.initState();
    _runTour();
  }

  void _note(String stage) {
    print('TOUR $stage');
    if (mounted) setState(() => _stage = stage);
  }

  Future<void> _hold(double seconds, String stage) async {
    _note(stage);
    await Future<void>.delayed(
      Duration(milliseconds: (seconds * 1000).round()),
    );
  }

  Offset? _findCenter(bool Function(Widget) predicate) {
    final Element? rootElement = WidgetsBinding.instance.rootElement;
    if (rootElement == null) return null;
    Element? match;
    void visitor(Element element) {
      if (match != null) return;
      if (predicate(element.widget)) {
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

  Element? _findElement(bool Function(Widget) predicate) {
    final Element? rootElement = WidgetsBinding.instance.rootElement;
    if (rootElement == null) return null;
    Element? match;
    void visitor(Element element) {
      if (match != null) return;
      if (predicate(element.widget)) {
        match = element;
        return;
      }
      element.visitChildElements(visitor);
    }

    rootElement.visitChildElements(visitor);
    return match;
  }

  /// Widget-tree positions exist even when scrolled out of view, so tapping a
  /// label below the fold would press empty space. Reveal the target inside
  /// its scrollable first, then the ordinary tap lands on it.
  Future<bool> _revealText(String needle) async {
    final Element? element = _findElement(
      (widget) =>
          widget is Text &&
          widget.data != null &&
          widget.data!.toLowerCase().contains(needle),
    );
    if (element == null) return false;
    await Scrollable.ensureVisible(
      element,
      duration: const Duration(milliseconds: 450),
      alignment: 0.35,
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return true;
  }

  void _tap(bool Function(Widget) predicate, String label) {
    final Offset? center = _findCenter(predicate);
    if (center == null) {
      _note('tap miss: $label');
      return;
    }
    GestureBinding.instance.handlePointerEvent(
      PointerDownEvent(position: center),
    );
    GestureBinding.instance.handlePointerEvent(
      PointerUpEvent(position: center),
    );
  }

  void _tapText(String needle) => _tap(
    (widget) =>
        widget is Text &&
        widget.data != null &&
        widget.data!.toLowerCase().contains(needle),
    'text "$needle"',
  );

  void _tapKey(String value) => _tap(
    (widget) => widget.key == Key(value),
    'key $value',
  );

  /// Taps the first visible dialog action so property purchases, card draws,
  /// rent confirmations, and the in-game menu never stall the tour.
  void _dismissDialogIfAny() {
    const candidates = [
      'back to game',
      'buy for',
      'got it',
      'skip',
      'pay',
    ];
    for (final candidate in candidates) {
      final center = _findCenter(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            widget.data!.toLowerCase().contains(candidate),
      );
      if (center != null) {
        GestureBinding.instance.handlePointerEvent(
          PointerDownEvent(position: center),
        );
        GestureBinding.instance.handlePointerEvent(
          PointerUpEvent(position: center),
        );
        _note('dismissed dialog via "$candidate"');
        return;
      }
    }
  }

  Future<void> _runTour() async {
    try {
      // 1. Main menu: tap New Game until the setup screen is actually up.
      for (var attempt = 1; attempt <= 5; attempt++) {
        await _hold(2.5, 'menu-$attempt');
        if (_findCenter(
              (widget) =>
                  widget is Text &&
                  (widget.data ?? '').toLowerCase().contains('create your'),
            ) !=
            null) {
          break;
        }
        _tapText('new game');
      }
      // 2. Setup screen — header, country and city cards.
      await _hold(8, 'setup-top');
      // 3. Reveal the players + dice sections inside the setup scroll.
      await _revealText('twelve-sided d12');
      await _hold(2.5, 'setup-scrolled');
      // 4. Select the twelve-sided dice and let the highlight settle.
      _tapText('twelve-sided d12');
      await _hold(10, 'setup-dice-selected');
      // 5. Player setup step.
      _tapKey('setup-primary-action');
      await _hold(4, 'players-step');
      // 6. Start the game (real start flow with diceSides: 12).
      _tapKey('setup-primary-action');
      await _hold(26, 'board-loading');
      // 7. Roll for each human turn; dialogs get dismissed along the way.
      // The 3D board exposes the tappable dice panel; the 2D fallback board
      // uses a roll button.
      for (var round = 1; round <= 7; round++) {
        _dismissDialogIfAny();
        await Future<void>.delayed(const Duration(milliseconds: 600));
        final diceCenter = _findCenter(
          (widget) => widget is CenterControls,
        );
        if (diceCenter != null) {
          GestureBinding.instance.handlePointerEvent(
            PointerDownEvent(position: diceCenter),
          );
          GestureBinding.instance.handlePointerEvent(
            PointerUpEvent(position: diceCenter),
          );
        }
        // The 3D board rolls through the labelled button; the 2D fallback
        // board uses a Roll Dice button.
        _tapText('roll for player');
        _tapText('roll dice');
        await _hold(9, 'roll-$round');
      }
      _dismissDialogIfAny();
      await _hold(6, 'complete');
    } catch (error) {
      _note('FAILED: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M&M Property Tycoon Tour',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      locale: LocaleService.instance.currentLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Stack(
        children: [
          // Start straight on the main menu so the tour timing never depends
          // on the splash auto-advance.
          const AppNavigator(initialScreen: AppScreen.mainMenu),
          Positioned(
            left: 14,
            top: 58,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xCC111A33),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE4B64E)),
                ),
                child: Text(
                  'TOUR: $_stage',
                  style: const TextStyle(
                    color: Color(0xFFFFE29A),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
