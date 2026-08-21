import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/avatar.dart';

/// Displays an avatar with optional animations
class AvatarWidget extends StatelessWidget {
  final Avatar avatar;
  final double size;
  final bool showEmoji;
  final bool showBorder;
  final Color? borderColor;
  final bool isSelected;

  const AvatarWidget({
    super.key,
    required this.avatar,
    this.size = 48,
    this.showEmoji = true,
    this.showBorder = true,
    this.borderColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // Handle custom photo avatars
    if (avatar.isCustom && avatar.customImagePath != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: showBorder
              ? Border.all(
                  color:
                      borderColor ?? (isSelected ? Colors.amber : Colors.white),
                  width: isSelected ? 3 : 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: avatar.primaryColor.withValues(alpha: 0.4),
              blurRadius: isSelected ? 12 : 6,
              spreadRadius: isSelected ? 2 : 0,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.file(
            File(avatar.customImagePath!),
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback if image can't be loaded
              return Container(
                color: avatar.primaryColor,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: size * 0.5,
                ),
              );
            },
          ),
        ),
      );
    }

    // Standard emoji avatar
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: avatar.gradientColors,
        ),
        border: showBorder
            ? Border.all(
                color:
                    borderColor ?? (isSelected ? Colors.amber : Colors.white),
                width: isSelected ? 3 : 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: avatar.primaryColor.withValues(alpha: 0.4),
            blurRadius: isSelected ? 12 : 6,
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      child: Center(
        child: showEmoji
            ? Text(avatar.emoji, style: TextStyle(fontSize: size * 0.5))
            : Icon(avatar.iconData, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}

/// Animated avatar with idle bounce
class AnimatedAvatarWidget extends StatefulWidget {
  final Avatar avatar;
  final double size;
  final bool isActive;
  final bool showEmoji;

  const AnimatedAvatarWidget({
    super.key,
    required this.avatar,
    this.size = 48,
    this.isActive = false,
    this.showEmoji = true,
  });

  @override
  State<AnimatedAvatarWidget> createState() => _AnimatedAvatarWidgetState();
}

class _AnimatedAvatarWidgetState extends State<AnimatedAvatarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
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
      animation: _bounceAnimation,
      builder: (context, child) {
        final bounce = widget.isActive
            ? sin(_bounceAnimation.value * pi) * 4
            : 0.0;
        return Transform.translate(
          offset: Offset(0, -bounce),
          child: AvatarWidget(
            avatar: widget.avatar,
            size: widget.size,
            showEmoji: widget.showEmoji,
            isSelected: widget.isActive,
          ),
        );
      },
    );
  }
}

/// Avatar for use as player token on the board
class AvatarToken extends StatelessWidget {
  final Avatar avatar;
  final double size;
  final bool isCurrentPlayer;
  final Color playerColor;

  const AvatarToken({
    super.key,
    required this.avatar,
    required this.size,
    required this.playerColor,
    this.isCurrentPlayer = false,
  });

  @override
  Widget build(BuildContext context) {
    // Handle custom photo avatars on the game board
    if (avatar.isCustom && avatar.customImagePath != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: playerColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(1, 1),
            ),
            if (isCurrentPlayer)
              BoxShadow(
                color: playerColor.withValues(alpha: 0.6),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
        child: ClipOval(
          child: Image.file(
            File(avatar.customImagePath!),
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: playerColor,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: size * 0.5,
                ),
              );
            },
          ),
        ),
      );
    }

    // Standard emoji token
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: playerColor,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(1, 1),
          ),
          if (isCurrentPlayer)
            BoxShadow(
              color: playerColor.withValues(alpha: 0.6),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Center(
        child: Text(avatar.emoji, style: TextStyle(fontSize: size * 0.55)),
      ),
    );
  }
}

/// Victory dance animation for winning avatar
class VictoryAvatarWidget extends StatefulWidget {
  final Avatar avatar;
  final double size;

  const VictoryAvatarWidget({super.key, required this.avatar, this.size = 120});

  @override
  State<VictoryAvatarWidget> createState() => _VictoryAvatarWidgetState();
}

class _VictoryAvatarWidgetState extends State<VictoryAvatarWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _rotateController;
  late AnimationController _scaleController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _danceTimer;

  @override
  void initState() {
    super.initState();

    // Bounce animation
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: -30,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -30,
          end: 0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50,
      ),
    ]).animate(_bounceController);

    // Rotation wobble
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 0.1), weight: 25),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: -0.1),
        weight: 50,
      ),
      TweenSequenceItem(tween: Tween<double>(begin: -0.1, end: 0), weight: 25),
    ]).animate(_rotateController);

    // Scale pulse
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 1.2),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.2, end: 1.0),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
        );

    // Start animations
    _startVictoryDance();
  }

  void _startVictoryDance() {
    if (!mounted) return;
    _bounceController.forward(from: 0);
    _danceTimer = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _rotateController.forward(from: 0);
      _danceTimer = Timer(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        _scaleController.forward(from: 0);
        _danceTimer = Timer(
          const Duration(milliseconds: 1000),
          _startVictoryDance,
        );
      });
    });
  }

  @override
  void dispose() {
    _danceTimer?.cancel();
    _bounceController.dispose();
    _rotateController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _bounceAnimation,
        _rotateAnimation,
        _scaleAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildAvatarContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarContent() {
    // Handle custom photo avatars
    if (widget.avatar.isCustom && widget.avatar.customImagePath != null) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.amber, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.6),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.file(
            File(widget.avatar.customImagePath!),
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: widget.avatar.primaryColor,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: widget.size * 0.5,
                ),
              );
            },
          ),
        ),
      );
    }

    // Standard emoji avatar
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.avatar.gradientColors,
        ),
        border: Border.all(color: Colors.amber, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.6),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.avatar.emoji,
          style: TextStyle(fontSize: widget.size * 0.55),
        ),
      ),
    );
  }
}

/// Sad avatar animation for losing/paying rent
class SadAvatarWidget extends StatefulWidget {
  final Avatar avatar;
  final double size;
  final Duration duration;
  final VoidCallback? onComplete;

  const SadAvatarWidget({
    super.key,
    required this.avatar,
    this.size = 48,
    this.duration = const Duration(milliseconds: 1500),
    this.onComplete,
  });

  @override
  State<SadAvatarWidget> createState() => _SadAvatarWidgetState();
}

class _SadAvatarWidgetState extends State<SadAvatarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Animation<double> _dropAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -5.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 0.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 50),
    ]).animate(_controller);

    _dropAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 50),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 5.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 5.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 25,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
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
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, _dropAnimation.value),
          child: AvatarWidget(avatar: widget.avatar, size: widget.size),
        );
      },
    );
  }
}
