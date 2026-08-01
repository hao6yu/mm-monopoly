import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/game_setup_screen.dart';
import 'screens/how_to_play_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/game_board_screen.dart';
import 'screens/shop_screen.dart';
import 'models/player.dart';
import 'models/game_state.dart';
import 'models/country.dart';
import 'models/city_board.dart';
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
enum AppScreen { splash, mainMenu, gameSetup, howToPlay, settings, shop, game }

/// Main app navigator managing screen transitions
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator>
    with WidgetsBindingObserver {
  AppScreen _currentScreen = AppScreen.splash;
  AppScreen? _previousScreen; // Track where user came from
  GameState? _gameState;
  GameSettings _settings = const GameSettings();
  int _diceCount = 2; // Track dice count for the game
  CityBoard _selectedCityBoard = CityBoardRegistry.defaultForCountry(
    Country.usa,
  ); // Track selected city board

  @override
  void initState() {
    super.initState();
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
    final players =
        configs.asMap().entries.map((entry) {
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

    // Create game state using factory constructor
    setState(() {
      _diceCount = diceCount;
      _selectedCityBoard = board;
      _gameState = GameState.initial(
        players: players,
        tiles: tiles,
        startingCash: _settings.startingCash,
        diceCount: diceCount,
        cityBoardId: board.boardId,
      );
      _currentScreen = AppScreen.game;
    });

    // Play game music
    AudioService.instance.playGameMusic(boardId: board.boardId);
  }

  void _quitGame() {
    setState(() {
      _gameState = null;
      _currentScreen = AppScreen.mainMenu;
    });

    // Switch back to menu music
    AudioService.instance.playMenuMusic();
  }

  Future<void> _restartGame() async {
    if (_gameState != null) {
      // Reset all players
      final resetPlayers =
          _gameState!.players.map((p) {
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
      final tiles = await BoardFactory.generateLocalizedTiles(
        _selectedCityBoard,
        locale,
      );

      setState(() {
        _gameState = GameState.initial(
          players: resetPlayers,
          tiles: tiles,
          startingCash: _settings.startingCash,
          diceCount: _diceCount,
          cityBoardId: _selectedCityBoard.boardId,
        );
      });
    }
  }

  Future<void> _loadSavedGame() async {
    final savedState = await SaveService.instance.loadGame();
    if (savedState != null) {
      setState(() {
        _gameState = savedState;
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load saved game'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildCurrentScreen(),
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
              (_gameState != null || SaveService.instance.hasSavedGame())
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
        final returnScreen =
            _previousScreen == AppScreen.game
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
        return GameBoardScreen(
          key: ValueKey('game_${_gameState!.id}'),
          gameState: _gameState!,
          cityBoard: _selectedCityBoard,
          onQuit: _quitGame,
          onRestart: _restartGame,
          onHowToPlay: () => _navigateTo(AppScreen.howToPlay),
          tradingEnabled: _settings.tradingEnabled,
          bankEnabled: _settings.bankEnabled,
          auctionEnabled: _settings.auctionEnabled,
          boardTheme: BoardFactory.getThemeForCityBoard(_selectedCityBoard),
        );
    }
  }
}
