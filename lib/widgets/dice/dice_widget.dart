import 'dart:math';
import 'package:flutter/material.dart';
import 'dice_3d.dart';
import '../common/button_3d.dart';

// Re-export 3D dice components for easy access
export 'dice_3d.dart' show Dice3D, DicePair3D;
export '../common/button_3d.dart' show Button3D, RollButton3D;

/// Single die widget - now uses 3D dice by default
class DieWidget extends StatelessWidget {
  final int value;
  final bool isRolling;
  final AnimationController? animationController;
  final bool use3D;

  const DieWidget({
    super.key,
    required this.value,
    this.isRolling = false,
    this.animationController,
    this.use3D = true, // 3D by default
  });

  @override
  Widget build(BuildContext context) {
    if (use3D) {
      return Dice3D(
        value: value,
        isRolling: isRolling,
        animationController: animationController,
      );
    }

    if (isRolling && animationController != null) {
      return _AnimatedDie(controller: animationController!);
    }

    return _StaticDie(value: value);
  }
}

class _StaticDie extends StatelessWidget {
  final int value;

  const _StaticDie({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5),
        ],
      ),
      child:
          value == 0
              ? const Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              )
              : _DotPattern(value: value),
    );
  }
}

/// Displays traditional dice dot pattern
class _DotPattern extends StatelessWidget {
  final int value;
  static const double _dotSize = 10.0;
  static final Color _dotColor = Colors.red.shade700;

  const _DotPattern({required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(8.0), child: _buildPattern());
  }

  Widget _buildPattern() {
    switch (value) {
      case 1:
        return _buildOne();
      case 2:
        return _buildTwo();
      case 3:
        return _buildThree();
      case 4:
        return _buildFour();
      case 5:
        return _buildFive();
      case 6:
        return _buildSix();
      default:
        return const SizedBox();
    }
  }

  Widget _dot() {
    return Container(
      width: _dotSize,
      height: _dotSize,
      decoration: BoxDecoration(
        color: _dotColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _dotColor.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }

  Widget _emptyDot() {
    return SizedBox(width: _dotSize, height: _dotSize);
  }

  // Pattern: center dot only
  Widget _buildOne() {
    return Center(child: _dot());
  }

  // Pattern: top-left and bottom-right
  Widget _buildTwo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_dot(), _emptyDot()],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_emptyDot(), _dot()],
        ),
      ],
    );
  }

  // Pattern: top-left, center, bottom-right (diagonal)
  Widget _buildThree() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_dot(), _emptyDot()],
        ),
        Center(child: _dot()),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_emptyDot(), _dot()],
        ),
      ],
    );
  }

  // Pattern: all four corners
  Widget _buildFour() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_dot(), _dot()],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_dot(), _dot()],
        ),
      ],
    );
  }

  // Pattern: all four corners + center
  Widget _buildFive() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_dot(), _dot()],
        ),
        Center(child: _dot()),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_dot(), _dot()],
        ),
      ],
    );
  }

  // Pattern: two columns of three dots
  Widget _buildSix() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_dot(), _dot()],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_dot(), _dot()],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_dot(), _dot()],
        ),
      ],
    );
  }
}

class _AnimatedDie extends StatelessWidget {
  final AnimationController controller;
  final Random _random = Random();

  _AnimatedDie({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final rotation = controller.value * 4 * pi;
        final scale = 1.0 + sin(controller.value * pi) * 0.2;
        final randomValue = _random.nextInt(6) + 1;

        return Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: rotation,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.6),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _DotPattern(value: randomValue),
            ),
          ),
        );
      },
    );
  }
}

/// Pair of dice widget - now uses 3D dice by default
class DicePair extends StatelessWidget {
  final int die1;
  final int die2;
  final bool isRolling;
  final AnimationController? animationController;
  final bool use3D;
  final int diceCount; // 1 or 2 dice

  const DicePair({
    super.key,
    required this.die1,
    required this.die2,
    this.isRolling = false,
    this.animationController,
    this.use3D = true, // 3D by default
    this.diceCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (use3D) {
      return DicePair3D(
        die1: die1,
        die2: die2,
        isRolling: isRolling,
        animationController: animationController,
        diceCount: diceCount,
      );
    }

    if (diceCount == 1) {
      return Center(
        child: DieWidget(
          value: die1,
          isRolling: isRolling,
          animationController: animationController,
          use3D: false,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DieWidget(
          value: die1,
          isRolling: isRolling,
          animationController: animationController,
          use3D: false,
        ),
        const SizedBox(width: 16),
        DieWidget(
          value: die2,
          isRolling: isRolling,
          animationController: animationController,
          use3D: false,
        ),
      ],
    );
  }
}

/// Roll button with glow effect - now uses 3D button by default
class RollButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isRolling;
  final bool isMoving;
  final AnimationController glowController;
  final bool use3D;

  const RollButton({
    super.key,
    required this.onPressed,
    required this.isRolling,
    required this.isMoving,
    required this.glowController,
    this.use3D = true, // 3D by default
  });

  @override
  Widget build(BuildContext context) {
    // Use 3D button by default
    if (use3D) {
      return RollButton3D(
        onPressed: onPressed,
        isRolling: isRolling,
        isMoving: isMoving,
        glowController: glowController,
      );
    }

    // Legacy 2D button
    final isDisabled = isRolling || isMoving;

    return AnimatedBuilder(
      animation: glowController,
      builder: (context, child) {
        final glow = 0.3 + glowController.value * 0.3;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow:
                isDisabled
                    ? []
                    : [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: glow),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
          ),
          child: ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
            child: Text(
              isRolling
                  ? 'ROLLING...'
                  : isMoving
                  ? 'MOVING...'
                  : 'ROLL DICE',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Center controls widget containing tappable dice (no button)
class CenterControls extends StatefulWidget {
  final int die1;
  final int die2;
  final bool isRolling;
  final bool isMoving;
  final VoidCallback? onRoll;
  final AnimationController diceController;
  final AnimationController glowController;
  final int diceCount;

  const CenterControls({
    super.key,
    required this.die1,
    required this.die2,
    required this.isRolling,
    required this.isMoving,
    required this.onRoll,
    required this.diceController,
    required this.glowController,
    this.diceCount = 2,
  });

  @override
  State<CenterControls> createState() => _CenterControlsState();
}

class _CenterControlsState extends State<CenterControls>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canRoll =
        !widget.isRolling && !widget.isMoving && widget.onRoll != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Large tappable area panel around dice - clicking anywhere in the panel rolls
        GestureDetector(
          onTap: canRoll ? widget.onRoll : null,
          behavior: HitTestBehavior.opaque, // Makes entire area tappable
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _pulseController,
              widget.glowController,
            ]),
            builder: (context, child) {
              final pulseScale =
                  canRoll ? 1.0 + _pulseController.value * 0.05 : 1.0;
              final glowIntensity =
                  canRoll ? 0.3 + widget.glowController.value * 0.4 : 0.0;

              return Container(
                // Padding creates larger clickable area around dice
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: Transform.scale(
                  scale: pulseScale,
                  child: _GlowingDice(
                    die1: widget.die1,
                    die2: widget.die2,
                    isRolling: widget.isRolling,
                    diceController: widget.diceController,
                    diceCount: widget.diceCount,
                    canRoll: canRoll,
                    glowIntensity: glowIntensity,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Widget that applies glow effect directly to each die
class _GlowingDice extends StatelessWidget {
  final int die1;
  final int die2;
  final bool isRolling;
  final AnimationController diceController;
  final int diceCount;
  final bool canRoll;
  final double glowIntensity;

  const _GlowingDice({
    required this.die1,
    required this.die2,
    required this.isRolling,
    required this.diceController,
    required this.diceCount,
    required this.canRoll,
    required this.glowIntensity,
  });

  @override
  Widget build(BuildContext context) {
    if (diceCount == 1) {
      return _buildSingleGlowingDie(die1);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSingleGlowingDie(die1),
        const SizedBox(
          width: 40,
        ), // Increased spacing to prevent overlap during animation
        _buildSingleGlowingDie(die2),
      ],
    );
  }

  Widget _buildSingleGlowingDie(int value) {
    return Container(
      decoration:
          canRoll
              ? BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(glowIntensity),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: Colors.orange.withOpacity(glowIntensity * 0.5),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                ],
              )
              : null,
      child: Dice3D(
        value: value,
        isRolling: isRolling,
        animationController: diceController,
        size: 80.0, // Increased from 68
      ),
    );
  }
}

/// Card deck display widget with realistic 3D stacked cards effect and shuffle animation
class CardDeck extends StatefulWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const CardDeck({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  State<CardDeck> createState() => _CardDeckState();
}

class _CardDeckState extends State<CardDeck> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(CardDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted && !oldWidget.isHighlighted) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isHighlighted && oldWidget.isHighlighted) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Only respond to taps when highlighted (player needs to pick a card)
      onTap: widget.isHighlighted ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_hoverController, _pulseAnimation]),
        builder: (context, child) {
          final float = sin(_hoverController.value * pi) * 2;
          final scale = widget.isHighlighted ? _pulseAnimation.value : 1.0;

          return Transform.scale(
            scale: scale,
            child: Transform.translate(
              offset: Offset(0, -float),
              child: _build3DCardDeck(),
            ),
          );
        },
      ),
    );
  }

  Widget _build3DCardDeck() {
    const deckWidth = 90.0;
    const deckHeight = 125.0;
    const cardCount = 5; // Number of visible cards in stack
    const stackOffset = 4.0; // Offset between cards for 3D effect

    // Calculate total stack offset
    const totalStackOffset = (cardCount - 1) * stackOffset;

    return SizedBox(
      width: deckWidth + totalStackOffset,
      height: deckHeight + totalStackOffset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Stacked cards (back to front)
          ...List.generate(cardCount, (index) {
            final baseOffset = (cardCount - 1 - index) * stackOffset;
            final isTop = index == cardCount - 1;

            return Positioned(
              left: baseOffset,
              top: baseOffset,
              child: _build3DCard(isTop: isTop, depth: cardCount - 1 - index),
            );
          }),
          // Glow effect when highlighted
          if (widget.isHighlighted)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _build3DCard({required bool isTop, required int depth}) {
    const cardWidth = 90.0; // Increased from 80
    const cardHeight = 125.0; // Increased from 110

    // Calculate opacity and color based on depth
    final opacity = isTop ? 1.0 : (0.9 - depth * 0.15).clamp(0.4, 0.9);
    final darkenAmount = depth * 0.08;

    // Create a darker shade for cards below
    final cardColor =
        isTop
            ? widget.color
            : HSLColor.fromColor(widget.color)
                .withLightness(
                  (HSLColor.fromColor(widget.color).lightness - darkenAmount)
                      .clamp(0.1, 0.9),
                )
                .toColor();

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        // 3D effect with gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isTop
                  ? [
                    cardColor,
                    HSLColor.fromColor(cardColor)
                        .withLightness(
                          (HSLColor.fromColor(cardColor).lightness - 0.1).clamp(
                            0.0,
                            1.0,
                          ),
                        )
                        .toColor(),
                  ]
                  : [
                    cardColor.withOpacity(opacity),
                    cardColor.withOpacity(opacity * 0.8),
                  ],
        ),
        border: Border.all(
          color:
              isTop
                  ? (widget.isHighlighted
                      ? Colors.amber
                      : Colors.white.withOpacity(0.6))
                  : Colors.white.withOpacity(0.2 * opacity),
          width: isTop ? (widget.isHighlighted ? 3 : 2) : 1,
        ),
        boxShadow:
            isTop
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(2, 3),
                  ),
                  if (widget.isHighlighted)
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                ]
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ],
      ),
      child: isTop ? _buildTopCardContent() : _buildBackCardPattern(opacity),
    );
  }

  Widget _buildTopCardContent() {
    return Stack(
      children: [
        // Decorative border pattern (double border like playing cards)
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
        // Main content
        Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with decorative circle
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 8),
                // Label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Tap hint when highlighted
                if (widget.isHighlighted) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'TAP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackCardPattern(double opacity) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: CustomPaint(
        painter: _CardPatternPainter(
          color: Colors.white.withOpacity(0.1 * opacity),
        ),
      ),
    );
  }
}

/// Custom painter for card back pattern
class _CardPatternPainter extends CustomPainter {
  final Color color;

  _CardPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    // Draw diagonal lines
    const spacing = 6.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
