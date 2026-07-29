import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../models/tile.dart';
import '../../models/board_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../config/board_configs/classic_board.dart';
import 'tile_widget.dart';
import '../player/player_token.dart';
import '../dice/dice_widget.dart';

/// Main game board widget
class GameBoard extends StatelessWidget {
  final List<Player> players;
  final int currentPlayerIndex;
  final int? highlightedTile;
  final Animation<double> bounceAnimation;
  final AnimationController glowController;
  final Widget? centerControls;
  final List<TileData>? tiles;
  final BoardTheme? boardTheme;
  final VoidCallback? onMenuTap;
  final VoidCallback? onTradeTap;
  final VoidCallback? onBankTap;
  final void Function(TileData)? onTileTap;
  final bool isChanceHighlighted;
  final bool isChestHighlighted;
  final VoidCallback? onChanceTap;
  final VoidCallback? onChestTap;
  final bool showActionButtons;
  final VoidCallback? onMusicToggle;
  final bool isMusicPlaying;

  const GameBoard({
    super.key,
    required this.players,
    required this.currentPlayerIndex,
    required this.highlightedTile,
    required this.bounceAnimation,
    required this.glowController,
    this.centerControls,
    this.tiles,
    this.boardTheme,
    this.onMenuTap,
    this.onTradeTap,
    this.onBankTap,
    this.onTileTap,
    this.isChanceHighlighted = false,
    this.isChestHighlighted = false,
    this.onChanceTap,
    this.onChestTap,
    this.showActionButtons = false,
    this.onMusicToggle,
    this.isMusicPlaying = true,
  });

  @override
  Widget build(BuildContext context) {
    final boardTiles = tiles ?? ClassicBoard.generateTiles();

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth;
        final cornerSize = boardSize * 0.12;
        final tileWidth = (boardSize - cornerSize * 2) / 9;
        final tileHeight = cornerSize;

        return Container(
          width: boardSize,
          height: boardSize,
          decoration: BoxDecoration(
            color: boardTheme?.boardColor ?? const Color(0xFFCCE5CC),
            border: Border.all(
              color: boardTheme?.tileBorder ?? Colors.black,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(5, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Center area
              _CenterArea(
                boardSize: boardSize,
                cornerSize: cornerSize,
                centerControls: centerControls,
                onMenuTap: onMenuTap,
                onTradeTap: onTradeTap,
                onBankTap: onBankTap,
                showActionButtons: showActionButtons,
                isChanceHighlighted: isChanceHighlighted,
                isChestHighlighted: isChestHighlighted,
                onChanceTap: onChanceTap,
                onChestTap: onChestTap,
                boardTheme: boardTheme,
                onMusicToggle: onMusicToggle,
                isMusicPlaying: isMusicPlaying,
              ),
              // All tiles
              ..._buildAllTiles(
                boardTiles,
                boardSize,
                cornerSize,
                tileWidth,
                tileHeight,
              ),
              // All player tokens
              ..._buildAllPlayerTokens(
                boardSize,
                cornerSize,
                tileWidth,
                tileHeight,
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildAllTiles(
    List<TileData> tileData,
    double boardSize,
    double cornerSize,
    double tileWidth,
    double tileHeight,
  ) {
    return tileData.map((data) {
      final position = _calculateTilePosition(
        data.index,
        boardSize,
        cornerSize,
        tileWidth,
        tileHeight,
      );

      // Find owner color if property is owned
      Color? ownerColor;
      if (data is PropertyTileData && data.ownerId != null) {
        final owner = players.where((p) => p.id == data.ownerId).firstOrNull;
        ownerColor = owner?.color;
      } else if (data is RailroadTileData && data.ownerId != null) {
        final owner = players.where((p) => p.id == data.ownerId).firstOrNull;
        ownerColor = owner?.color;
      } else if (data is UtilityTileData && data.ownerId != null) {
        final owner = players.where((p) => p.id == data.ownerId).firstOrNull;
        ownerColor = owner?.color;
      }

      return PositionedTileWidget(
        data: data,
        position: position,
        isHighlighted: highlightedTile == data.index,
        glowController: glowController,
        ownerColor: ownerColor,
        onTap: onTileTap,
      );
    }).toList();
  }

  TilePosition _calculateTilePosition(
    int index,
    double boardSize,
    double cornerSize,
    double tileWidth,
    double tileHeight,
  ) {
    double left, top, width, height;
    int rotation = 0;

    if (index == 0) {
      // GO corner (bottom-right)
      left = boardSize - cornerSize;
      top = boardSize - cornerSize;
      width = cornerSize;
      height = cornerSize;
    } else if (index < 10) {
      // Bottom row (right to left)
      left = boardSize - cornerSize - (index * tileWidth);
      top = boardSize - tileHeight;
      width = tileWidth;
      height = tileHeight;
    } else if (index == 10) {
      // Jail corner (bottom-left)
      left = 0;
      top = boardSize - cornerSize;
      width = cornerSize;
      height = cornerSize;
    } else if (index < 20) {
      // Left column (bottom to top)
      left = 0;
      top = boardSize - cornerSize - ((index - 10) * tileWidth);
      width = tileHeight;
      height = tileWidth;
      rotation = 1;
    } else if (index == 20) {
      // Free Parking corner (top-left)
      left = 0;
      top = 0;
      width = cornerSize;
      height = cornerSize;
    } else if (index < 30) {
      // Top row (left to right)
      left = cornerSize + ((index - 21) * tileWidth);
      top = 0;
      width = tileWidth;
      height = tileHeight;
      rotation = 2;
    } else if (index == 30) {
      // Go To Jail corner (top-right)
      left = boardSize - cornerSize;
      top = 0;
      width = cornerSize;
      height = cornerSize;
    } else {
      // Right column (top to bottom)
      left = boardSize - tileHeight;
      top = cornerSize + ((index - 31) * tileWidth);
      width = tileHeight;
      height = tileWidth;
      rotation = 3;
    }

    return TilePosition(
      index: index,
      left: left,
      top: top,
      width: width,
      height: height,
      rotation: rotation,
    );
  }

  List<Widget> _buildAllPlayerTokens(
    double boardSize,
    double cornerSize,
    double tileWidth,
    double tileHeight,
  ) {
    final calculator = TokenPositionCalculator(
      boardSize: boardSize,
      cornerSize: cornerSize,
      tileWidth: tileWidth,
      tileHeight: tileHeight,
    );

    final tokenSize = tileWidth * 0.35;

    // Filter out bankrupt players - they shouldn't show on the board
    final activePlayers =
        players.where((p) => p.status == PlayerStatus.active).toList();

    return players
        .asMap()
        .entries
        .where((entry) => entry.value.status == PlayerStatus.active)
        .map((entry) {
          final index = entry.key;
          final player = entry.value;
          final isCurrentPlayer = index == currentPlayerIndex;

          // Get position with stacking offset (use activePlayers for stacking calculation)
          final pos = calculator.getPlayerPosition(
            player,
            activePlayers,
            activePlayers.indexOf(player),
          );

          return AnimatedPlayerToken(
            player: player,
            position: pos,
            size: tokenSize,
            isCurrentPlayer: isCurrentPlayer,
            bounceAnimation: bounceAnimation,
          );
        })
        .toList();
  }
}

/// Center area of the board
class _CenterArea extends StatelessWidget {
  final double boardSize;
  final double cornerSize;
  final Widget? centerControls;
  final BoardTheme? boardTheme;
  final VoidCallback? onMenuTap;
  final VoidCallback? onTradeTap;
  final VoidCallback? onBankTap;
  final bool showActionButtons;
  final bool isChanceHighlighted;
  final bool isChestHighlighted;
  final VoidCallback? onChanceTap;
  final VoidCallback? onChestTap;
  final VoidCallback? onMusicToggle;
  final bool isMusicPlaying;

  const _CenterArea({
    required this.boardSize,
    required this.cornerSize,
    this.centerControls,
    this.boardTheme,
    this.onMenuTap,
    this.onTradeTap,
    this.onBankTap,
    this.showActionButtons = false,
    this.isChanceHighlighted = false,
    this.isChestHighlighted = false,
    this.onChanceTap,
    this.onChestTap,
    this.onMusicToggle,
    this.isMusicPlaying = true,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: cornerSize,
      top: cornerSize,
      right: cornerSize,
      bottom: cornerSize,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: boardTheme?.centerBackground ?? const Color(0xFFCCE5CC),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Logo at top (with more spacing from tiles)
                Center(child: _buildVegasLogo(context)),
                const Spacer(),
                // Controls (dice only, no button)
                if (centerControls != null) Center(child: centerControls!),
                const Spacer(),
                // Card decks at bottom - centered and moved up
                Center(
                  child: Transform.translate(
                    offset: const Offset(0, -30), // Move up 30px
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CardDeck(
                          label:
                              AppLocalizations.of(
                                context,
                              )!.chanceCard.toUpperCase(),
                          color: Colors.orange,
                          icon: Icons.help_outline,
                          isHighlighted: isChanceHighlighted,
                          onTap: onChanceTap,
                        ),
                        const SizedBox(
                          width: 16,
                        ), // Reduced gap for better centering
                        CardDeck(
                          label:
                              AppLocalizations.of(
                                context,
                              )!.communityChestCard.toUpperCase(),
                          color: Colors.blue,
                          icon: Icons.inventory_2,
                          isHighlighted: isChestHighlighted,
                          onTap: onChestTap,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          // Menu and Music buttons inside board (top-right of center area)
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Music toggle button
                if (onMusicToggle != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: onMusicToggle,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors:
                                  isMusicPlaying
                                      ? [
                                        Colors.green.shade600,
                                        Colors.green.shade800,
                                      ]
                                      : [
                                        Colors.grey.shade700,
                                        Colors.grey.shade800,
                                      ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white24, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isMusicPlaying ? Icons.music_note : Icons.music_off,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Settings/Menu button
                if (onMenuTap != null)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onMenuTap,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.grey.shade700,
                              Colors.grey.shade800,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Trade and Bank buttons (top-left of center area)
          if (showActionButtons)
            Positioned(
              top: 8,
              left: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onTradeTap != null)
                    _ActionButton(
                      icon: Icons.swap_horiz,
                      label: AppLocalizations.of(context)!.proposeTradeBtn,
                      color: Colors.teal,
                      onTap: onTradeTap!,
                    ),
                  if (onTradeTap != null && onBankTap != null)
                    const SizedBox(width: 6),
                  if (onBankTap != null)
                    _ActionButton(
                      icon: Icons.account_balance,
                      label: AppLocalizations.of(context)!.bankFeatures,
                      color: Colors.deepPurple,
                      onTap: onBankTap!,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Vegas-style welcome sign shaped logo
  Widget _buildVegasLogo(BuildContext context) {
    return CustomPaint(
      painter: _VegasSignPainter(),
      child: Container(
        width: 320,
        height: 110,
        padding: const EdgeInsets.only(
          top: 10,
          left: 20,
          right: 20,
          bottom: 14,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // "M&M" at top
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOutlinedText(
                    'M',
                    Colors.red.shade400,
                    28,
                    strokeWidth: 3,
                  ),
                  _buildOutlinedText('&', Colors.amber, 20, strokeWidth: 2),
                  _buildOutlinedText(
                    'M',
                    Colors.green.shade400,
                    28,
                    strokeWidth: 3,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              // "PROPERTY TYCOON" on one line
              Stack(
                children: [
                  Text(
                    AppLocalizations.of(context)!.propertyTycoon,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      foreground:
                          Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3
                            ..color = Colors.white,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback:
                        (bounds) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Colors.amber],
                        ).createShader(bounds),
                    child: Text(
                      AppLocalizations.of(context)!.propertyTycoon,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Light bulbs row
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(17, (i) {
                  final colors = [
                    Colors.red,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                    Colors.orange,
                  ];
                  final color = colors[i % colors.length];
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: color, blurRadius: 4, spreadRadius: 1),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedText(
    String text,
    Color fillColor,
    double fontSize, {
    double strokeWidth = 2,
  }) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            foreground:
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = strokeWidth
                  ..color = Colors.white,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: fillColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _VegasSignPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final path = Path();
    const topRadius = 14.0;
    const bottomPointHeight = 12.0;

    path.moveTo(topRadius, 0);
    path.lineTo(width - topRadius, 0);
    path.arcToPoint(
      Offset(width, topRadius),
      radius: const Radius.circular(topRadius),
    );
    path.lineTo(width, height - bottomPointHeight);
    path.lineTo(width / 2, height);
    path.lineTo(0, height - bottomPointHeight);
    path.lineTo(0, topRadius);
    path.arcToPoint(
      Offset(topRadius, 0),
      radius: const Radius.circular(topRadius),
    );
    path.close();

    canvas.save();
    canvas.translate(3, 3);
    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.35)
          ..style = PaintingStyle.fill;
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    final bgPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade500,
              Colors.red.shade700,
              Colors.red.shade900,
            ],
          ).createShader(Rect.fromLTWH(0, 0, width, height))
          ..style = PaintingStyle.fill;
    canvas.drawPath(path, bgPaint);

    final borderPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.shade400,
              Colors.amber.shade700,
              Colors.amber.shade500,
            ],
          ).createShader(Rect.fromLTWH(0, 0, width, height))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
    canvas.drawPath(path, borderPaint);

    final innerPath = Path();
    const inset = 6.0;
    const innerTopRadius = 10.0;

    innerPath.moveTo(inset + innerTopRadius, inset);
    innerPath.lineTo(width - inset - innerTopRadius, inset);
    innerPath.arcToPoint(
      Offset(width - inset, inset + innerTopRadius),
      radius: const Radius.circular(innerTopRadius),
    );
    innerPath.lineTo(width - inset, height - bottomPointHeight - 3);
    innerPath.lineTo(width / 2, height - inset);
    innerPath.lineTo(inset, height - bottomPointHeight - 3);
    innerPath.lineTo(inset, inset + innerTopRadius);
    innerPath.arcToPoint(
      Offset(inset + innerTopRadius, inset),
      radius: const Radius.circular(innerTopRadius),
    );
    innerPath.close();

    final innerBorderPaint =
        Paint()
          ..color = Colors.amber.shade200.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
    canvas.drawPath(innerPath, innerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Action button for Trade/Bank inside the board
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, Color.lerp(color, Colors.black, 0.2)!],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
