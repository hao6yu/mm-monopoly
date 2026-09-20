import 'dart:math';
import 'package:flutter/material.dart';

/// A 3D dice widget using Matrix4 transforms to create a rotating cube effect.
/// This technique can be reused for buttons, cards, and other 3D UI elements.
/// [sides] selects the die shape: 6 renders the classic pip cube, 12 renders
/// a numbered dodecahedron-style face.
class Dice3D extends StatelessWidget {
  final int value;
  final bool isRolling;
  final AnimationController? animationController;
  final double size;
  final int sides;

  const Dice3D({
    super.key,
    required this.value,
    this.isRolling = false,
    this.animationController,
    this.size = 56.0,
    this.sides = 6,
  });

  @override
  Widget build(BuildContext context) {
    if (sides == 12) {
      if (isRolling && animationController != null) {
        return _AnimatedDice12(
          controller: animationController!,
          size: size,
          targetValue: value,
        );
      }
      return _StaticDice12(value: value, size: size);
    }

    if (isRolling && animationController != null) {
      return _AnimatedDice3D(
        controller: animationController!,
        size: size,
        targetValue: value,
      );
    }

    return _StaticDice3D(value: value, size: size);
  }
}

/// Static 3D dice with clean depth effect using layered shadows and highlights
class _StaticDice3D extends StatefulWidget {
  final int value;
  final double size;

  const _StaticDice3D({required this.value, required this.size});

  @override
  State<_StaticDice3D> createState() => _StaticDice3DState();
}

class _StaticDice3DState extends State<_StaticDice3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _idleController;
  late Animation<double> _idleAnimation;

  @override
  void initState() {
    super.initState();
    // Subtle idle float animation
    _idleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _idleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final depth = size * 0.12; // 3D depth amount

    return AnimatedBuilder(
      animation: _idleAnimation,
      builder: (context, child) {
        // Subtle floating effect
        final float = sin(_idleAnimation.value * pi) * 2;

        return Transform.translate(
          offset: Offset(0, -float),
          child: SizedBox(
            width: size + depth,
            height: size + depth,
            child: Stack(
              children: [
                // Drop shadow on ground
                Positioned(
                  bottom: 0,
                  left: depth / 2,
                  child: Container(
                    width: size * 0.85,
                    height: size * 0.12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size * 0.4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25 - float * 0.02),
                          blurRadius: 10 + float,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom edge (3D depth - darker)
                Positioned(
                  left: depth,
                  top: depth,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB0B0B0),
                      borderRadius: BorderRadius.circular(size * 0.15),
                    ),
                  ),
                ),
                // Right edge (3D depth - medium)
                Positioned(
                  left: depth * 0.6,
                  top: depth * 0.6,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0D0D0),
                      borderRadius: BorderRadius.circular(size * 0.15),
                    ),
                  ),
                ),
                // Main face (top - brightest)
                Positioned(
                  left: 0,
                  top: 0,
                  child: _DiceFace(
                    value: widget.value,
                    size: size,
                    color: Colors.white,
                    isTop: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Animated 3D dice that tumbles through space
class _AnimatedDice3D extends StatelessWidget {
  final AnimationController controller;
  final double size;
  final int targetValue;
  final Random _random = Random();

  _AnimatedDice3D({
    required this.controller,
    required this.size,
    required this.targetValue,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Calculate rotation angles for tumbling effect
        final progress = controller.value;
        final rotationX = progress * 4 * pi; // 2 full rotations on X
        final rotationY = progress * 6 * pi; // 3 full rotations on Y
        final rotationZ = progress * 2 * pi; // 1 full rotation on Z

        // Add bounce scale effect
        final scale = 1.0 + sin(progress * pi) * 0.15;

        // Determine which face to show based on rotation
        final displayValue = progress < 0.9 ? _random.nextInt(6) + 1 : targetValue;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002) // stronger perspective during animation
            ..multiply(Matrix4.diagonal3Values(scale, scale, scale))
            ..rotateX(rotationX)
            ..rotateY(rotationY)
            ..rotateZ(rotationZ * 0.3),
          child: _DiceCube(
            size: size,
            displayValue: displayValue,
            glowIntensity: 0.6 + sin(progress * pi * 2) * 0.4,
          ),
        );
      },
    );
  }
}

/// A full 3D cube with all 6 faces
class _DiceCube extends StatelessWidget {
  final double size;
  final int displayValue;
  final double glowIntensity;

  const _DiceCube({
    required this.size,
    required this.displayValue,
    this.glowIntensity = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final halfSize = size / 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: glowIntensity),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Front face (value shown)
          _buildFace(
            value: displayValue,
            transform: Matrix4.identity()..setTranslationRaw(0.0, 0.0, halfSize),
          ),
          // Back face
          _buildFace(
            value: 7 - displayValue, // opposite face
            transform: Matrix4.identity()
              ..setTranslationRaw(0.0, 0.0, -halfSize)
              ..rotateY(pi),
          ),
          // Right face
          _buildFace(
            value: _getAdjacentValue(displayValue, 'right'),
            transform: Matrix4.identity()
              ..setTranslationRaw(halfSize, 0.0, 0.0)
              ..rotateY(pi / 2),
          ),
          // Left face
          _buildFace(
            value: _getAdjacentValue(displayValue, 'left'),
            transform: Matrix4.identity()
              ..setTranslationRaw(-halfSize, 0.0, 0.0)
              ..rotateY(-pi / 2),
          ),
          // Top face
          _buildFace(
            value: _getAdjacentValue(displayValue, 'top'),
            transform: Matrix4.identity()
              ..setTranslationRaw(0.0, -halfSize, 0.0)
              ..rotateX(pi / 2),
          ),
          // Bottom face
          _buildFace(
            value: _getAdjacentValue(displayValue, 'bottom'),
            transform: Matrix4.identity()
              ..setTranslationRaw(0.0, halfSize, 0.0)
              ..rotateX(-pi / 2),
          ),
        ],
      ),
    );
  }

  Widget _buildFace({required int value, required Matrix4 transform}) {
    return Transform(
      alignment: Alignment.center,
      transform: transform,
      child: _DiceFace(value: value, size: size, color: Colors.white),
    );
  }

  // Standard dice: opposite faces sum to 7
  // Adjacent faces follow a specific pattern
  int _getAdjacentValue(int front, String position) {
    // Standard dice layout when 1 is front and 2 is top:
    // Front=1, Back=6, Top=2, Bottom=5, Right=3, Left=4
    final Map<int, Map<String, int>> adjacencyMap = {
      1: {'right': 3, 'left': 4, 'top': 2, 'bottom': 5},
      2: {'right': 3, 'left': 4, 'top': 6, 'bottom': 1},
      3: {'right': 6, 'left': 1, 'top': 2, 'bottom': 5},
      4: {'right': 1, 'left': 6, 'top': 2, 'bottom': 5},
      5: {'right': 3, 'left': 4, 'top': 1, 'bottom': 6},
      6: {'right': 4, 'left': 3, 'top': 2, 'bottom': 5},
    };
    return adjacencyMap[front]?[position] ?? 1;
  }
}

/// A single face of the dice with dots
class _DiceFace extends StatelessWidget {
  final int value;
  final double size;
  final Color color;
  final bool isTop;

  const _DiceFace({
    required this.value,
    required this.size,
    required this.color,
    this.isTop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.15),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            Color.lerp(color, Colors.grey.shade200, 0.3)!,
          ],
        ),
        boxShadow: isTop
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 2,
                ),
              ],
      ),
      child: value == 0
          ? Center(
              child: Text(
                '?',
                style: TextStyle(
                  fontSize: size * 0.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            )
          : _DotPattern3D(value: value, size: size),
    );
  }
}

/// Displays traditional dice dot pattern with 3D-styled dots
class _DotPattern3D extends StatelessWidget {
  final int value;
  final double size;

  const _DotPattern3D({required this.value, required this.size});

  double get _dotSize => size * 0.16;
  Color get _dotColor => Colors.red.shade700;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(size * 0.14),
      child: _buildPattern(),
    );
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
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            _dotColor.withValues(alpha: 0.8),
            _dotColor,
            Color.lerp(_dotColor, Colors.black, 0.3)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          // Inner highlight (top-left)
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: 1,
            offset: Offset(-_dotSize * 0.1, -_dotSize * 0.1),
          ),
          // Drop shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 2,
            offset: Offset(_dotSize * 0.1, _dotSize * 0.15),
          ),
        ],
      ),
    );
  }

  Widget _emptyDot() {
    return SizedBox(width: _dotSize, height: _dotSize);
  }

  Widget _buildOne() {
    return Center(child: _dot());
  }

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

/// Small static dice icon for pickers and menus: a pip face for the classic
/// cube and a numbered pentagon face for the twelve-sided die, matching the
/// look of the 3D board dice.
class DiceIcon extends StatelessWidget {
  final int sides;
  final double size;

  const DiceIcon({super.key, this.sides = 6, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: sides == 12
          ? _Die12FacePainter(value: 12)
          : _Dice6IconPainter(value: 5),
    );
  }
}

/// Paints a classic cube face with pips for the small icon.
class _Dice6IconPainter extends CustomPainter {
  final int value;

  _Dice6IconPainter({required this.value});

  static const _pipLayouts = {
    1: [Offset(0.5, 0.5)],
    2: [Offset(0.28, 0.28), Offset(0.72, 0.72)],
    3: [Offset(0.26, 0.26), Offset(0.5, 0.5), Offset(0.74, 0.74)],
    4: [
      Offset(0.28, 0.28),
      Offset(0.72, 0.28),
      Offset(0.28, 0.72),
      Offset(0.72, 0.72),
    ],
    5: [
      Offset(0.27, 0.27),
      Offset(0.73, 0.27),
      Offset(0.5, 0.5),
      Offset(0.27, 0.73),
      Offset(0.73, 0.73),
    ],
    6: [
      Offset(0.28, 0.24),
      Offset(0.72, 0.24),
      Offset(0.28, 0.5),
      Offset(0.72, 0.5),
      Offset(0.28, 0.76),
      Offset(0.72, 0.76),
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = size.width * 0.18;

    final facePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Colors.grey.shade200],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(0.5), Radius.circular(radius)),
      facePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(0.5), Radius.circular(radius)),
      Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.03,
    );

    final dotPaint = Paint()..color = const Color(0xFFB03A2E);
    final dotRadius = size.width * 0.09;
    for (final fraction in _pipLayouts[value] ?? const <Offset>[]) {
      canvas.drawCircle(
        Offset(size.width * fraction.dx, size.height * fraction.dy),
        dotRadius,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_Dice6IconPainter oldDelegate) =>
      oldDelegate.value != value;
}

/// Static twelve-sided die: a numbered pentagon face with soft depth edges.
class _StaticDice12 extends StatefulWidget {
  final int value;
  final double size;

  const _StaticDice12({required this.value, required this.size});

  @override
  State<_StaticDice12> createState() => _StaticDice12State();
}

class _StaticDice12State extends State<_StaticDice12>
    with SingleTickerProviderStateMixin {
  late AnimationController _idleController;
  late Animation<double> _idleAnimation;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _idleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final depth = size * 0.12;

    return AnimatedBuilder(
      animation: _idleAnimation,
      builder: (context, child) {
        final float = sin(_idleAnimation.value * pi) * 2;

        return Transform.translate(
          offset: Offset(0, -float),
          child: SizedBox(
            width: size + depth,
            height: size + depth,
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: depth / 2,
                  child: Container(
                    width: size * 0.85,
                    height: size * 0.12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size * 0.4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.25 - float * 0.02,
                          ),
                          blurRadius: 10 + float,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: depth,
                  top: depth,
                  child: CustomPaint(
                    size: Size.square(size),
                    painter: _Die12FacePainter(
                      value: widget.value,
                      shade: 0.82,
                    ),
                  ),
                ),
                Positioned(
                  left: depth * 0.6,
                  top: depth * 0.6,
                  child: CustomPaint(
                    size: Size.square(size),
                    painter: _Die12FacePainter(
                      value: widget.value,
                      shade: 0.9,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: CustomPaint(
                    size: Size.square(size),
                    painter: _Die12FacePainter(value: widget.value),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Animated twelve-sided die that tumbles through random faces before
/// settling on the target value.
class _AnimatedDice12 extends StatelessWidget {
  final AnimationController controller;
  final double size;
  final int targetValue;
  final Random _random = Random();

  _AnimatedDice12({
    required this.controller,
    required this.size,
    required this.targetValue,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = controller.value;
        final rotationX = progress * 4 * pi;
        final rotationY = progress * 6 * pi;
        final rotationZ = progress * 2 * pi;
        final scale = 1.0 + sin(progress * pi) * 0.15;
        final displayValue = progress < 0.9 ? _random.nextInt(12) + 1 : targetValue;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..multiply(Matrix4.diagonal3Values(scale, scale, scale))
            ..rotateX(rotationX)
            ..rotateY(rotationY)
            ..rotateZ(rotationZ * 0.3),
          child: CustomPaint(
            size: Size.square(size),
            painter: _Die12FacePainter(value: displayValue, glow: true),
          ),
        );
      },
    );
  }
}

/// Paints one pentagonal d12 face with a centered numeral, matching the
/// ivory-and-ink look of the 3D board dice.
class _Die12FacePainter extends CustomPainter {
  final int value;
  final double shade;
  final bool glow;

  _Die12FacePainter({required this.value, this.shade = 1.0, this.glow = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final facePath = _pentagonPath(center, radius * 0.98);

    if (glow) {
      canvas.drawShadow(facePath, Colors.amber, 6.0, false);
    }

    final basePaint = Paint()
      ..color = Color.lerp(Colors.white, Colors.grey.shade300, 1 - shade)!;
    canvas.drawPath(facePath, basePaint);

    final borderPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02;
    canvas.drawPath(facePath, borderPaint);

    final textSpan = TextSpan(
      text: value <= 0 ? '?' : '$value',
      style: TextStyle(
        fontSize: size.width * (value >= 10 ? 0.42 : 0.48),
        fontWeight: FontWeight.w900,
        color: const Color(0xFF1D2436),
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  Path _pentagonPath(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final angle = -pi / 2 + i * 2 * pi / 5;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_Die12FacePainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.shade != shade ||
      oldDelegate.glow != glow;
}

/// Pair of 3D dice
class DicePair3D extends StatelessWidget {
  final int die1;
  final int die2;
  final bool isRolling;
  final AnimationController? animationController;
  final double diceSize;
  final int diceCount;
  final int sides;

  const DicePair3D({
    super.key,
    required this.die1,
    required this.die2,
    this.isRolling = false,
    this.animationController,
    this.diceSize = 56.0,
    this.diceCount = 2,
    this.sides = 6,
  });

  @override
  Widget build(BuildContext context) {
    // Single die mode
    if (diceCount == 1) {
      return Center(
        child: Dice3D(
          value: die1,
          isRolling: isRolling,
          animationController: animationController,
          size: diceSize,
          sides: sides,
        ),
      );
    }

    // Two dice mode
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Dice3D(
          value: die1,
          isRolling: isRolling,
          animationController: animationController,
          size: diceSize,
          sides: sides,
        ),
        SizedBox(width: diceSize * 0.3),
        Dice3D(
          value: die2,
          isRolling: isRolling,
          animationController: animationController,
          size: diceSize,
          sides: sides,
        ),
      ],
    );
  }
}
