import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../models/board_theme.dart';
import '../models/player_stats.dart';
import '../models/city_board.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../services/audio_catalog.dart';
import '../services/audio_service.dart';
import '../services/save_service.dart';
import '../services/stats_service.dart';
import '../services/locale_service.dart';
import '../services/game_content_loader.dart';
import '../integration/godot_board_contract.dart';
import '../integration/godot_board_controller.dart';
import '../widgets/achievements/achievement_notification.dart';
import '../widgets/board/game_board.dart';
import '../widgets/board/godot_board_host.dart';
import '../widgets/player/player_card.dart';
import '../widgets/dice/dice_widget.dart';
import '../widgets/dialogs/buy_property_dialog.dart';
import '../widgets/dialogs/rent_payment_dialog.dart';
import '../widgets/dialogs/tax_payment_dialog.dart';
import '../widgets/dialogs/game_menu_dialog.dart';
import '../widgets/dialogs/jail_dialog.dart';
import '../widgets/dialogs/property_upgrade_dialog.dart';
import '../widgets/dialogs/spin_wheel_dialog.dart';
import '../widgets/dialogs/event_dialog.dart';
import '../widgets/dialogs/ai_action_dialog.dart';
import '../widgets/dialogs/auction_dialog.dart';
import '../widgets/dialogs/trade_dialog.dart';
import '../widgets/dialogs/property_management_dialog.dart';
import '../widgets/dialogs/property_portfolio_dialog.dart';
import '../widgets/dialogs/tile_info_dialog.dart';
import '../widgets/dialogs/card_pick_dialog.dart';
import '../widgets/dialogs/free_house_dialog.dart';
import '../widgets/dialogs/teleport_dialog.dart';
import '../widgets/cards/power_up_card_widget.dart';
import '../engine/game_engine.dart';
import '../engine/card_effect_engine.dart';
import '../models/tile.dart';
import '../models/spin_prize.dart';
import '../models/event_card.dart';
import '../models/power_up_card.dart';
import '../models/trade.dart';
import '../models/ai_player.dart';
import 'mini_games/memory_match_game.dart';
import 'mini_games/quick_tap_game.dart';
import 'victory_screen.dart';

/// Main game board screen
class GameBoardScreen extends StatefulWidget {
  final GameState gameState;
  final CityBoard cityBoard;
  final VoidCallback onQuit;
  final VoidCallback onRestart;
  final VoidCallback? onHowToPlay;
  final bool tradingEnabled;
  final bool bankEnabled;
  final bool auctionEnabled;
  final BoardTheme? boardTheme;

  const GameBoardScreen({
    super.key,
    required this.gameState,
    required this.cityBoard,
    required this.onQuit,
    required this.onRestart,
    this.onHowToPlay,
    this.tradingEnabled = false,
    this.bankEnabled = false,
    this.auctionEnabled = false,
    this.boardTheme,
  });

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen>
    with TickerProviderStateMixin {
  late GameState gameState;
  late GameEngine engine;
  late AnimationController _diceController;
  late AnimationController _bounceController;
  late AnimationController _glowController;
  late Animation<double> _bounceAnimation;

  final Random _random = Random.secure();
  int _totalRounds = 1;
  bool _isPaused = false; // Track if game menu is open
  bool _isMusicPlaying = true; // Track music state
  bool _isProcessingTurn = false; // Prevent dice rolls while processing
  late final GodotBoardController _godotBoardController;
  StreamSubscription<GodotBoardSelection>? _godotSelectionSubscription;
  bool _show3DBoard = false;
  ui.Offset _last3DGestureFocalPoint = ui.Offset.zero;
  double _last3DGestureScale = 1;

  // Phase 4: AI Decision Engines per AI player
  final Map<String, AIDecisionEngine> _aiEngines = {};

  // Card picking state
  bool _waitingForCardPick = false;
  bool _isChanceCard = false;
  Player? _cardPickPlayer;
  Completer<int?>? _cardPickCompleter;

  // Localized cards (loaded from JSON)
  List<Map<String, dynamic>> _localizedChanceCards = [];
  List<Map<String, dynamic>> _localizedChestCards = [];

  @override
  void initState() {
    super.initState();
    gameState = widget.gameState;
    engine = GameEngine(gameState);
    _initializeAnimations();
    _initializeAIEngines();
    _isMusicPlaying = AudioService.instance.musicEnabled;
    _updateMusicIntensity();
    _loadLocalizedCards();
    _godotBoardController = GodotBoardController();
    _godotBoardController.addListener(_onGodotBoardChanged);
    _godotSelectionSubscription = _godotBoardController.selections.listen(
      _handle3DBoardSelection,
    );
    _initialize3DBoard();
  }

  bool get _supports3DBoard =>
      GodotBoardProtocol.supportedBoardIds.contains(widget.cityBoard.boardId);

  Future<void> _initialize3DBoard() async {
    await _godotBoardController.initialize();
    if (!mounted) return;
    setState(() {
      _show3DBoard = _supports3DBoard && _godotBoardController.isAvailable;
    });
    await _sync3DBoard();
  }

  Future<void> _sync3DBoard() async {
    if (!_supports3DBoard || !_godotBoardController.isAvailable) return;
    await _godotBoardController.syncGameState(
      gameState,
      boardId: widget.cityBoard.boardId,
    );
  }

  void _onGodotBoardChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadLocalizedCards() async {
    final locale = LocaleService.instance.currentLocale;
    final cards = await GameContentLoader.instance.loadCards(locale);
    if (mounted) {
      setState(() {
        _localizedChanceCards = cards['chance'] ?? [];
        _localizedChestCards = cards['communityChest'] ?? [];
      });
    }
  }

  void _initializeAIEngines() {
    for (final player in gameState.players) {
      if (player.isAI) {
        // Create AI engine with random personality for variety
        final personalities = AIPersonality.values;
        final personality =
            personalities[_random.nextInt(personalities.length)];
        _aiEngines[player.id] = AIDecisionEngine(
          config: AIConfig(
            difficulty: AIDifficulty.medium,
            personality: personality,
          ),
        );
      }
    }
  }

  @override
  void didUpdateWidget(GameBoardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Detect when the game state has been reset (restart game)
    if (widget.gameState != oldWidget.gameState) {
      setState(() {
        gameState = widget.gameState;
        engine = GameEngine(gameState);
        _totalRounds = 1;
        _isPaused = false;
      });
      _sync3DBoard();
    }
  }

  void _initializeAnimations() {
    _diceController = AnimationController(
      duration: AnimationDurations.diceRoll,
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: AnimationDurations.bounce,
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _glowController = AnimationController(
      duration: AnimationDurations.glow,
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _diceController.dispose();
    _bounceController.dispose();
    _glowController.dispose();
    _godotBoardController.removeListener(_onGodotBoardChanged);
    _godotSelectionSubscription?.cancel();
    _godotBoardController.dispose();
    super.dispose();
  }

  void _showTileInfo(TileData tile) {
    showTileInfoDialog(context: context, tile: tile);
  }

  void _handle3DBoardSelection(GodotBoardSelection selection) {
    if (!mounted) return;
    switch (selection.kind) {
      case 'tile':
        final logicalIndex = selection.logicalIndex;
        if (logicalIndex == null) return;
        for (final tile in gameState.tiles) {
          if (tile.index == logicalIndex) {
            if (_waitingForCardPick &&
                ((_isChanceCard && tile.type == TileType.chance) ||
                    (!_isChanceCard && tile.type == TileType.communityChest))) {
              _onCardDeckTap(_isChanceCard);
              return;
            }
            _showTileInfo(tile);
            return;
          }
        }
        return;
      case 'player':
        Player? selectedPlayer;
        for (final player in gameState.players) {
          if (player.id == selection.playerId) {
            selectedPlayer = player;
            break;
          }
        }
        final playerIndex = selection.playerIndex;
        if (selectedPlayer == null &&
            playerIndex != null &&
            playerIndex >= 0 &&
            playerIndex < gameState.players.length) {
          selectedPlayer = gameState.players[playerIndex];
        }
        if (selectedPlayer != null) {
          showPropertyPortfolioDialog(
            context: context,
            player: selectedPlayer,
            tiles: gameState.tiles,
            gameState: gameState,
          );
        }
        return;
      case 'dice':
        if (gameState.canRoll && !_isProcessingTurn) {
          _rollDice();
        } else {
          final value =
              gameState.diceCount == 1
                  ? '${gameState.die1Value}'
                  : '${gameState.die1Value} + ${gameState.die2Value}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isProcessingTurn
                    ? 'The dice are resolving this turn.'
                    : 'Last roll: $value',
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(milliseconds: 1400),
            ),
          );
        }
        return;
      case 'landmark':
      case 'scenic':
      case 'city':
      default:
        _showCityGuide(highlight: selection.title);
    }
  }

  void _showCityGuide({String? highlight}) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final city = widget.cityBoard.localizedDisplayName(l10n);
    final country = widget.cityBoard.country.localizedDisplayName(l10n);
    final factTiles =
        gameState.tiles
            .where((tile) => tile.funFact?.isNotEmpty ?? false)
            .toList();

    TileData? matchedTile;
    final query = _normalizeGuideText(highlight ?? '');
    if (query.isNotEmpty) {
      for (final tile in factTiles) {
        final tileName = _normalizeGuideText(tile.name);
        if (tileName.contains(query) || query.contains(tileName)) {
          matchedTile = tile;
          break;
        }
      }
    }
    final featuredTiles =
        <TileData>[
          if (matchedTile != null) matchedTile,
          for (final tile in factTiles)
            if (tile != matchedTile) tile,
        ].take(3).toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            constraints: const BoxConstraints(maxWidth: 620),
            decoration: BoxDecoration(
              color: const Color(0xF5131C34),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 30,
                  offset: ui.Offset(0, 12),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.cityBoard.emoji,
                        style: const TextStyle(fontSize: 38),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              highlight?.isNotEmpty == true ? highlight! : city,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '$city • $country • ${widget.cityBoard.nativeName}',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Explore $city as a living 3D theme park. The 40 game '
                    'locations keep the original rules, with extra scenic '
                    'stops and interactive landmarks between them.',
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                  if (featuredTiles.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const Text(
                      'QUICK FACTS',
                      style: TextStyle(
                        color: Color(0xFFFFD96A),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (final tile in featuredTiles)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: tile.color.withValues(alpha: 0.9),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                        title: Text(
                          tile.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: Text(
                          tile.funFact!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white60,
                            height: 1.3,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white54,
                        ),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) _showTileInfo(tile);
                          });
                        },
                      ),
                  ],
                  const SizedBox(height: 8),
                  const Text(
                    'Tap a location for its rules and fun fact, a character '
                    'for their portfolio, or the dice to roll.',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _normalizeGuideText(String value) {
    final normalized = StringBuffer();
    for (final rune in value.toLowerCase().runes) {
      final isAsciiLetter = rune >= 97 && rune <= 122;
      final isDigit = rune >= 48 && rune <= 57;
      final isNonAsciiLetter = rune > 127;
      if (isAsciiLetter || isDigit || isNonAsciiLetter) {
        normalized.writeCharCode(rune);
      }
    }
    return normalized.toString();
  }

  void _toggleMusic() {
    setState(() {
      _isMusicPlaying = !_isMusicPlaying;
    });
    AudioService.instance.setMusicEnabled(_isMusicPlaying);
  }

  void _showGameMenu() {
    final canPersistTurn =
        !_isProcessingTurn &&
        !_waitingForCardPick &&
        gameState.logicPhase == TurnLogicPhase.preRoll &&
        gameState.animationState == TurnAnimationState.idle;
    _isPaused = true;
    showGameMenuDialog(
      context: context,
      onClose: () {
        _isPaused = false;
        // Resume AI if it's their turn
        if (gameState.currentPlayer.isAI && gameState.canRoll) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && !_isPaused && gameState.canRoll) {
              _rollDice();
            }
          });
        }
      },
      onRestart: () {
        _isPaused = false;
        widget.onRestart();
      },
      onQuit: () {
        _isPaused = false;
        widget.onQuit();
      },
      onRules: widget.onHowToPlay,
      // Saving or replacing the board while a roll, dialog, or card draw is
      // unresolved leaves an old async turn attached to the new state. Only
      // expose persistence at the clean boundary before a roll.
      onSave: canPersistTurn ? _saveGame : null,
      onLoad:
          canPersistTurn && SaveService.instance.hasSavedGame()
              ? _loadGame
              : null,
    );
  }

  Future<void> _saveGame() async {
    final success = await SaveService.instance.saveGame(gameState);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                success
                    ? AppLocalizations.of(context)!.gameSaved
                    : AppLocalizations.of(context)!.failedToSave,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor:
              success ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _loadGame() async {
    if (_isProcessingTurn || _waitingForCardPick) return;
    final loadedState = await SaveService.instance.loadGame();

    if (loadedState != null && mounted) {
      // Older saves could be created in the middle of a turn. They cannot
      // safely recreate an open Flutter dialog, so recover them at a stable
      // pre-roll boundary for the same player.
      final recoveredState =
          loadedState.canRoll
              ? loadedState
              : loadedState.copyWith(
                logicPhase: TurnLogicPhase.preRoll,
                animationState: TurnAnimationState.idle,
              );
      setState(() {
        gameState = recoveredState;
        engine = GameEngine(gameState);
        _isPaused = false;
        _isProcessingTurn = false;
        _waitingForCardPick = false;
        _isChanceCard = false;
        _cardPickPlayer = null;
        _cardPickCompleter = null;
      });
      _sync3DBoard();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.gameLoaded(gameState.roundNumber),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2196F3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // If it's AI turn, trigger their action
      if (gameState.currentPlayer.isAI && gameState.canRoll) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted && !_isPaused && gameState.canRoll) {
            _rollDice();
          }
        });
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.failedToLoad,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFF5252),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.boardTheme;
    final backgroundGradient =
        theme != null
            ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.boardColor, theme.centerBackground],
            )
            : AppTheme.backgroundGradient;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (_show3DBoard) {
                    return _build3DBoardLayout();
                  }
                  final useLandscape =
                      constraints.maxWidth > constraints.maxHeight * 1.08;
                  return Padding(
                    // The city guide is an overlay. Reserve its row so it
                    // never covers a player card on four-player layouts.
                    padding: const EdgeInsets.only(top: 46),
                    child:
                        useLandscape
                            ? _buildLandscapeLayout()
                            : _buildPortraitLayout(),
                  );
                },
              ),
              Positioned(
                top: 8,
                left: _show3DBoard ? null : 0,
                right: _show3DBoard ? 8 : 0,
                child:
                    _show3DBoard
                        ? _buildCityBadge()
                        : Center(child: _buildCityBadge()),
              ),
              // Power-up cards button (if has cards) - top left overlay
              if (!_show3DBoard &&
                  !gameState.currentPlayer.isAI &&
                  gameState.getPowerUps(gameState.currentPlayer.id).isNotEmpty)
                Positioned(
                  top: 8,
                  left: 8,
                  child: _buildActionButton(
                    icon: Icons.style,
                    label:
                        '${gameState.getPowerUps(gameState.currentPlayer.id).length}',
                    color: Colors.amber,
                    onTap: _showPowerUpHand,
                  ),
                ),
              // Phase 3: Active event indicators
              if (gameState.activeEvents.isNotEmpty)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        gameState.activeEvents
                            .where((e) => !e.isExpired)
                            .map(
                              (event) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: ActiveEventIndicator(activeEvent: event),
                              ),
                            )
                            .toList(),
                  ),
                ),
              if (!_show3DBoard && _waitingForCardPick)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: MediaQuery.sizeOf(context).width < 700 ? 76 : 14,
                  child: Center(
                    child: KeyedSubtree(
                      key: const Key('card-pick-prompt'),
                      child: _build3DCardDeckPrompt(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityBadge() {
    final l10n = AppLocalizations.of(context)!;
    final city = widget.cityBoard.localizedDisplayName(l10n);
    final country = widget.cityBoard.country.localizedDisplayName(l10n);

    return Material(
      color: Colors.black.withValues(alpha: 0.42),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: _showCityGuide,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width < 600 ? 180 : 260,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.cityBoard.emoji),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '$city • $country',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DBoardLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: GodotBoardHost(controller: _godotBoardController),
            ),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                excludeFromSemantics: true,
                onScaleStart: _on3DGestureStart,
                onScaleUpdate: _on3DGestureUpdate,
                onScaleEnd: _on3DGestureEnd,
                onTapUp:
                    (details) => _on3DBoardTap(details, constraints.biggest),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: _build3DActionBar(compact: constraints.maxWidth < 700),
            ),
            Positioned(
              top: constraints.maxWidth < 700 ? 66 : 12,
              left: 68,
              right: 68,
              child: Center(child: _build3DCurrentPlayerHud()),
            ),
            if (constraints.maxWidth >= 700)
              Positioned(left: 14, bottom: 16, child: _build3DGestureHint()),
            if (_waitingForCardPick)
              Positioned(
                left: 12,
                right: 12,
                bottom: 106,
                child: Center(child: _build3DCardDeckPrompt()),
              ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 14,
              child: Align(
                alignment: Alignment.bottomRight,
                child: _build3DRollControl(),
              ),
            ),
          ],
        );
      },
    );
  }

  void _on3DGestureStart(ScaleStartDetails details) {
    _last3DGestureFocalPoint = details.localFocalPoint;
    _last3DGestureScale = 1;
  }

  void _on3DGestureUpdate(ScaleUpdateDetails details) {
    final focalDelta = details.localFocalPoint - _last3DGestureFocalPoint;
    var panDeltaX = 0.0;
    var panDeltaY = 0.0;
    var zoomScale = 1.0;

    if (details.pointerCount >= 2) {
      if (_last3DGestureScale > 0) {
        zoomScale = (details.scale / _last3DGestureScale).clamp(0.82, 1.18);
      }
    } else {
      panDeltaX = focalDelta.dx;
      panDeltaY = focalDelta.dy;
    }

    _last3DGestureFocalPoint = details.localFocalPoint;
    _last3DGestureScale = details.scale;
    unawaited(
      _godotBoardController.updateCameraGesture(
        panDeltaX: panDeltaX,
        panDeltaY: panDeltaY,
        zoomScale: zoomScale,
      ),
    );
  }

  void _on3DGestureEnd(ScaleEndDetails details) {
    _last3DGestureScale = 1;
  }

  void _on3DBoardTap(TapUpDetails details, Size boardSize) {
    if (boardSize.width <= 0 || boardSize.height <= 0) return;
    unawaited(
      _godotBoardController.pickBoardObject(
        normalizedX: details.localPosition.dx / boardSize.width,
        normalizedY: details.localPosition.dy / boardSize.height,
      ),
    );
  }

  Widget _build3DCurrentPlayerHud() {
    final player = gameState.currentPlayer;
    return Semantics(
      button: true,
      label: 'Open ${player.name} portfolio',
      child: Tooltip(
        message: 'View ${player.name} portfolio',
        child: AnimatedContainer(
          key: const Key('3d-current-player-hud'),
          duration: const Duration(milliseconds: 220),
          constraints: const BoxConstraints(maxWidth: 230),
          decoration: BoxDecoration(
            color: const Color(0xE6111A33),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: player.color, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: player.color.withValues(alpha: 0.3),
                blurRadius: 16,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap:
                  () => showPropertyPortfolioDialog(
                    context: context,
                    player: player,
                    tiles: gameState.tiles,
                    gameState: gameState,
                  ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(player.icon.iconData, size: 17, color: player.color),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        '${player.name}’s turn',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${player.cash}',
                      style: TextStyle(
                        color: player.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _build3DActionBar({required bool compact}) {
    final currentPlayer = gameState.currentPlayer;
    final powerUpCount = gameState.getPowerUps(currentPlayer.id).length;
    final hasMoreActions =
        !currentPlayer.isAI &&
        (widget.tradingEnabled || widget.bankEnabled || powerUpCount > 0);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _build3DOverlayButton(
          icon: Icons.menu_rounded,
          tooltip: 'Game menu',
          onTap: _showGameMenu,
        ),
        const SizedBox(width: 7),
        _build3DOverlayButton(
          icon: _isMusicPlaying ? Icons.music_note : Icons.music_off,
          tooltip: _isMusicPlaying ? 'Mute music' : 'Play music',
          onTap: _toggleMusic,
          color:
              _isMusicPlaying
                  ? const Color(0xE61D765F)
                  : const Color(0xE6111A33),
        ),
        if (!compact && !currentPlayer.isAI && widget.tradingEnabled) ...[
          const SizedBox(width: 7),
          _build3DOverlayButton(
            icon: Icons.swap_horiz_rounded,
            tooltip: 'Trade',
            onTap: _showTradeDialog,
            color: const Color(0xE6197C78),
          ),
        ],
        if (!compact && !currentPlayer.isAI && widget.bankEnabled) ...[
          const SizedBox(width: 7),
          _build3DOverlayButton(
            icon: Icons.account_balance_rounded,
            tooltip: 'Bank',
            onTap: _showMortgageDialog,
            color: const Color(0xE65A3B87),
          ),
        ],
        if (!compact && !currentPlayer.isAI && powerUpCount > 0) ...[
          const SizedBox(width: 7),
          Badge.count(
            count: powerUpCount,
            child: _build3DOverlayButton(
              icon: Icons.style_rounded,
              tooltip: 'Power-up cards',
              onTap: _showPowerUpHand,
              color: const Color(0xE69A6C16),
            ),
          ),
        ],
        if (compact && hasMoreActions) ...[
          const SizedBox(width: 7),
          _build3DOverlayButton(
            icon: Icons.more_horiz_rounded,
            tooltip: 'More actions',
            onTap: _show3DMoreActions,
          ),
        ],
      ],
    );
  }

  void _show3DMoreActions() {
    final player = gameState.currentPlayer;
    final powerUpCount = gameState.getPowerUps(player.id).length;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF131C34),
      showDragHandle: true,
      builder:
          (sheetContext) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.tradingEnabled)
                  ListTile(
                    leading: const Icon(
                      Icons.swap_horiz_rounded,
                      color: Colors.tealAccent,
                    ),
                    title: const Text(
                      'Trade',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showTradeDialog();
                    },
                  ),
                if (widget.bankEnabled)
                  ListTile(
                    leading: const Icon(
                      Icons.account_balance_rounded,
                      color: Colors.deepPurpleAccent,
                    ),
                    title: const Text(
                      'Bank',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showMortgageDialog();
                    },
                  ),
                if (powerUpCount > 0)
                  ListTile(
                    leading: const Icon(
                      Icons.style_rounded,
                      color: Colors.amber,
                    ),
                    title: Text(
                      'Power-up cards ($powerUpCount)',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showPowerUpHand();
                    },
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  Widget _build3DCardDeckPrompt() {
    final isChance = _isChanceCard;
    final color = isChance ? Colors.orange : Colors.blue;
    return Material(
      color: color.shade700.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(16),
      elevation: 12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onCardDeckTap(isChance),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isChance ? Icons.help_outline : Icons.inventory_2_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text(
                isChance ? 'DRAW A CHANCE CARD' : 'OPEN COMMUNITY CHEST',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DRollControl() {
    final boardReady = _godotBoardController.isBoardReady;
    final canRoll = boardReady && gameState.canRoll && !_isProcessingTurn;
    final isRolling =
        gameState.animationState == TurnAnimationState.rollingDice;
    final isMoving = gameState.animationState == TurnAnimationState.movingToken;
    final label =
        !boardReady
            ? 'LOADING BOARD'
            : isRolling
            ? 'ROLLING…'
            : isMoving
            ? 'MOVING…'
            : 'ROLL FOR ${gameState.currentPlayer.name.toUpperCase()}';
    final diceValue =
        gameState.die1Value <= 0
            ? 'READY'
            : gameState.diceCount == 1
            ? '${gameState.die1Value}'
            : '${gameState.die1Value} + ${gameState.die2Value}';

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = canRoll ? 0.16 + _glowController.value * 0.22 : 0.05;
        return Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xEE111A33),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: glow),
                blurRadius: 28,
                spreadRadius: 1,
                offset: const ui.Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 82,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'DICE',
                      style: TextStyle(
                        color: Color(0xFFFFE29A),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      diceValue,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Material(
                  color:
                      canRoll
                          ? const Color(0xFFF2C452)
                          : const Color(0xFF26324E),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: canRoll ? _rollDice : null,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 190,
                        minHeight: 58,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isRolling || isMoving)
                            const SizedBox(
                              width: 21,
                              height: 21,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          else
                            Icon(
                              Icons.casino_rounded,
                              size: 23,
                              color:
                                  canRoll
                                      ? const Color(0xFF142033)
                                      : Colors.white54,
                            ),
                          const SizedBox(width: 9),
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color:
                                    canRoll
                                        ? const Color(0xFF142033)
                                        : Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'Reset view',
                child: Material(
                  color: const Color(0xFF26324E),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _godotBoardController.resetCamera,
                    child: const SizedBox(
                      width: 58,
                      height: 58,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.center_focus_strong_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'VIEW',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _build3DGestureHint() {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xB3111A33),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pinch_rounded, size: 16, color: Colors.white70),
            SizedBox(width: 6),
            Text(
              'Tap to explore  •  Drag to move  •  Pinch to zoom',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DOverlayButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = const Color(0xE6111A33),
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        color: Colors.white,
        icon: Icon(icon),
      ),
    );
  }

  Widget _build2DBoardViewport(double boardSize, {bool interactive = false}) {
    // The original 2D board contains rich fixed-size details. Lay it out at a
    // comfortable logical canvas and scale the complete board on small phones.
    // This preserves every control without RenderFlex overflows.
    final logicalBoardSize = max(boardSize, 1100.0);
    final scaledBoard = SizedBox(
      width: boardSize,
      height: boardSize,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: logicalBoardSize,
          height: logicalBoardSize,
          child: GameBoard(
            players: gameState.players,
            currentPlayerIndex: gameState.currentPlayerIndex,
            highlightedTile: gameState.highlightedTileIndex,
            bounceAnimation: _bounceAnimation,
            glowController: _glowController,
            tiles: gameState.tiles,
            boardTheme: widget.boardTheme,
            centerControls: _buildCenterControls(),
            onMenuTap: _showGameMenu,
            onTradeTap: widget.tradingEnabled ? _showTradeDialog : null,
            onBankTap: widget.bankEnabled ? _showMortgageDialog : null,
            showActionButtons:
                !gameState.currentPlayer.isAI &&
                (widget.tradingEnabled || widget.bankEnabled),
            onTileTap: _showTileInfo,
            isChanceHighlighted: _waitingForCardPick && _isChanceCard,
            isChestHighlighted: _waitingForCardPick && !_isChanceCard,
            onChanceTap: () => _onCardDeckTap(true),
            onChestTap: () => _onCardDeckTap(false),
            onMusicToggle: _toggleMusic,
            isMusicPlaying: _isMusicPlaying,
          ),
        ),
      ),
    );

    if (!interactive) return scaledBoard;

    return InteractiveViewer(
      key: const Key('compact-2d-board-zoom'),
      minScale: 1,
      maxScale: 4.5,
      boundaryMargin: const EdgeInsets.all(80),
      clipBehavior: Clip.hardEdge,
      child: scaledBoard,
    );
  }

  Widget _buildCompactPlayerPill(Player player, {bool vertical = false}) {
    final isCurrent = player.id == gameState.currentPlayer.id;
    return Material(
      color:
          isCurrent
              ? player.color.withValues(alpha: 0.28)
              : const Color(0xC9142038),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap:
            () => showPropertyPortfolioDialog(
              context: context,
              player: player,
              tiles: gameState.tiles,
              gameState: gameState,
            ),
        child: Container(
          width: vertical ? double.infinity : 104,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCurrent ? player.color : Colors.white12,
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(player.icon.iconData, color: player.color, size: 20),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        height: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '\$${player.cash}',
                      style: TextStyle(
                        color: isCurrent ? player.color : Colors.white70,
                        fontSize: 11,
                        height: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactPlayerStrip() {
    final players =
        gameState.players
            .where((p) => p.status == PlayerStatus.active)
            .toList();
    return SizedBox(
      key: const Key('compact-2d-hud'),
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        itemCount: players.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (_, index) => _buildCompactPlayerPill(players[index]),
      ),
    );
  }

  Widget _buildCompact2DActionBar() {
    final player = gameState.currentPlayer;
    final canRoll = gameState.canRoll && !_isProcessingTurn;
    final powerUpCount = gameState.getPowerUps(player.id).length;
    final hasMoreActions =
        !player.isAI &&
        (widget.tradingEnabled || widget.bankEnabled || powerUpCount > 0);

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 5, 8, 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xE6111A33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('compact-menu-button'),
            tooltip: 'Game menu',
            onPressed: _showGameMenu,
            color: Colors.white,
            icon: const Icon(Icons.menu_rounded),
          ),
          IconButton(
            tooltip: _isMusicPlaying ? 'Mute music' : 'Play music',
            onPressed: _toggleMusic,
            color: Colors.white,
            icon: Icon(
              _isMusicPlaying ? Icons.music_note_rounded : Icons.music_off,
            ),
          ),
          if (hasMoreActions)
            IconButton(
              tooltip: 'More actions',
              onPressed: _show3DMoreActions,
              color: Colors.white,
              icon: const Icon(Icons.more_horiz_rounded),
            ),
          const SizedBox(width: 4),
          Expanded(
            child: FilledButton.icon(
              key: const Key('compact-roll-button'),
              onPressed: canRoll ? _rollDice : null,
              icon: const Icon(Icons.casino_rounded),
              label: Text(
                canRoll
                    ? AppLocalizations.of(context)!.rollDice
                    : gameState.animationState == TurnAnimationState.movingToken
                    ? 'MOVING…'
                    : 'PLEASE WAIT…',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF2BD49),
                foregroundColor: const Color(0xFF111A33),
                disabledBackgroundColor: Colors.white12,
                disabledForegroundColor: Colors.white54,
                minimumSize: const Size(0, 46),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPortraitLayout(BoxConstraints constraints) {
    final boardSize = max(
      0.0,
      min(constraints.maxWidth - 16, constraints.maxHeight - 136),
    );
    return Column(
      children: [
        _buildCompactPlayerStrip(),
        Expanded(
          child: Center(
            child: Stack(
              children: [
                _build2DBoardViewport(boardSize, interactive: true),
                Positioned(
                  top: 8,
                  left: 8,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xC9142038),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Pinch to zoom • drag to explore',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildCompact2DActionBar(),
      ],
    );
  }

  Widget _buildCompactLandscapeLayout(BoxConstraints constraints) {
    final players =
        gameState.players
            .where((p) => p.status == PlayerStatus.active)
            .toList();
    final sidebarWidth = min(196.0, max(164.0, constraints.maxWidth * 0.24));
    final boardSize = max(
      0.0,
      min(constraints.maxHeight - 16, constraints.maxWidth - sidebarWidth - 24),
    );
    return Row(
      key: const Key('compact-2d-hud'),
      children: [
        SizedBox(
          width: sidebarWidth,
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  itemCount: players.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder:
                      (_, index) => _buildCompactPlayerPill(
                        players[index],
                        vertical: true,
                      ),
                ),
              ),
              _buildCompact2DActionBar(),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: _build2DBoardViewport(boardSize, interactive: true),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    final activePlayers =
        gameState.players
            .where((p) => p.status == PlayerStatus.active)
            .toList();
    final halfCount = (activePlayers.length / 2).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight < 600 || constraints.maxWidth < 700) {
          return _buildCompactLandscapeLayout(constraints);
        }
        final boardSize = max(
          0.0,
          min(constraints.maxHeight - 16, constraints.maxWidth - 16),
        );
        final remainingWidth = constraints.maxWidth - boardSize;
        final showPlayerPanels =
            constraints.maxHeight >= 600 && remainingWidth >= 480;
        final playerPanelWidth = showPlayerPanels ? remainingWidth / 2 : 0.0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left player panel - fixed width based on remaining space
            if (showPlayerPanels && activePlayers.isNotEmpty)
              SizedBox(
                width: playerPanelWidth,
                child: _buildVerticalPlayerPanel(
                  activePlayers.take(halfCount).toList(),
                ),
              ),
            // Game board - maximized square
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _build2DBoardViewport(boardSize),
            ),
            // Right player panel - fixed width based on remaining space
            if (showPlayerPanels && activePlayers.length > halfCount)
              SizedBox(
                width: playerPanelWidth,
                child: _buildVerticalPlayerPanel(
                  activePlayers.skip(halfCount).toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPortraitLayout() {
    final activePlayers =
        gameState.players
            .where((p) => p.status == PlayerStatus.active)
            .toList();
    final halfCount = (activePlayers.length / 2).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return _buildCompactPortraitLayout(constraints);
        }
        final boardSize = max(
          0.0,
          min(constraints.maxWidth - 16, constraints.maxHeight - 16),
        );
        final remainingHeight = constraints.maxHeight - boardSize;
        final showPlayerPanels =
            constraints.maxWidth >= 700 && remainingHeight >= 240;
        final playerPanelHeight = showPlayerPanels ? remainingHeight / 2 : 0.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top player panel - fixed height based on remaining space
            if (showPlayerPanels && activePlayers.isNotEmpty)
              SizedBox(
                height: playerPanelHeight,
                child: _buildHorizontalPlayerPanel(
                  activePlayers.take(halfCount).toList(),
                ),
              ),
            // Game board - maximized square
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _build2DBoardViewport(boardSize),
            ),
            // Bottom player panel - fixed height based on remaining space
            if (showPlayerPanels && activePlayers.length > halfCount)
              SizedBox(
                height: playerPanelHeight,
                child: _buildHorizontalPlayerPanel(
                  activePlayers.skip(halfCount).toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildVerticalPlayerPanel(List<Player> players) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Column(
        children:
            players.map((player) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PlayerCard(
                    player: player,
                    isCurrentPlayer: player.id == gameState.currentPlayer.id,
                    tiles: gameState.tiles,
                    gameState: gameState,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildHorizontalPlayerPanel(List<Player> players) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children:
            players.map((player) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: PlayerCardCompact(
                    player: player,
                    isCurrentPlayer: player.id == gameState.currentPlayer.id,
                    tiles: gameState.tiles,
                    gameState: gameState,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCenterControls({bool boardReady = true}) {
    // Only allow roll if game state allows AND we're not processing a turn
    final canRoll = boardReady && gameState.canRoll && !_isProcessingTurn;

    return CenterControls(
      die1: gameState.die1Value,
      die2: gameState.die2Value,
      isRolling: gameState.animationState == TurnAnimationState.rollingDice,
      isMoving: gameState.animationState == TurnAnimationState.movingToken,
      onRoll: canRoll ? _rollDice : null,
      diceController: _diceController,
      glowController: _glowController,
      diceCount: gameState.diceCount,
    );
  }

  Future<void> _rollDice() async {
    // Prevent double-tap exploits
    if (_isProcessingTurn) return;

    // Lock turn processing
    setState(() {
      _isProcessingTurn = true;
      gameState = gameState.copyWith(
        animationState: TurnAnimationState.rollingDice,
      );
    });
    final use3DRoll = _show3DBoard && _godotBoardController.isBoardReady;
    if (!use3DRoll) {
      _diceController.forward(from: 0);
    }

    // Play dice roll sound
    AudioService.instance.onDiceRoll();

    // Generate dice values (respect configured dice count and double-dice power-up)
    final player = gameState.currentPlayer;
    int die1;
    int die2;
    int roll;
    bool isDoubles = false;
    final hasDoubleDice = gameState.hasActivePowerUp(
      player.id,
      PowerUpType.doubleDice,
    );

    if (gameState.diceCount == 1) {
      if (hasDoubleDice) {
        final r1 = _random.nextInt(6) + 1;
        final r2 = _random.nextInt(6) + 1;
        die1 = r1 > r2 ? r1 : r2;
      } else {
        die1 = _random.nextInt(6) + 1;
      }
      die2 = 0;
      roll = die1;
    } else {
      if (hasDoubleDice) {
        final rolls = List<int>.generate(4, (_) => _random.nextInt(6) + 1)
          ..sort((a, b) => b.compareTo(a));
        die1 = rolls[0];
        die2 = rolls[1];
      } else {
        die1 = _random.nextInt(6) + 1;
        die2 = _random.nextInt(6) + 1;
      }
      roll = die1 + die2;
      isDoubles = die1 == die2;
    }

    if (!use3DRoll) {
      await Future.delayed(AnimationDurations.diceRoll);
      AudioService.instance.onDiceLand();
    }

    // Phase 3: Track dice stats
    final newTotalRolls = gameState.totalDiceRolls + 1;
    final newTotalSum = gameState.totalDiceSum + roll;
    final newDoublesTotal = gameState.doublesRolledTotal + (isDoubles ? 1 : 0);

    // Update dice values and start moving
    setState(() {
      gameState = gameState.copyWith(
        die1Value: die1,
        die2Value: die2,
        lastDiceRoll: roll,
        animationState:
            use3DRoll
                ? TurnAnimationState.rollingDice
                : TurnAnimationState.movingToken,
        logicPhase: TurnLogicPhase.rolled,
        totalDiceRolls: newTotalRolls,
        totalDiceSum: newTotalSum,
        doublesRolledTotal: newDoublesTotal,
      );
    });

    // Move current player tile by tile. Flutter owns the logical destination;
    // Godot only animates the mapped visual route.
    final startPosition = player.position;
    final tileCount = gameState.tiles.length;
    final endPosition = (startPosition + roll) % tileCount;
    var movedInGodot = false;

    if (_show3DBoard && _godotBoardController.isBoardReady) {
      final command = _godotBoardController.createRollCommand(
        gameState: gameState,
        playerIndex: gameState.currentPlayerIndex,
        die1: die1,
        die2: die2,
      );
      try {
        final movementFuture = _godotBoardController.animateRoll(command);
        await Future.delayed(const Duration(milliseconds: 1040));
        AudioService.instance.onDiceLand();
        if (mounted) {
          setState(() {
            gameState = gameState.copyWith(
              animationState: TurnAnimationState.movingToken,
            );
          });
        }
        final movement = await movementFuture;
        movedInGodot =
            movement.playerId == player.id &&
            movement.logicalPosition == endPosition;
      } on Object {
        movedInGodot = false;
        if (mounted) {
          setState(() {
            gameState = gameState.copyWith(
              animationState: TurnAnimationState.movingToken,
            );
          });
        }
      }
    }

    if (movedInGodot) {
      setState(() {
        player.position = endPosition;
        if (startPosition + roll >= tileCount) {
          player.cash += gameState.getGoBonusForPlayer(player.id);
          AudioService.instance.onPassGo();
          _checkMidGameAchievements(player);
        }
      });
    } else {
      for (int i = 0; i < roll; i++) {
        await Future.delayed(AnimationDurations.tokenHop);

        AudioService.instance.onTokenStep();
        setState(() {
          player.position = (player.position + 1) % tileCount;
          if (player.position == 0) {
            player.cash += gameState.getGoBonusForPlayer(player.id);
            AudioService.instance.onPassGo();
            _checkMidGameAchievements(player);
          }
        });
        _bounceController.forward(from: 0);
      }
    }

    // Play token land sound
    AudioService.instance.onTokenLand();

    // Highlight landing tile
    setState(() {
      gameState = gameState.copyWith(
        highlightedTileIndex: endPosition,
        animationState: TurnAnimationState.idle,
        logicPhase: TurnLogicPhase.tileResolution,
      );
    });
    await _sync3DBoard();

    // Wait for the bounce animation to complete before showing dialogs
    await Future.delayed(const Duration(milliseconds: 600));

    // Resolve the tile landing
    await _resolveTileLanding(player, endPosition);
  }

  Future<void> _resolveTileLanding(
    Player player,
    int tileIndex, {
    bool skipEndTurn = false,
  }) async {
    final result = engine.resolveTileLanding(player, tileIndex);

    switch (result.actionType) {
      case TileActionType.buyProperty:
        await _handleBuyOption(player, result.tile!);
        break;

      case TileActionType.payRent:
        await _handlePayRent(
          player,
          result.tile!,
          result.amount!,
          result.targetPlayerId!,
        );
        break;

      case TileActionType.payTax:
        await _handlePayTax(player, result.tile!.name, result.amount!);
        break;

      case TileActionType.goToJail:
        _handleGoToJail(player);
        break;

      case TileActionType.drawCard:
        await _handleDrawCard(player, result.tile!);
        break;

      case TileActionType.upgradeProperty:
        await _handleUpgradeOption(player, result.tile! as PropertyTileData);
        break;

      case TileActionType.spinWheel:
        await _handleSpinWheel(player);
        break;

      case TileActionType.miniGame:
        await _handleMiniGame(player);
        break;

      case TileActionType.nothing:
      case TileActionType.collectGo:
        // Nothing happens on GO, Free Parking, Jail (visiting), etc.
        break;
    }

    if (skipEndTurn) return;

    // Check win condition
    if (_checkWinCondition()) {
      return;
    }

    // End turn
    await Future.delayed(const Duration(milliseconds: 500));
    _endTurn();
  }

  // Show centered AI action notification popup (kid-friendly)
  Future<void> _showAIActionNotification(
    String playerName,
    String message,
    IconData icon,
    Color color,
  ) async {
    if (!mounted) return;
    await showAIActionDialog(
      context: context,
      playerName: playerName,
      message: message,
      icon: icon,
      color: color,
    );
  }

  Future<void> _handleBuyOption(Player player, TileData tile) async {
    // AI automatically decides whether to buy using enhanced AI engine
    if (player.isAI) {
      await Future.delayed(const Duration(milliseconds: 300));

      final aiEngine = _aiEngines[player.id];
      final shouldBuy =
          aiEngine?.shouldBuyProperty(player, tile, gameState) ??
          _defaultAIShouldBuy(player, tile);

      if (shouldBuy) {
        final price = engine.getPurchasePrice(player, tile);

        await _showAIActionNotification(
          player.name,
          AppLocalizations.of(context)!.boughtProperty(tile.name, price),
          Icons.home,
          Colors.green,
        );
        if (engine.buyProperty(player, tile)) {
          AudioService.instance.onBuyProperty();
          setState(() {});
          await _sync3DBoard();
        }
      } else {
        // AI declined - start auction for all players
        await _startAuction(tile);
      }
      return;
    }

    // Human player gets dialog
    await showBuyPropertyDialog(
      context: context,
      tile: tile,
      playerCash: player.cash,
      purchasePrice: engine.getPurchasePrice(player, tile),
      onBuy: () {
        if (engine.buyProperty(player, tile)) {
          AudioService.instance.onBuyProperty();
          setState(() {});
          unawaited(_sync3DBoard());
        }
      },
      onSkip: () async {
        // Player chose not to buy - start auction
        await _startAuction(tile);
      },
    );
  }

  bool _defaultAIShouldBuy(Player player, TileData tile) {
    final price = engine.getPurchasePrice(player, tile);
    return price > 0 && player.cash >= price + 100;
  }

  Future<void> _startAuction(TileData tile) async {
    if (!mounted) return;

    // Skip auction if disabled - property stays unowned
    if (!widget.auctionEnabled) return;

    final activePlayers =
        gameState.players
            .where((p) => p.status == PlayerStatus.active)
            .toList();

    if (activePlayers.length < 2) return;

    await showAuctionDialog(
      context: context,
      property: tile,
      participants: activePlayers,
      onAuctionComplete: (winner, amount) {
        // Winner pays and gets property
        winner.cash -= amount;
        if (tile is PropertyTileData) {
          tile.ownerId = winner.id;
          winner.propertyIds.add(tile.index.toString());
        } else if (tile is RailroadTileData) {
          tile.ownerId = winner.id;
          winner.propertyIds.add(tile.index.toString());
        } else if (tile is UtilityTileData) {
          tile.ownerId = winner.id;
          winner.propertyIds.add(tile.index.toString());
        }
        setState(() {});
        unawaited(_sync3DBoard());
      },
      onNoWinner: () {
        // Property goes back to bank (no change needed)
      },
    );
  }

  Future<void> _handleUpgradeOption(
    Player player,
    PropertyTileData property,
  ) async {
    // AI automatically decides whether to upgrade using enhanced AI engine
    if (player.isAI) {
      await Future.delayed(const Duration(milliseconds: 300));

      final aiEngine = _aiEngines[player.id];
      final shouldUpgrade =
          aiEngine?.shouldUpgradeProperty(player, property, gameState) ??
          (player.cash >= property.upgradeCost + 200);

      if (shouldUpgrade) {
        final levelName =
            property.upgradeLevel < 4
                ? AppLocalizations.of(
                  context,
                )!.buildHouse.toLowerCase().replaceAll('!', '')
                : AppLocalizations.of(
                  context,
                )!.buildHotel.toLowerCase().replaceAll('!', '');
        await _showAIActionNotification(
          player.name,
          AppLocalizations.of(context)!.aiBuiltOn(levelName, property.name),
          Icons.construction,
          Colors.green,
        );
        if (engine.upgradeProperty(player, property)) {
          AudioService.instance.onUpgrade();
          setState(() {});
          await _sync3DBoard();
        }
      }
      return;
    }

    // Human player gets dialog
    await showPropertyUpgradeDialog(
      context: context,
      property: property,
      playerCash: player.cash,
      onUpgrade: () {
        if (engine.upgradeProperty(player, property)) {
          AudioService.instance.onUpgrade();
          setState(() {});
          unawaited(_sync3DBoard());
        }
      },
      onSkip: () {
        // Player chose not to upgrade
      },
    );
  }

  Future<void> _handlePayRent(
    Player player,
    TileData tile,
    int amount,
    String ownerId,
  ) async {
    final owner = gameState.players.firstWhere((p) => p.id == ownerId);
    final isBankruptcy = player.cash < amount;

    // Determine rent type and additional info for display
    RentType rentType = RentType.property;
    int? diceRoll;
    int? ownedCount;

    if (tile is UtilityTileData) {
      rentType = RentType.utility;
      diceRoll = gameState.lastDiceRoll;
      ownedCount =
          gameState.tiles
              .whereType<UtilityTileData>()
              .where((u) => u.ownerId == ownerId)
              .length;
    } else if (tile is RailroadTileData) {
      rentType = RentType.railroad;
      ownedCount =
          gameState.tiles
              .whereType<RailroadTileData>()
              .where((r) => r.ownerId == ownerId)
              .length;
    }

    // AI automatically pays rent with notification
    if (player.isAI) {
      await _showAIActionNotification(
        player.name,
        AppLocalizations.of(context)!.paidRentTo(amount, owner.name),
        Icons.payments,
        Colors.red,
      );
      AudioService.instance.onPayMoney();
      final result = engine.payRent(player, ownerId, amount);
      if (!result.bankruptcy) {
        AudioService.instance.onCollectMoney(); // Owner collects
      }
      setState(() {
        if (result.bankruptcy) {
          AudioService.instance.onDefeat();
          player.status = PlayerStatus.bankrupt;
          // Transfer all properties to owner
          for (final propId in player.propertyIds) {
            owner.propertyIds.add(propId);
          }
          player.propertyIds.clear();
        }
      });
      return;
    }

    // Human player gets dialog
    await showRentPaymentDialog(
      context: context,
      propertyName: tile.name,
      amount: amount,
      owner: owner,
      payer: player,
      isBankruptcy: isBankruptcy,
      rentType: rentType,
      diceRoll: diceRoll,
      ownedCount: ownedCount,
      onConfirm: () {
        AudioService.instance.onPayMoney();
        final result = engine.payRent(player, ownerId, amount);
        setState(() {
          if (result.bankruptcy) {
            AudioService.instance.onDefeat();
            player.status = PlayerStatus.bankrupt;
            // Transfer all properties to owner
            for (final propId in player.propertyIds) {
              owner.propertyIds.add(propId);
            }
            player.propertyIds.clear();
          } else {
            AudioService.instance.onCollectMoney(); // Owner collects
          }
        });
      },
    );
  }

  Future<void> _handlePayTax(Player player, String taxName, int amount) async {
    final isBankruptcy = player.cash < amount;

    // AI automatically pays tax with notification
    if (player.isAI) {
      await _showAIActionNotification(
        player.name,
        AppLocalizations.of(context)!.paidTax(amount, taxName),
        Icons.account_balance,
        Colors.amber.shade700,
      );
      AudioService.instance.onPayMoney();
      final result = engine.payTax(player, amount);
      setState(() {
        if (result.bankruptcy) {
          AudioService.instance.onDefeat();
          player.status = PlayerStatus.bankrupt;
          player.propertyIds.clear();
        }
      });
      return;
    }

    // Human player gets dialog
    await showTaxPaymentDialog(
      context: context,
      taxName: taxName,
      amount: amount,
      playerCash: player.cash,
      isBankruptcy: isBankruptcy,
      onConfirm: () {
        AudioService.instance.onPayMoney();
        final result = engine.payTax(player, amount);
        setState(() {
          if (result.bankruptcy) {
            AudioService.instance.onDefeat();
            player.status = PlayerStatus.bankrupt;
            player.propertyIds.clear();
          }
        });
      },
    );
  }

  Future<void> _handleGoToJail(Player player) async {
    AudioService.instance.onJail();
    engine.sendToJail(player);
    setState(() {});

    if (!mounted) return;

    // Show notification for both AI and human players
    if (player.isAI) {
      await _showAIActionNotification(
        player.name,
        AppLocalizations.of(context)!.goingToJail,
        Icons.gavel,
        Colors.grey.shade700,
      );
    } else {
      // Show a brief dialog for human players so they know what happened
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 300),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D44),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🚔', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.goToJailTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.goToJailMessage,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.ok,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );
    }
  }

  // ==========================================================================
  // Phase 3: Spin Wheel Handler
  // ==========================================================================
  Future<void> _handleSpinWheel(Player player) async {
    // AI gets automatic random prize with notification
    if (player.isAI) {
      AudioService.instance.onSpinWheel();
      final prize = SpinPrizes.getRandomPrize();
      final prizeText = prize.value != null ? '\$${prize.value}' : prize.name;
      AudioService.instance.onSpinResult();
      await _showAIActionNotification(
        player.name,
        AppLocalizations.of(context)!.wonPrize(prizeText),
        Icons.casino,
        Colors.purple,
      );
      await _applySpinPrizeWithUI(player, prize);
      setState(() {});
      await _sync3DBoard();
      return;
    }

    // Human player gets spin wheel dialog
    if (!mounted) return;

    await showSpinWheelDialog(
      context: context,
      playerName: player.name,
      onPrizeWon: (prize) async {
        // Apply prize first (may show sub-dialogs like Free House or Teleport)
        await _applySpinPrizeWithUI(player, prize);
        if (mounted) {
          setState(() {});
          await _sync3DBoard();
        }
      },
    );
  }

  /// Apply spin prize with UI dialogs for interactive prizes (Free House, Teleport)
  Future<void> _applySpinPrizeWithUI(Player player, SpinPrize prize) async {
    switch (prize.type) {
      case SpinPrizeType.cash:
      case SpinPrizeType.jackpot:
        player.cash += prize.value ?? 0;
        break;

      case SpinPrizeType.freeHouse:
        // Show property selection dialog for human players
        if (!player.isAI && mounted) {
          // Get all upgradable properties owned by the player
          final ownedProperties =
              gameState.tiles
                  .whereType<PropertyTileData>()
                  .where((p) => p.ownerId == player.id && p.canUpgrade)
                  .toList();

          if (ownedProperties.isNotEmpty) {
            bool houseUsed = false;
            await showFreeHouseDialog(
              context: context,
              properties: ownedProperties,
              onPropertySelected: (property) {
                houseUsed = true;
                property.upgradeLevel++;
                setState(() {});
              },
            );
            // If player chose "Save for Later", store the prize
            if (!houseUsed) {
              gameState.playerSpinPrizes[player.id] ??= [];
              gameState.playerSpinPrizes[player.id]!.add(prize);
            }
          } else {
            // Store for later if no properties available
            gameState.playerSpinPrizes[player.id] ??= [];
            gameState.playerSpinPrizes[player.id]!.add(prize);
          }
        } else {
          // AI: automatically upgrade first available property
          final ownedProperties =
              gameState.tiles
                  .whereType<PropertyTileData>()
                  .where((p) => p.ownerId == player.id && p.canUpgrade)
                  .toList();
          if (ownedProperties.isNotEmpty) {
            ownedProperties.first.upgradeLevel++;
          }
        }
        break;

      case SpinPrizeType.doubleRent:
        gameState.playerDoubleRent[player.id] = true;
        break;

      case SpinPrizeType.shield:
        gameState.playerShields[player.id] = true;
        break;

      case SpinPrizeType.teleport:
        // Show teleport dialog for human players
        if (!player.isAI && mounted) {
          bool teleportUsed = false;
          await showTeleportDialog(
            context: context,
            tiles: gameState.tiles,
            currentPosition: player.position,
            onTileSelected: (tileIndex) {
              teleportUsed = true;
              player.position = tileIndex;
              setState(() {});
            },
          );
          // If player chose "Save for Later", store the prize
          if (!teleportUsed) {
            gameState.playerSpinPrizes[player.id] ??= [];
            gameState.playerSpinPrizes[player.id]!.add(prize);
          }
        } else {
          // AI: teleport to a random unowned property if available
          final unownedProperties =
              gameState.tiles
                  .whereType<PropertyTileData>()
                  .where((p) => p.ownerId == null)
                  .toList();
          if (unownedProperties.isNotEmpty) {
            final randomProperty =
                unownedProperties[_random.nextInt(unownedProperties.length)];
            player.position = randomProperty.index;
          }
        }
        break;
    }
  }

  // ==========================================================================
  // Phase 3: Mini-Game Handler (on Chance/Community Chest)
  // ==========================================================================
  Future<void> _handleMiniGame(Player player) async {
    // AI doesn't play mini-games, just gets standard card effect
    if (player.isAI) {
      // Give AI a random power-up card instead
      awardPowerUpCard(player, gameState);
      setState(() {});
      return;
    }

    // 50% chance for mini-game, 50% chance for standard card
    final playMiniGame = _random.nextBool();

    if (!playMiniGame || !mounted) {
      // Standard card draw
      await _handleDrawCard(player, gameState.tiles[player.position]);
      return;
    }

    // Choose random mini-game
    final isMemorayMatch = _random.nextBool();
    int earnedScore = 0;

    if (isMemorayMatch) {
      // Memory Match Game
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => MemoryMatchGame(
                onComplete: () => Navigator.pop(context),
                onScoreEarned: (score) {
                  earnedScore = score;
                },
              ),
        ),
      );
    } else {
      // Quick Tap Game
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => QuickTapGame(
                onComplete: () => Navigator.pop(context),
                onScoreEarned: (score) {
                  earnedScore = score;
                },
              ),
        ),
      );
    }

    // Award prize based on score
    if (earnedScore > 0) {
      player.cash += earnedScore;
      awardPowerUpCard(player, gameState, guaranteeRare: earnedScore >= 100);
      setState(() {});
    }
  }

  // ==========================================================================
  // Phase 3: Event Trigger Check
  // ==========================================================================
  void _checkEventTrigger() {
    gameState.turnsSinceLastEvent++;

    // 10% chance each round, guaranteed every 10 rounds
    final shouldTrigger =
        EventCards.shouldTriggerEvent(_totalRounds) ||
        gameState.turnsSinceLastEvent >= 10;

    if (shouldTrigger) {
      gameState.turnsSinceLastEvent = 0;
      final event = EventCards.getRandomEvent();

      // Apply event effect
      applyEventEffect(event, gameState);

      // Show event dialog for human players
      if (!gameState.currentPlayer.isAI && mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            showEventDialog(context: context, event: event, onDismiss: () {});
          }
        });
      }

      setState(() {});
    }
  }

  // ==========================================================================
  // Phase 3: Power-Up Card Usage
  // ==========================================================================
  void _usePowerUpCard(PowerUpCard card) {
    final player = gameState.currentPlayer;
    applyPowerUpCard(player, card, gameState);
    setState(() {});
    unawaited(_sync3DBoard());
  }

  // ==========================================================================
  // Phase 3: Show Power-Up Hand (for human players)
  // ==========================================================================
  void _showPowerUpHand() {
    final player = gameState.currentPlayer;
    final cards = gameState.getPowerUps(player.id);

    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noPowerUpCards),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: 280,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    AppLocalizations.of(context)!.yourPowerUpCards,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: PowerUpHand(
                    cards: cards,
                    onCardTap: (card) {
                      Navigator.pop(context);
                      _usePowerUpCard(card);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Card definitions with text and effects - Fun kid-friendly wording!
  static const List<Map<String, String>> _chanceCards = [
    {'text': '🎲', 'effect': '+\$25', 'action': 'collect25'},
    {'text': '🎲', 'effect': '+\$50', 'action': 'collect50'},
    {'text': '🎲', 'effect': '+\$100', 'action': 'collect100'},
    {'text': '🎲', 'effect': '+\$150', 'action': 'collect150'},
    {'text': '🎲', 'effect': '+\$200', 'action': 'collect200'},
    {'text': '🎲', 'effect': '-\$15', 'action': 'pay15'},
    {'text': '🎲', 'effect': '-\$50', 'action': 'pay50'},
    {'text': '🎲', 'effect': 'GO', 'action': 'advanceGo'},
    {'text': '🎲', 'effect': '-3', 'action': 'back3'},
    {'text': '🎲', 'effect': '+\$75', 'action': 'collect75'},
    {'text': '🎲', 'effect': '-\$25', 'action': 'pay25'},
    {'text': '🎲', 'effect': '+5', 'action': 'forward5'},
    {'text': '🎲', 'effect': '-5', 'action': 'back5'},
    {'text': '🎲', 'effect': '🚂', 'action': 'nearestRailroad'},
    {'text': '🎲', 'effect': '💡', 'action': 'nearestUtility'},
    {'text': '🎲', 'effect': '🔒', 'action': 'goToJail'},
    {'text': '🎲', 'effect': '+\$20 each', 'action': 'collect20FromEach'},
    {'text': '🎲', 'effect': '-\$25/house', 'action': 'repairs25'},
    {'text': '🎲', 'effect': '🏠 FREE', 'action': 'freeUpgrade'},
  ];

  static const List<Map<String, String>> _chestCards = [
    {'text': '📦', 'effect': '+\$25', 'action': 'collect25'},
    {'text': '📦', 'effect': '+\$50', 'action': 'collect50'},
    {'text': '📦', 'effect': '+\$100', 'action': 'collect100'},
    {'text': '📦', 'effect': '+\$150', 'action': 'collect150'},
    {'text': '📦', 'effect': '+\$200', 'action': 'collect200'},
    {'text': '📦', 'effect': '-\$15', 'action': 'pay15'},
    {'text': '📦', 'effect': '-\$50', 'action': 'pay50'},
    {'text': '📦', 'effect': '+\$75', 'action': 'collect75'},
    {'text': '📦', 'effect': '-\$25', 'action': 'pay25'},
    {'text': '📦', 'effect': 'GO', 'action': 'advanceGo'},
    {'text': '📦', 'effect': '+3', 'action': 'forward3'},
    {'text': '📦', 'effect': '-5', 'action': 'back5'},
    {'text': '📦', 'effect': '+\$20 each', 'action': 'collect20FromEach'},
    {'text': '📦', 'effect': '-\$20 each', 'action': 'pay20Each'},
    {'text': '📦', 'effect': '+\$25/deed', 'action': 'propertyBonus25'},
    {'text': '📦', 'effect': '-\$25/house', 'action': 'repairs25'},
    {'text': '📦', 'effect': '🏠 FREE', 'action': 'freeUpgrade'},
  ];

  /// Apply card effect. Returns the new tile index if the player moved, null otherwise.
  int? _applyCardEffect(Player player, String action) {
    late CardEffectResult result;
    setState(() {
      result = CardEffectEngine(gameState).apply(player, action);
    });
    if (result.bankruptcy) AudioService.instance.onDefeat();
    if (result.passedGo) AudioService.instance.onPassGo();
    if (action == 'goToJail') AudioService.instance.onJail();
    unawaited(_sync3DBoard());
    return result.resolveLanding ? result.landingPosition : null;
  }

  void _onCardDeckTap(bool isChance) {
    if (!_waitingForCardPick) return;
    if (isChance != _isChanceCard) return; // Wrong deck tapped
    if (_cardPickPlayer == null) return;

    final localizedCards =
        isChance ? _localizedChanceCards : _localizedChestCards;
    final fallbackCards = isChance ? _chanceCards : _chestCards;
    final cards = localizedCards.isNotEmpty ? localizedCards : fallbackCards;

    // Shuffle and pick 5 random cards for the player to choose from
    final shuffledCards = List<Map<String, dynamic>>.from(cards)
      ..shuffle(_random);
    final pickableCards =
        shuffledCards
            .take(5)
            .map(
              (c) => PickableCard(
                text: c['text'] as String,
                effect: c['effect'] as String,
                action: c['action'] as String,
              ),
            )
            .toList();

    AudioService.instance.onDrawCard();
    showCardPickDialog(
      context: context,
      isChance: isChance,
      cards: pickableCards,
      onCardPicked: (pickedCard) {
        AudioService.instance.onFlipCard();
        final newPosition = _applyCardEffect(
          _cardPickPlayer!,
          pickedCard.action,
        );

        // Reset card picking state
        setState(() {
          _waitingForCardPick = false;
          _isChanceCard = false;
          _cardPickPlayer = null;
        });

        // Complete the future to continue game flow (pass new position if moved)
        _cardPickCompleter?.complete(newPosition);
        _cardPickCompleter = null;
      },
    );
  }

  Future<void> _handleDrawCard(Player player, TileData tile) async {
    final isChance = tile.type == TileType.chance;

    final localizedCards =
        isChance ? _localizedChanceCards : _localizedChestCards;
    final fallbackCards = isChance ? _chanceCards : _chestCards;
    final cards = localizedCards.isNotEmpty ? localizedCards : fallbackCards;

    // AI automatically handles card effect with notification
    if (player.isAI) {
      AudioService.instance.onDrawCard();
      final card = cards[_random.nextInt(cards.length)];
      AudioService.instance.onFlipCard();
      await _showAIActionNotification(
        player.name,
        '${card['text']}\n${card['effect']}',
        isChance ? Icons.help_outline : Icons.inventory_2,
        isChance ? Colors.orange : Colors.blue,
      );
      final newPosition = _applyCardEffect(player, card['action'] as String);
      // If card moved the player, resolve the new tile (skip end turn since outer caller handles it)
      if (newPosition != null) {
        await _resolveTileLanding(player, newPosition, skipEndTurn: true);
      }
      return;
    }

    // Human player - highlight the deck and wait for them to tap it
    _cardPickCompleter = Completer<int?>();
    setState(() {
      _waitingForCardPick = true;
      _isChanceCard = isChance;
      _cardPickPlayer = player;
    });

    // Wait for the card to be picked
    final newPosition = await _cardPickCompleter!.future;
    // If card moved the player, resolve the new tile (skip end turn since outer caller handles it)
    if (newPosition != null) {
      await _resolveTileLanding(player, newPosition, skipEndTurn: true);
    }
  }

  bool _checkWinCondition() {
    if (gameState.status == GameStatus.finished) return true;

    final winnerId = gameState.checkWinCondition();
    if (winnerId == null) return false;

    final winner = gameState.players.firstWhere(
      (p) => p.id == winnerId,
      orElse: () => gameState.currentPlayer,
    );

    setState(() {
      gameState = gameState.copyWith(
        status: GameStatus.finished,
        winnerId: winnerId,
      );
    });
    _showGameOverDialog(winner);
    return true;
  }

  /// Check for mid-game achievements (like Cash King)
  void _checkMidGameAchievements(Player player) async {
    // Skip AI players
    if (player.isAI) return;

    final stats = StatsService.instance.getOrCreateStats(
      player.name,
      avatarId: player.avatar?.id,
    );

    // Check for Cash King (have $5000+ at once)
    if (player.cash >= 5000 && stats.highestCash < player.cash) {
      stats.highestCash = player.cash;

      // Check if this unlocks any achievements
      final achievements = Achievements.checkNewAchievements(stats);

      // Show notifications for newly unlocked achievements
      if (achievements.isNotEmpty && mounted) {
        for (final achievement in achievements) {
          if (!mounted) break;
          AchievementNotificationManager.show(context, achievement);
          await Future.delayed(const Duration(milliseconds: 3500));
        }
      }
    }
  }

  void _showGameOverDialog(Player winner) async {
    // Record stats and check for achievements
    final achievements = await StatsService.instance.recordGameResult(
      players: gameState.players,
      winner: winner,
      gameState: gameState,
      totalRounds: _totalRounds,
    );

    // Show achievement notifications
    if (achievements.isNotEmpty && mounted) {
      for (final achievement in achievements) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          AchievementNotificationManager.show(context, achievement);
        }
        // Wait for notification to be visible before showing next
        await Future.delayed(const Duration(milliseconds: 3500));
      }
    }

    // Phase 3: Use Victory Screen instead of simple dialog
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => VictoryScreen(
                winner: winner,
                allPlayers: gameState.players,
                gameTurns: _totalRounds,
                onPlayAgain: widget.onRestart,
                onGoHome: widget.onQuit,
              ),
        ),
      );
    }
  }

  void _endTurn() {
    // Phase 3: Check for extra turn
    if (gameState.hasExtraTurn) {
      setState(() {
        _isProcessingTurn = false; // Unlock for next roll
        gameState = gameState.copyWith(
          hasExtraTurn: false,
          highlightedTileIndex: null,
          logicPhase: TurnLogicPhase.preRoll,
        );
      });

      // Continue with same player
      if (gameState.currentPlayer.isAI) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted &&
              !_isPaused &&
              gameState.canRoll &&
              !_isProcessingTurn) {
            _rollDice();
          }
        });
      }
      _sync3DBoard();
      _updateMusicIntensity();
      return;
    }

    setState(() {
      // Find next active player
      int nextIndex = gameState.currentPlayerIndex;
      bool crossedRound = false;
      do {
        nextIndex = (nextIndex + 1) % gameState.players.length;
        if (nextIndex == 0) {
          _totalRounds++;
          crossedRound = true;
          // Tick active events at round end
          gameState.tickActiveEvents();
        }
      } while (gameState.players[nextIndex].status != PlayerStatus.active);

      // Tick active power-ups
      gameState.tickActivePowerUps();

      _isProcessingTurn = false; // Unlock for next player's turn
      gameState = gameState.copyWith(
        currentPlayerIndex: nextIndex,
        highlightedTileIndex: null,
        logicPhase: TurnLogicPhase.preRoll,
      );

      // Phase 3: Check for random event trigger at new round
      if (crossedRound) {
        _checkEventTrigger();
      }
    });
    _sync3DBoard();
    _updateMusicIntensity();

    // Check if next player is in jail
    final nextPlayer = gameState.currentPlayer;
    if (nextPlayer.jailTurnsRemaining > 0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isPaused) {
          _handleJailTurn(nextPlayer);
        }
      });
      return;
    }

    // If next player is AI, auto-roll after a delay
    if (gameState.currentPlayer.isAI) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && !_isPaused && gameState.canRoll && !_isProcessingTurn) {
          _rollDice();
        }
      });
    }
  }

  void _updateMusicIntensity() {
    final activePlayers = gameState.activePlayers;
    final isTense =
        activePlayers.any((player) => player.cash <= 300) ||
        (gameState.players.length > 2 && activePlayers.length <= 2) ||
        _totalRounds >= 12;
    final intensity =
        isTense
            ? MusicIntensity.tense
            : _totalRounds <= 2
            ? MusicIntensity.relaxed
            : MusicIntensity.standard;
    unawaited(AudioService.instance.setMusicIntensity(intensity));
  }

  Future<void> _handleJailTurn(Player player) async {
    // AI automatically decides
    if (player.isAI) {
      await Future.delayed(const Duration(milliseconds: 800));

      // AI pays fine if they can afford it, otherwise stays
      if (player.cash >= GameConstants.jailBailAmount) {
        engine.payJailBail(player);
        setState(() {});
        // Now AI can roll
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !_isPaused && gameState.canRoll) {
            _rollDice();
          }
        });
      } else {
        // AI stays in jail
        setState(() {
          player.jailTurnsRemaining--;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _endTurn();
          }
        });
      }
      return;
    }

    // Human player gets dialog
    await showJailDialog(
      context: context,
      playerCash: player.cash,
      turnsRemaining: player.jailTurnsRemaining,
      onPayFine: () {
        // Pay fine and allow normal turn
        if (engine.payJailBail(player)) {
          setState(() {});
        }
      },
      onStay: () {
        // Stay in jail, decrement turns and end turn
        setState(() {
          player.jailTurnsRemaining--;
        });
        // End turn immediately
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _endTurn();
          }
        });
      },
    );
  }

  // ==========================================================================
  // Phase 4: Action Button Widget Builder
  // ==========================================================================
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.9),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Phase 4: Trade Dialog
  // ==========================================================================
  void _showTradeDialog() {
    final currentPlayer = gameState.currentPlayer;
    final otherPlayers =
        gameState.players
            .where(
              (p) =>
                  p.id != currentPlayer.id && p.status == PlayerStatus.active,
            )
            .toList();

    if (otherPlayers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noOtherPlayers),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    showTradeDialog(
      context: context,
      currentPlayer: currentPlayer,
      otherPlayers: otherPlayers,
      tiles: gameState.tiles,
      onTradeProposed: _handleTradeProposal,
    );
  }

  Future<void> _handleTradeProposal(TradeOffer offer) async {
    final recipient = offer.recipient;

    // AI evaluates trade
    if (recipient.isAI) {
      await Future.delayed(const Duration(milliseconds: 500));

      final aiEngine = _aiEngines[recipient.id];
      final shouldAccept =
          aiEngine?.shouldAcceptTrade(offer, recipient, gameState) ??
          AITradeStrategy.shouldAcceptTrade(offer, recipient);

      if (shouldAccept) {
        await _showAIActionNotification(
          recipient.name,
          AppLocalizations.of(context)!.tradeAccepted,
          Icons.handshake,
          Colors.green,
        );
        offer.execute();
        setState(() {});
        await _sync3DBoard();
      } else {
        await _showAIActionNotification(
          recipient.name,
          AppLocalizations.of(context)!.tradeRejected,
          Icons.cancel,
          Colors.red,
        );
      }
      return;
    }

    // Human recipient sees trade response dialog
    if (!mounted) return;
    await showTradeResponseDialog(
      context: context,
      offer: offer,
      onAccept: () {
        offer.execute();
        setState(() {});
        unawaited(_sync3DBoard());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.tradeCompleted),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onReject: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.tradeRejectedShort),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // Phase 4: Mortgage Dialog
  // ==========================================================================
  void _showMortgageDialog() {
    final currentPlayer = gameState.currentPlayer;

    showPropertyManagementDialog(
      context: context,
      player: currentPlayer,
      tiles: gameState.tiles,
      onMortgage: (tile) {
        if (engine.mortgageProperty(currentPlayer, tile)) {
          setState(() {});
          _sync3DBoard();
        }
      },
      onUnmortgage: (tile) {
        if (engine.unmortgageProperty(currentPlayer, tile)) {
          setState(() {});
          _sync3DBoard();
        }
      },
    );
  }
}
