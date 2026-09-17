import 'dart:math';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/spin_prize.dart';
import '../../services/audio_service.dart';

/// 3D Animated spin wheel widget
class SpinWheelWidget extends StatefulWidget {
  final List<SpinPrize> prizes;
  final Function(SpinPrize) onPrizeWon;
  final VoidCallback? onSpinStarted;
  final bool enabled;
  final double size;

  const SpinWheelWidget({
    super.key,
    required this.prizes,
    required this.onPrizeWon,
    this.onSpinStarted,
    this.enabled = true,
    this.size = 300,
  });

  @override
  State<SpinWheelWidget> createState() => SpinWheelWidgetState();
}

class SpinWheelWidgetState extends State<SpinWheelWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  bool _isSpinning = false;
  SpinPrize? _selectedPrize;
  double _currentRotation = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 5), vsync: this);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isSpinning = false);
        if (_selectedPrize != null) {
          widget.onPrizeWon(_selectedPrize!);
        }
      }
    });
  }

  void spin() {
    if (_isSpinning || !widget.enabled) return;
    
    AudioService.instance.onSpinWheel();
    widget.onSpinStarted?.call();

    setState(() {
      _isSpinning = true;
      _selectedPrize = _selectRandomPrize();
    });

    // Calculate target rotation
    final prizeIndex = widget.prizes.indexOf(_selectedPrize!);
    final sliceAngle = 2 * pi / widget.prizes.length;
    final prizeAngle = prizeIndex * sliceAngle + sliceAngle / 2;

    // Spin multiple rotations plus land on prize
    final targetRotation = _currentRotation + (5 * 2 * pi) + (2 * pi - prizeAngle) - (_currentRotation % (2 * pi));

    _rotationAnimation = Tween<double>(begin: _currentRotation, end: targetRotation).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _currentRotation = targetRotation;
    _controller.forward(from: 0);
  }

  SpinPrize _selectRandomPrize() {
    final random = Random();
    final totalWeight = widget.prizes.fold<double>(0, (sum, p) => sum + p.weight);
    final randomValue = random.nextDouble() * totalWeight;

    double cumulative = 0;
    for (final prize in widget.prizes) {
      cumulative += prize.weight;
      if (randomValue <= cumulative) {
        return prize;
      }
    }
    return widget.prizes.last;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spinLabel = AppLocalizations.of(context)!.spin;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 3D Shadow under the wheel
          Positioned(
            top: 8,
            child: Container(
              width: widget.size - 10,
              height: widget.size - 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 5)],
              ),
            ),
          ),

          // Outer 3D rim (base layer - darker)
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.amber.shade900, Colors.amber.shade800, Colors.brown.shade700]),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 15, offset: const Offset(0, 8))],
            ),
          ),

          // Outer 3D rim (top layer - shiny)
          Container(
            width: widget.size - 8,
            height: widget.size - 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.amber.shade300, Colors.amber.shade500, Colors.amber.shade700]),
              border: Border.all(color: Colors.amber.shade200, width: 2),
            ),
          ),

          // Wheel with rotation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final rotation = _isSpinning ? _rotationAnimation.value : _currentRotation;
              return Transform.rotate(
                angle: rotation,
                child: CustomPaint(
                  size: Size(widget.size - 24, widget.size - 24),
                  painter: _Wheel3DPainter(prizes: widget.prizes),
                ),
              );
            },
          ),

          // Inner rim shadow
          Container(
            width: widget.size * 0.3,
            height: widget.size * 0.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 2)],
            ),
          ),

          // 3D Center button base (shadow layer)
          Container(
            width: widget.size * 0.28,
            height: widget.size * 0.28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.amber.shade800, Colors.brown.shade800]),
            ),
          ),

          // 3D Center button (main)
          GestureDetector(
            key: const Key('spin-wheel-center'),
            onTap: _isSpinning || !widget.enabled ? null : spin,
            child: Container(
              width: widget.size * 0.25,
              height: widget.size * 0.25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.amber.shade200, Colors.amber.shade400, Colors.amber.shade600], stops: const [0.0, 0.5, 1.0]),
                border: Border.all(color: Colors.amber.shade100, width: 3),
                boxShadow: [
                  BoxShadow(color: Colors.amber.shade300.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(-2, -2)),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(3, 3)),
                ],
              ),
              child: Center(
                child: _isSpinning
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          // Text shadow
                          Text(
                            spinLabel,
                            style: TextStyle(color: Colors.brown.shade800, fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          // Main text with offset for 3D effect
                          Transform.translate(
                            offset: const Offset(-1, -1),
                            child: Text(
                              spinLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                shadows: [Shadow(color: Colors.black38, offset: Offset(1, 1), blurRadius: 2)],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // 3D Pointer
          Positioned(top: 0, child: _build3DPointer()),
        ],
      ),
    );
  }

  Widget _build3DPointer() {
    return SizedBox(
      width: 36,
      height: 48,
      child: Stack(
        children: [
          // Shadow
          Positioned(
            left: 4,
            top: 4,
            child: CustomPaint(size: const Size(32, 44), painter: _PointerShadowPainter()),
          ),
          // Base (darker)
          Positioned(
            left: 2,
            top: 2,
            child: CustomPaint(size: const Size(32, 44), painter: _Pointer3DBasePainter()),
          ),
          // Main pointer
          CustomPaint(size: const Size(32, 44), painter: _Pointer3DPainter()),
          // Highlight
          Positioned(
            left: 8,
            top: 4,
            child: Container(
              width: 8,
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white.withValues(alpha: 0.6), Colors.white.withValues(alpha: 0.0)]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Wheel3DPainter extends CustomPainter {
  final List<SpinPrize> prizes;

  _Wheel3DPainter({required this.prizes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    final sliceAngle = 2 * pi / prizes.length;

    // Draw inner shadow circle for depth
    final innerShadowPaint = Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: 0.1), Colors.black.withValues(alpha: 0.2)], stops: const [0.6, 0.85, 1.0]).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, innerShadowPaint);

    // Draw slices with 3D gradient effect
    for (int i = 0; i < prizes.length; i++) {
      final startAngle = i * sliceAngle - pi / 2;
      final prize = prizes[i];

      // Get base color for slice
      final baseColor = prize.color;

      // Slice rect for gradient shaders
      final sliceRect = Rect.fromCircle(center: center, radius: radius);

      // Actually draw with solid color but add inner edge gradient
      final solidPaint = Paint()
        ..color = baseColor
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(Rect.fromCircle(center: center, radius: radius), startAngle, sliceAngle, false)
        ..close();

      canvas.drawPath(path, solidPaint);

      // Draw gradient overlay for 3D depth
      final gradientPaint = Paint()..shader = RadialGradient(center: const Alignment(0.3, -0.3), radius: 1.2, colors: [Colors.white.withValues(alpha: 0.25), Colors.transparent, Colors.black.withValues(alpha: 0.15)], stops: const [0.0, 0.5, 1.0]).createShader(sliceRect);

      canvas.drawPath(path, gradientPaint);

      // Slice border with slight bevel effect
      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(path, borderPaint);

      // Draw icon and text
      final iconAngle = startAngle + sliceAngle / 2;
      final iconRadius = radius * 0.6;
      final iconCenter = Offset(center.dx + cos(iconAngle) * iconRadius, center.dy + sin(iconAngle) * iconRadius);

      // Draw icon shadow
      final iconShadowPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(prize.icon.codePoint),
          style: TextStyle(fontSize: 26, fontFamily: prize.icon.fontFamily, color: Colors.black38),
        ),
        textDirection: TextDirection.ltr,
      );
      iconShadowPainter.layout();
      iconShadowPainter.paint(canvas, Offset(iconCenter.dx - iconShadowPainter.width / 2 + 2, iconCenter.dy - iconShadowPainter.height / 2 + 2));

      // Draw icon
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(prize.icon.codePoint),
          style: TextStyle(
            fontSize: 26,
            fontFamily: prize.icon.fontFamily,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2)],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      iconPainter.layout();
      iconPainter.paint(canvas, Offset(iconCenter.dx - iconPainter.width / 2, iconCenter.dy - iconPainter.height / 2));

      // Draw prize name (smaller, closer to edge)
      final textRadius = radius * 0.85;
      final textCenter = Offset(center.dx + cos(iconAngle) * textRadius, center.dy + sin(iconAngle) * textRadius);

      canvas.save();
      canvas.translate(textCenter.dx, textCenter.dy);
      canvas.rotate(iconAngle + pi / 2);

      final textPainter = TextPainter(
        text: TextSpan(
          text: prize.name,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black45, offset: Offset(1, 1), blurRadius: 2)],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

      canvas.restore();
    }

    // Draw 3D decorative pegs with metallic effect
    final pegCount = prizes.length;
    for (int i = 0; i < pegCount; i++) {
      final angle = i * sliceAngle - pi / 2;
      final pegCenter = Offset(center.dx + cos(angle) * (radius - 2), center.dy + sin(angle) * (radius - 2));

      // Peg shadow (offset)
      canvas.drawCircle(pegCenter + const Offset(2, 2), 6, Paint()..color = Colors.black38);

      // Peg base (darker gold)
      canvas.drawCircle(pegCenter, 6, Paint()..shader = RadialGradient(center: const Alignment(-0.3, -0.3), colors: [Colors.amber.shade300, Colors.amber.shade700]).createShader(Rect.fromCircle(center: pegCenter, radius: 6)));

      // Peg highlight
      canvas.drawCircle(pegCenter + const Offset(-1, -1), 3, Paint()..color = Colors.amber.shade100);

      // Peg center dot
      canvas.drawCircle(pegCenter, 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_Wheel3DPainter oldDelegate) => false;
}

class _PointerShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, Paint()..color = Colors.black.withValues(alpha: 0.4));
  }

  @override
  bool shouldRepaint(_PointerShadowPainter oldDelegate) => false;
}

class _Pointer3DBasePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, Paint()..color = Colors.red.shade900);
  }

  @override
  bool shouldRepaint(_Pointer3DBasePainter oldDelegate) => false;
}

class _Pointer3DPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    // Main gradient fill
    final paint = Paint()..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.red.shade400, Colors.red.shade600, Colors.red.shade800]).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);

    // Edge highlight on left
    final leftEdge = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width / 4, 0)
      ..lineTo(size.width / 2, size.height * 0.8)
      ..close();

    canvas.drawPath(leftEdge, Paint()..color = Colors.red.shade300.withValues(alpha: 0.5));

    // Border
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.red.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_Pointer3DPainter oldDelegate) => false;
}
