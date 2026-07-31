import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../config/constants.dart' as constants;
import 'player_token_3d.dart';

// Re-export 3D token components for easy access
export 'player_token_3d.dart'
    show PlayerToken3D, ArcAnimatedPlayerToken3D, HoppingPlayerToken3D;

/// Widget for rendering a player token on the board - now uses 3D by default
class PlayerToken extends StatelessWidget {
  final Player player;
  final double size;
  final bool isCurrentPlayer;
  final double bounceOffset;
  final bool use3D;

  const PlayerToken({
    super.key,
    required this.player,
    required this.size,
    this.isCurrentPlayer = false,
    this.bounceOffset = 0,
    this.use3D = true, // 3D by default
  });

  @override
  Widget build(BuildContext context) {
    if (use3D) {
      return PlayerToken3D(
        player: player,
        size: size,
        isCurrentPlayer: isCurrentPlayer,
      );
    }

    // Legacy 2D token
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: player.color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: constants.LayoutConstants.tokenBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: Offset(1, 1 + bounceOffset / 4),
          ),
          if (isCurrentPlayer)
            BoxShadow(
              color: player.color.withValues(alpha: 0.6),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Center(
        child: Text(
          player.effectiveAvatar.emoji,
          style: TextStyle(fontSize: size * 0.55),
        ),
      ),
    );
  }
}

/// Animated player token with bounce effect
class AnimatedPlayerToken extends StatelessWidget {
  final Player player;
  final Offset position;
  final double size;
  final bool isCurrentPlayer;
  final Animation<double> bounceAnimation;

  const AnimatedPlayerToken({
    super.key,
    required this.player,
    required this.position,
    required this.size,
    required this.isCurrentPlayer,
    required this.bounceAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: bounceAnimation,
      builder: (context, child) {
        final bounce =
            isCurrentPlayer ? sin(bounceAnimation.value * pi) * 10 : 0.0;

        // 3D pawn is 1.5x height, offset to place base at position
        final pawnHeight = size * 1.5;
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          left: position.dx - size / 2,
          top: position.dy - pawnHeight + size * 0.35 - bounce,
          child: PlayerToken(
            player: player,
            size: size,
            isCurrentPlayer: isCurrentPlayer,
            bounceOffset: bounce,
          ),
        );
      },
    );
  }
}

/// Enhanced token with arc movement and landing bounce animation - now uses 3D by default
class ArcAnimatedPlayerToken extends StatelessWidget {
  final Player player;
  final Offset targetPosition;
  final double size;
  final bool isCurrentPlayer;
  final bool isMoving;
  final VoidCallback? onMoveComplete;
  final bool use3D;

  const ArcAnimatedPlayerToken({
    super.key,
    required this.player,
    required this.targetPosition,
    required this.size,
    required this.isCurrentPlayer,
    this.isMoving = false,
    this.onMoveComplete,
    this.use3D = true, // 3D by default
  });

  @override
  Widget build(BuildContext context) {
    if (use3D) {
      return ArcAnimatedPlayerToken3D(
        player: player,
        targetPosition: targetPosition,
        size: size,
        isCurrentPlayer: isCurrentPlayer,
        isMoving: isMoving,
        onMoveComplete: onMoveComplete,
      );
    }

    return _ArcAnimatedPlayerToken2D(
      player: player,
      targetPosition: targetPosition,
      size: size,
      isCurrentPlayer: isCurrentPlayer,
      isMoving: isMoving,
      onMoveComplete: onMoveComplete,
    );
  }
}

/// Legacy 2D arc animated token
class _ArcAnimatedPlayerToken2D extends StatefulWidget {
  final Player player;
  final Offset targetPosition;
  final double size;
  final bool isCurrentPlayer;
  final bool isMoving;
  final VoidCallback? onMoveComplete;

  const _ArcAnimatedPlayerToken2D({
    required this.player,
    required this.targetPosition,
    required this.size,
    required this.isCurrentPlayer,
    this.isMoving = false,
    this.onMoveComplete,
  });

  @override
  State<_ArcAnimatedPlayerToken2D> createState() =>
      _ArcAnimatedPlayerToken2DState();
}

class _ArcAnimatedPlayerToken2DState extends State<_ArcAnimatedPlayerToken2D>
    with TickerProviderStateMixin {
  late AnimationController _moveController;
  late AnimationController _bounceController;
  late AnimationController _idleBounceController;

  late Animation<double> _moveAnimation;
  late Animation<double> _arcAnimation;
  late Animation<double> _landingBounceAnimation;
  late Animation<double> _landingSquashAnimation;
  late Animation<double> _idleBounceAnimation;

  Offset _startPosition = Offset.zero;
  Offset _currentPosition = Offset.zero;
  bool _hasLanded = false;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.targetPosition;
    _startPosition = widget.targetPosition;

    // Movement controller for arc animation
    _moveController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Landing bounce controller
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Idle bounce for current player
    _idleBounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _setupAnimations();

    if (widget.isCurrentPlayer) {
      _idleBounceController.repeat();
    }
  }

  void _setupAnimations() {
    // Horizontal/position movement
    _moveAnimation = CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeInOut,
    );

    // Arc height (parabola)
    _arcAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_moveController);

    // Landing bounce (up then settle)
    _landingBounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: -8,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -8,
          end: 3,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 3,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
    ]).animate(_bounceController);

    // Squash on landing
    _landingSquashAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 0.9,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_bounceController);

    // Gentle idle bounce
    _idleBounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _idleBounceController, curve: Curves.easeInOut),
    );

    _moveController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _currentPosition = widget.targetPosition;
        _hasLanded = true;
        _bounceController.forward(from: 0);
      }
    });

    _bounceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _hasLanded = false;
        widget.onMoveComplete?.call();
        if (widget.isCurrentPlayer) {
          _idleBounceController.repeat();
        }
      }
    });
  }

  @override
  void didUpdateWidget(_ArcAnimatedPlayerToken2D oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle movement
    if (widget.targetPosition != _currentPosition && widget.isMoving) {
      _startPosition = _currentPosition;
      _idleBounceController.stop();
      _moveController.forward(from: 0);
    }

    // Handle current player changes
    if (widget.isCurrentPlayer != oldWidget.isCurrentPlayer) {
      if (widget.isCurrentPlayer &&
          !_moveController.isAnimating &&
          !_bounceController.isAnimating) {
        _idleBounceController.repeat();
      } else if (!widget.isCurrentPlayer) {
        _idleBounceController.stop();
        _idleBounceController.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _moveController.dispose();
    _bounceController.dispose();
    _idleBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _moveAnimation,
        _arcAnimation,
        _landingBounceAnimation,
        _landingSquashAnimation,
        _idleBounceAnimation,
      ]),
      builder: (context, child) {
        // Calculate position
        double x, y;
        double scaleX = 1.0;
        double scaleY = 1.0;

        if (_moveController.isAnimating) {
          // Arc movement
          x =
              _startPosition.dx +
              (_moveAnimation.value *
                  (widget.targetPosition.dx - _startPosition.dx));
          y =
              _startPosition.dy +
              (_moveAnimation.value *
                  (widget.targetPosition.dy - _startPosition.dy)) -
              (_arcAnimation.value * 30); // Arc height of 30 pixels
        } else if (_hasLanded && _bounceController.isAnimating) {
          // Landing bounce
          x = widget.targetPosition.dx;
          y = widget.targetPosition.dy + _landingBounceAnimation.value;
          scaleX = _landingSquashAnimation.value;
          scaleY =
              2.0 - _landingSquashAnimation.value; // Inverse for squash effect
        } else {
          // Idle position with gentle bounce
          x = widget.targetPosition.dx;
          final idleBounce =
              widget.isCurrentPlayer
                  ? sin(_idleBounceAnimation.value * pi) * 6
                  : 0.0;
          y = widget.targetPosition.dy - idleBounce;
        }

        return Positioned(
          left: x - widget.size / 2,
          top: y - widget.size / 2,
          child: Transform.scale(
            scaleX: scaleX,
            scaleY: scaleY,
            child: PlayerToken(
              player: widget.player,
              size: widget.size,
              isCurrentPlayer: widget.isCurrentPlayer,
              bounceOffset: _hasLanded ? _landingBounceAnimation.value : 0,
              use3D: false, // Use 2D for legacy animated token
            ),
          ),
        );
      },
    );
  }
}

/// Simple token that hops between positions with a small arc - now uses 3D by default
class HoppingPlayerToken extends StatelessWidget {
  final Player player;
  final Offset position;
  final double size;
  final bool isCurrentPlayer;
  final bool shouldAnimate;
  final bool use3D;

  const HoppingPlayerToken({
    super.key,
    required this.player,
    required this.position,
    required this.size,
    required this.isCurrentPlayer,
    this.shouldAnimate = true,
    this.use3D = true, // 3D by default
  });

  @override
  Widget build(BuildContext context) {
    if (use3D) {
      return HoppingPlayerToken3D(
        player: player,
        position: position,
        size: size,
        isCurrentPlayer: isCurrentPlayer,
        shouldAnimate: shouldAnimate,
      );
    }

    return _HoppingPlayerToken2D(
      player: player,
      position: position,
      size: size,
      isCurrentPlayer: isCurrentPlayer,
      shouldAnimate: shouldAnimate,
    );
  }
}

/// Legacy 2D hopping token
class _HoppingPlayerToken2D extends StatefulWidget {
  final Player player;
  final Offset position;
  final double size;
  final bool isCurrentPlayer;
  final bool shouldAnimate;

  const _HoppingPlayerToken2D({
    required this.player,
    required this.position,
    required this.size,
    required this.isCurrentPlayer,
    this.shouldAnimate = true,
  });

  @override
  State<_HoppingPlayerToken2D> createState() => _HoppingPlayerToken2DState();
}

class _HoppingPlayerToken2DState extends State<_HoppingPlayerToken2D>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _hopAnimation;
  late Animation<double> _squashAnimation;

  Offset _previousPosition = Offset.zero;
  Offset _currentPosition = Offset.zero;
  bool _isHopping = false;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.position;
    _previousPosition = widget.position;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _hopAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _squashAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.85),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 1.1),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isHopping = false;
          _previousPosition = _currentPosition;
        });
      }
    });
  }

  @override
  void didUpdateWidget(_HoppingPlayerToken2D oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.position != _currentPosition && widget.shouldAnimate) {
      _previousPosition = _currentPosition;
      _currentPosition = widget.position;
      _isHopping = true;
      _controller.forward(from: 0);
    } else if (widget.position != _currentPosition) {
      _currentPosition = widget.position;
      _previousPosition = widget.position;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double x, y;
        double scale = 1.0;

        if (_isHopping) {
          // Interpolate position
          final progress = _controller.value;
          x =
              _previousPosition.dx +
              (progress * (_currentPosition.dx - _previousPosition.dx));
          y =
              _previousPosition.dy +
              (progress * (_currentPosition.dy - _previousPosition.dy));

          // Add hop arc
          y -= _hopAnimation.value * 20;

          // Apply squash
          scale = _squashAnimation.value;
        } else {
          x = widget.position.dx;
          y = widget.position.dy;

          // Subtle idle bounce for current player
          if (widget.isCurrentPlayer) {
            final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
            y -= sin(time * 3) * 3;
          }
        }

        return Positioned(
          left: x - widget.size / 2,
          top: y - widget.size / 2,
          child: Transform.scale(
            scale: scale,
            child: PlayerToken(
              player: widget.player,
              size: widget.size,
              isCurrentPlayer: widget.isCurrentPlayer,
              use3D: false, // Use 2D for legacy animated token
            ),
          ),
        );
      },
    );
  }
}

/// Calculates token positions on the board, handling stacking
class TokenPositionCalculator {
  final double boardSize;
  final double cornerSize;
  final double tileWidth;
  final double tileHeight;

  const TokenPositionCalculator({
    required this.boardSize,
    required this.cornerSize,
    required this.tileWidth,
    required this.tileHeight,
  });

  /// Get base position for a tile
  /// Note: For property tiles, there's a 16px color band, so we offset tokens slightly
  /// to center them in the content area rather than the full tile area
  Offset getBasePosition(int tileIndex) {
    // Color band width for property tiles
    const colorBandWidth = 16.0;
    // Offset to center tokens in content area (not including color band)
    final contentOffset = colorBandWidth / 2;

    if (tileIndex == 0) {
      // GO corner (bottom-right)
      return Offset(boardSize - cornerSize / 2, boardSize - cornerSize / 2);
    } else if (tileIndex < 10) {
      // Bottom row (right to left) - color band at top, center in lower content area
      return Offset(
        boardSize - cornerSize - (tileIndex * tileWidth) + tileWidth / 2,
        boardSize - tileHeight / 2 + contentOffset,
      );
    } else if (tileIndex == 10) {
      // Jail corner (bottom-left)
      return Offset(cornerSize / 2, boardSize - cornerSize / 2);
    } else if (tileIndex < 20) {
      // Left column (bottom to top) - color band on right, center in left content area
      return Offset(
        tileHeight / 2 - contentOffset,
        boardSize - cornerSize - ((tileIndex - 10) * tileWidth) + tileWidth / 2,
      );
    } else if (tileIndex == 20) {
      // Free Parking corner (top-left)
      return Offset(cornerSize / 2, cornerSize / 2);
    } else if (tileIndex < 30) {
      // Top row (left to right) - color band at bottom, center in upper content area
      return Offset(
        cornerSize + ((tileIndex - 21) * tileWidth) + tileWidth / 2,
        tileHeight / 2 - contentOffset,
      );
    } else if (tileIndex == 30) {
      // Go To Jail corner (top-right)
      return Offset(boardSize - cornerSize / 2, cornerSize / 2);
    } else {
      // Right column (top to bottom) - color band on left, center in right content area
      return Offset(
        boardSize - tileHeight / 2 + contentOffset,
        cornerSize + ((tileIndex - 31) * tileWidth) + tileWidth / 2,
      );
    }
  }

  /// Get position for a player, accounting for other players on the same tile
  /// This addresses design concern #4: Player Token Stacking
  Offset getPlayerPosition(
    Player player,
    List<Player> allPlayers,
    int playerIndex,
  ) {
    final basePos = getBasePosition(player.position);

    // Find all players on the same tile
    final playersOnSameTile =
        allPlayers.where((p) => p.position == player.position).toList();

    if (playersOnSameTile.length <= 1) {
      return basePos;
    }

    // Find this player's index among players on the same tile
    final indexOnTile = playersOnSameTile.indexOf(player);

    // Get stacking offset
    final stackOffset = constants.TokenStackingOffsets.getOffset(
      indexOnTile,
      playersOnSameTile.length,
    );
    // The legacy offsets were fixed pixels and became too small once the
    // board moved to a large logical canvas. Scale the formation with each
    // tile so four character pieces remain individually visible.
    final formationScale = tileWidth / 42.0;

    return Offset(
      basePos.dx + stackOffset.dx * formationScale,
      basePos.dy + stackOffset.dy * formationScale,
    );
  }
}
