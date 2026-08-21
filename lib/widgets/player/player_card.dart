import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../models/tile.dart';
import '../../models/game_state.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../effects/floating_cash_indicator.dart';
import '../avatar/avatar_widget.dart';
import '../dialogs/property_portfolio_dialog.dart';

/// Full player card for landscape mode
class PlayerCard extends StatefulWidget {
  final Player player;
  final bool isCurrentPlayer;
  final List<TileData>? tiles;
  final GameState? gameState;
  final bool portfolioEnabled;

  const PlayerCard({
    super.key,
    required this.player,
    required this.isCurrentPlayer,
    this.tiles,
    this.gameState,
    this.portfolioEnabled = true,
  });

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    if (widget.isCurrentPlayer) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrentPlayer && !oldWidget.isCurrentPlayer) {
      _glowController.repeat(reverse: true);
    } else if (!widget.isCurrentPlayer && oldWidget.isCurrentPlayer) {
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Player get player => widget.player;
  bool get isCurrentPlayer => widget.isCurrentPlayer;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowIntensity = isCurrentPlayer
            ? 0.4 + _glowAnimation.value * 0.4
            : 0.0;
        final borderWidth = isCurrentPlayer
            ? 3.0 + _glowAnimation.value * 2
            : 1.0;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap:
              widget.portfolioEnabled &&
                  widget.tiles != null &&
                  widget.gameState != null
              ? () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!context.mounted) return;
                    showPropertyPortfolioDialog(
                      context: context,
                      player: player,
                      tiles: widget.tiles!,
                      gameState: widget.gameState!,
                    );
                  });
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isCurrentPlayer
                    ? [
                        player.color.withValues(alpha: 0.5),
                        player.color.withValues(alpha: 0.3),
                      ]
                    : [
                        Colors.grey.shade800.withValues(alpha: 0.8),
                        Colors.grey.shade900.withValues(alpha: 0.8),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrentPlayer ? Colors.amber : Colors.grey.shade700,
                width: borderWidth,
              ),
              boxShadow: isCurrentPlayer
                  ? [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: glowIntensity),
                        blurRadius: 15 + _glowAnimation.value * 10,
                        spreadRadius: 2 + _glowAnimation.value * 4,
                      ),
                      BoxShadow(
                        color: player.color.withValues(
                          alpha: glowIntensity * 0.5,
                        ),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ]
                  : [],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  _buildCashDisplay(),
                  // AI indicator under cash
                  if (player.isAI) ...[
                    const SizedBox(height: 6),
                    const _AIBadge(),
                  ],
                  const SizedBox(height: 8),
                  Expanded(child: _buildPropertiesSection()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Scale avatar based on available width
        final avatarSize = (constraints.maxWidth * 0.25).clamp(40.0, 70.0);
        return Row(
          children: [
            _PlayerAvatar(player: player, size: avatarSize),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          player.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Show current location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          _getTileNameForPosition(player.position),
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _getTileNameForPosition(int position) {
    final tiles = widget.tiles;
    if (tiles != null && tiles.isNotEmpty) {
      final tile = tiles.firstWhere(
        (t) => t.index == position,
        orElse: () => tiles[0],
      );
      return tile.name;
    }
    return '${AppLocalizations.of(context)!.propertyLocation} $position';
  }

  Widget _buildCashDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.cash,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          AnimatedCashDisplay(
            cash: player.cash,
            style: const TextStyle(
              color: AppTheme.cashGreen,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.properties,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: player.propertyIds.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.nothing,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: player.propertyIds
                          .map(
                            (p) => _PropertyChip(
                              propertyId: p,
                              tiles: widget.tiles,
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Compact player card for portrait mode - shows properties like landscape
class PlayerCardCompact extends StatefulWidget {
  final Player player;
  final bool isCurrentPlayer;
  final List<TileData>? tiles;
  final GameState? gameState;
  final bool portfolioEnabled;

  const PlayerCardCompact({
    super.key,
    required this.player,
    required this.isCurrentPlayer,
    this.tiles,
    this.gameState,
    this.portfolioEnabled = true,
  });

  @override
  State<PlayerCardCompact> createState() => _PlayerCardCompactState();
}

class _PlayerCardCompactState extends State<PlayerCardCompact>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    if (widget.isCurrentPlayer) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PlayerCardCompact oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrentPlayer && !oldWidget.isCurrentPlayer) {
      _glowController.repeat(reverse: true);
    } else if (!widget.isCurrentPlayer && oldWidget.isCurrentPlayer) {
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Player get player => widget.player;
  bool get isCurrentPlayer => widget.isCurrentPlayer;
  List<TileData>? get tiles => widget.tiles;

  /// Get tile name for current position
  String _getTileName() {
    if (tiles == null || tiles!.isEmpty) {
      return AppLocalizations.of(context)!.tileN(player.position);
    }
    final tile = tiles!.firstWhere(
      (t) => t.index == player.position,
      orElse: () => tiles![0],
    );
    return tile.name;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowIntensity = isCurrentPlayer
            ? 0.4 + _glowAnimation.value * 0.4
            : 0.0;
        final borderWidth = isCurrentPlayer
            ? 2.0 + _glowAnimation.value * 2
            : 1.0;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap:
              widget.portfolioEnabled &&
                  widget.tiles != null &&
                  widget.gameState != null
              ? () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!context.mounted) return;
                    showPropertyPortfolioDialog(
                      context: context,
                      player: player,
                      tiles: widget.tiles!,
                      gameState: widget.gameState!,
                    );
                  });
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isCurrentPlayer
                    ? [
                        player.color.withValues(alpha: 0.5),
                        player.color.withValues(alpha: 0.3),
                      ]
                    : [
                        Colors.grey.shade800.withValues(alpha: 0.8),
                        Colors.grey.shade900.withValues(alpha: 0.8),
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrentPlayer ? Colors.amber : Colors.grey.shade700,
                width: borderWidth,
              ),
              boxShadow: isCurrentPlayer
                  ? [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: glowIntensity),
                        blurRadius: 12 + _glowAnimation.value * 8,
                        spreadRadius: 1 + _glowAnimation.value * 3,
                      ),
                      BoxShadow(
                        color: player.color.withValues(
                          alpha: glowIntensity * 0.5,
                        ),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ]
                  : [],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final avatarSize = (constraints.maxHeight * 0.35).clamp(
                  40.0,
                  80.0,
                );
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _PlayerAvatar(player: player, size: avatarSize),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        player.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (player.isAI) ...[
                                      const SizedBox(width: 6),
                                      const _AIBadgeSmall(),
                                    ],
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 10,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(width: 2),
                                      Flexible(
                                        child: Text(
                                          _getTileName(),
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 10,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedCashDisplay(
                            cash: player.cash,
                            style: const TextStyle(
                              color: AppTheme.cashGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.home,
                                size: 14,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: player.propertyIds.isEmpty
                                    ? Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.noPropertiesAvailable,
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 10,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      )
                                    : Wrap(
                                        spacing: 3,
                                        runSpacing: 3,
                                        children: player.propertyIds
                                            .map(
                                              (p) => _PropertyChip(
                                                propertyId: p,
                                                tiles: tiles,
                                              ),
                                            )
                                            .toList(),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Player avatar widget - uses the new avatar system
class _PlayerAvatar extends StatelessWidget {
  final Player player;
  final double size;

  const _PlayerAvatar({required this.player, required this.size});

  @override
  Widget build(BuildContext context) {
    return AvatarWidget(
      avatar: player.effectiveAvatar,
      size: size,
      borderColor: player.color,
    );
  }
}

/// AI indicator badge (shown under cash amount - for landscape mode)
class _AIBadge extends StatelessWidget {
  const _AIBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.purple.shade600,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.smart_toy, color: Colors.white, size: 12),
          const SizedBox(width: 3),
          Text(
            AppLocalizations.of(context)!.ai,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small AI badge for compact cards (inline with name)
class _AIBadgeSmall extends StatelessWidget {
  const _AIBadgeSmall();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.purple.shade600,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.smart_toy, color: Colors.white, size: 10),
          const SizedBox(width: 2),
          Text(
            AppLocalizations.of(context)!.ai,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// "YOUR TURN" indicator badge with pulsing glow animation
class _TurnIndicator extends StatefulWidget {
  const _TurnIndicator();

  @override
  State<_TurnIndicator> createState() => _TurnIndicatorState();
}

class _TurnIndicatorState extends State<_TurnIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(
                    alpha: 0.3 + _glowAnimation.value * 0.5,
                  ),
                  blurRadius: 6 + _glowAnimation.value * 10,
                  spreadRadius: _glowAnimation.value * 3,
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated arrow icon
                  Transform.translate(
                    offset: Offset(_glowAnimation.value * 3 - 1.5, 0),
                    child: const Icon(
                      Icons.play_arrow,
                      size: 12,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    AppLocalizations.of(context)!.yourTurn,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
}

/// Property chip showing owned property
class _PropertyChip extends StatelessWidget {
  final String propertyId;
  final List<TileData>? tiles;

  const _PropertyChip({required this.propertyId, this.tiles});

  TileData? get tile {
    if (tiles == null) return null;
    final index = int.tryParse(propertyId);
    if (index == null || index >= tiles!.length) return null;
    return tiles![index];
  }

  Color get _color {
    final t = tile;
    if (t is PropertyTileData) return t.groupColor;
    if (t is RailroadTileData) return Colors.grey.shade800;
    if (t is UtilityTileData) return Colors.blue.shade300;

    // Fallback to index-based colors if tiles not available
    final index = int.tryParse(propertyId) ?? 0;
    const colors = [
      Color(0xFF795548),
      Color(0xFF795548),
      Color(0xFF4FC3F7),
      Color(0xFF4FC3F7),
      Color(0xFF4FC3F7),
      Color(0xFFF48FB1),
      Color(0xFFF48FB1),
      Color(0xFFF48FB1),
      Color(0xFFFF9800),
      Color(0xFFFF9800),
      Color(0xFFFF9800),
      Color(0xFFF44336),
      Color(0xFFF44336),
      Color(0xFFF44336),
      Color(0xFFFFEB3B),
      Color(0xFFFFEB3B),
      Color(0xFFFFEB3B),
      Color(0xFF4CAF50),
      Color(0xFF4CAF50),
      Color(0xFF4CAF50),
      Color(0xFF1976D2),
      Color(0xFF1976D2),
    ];
    return colors[index % colors.length];
  }

  bool get _isMortgaged {
    final t = tile;
    if (t is PropertyTileData) return t.isMortgaged;
    if (t is RailroadTileData) return t.isMortgaged;
    if (t is UtilityTileData) return t.isMortgaged;
    return false;
  }

  int get _upgradeLevel {
    final t = tile;
    if (t is PropertyTileData) return t.upgradeLevel;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 24,
          height: 16,
          decoration: BoxDecoration(
            color: _color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: _upgradeLevel > 0
              ? Center(
                  child: Text(
                    _upgradeLevel == 5 ? 'H' : '$_upgradeLevel',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(0.5, 0.5),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        ),
        if (_isMortgaged)
          Positioned.fill(
            child: CustomPaint(painter: _DiagonalStripePainter()),
          ),
      ],
    );
  }
}

/// Custom painter for mortgage indicator (diagonal stripe)
class _DiagonalStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw diagonal line from top-left to bottom-right
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vertical player panel (for landscape mode)
class VerticalPlayerPanel extends StatelessWidget {
  final Player player1;
  final Player player2;
  final int currentPlayerIndex;
  final List<TileData>? tiles;
  final GameState? gameState;

  const VerticalPlayerPanel({
    super.key,
    required this.player1,
    required this.player2,
    required this.currentPlayerIndex,
    this.tiles,
    this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: PlayerCard(
              player: player1,
              isCurrentPlayer:
                  player1.id == (currentPlayerIndex + 1).toString(),
              tiles: tiles,
              gameState: gameState,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PlayerCard(
              player: player2,
              isCurrentPlayer:
                  player2.id == (currentPlayerIndex + 1).toString(),
              tiles: tiles,
              gameState: gameState,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal player panel (for portrait mode)
class HorizontalPlayerPanel extends StatelessWidget {
  final Player player1;
  final Player player2;
  final int currentPlayerIndex;
  final List<TileData>? tiles;
  final GameState? gameState;

  const HorizontalPlayerPanel({
    super.key,
    required this.player1,
    required this.player2,
    required this.currentPlayerIndex,
    this.tiles,
    this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: PlayerCardCompact(
              player: player1,
              isCurrentPlayer:
                  player1.id == (currentPlayerIndex + 1).toString(),
              tiles: tiles,
              gameState: gameState,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: PlayerCardCompact(
              player: player2,
              isCurrentPlayer:
                  player2.id == (currentPlayerIndex + 1).toString(),
              tiles: tiles,
              gameState: gameState,
            ),
          ),
        ],
      ),
    );
  }
}
