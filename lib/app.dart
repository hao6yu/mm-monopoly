import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/game_setup_screen.dart';
import 'screens/how_to_play_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/game_board_screen.dart';
import 'screens/victory_screen.dart';
import 'screens/shop_screen.dart';
import 'models/player.dart';
import 'models/game_state.dart';
import 'models/tile.dart';
import 'models/game_result.dart';
import 'models/country.dart';
import 'models/city_board.dart';
import 'controllers/game_session_controller.dart';
import 'config/board_factory.dart';
import 'config/city_board_registry.dart';
import 'services/audio_service.dart';
import 'services/save_service.dart';
import 'services/locale_service.dart';

/// Main app widget with navigation
class MonopolyApp extends StatelessWidget {
  const MonopolyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleService.instance.localeNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'M&M Property Tycoon',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const AppNavigator(),
        );
      },
    );
  }
}

/// Navigation state for the app
enum AppScreen {
  splash,
  mainMenu,
  gameSetup,
  howToPlay,
  settings,
  shop,
  game,
  victory,
}

/// Main app navigator managing screen transitions
class AppNavigator extends StatefulWidget {
  const AppNavigator({
    super.key,
    this.initialScreen = AppScreen.splash,
    this.initialGameSession,
    this.initialCityBoard,
    this.initialGameResult,
  }) : assert(
         initialScreen != AppScreen.game || initialGameSession != null,
         'A game screen requires an initial game session',
       ),
       assert(
         initialScreen != AppScreen.victory ||
             (initialGameSession != null && initialGameResult != null),
         'A victory screen requires a game session and result',
       );

  /// Optional restored state. These values also make navigation flows easy to
  /// exercise in widget tests without waiting through the splash/setup flow.
  final AppScreen initialScreen;
  final GameSessionController? initialGameSession;
  final CityBoard? initialCityBoard;
  final GameResult? initialGameResult;

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator>
    with WidgetsBindingObserver {
  late AppScreen _currentScreen;
  AppScreen? _previousScreen; // Track where user came from
  GameSessionController? _gameSession;
  GameResult? _gameResult;
  GameSettings _settings = const GameSettings();
  int _diceCount = 2; // Track dice count for the game
  CityBoard _selectedCityBoard = CityBoardRegistry.defaultForCountry(
    Country.usa,
  ); // Track selected city board

  @override
  void initState() {
    super.initState();
    _currentScreen = widget.initialScreen;
    _gameSession = widget.initialGameSession;
    _gameResult = widget.initialGameResult;
    _diceCount = _gameSession?.state.diceCount ?? _diceCount;
    final restoredBoardId = _gameSession?.state.cityBoardId;
    _selectedCityBoard =
        widget.initialCityBoard ??
        (restoredBoardId == null
            ? _selectedCityBoard
            : CityBoardRegistry.byBoardId(restoredBoardId) ??
                  _inferCityBoardFromTheme(_gameSession!.state.boardTheme.id));
    final audio = AudioService.instance;
    _settings = _settings.copyWith(
      musicEnabled: audio.musicEnabled,
      sfxEnabled: audio.sfxEnabled,
      musicVolume: audio.musicVolume,
      sfxVolume: audio.sfxVolume,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _gameSession?.deactivate();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AudioService.instance.resumeBgm();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      AudioService.instance.pauseBgm();
    }
  }

  void _navigateTo(AppScreen screen) {
    if (!mounted) return;
    setState(() {
      _previousScreen = _currentScreen;
      _currentScreen = screen;
    });
    _handleScreenAudio(screen);
  }

  void _handleScreenAudio(AppScreen screen) {
    final audio = AudioService.instance;
    switch (screen) {
      case AppScreen.mainMenu:
      case AppScreen.gameSetup:
      case AppScreen.howToPlay:
      case AppScreen.settings:
      case AppScreen.shop:
        // Play menu music for all menu screens
        audio.playMenuMusic();
        break;
      case AppScreen.game:
        // Play game music when entering game
        audio.playGameMusic(boardId: _selectedCityBoard.boardId);
        break;
      case AppScreen.victory:
        // VictoryScreen owns its celebration music.
        break;
      case AppScreen.splash:
        // No music on splash
        break;
    }
  }

  Future<void> _startGame(
    List<PlayerConfig> configs, {
    int diceCount = 2,
    CityBoard? cityBoard,
  }) async {
    final board = cityBoard ?? CityBoardRegistry.defaultForCountry(Country.usa);

    // Create players from configs
    final players = configs.asMap().entries.map((entry) {
      final index = entry.key;
      final config = entry.value;
      return Player(
        id: 'player_$index',
        name: config.name,
        color: config.color,
        icon: config.icon,
        avatar: config.avatar,
        isAI: config.isAI,
        cash: _settings.startingCash,
      );
    }).toList();

    // Load localized tiles
    final locale = LocaleService.instance.currentLocale;
    final tiles = await BoardFactory.generateLocalizedTiles(board, locale);
    if (!mounted || _currentScreen != AppScreen.gameSetup) return;

    // Create game state using factory constructor
    setState(() {
      _diceCount = diceCount;
      _selectedCityBoard = board;
      _gameSession = GameSessionController(
        GameState.initial(
          players: players,
          tiles: tiles,
          startingCash: _settings.startingCash,
          diceCount: diceCount,
          cityBoardId: board.boardId,
        ),
      );
      _gameResult = null;
      _currentScreen = AppScreen.game;
    });

    // Play game music
    AudioService.instance.playGameMusic(boardId: board.boardId);
  }

  void _quitGame() {
    _gameSession?.deactivate();
    setState(() {
      _gameSession = null;
      _gameResult = null;
      _currentScreen = AppScreen.mainMenu;
    });

    // Switch back to menu music
    AudioService.instance.playMenuMusic();
  }

  Future<void> _restartGame() async {
    final session = _gameSession;
    if (session != null) {
      session.suspend();
      if (mounted) setState(() {});
      final board =
          CityBoardRegistry.byBoardId(session.state.cityBoardId) ??
          _inferCityBoardFromTheme(session.state.boardTheme.id);
      final diceCount = session.state.diceCount;
      // Reset all players
      final resetPlayers = session.state.players.map((p) {
        return Player(
          id: p.id,
          name: p.name,
          color: p.color,
          icon: p.icon,
          avatar: p.avatar,
          isAI: p.isAI,
          cash: _settings.startingCash,
        );
      }).toList();

      final locale = LocaleService.instance.currentLocale;
      late final List<TileData> tiles;
      try {
        tiles = await BoardFactory.generateLocalizedTiles(board, locale);
      } on Object {
        if (mounted && identical(session, _gameSession)) {
          session.resume();
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to restart the game. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      if (!mounted || !identical(session, _gameSession)) return;

      session.deactivate();
      setState(() {
        _diceCount = diceCount;
        _selectedCityBoard = board;
        _gameSession = GameSessionController(
          GameState.initial(
            players: resetPlayers,
            tiles: tiles,
            startingCash: _settings.startingCash,
            diceCount: diceCount,
            cityBoardId: board.boardId,
          ),
        );
        _gameResult = null;
        _currentScreen = AppScreen.game;
      });
      AudioService.instance.playGameMusic(boardId: board.boardId);
    }
  }

  Future<void> _loadSavedGame() async {
    final savedState = await SaveService.instance.loadGame();
    if (!mounted || _currentScreen != AppScreen.mainMenu) return;
    if (savedState != null) {
      _gameSession?.deactivate();
      setState(() {
        _gameSession = GameSessionController(savedState);
        _gameResult = null;
        _diceCount = savedState.diceCount;
        _selectedCityBoard =
            CityBoardRegistry.byBoardId(savedState.cityBoardId) ??
            _inferCityBoardFromTheme(savedState.boardTheme.id);
        _currentScreen = AppScreen.game;
      });
      // Play game music
      AudioService.instance.playGameMusic(boardId: _selectedCityBoard.boardId);
    } else {
      // Show error if load failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load saved game'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openInGameHelp() {
    if (!mounted || _gameSession == null) return;
    _navigateTo(AppScreen.howToPlay);
  }

  void _finishGame(GameResult result) {
    if (!mounted || _gameSession == null) return;
    _gameSession!.deactivate();
    setState(() {
      _gameResult = result;
      _currentScreen = AppScreen.victory;
    });
  }

  void _handleInGameLoad(GameState state) {
    final session = _gameSession;
    if (!mounted || session == null || !identical(session.state, state)) {
      return;
    }
    final board =
        CityBoardRegistry.byBoardId(state.cityBoardId) ??
        _inferCityBoardFromTheme(state.boardTheme.id);
    setState(() {
      _diceCount = state.diceCount;
      _selectedCityBoard = board;
    });
    AudioService.instance.playGameMusic(boardId: board.boardId);
  }

  Future<void> _confirmQuitGame() async {
    final l10n = AppLocalizations.of(context)!;
    final shouldQuit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.quitGame),
        content: Text(l10n.currentProgressLost),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.quitToMenu),
          ),
        ],
      ),
    );
    if (!mounted || shouldQuit != true) return;
    _quitGame();
  }

  void _handleSystemBack() {
    switch (_currentScreen) {
      case AppScreen.game:
        final session = _gameSession;
        final canSafelyConfirm =
            session != null &&
            session.acceptsInput &&
            session.state.canRoll &&
            !session.state.currentPlayer.isAI &&
            session.state.currentPlayer.jailTurnsRemaining == 0;
        if (canSafelyConfirm) {
          _confirmQuitGame();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Finish the current turn action before leaving.'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(milliseconds: 1400),
            ),
          );
        }
        break;
      case AppScreen.victory:
        _quitGame();
        break;
      case AppScreen.gameSetup:
      case AppScreen.settings:
      case AppScreen.shop:
        _navigateTo(AppScreen.mainMenu);
        break;
      case AppScreen.howToPlay:
        _navigateTo(
          _previousScreen == AppScreen.game
              ? AppScreen.game
              : _previousScreen == AppScreen.gameSetup
              ? AppScreen.gameSetup
              : AppScreen.mainMenu,
        );
        break;
      case AppScreen.splash:
      case AppScreen.mainMenu:
        break;
    }
  }

  CityBoard _inferCityBoardFromTheme(String themeId) {
    // Try to find by boardId first, then fall back to country theme
    final byId = CityBoardRegistry.byBoardId(themeId);
    if (byId != null) return byId;

    // Fall back to country default by theme ID
    switch (themeId) {
      case 'usa':
        return CityBoardRegistry.defaultForCountry(Country.usa);
      case 'uk':
        return CityBoardRegistry.defaultForCountry(Country.uk);
      case 'japan':
        return CityBoardRegistry.defaultForCountry(Country.japan);
      case 'france':
        return CityBoardRegistry.defaultForCountry(Country.france);
      case 'china':
        return CityBoardRegistry.defaultForCountry(Country.china);
      case 'mexico':
        return CityBoardRegistry.defaultForCountry(Country.mexico);
      default:
        return CityBoardRegistry.defaultForCountry(Country.usa);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allowSystemExit =
        _currentScreen == AppScreen.splash ||
        _currentScreen == AppScreen.mainMenu;
    return PopScope(
      canPop: allowSystemExit,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleSystemBack();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildVisibleContent(),
      ),
    );
  }

  Widget _buildVisibleContent() {
    final showingGameHelp =
        _currentScreen == AppScreen.howToPlay &&
        _previousScreen == AppScreen.game;
    if (_gameSession != null &&
        (_currentScreen == AppScreen.game || showingGameHelp)) {
      return KeyedSubtree(
        key: ValueKey<GameSessionController>(_gameSession!),
        child: IndexedStack(
          index: showingGameHelp ? 1 : 0,
          children: [
            _buildGameScreen(isActive: !showingGameHelp),
            if (showingGameHelp)
              HowToPlayScreen(
                key: const ValueKey('inGameHowToPlay'),
                onBack: () => _navigateTo(AppScreen.game),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      );
    }
    return _buildCurrentScreen();
  }

  Widget _buildGameScreen({bool isActive = true}) {
    final session = _gameSession!;
    return GameBoardScreen(
      key: ValueKey<GameSessionController>(session),
      session: session,
      cityBoard: _selectedCityBoard,
      onQuit: _quitGame,
      onRestart: _restartGame,
      onHowToPlay: _openInGameHelp,
      onGameFinished: _finishGame,
      onGameLoaded: _handleInGameLoad,
      isActive: isActive,
      tradingEnabled: _settings.tradingEnabled,
      bankEnabled: _settings.bankEnabled,
      auctionEnabled: _settings.auctionEnabled,
      boardTheme: BoardFactory.getThemeForCityBoard(_selectedCityBoard),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case AppScreen.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onComplete: () => _navigateTo(AppScreen.mainMenu),
        );

      case AppScreen.mainMenu:
        return MainMenuScreen(
          key: const ValueKey('mainMenu'),
          onNewGame: () => _navigateTo(AppScreen.gameSetup),
          onContinue:
              (_gameSession != null || SaveService.instance.hasSavedGame())
              ? _loadSavedGame
              : null,
          onHowToPlay: () => _navigateTo(AppScreen.howToPlay),
          onSettings: () => _navigateTo(AppScreen.settings),
          onShop: () => _navigateTo(AppScreen.shop),
        );

      case AppScreen.gameSetup:
        return GameSetupScreen(
          key: const ValueKey('gameSetup'),
          onBack: () => _navigateTo(AppScreen.mainMenu),
          onStartGame: _startGame,
        );

      case AppScreen.howToPlay:
        // Go back to where user came from (game or mainMenu)
        final returnScreen = _previousScreen == AppScreen.game
            ? AppScreen.game
            : AppScreen.mainMenu;
        return HowToPlayScreen(
          key: const ValueKey('howToPlay'),
          onBack: () => _navigateTo(returnScreen),
        );

      case AppScreen.settings:
        return SettingsScreen(
          key: const ValueKey('settings'),
          onBack: () => _navigateTo(AppScreen.mainMenu),
          settings: _settings,
          onSettingsChanged: (newSettings) {
            setState(() {
              _settings = newSettings;
            });
          },
        );

      case AppScreen.shop:
        return ShopScreen(
          key: const ValueKey('shop'),
          onBack: () => _navigateTo(AppScreen.mainMenu),
        );

      case AppScreen.game:
        return _buildGameScreen();

      case AppScreen.victory:
        final result = _gameResult!;
        return VictoryScreen(
          key: ValueKey('victory_${result.winner.id}'),
          winner: result.winner,
          allPlayers: result.players,
          gameTurns: result.turns,
          onPlayAgain: _restartGame,
          onGoHome: _quitGame,
        );
    }
  }
}
