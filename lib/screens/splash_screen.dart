import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/city_theme/city_theme.dart';

/// Splash screen shown on app launch
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  Timer? _completionTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _controller.forward();

    _completionTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _completionTimer?.cancel();
    _controller.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071427),
      body: CityThemeBackground(
        animation: _bounceController,
        imageAsset: 'assets/images/home_city_dusk.jpg',
        imageAlignment: const Alignment(0.08, 0),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  constraints.maxHeight < 500 || constraints.maxWidth < 430;
              final logoSize = compact ? 78.0 : 120.0;

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _controller,
                        _bounceController,
                      ]),
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: CityGlassPanel(
                              accent: const Color(0xFF35D5C5),
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 24 : 40,
                                vertical: compact ? 20 : 30,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Transform.translate(
                                    offset: Offset(
                                      0,
                                      -_bounceAnimation.value *
                                          (compact ? 0.5 : 1),
                                    ),
                                    child: Container(
                                      width: logoSize,
                                      height: logoSize,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          compact ? 20 : 26,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x66000000),
                                            blurRadius: 20,
                                            offset: Offset(0, 10),
                                          ),
                                          BoxShadow(
                                            color: Color(0x3335D5C5),
                                            blurRadius: 22,
                                            spreadRadius: -5,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          compact ? 20 : 26,
                                        ),
                                        child: Image.asset(
                                          'assets/icon/icon.png',
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 12 : 22),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildColorfulLetter(
                                        'M',
                                        const Color(0xFFFF6B6B),
                                        fontSize: compact ? 32 : 42,
                                      ),
                                      _buildColorfulLetter(
                                        '&',
                                        const Color(0xFFFFE66D),
                                        fontSize: compact ? 24 : 32,
                                      ),
                                      _buildColorfulLetter(
                                        'M',
                                        const Color(0xFF4ECDC4),
                                        fontSize: compact ? 32 : 42,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: compact ? 3 : 6),
                                  ShaderMask(
                                    shaderCallback:
                                        (bounds) => const LinearGradient(
                                          colors: [
                                            Color(0xFFFFFFFF),
                                            Color(0xFFFFE66D),
                                            Color(0xFFFFFFFF),
                                          ],
                                        ).createShader(bounds),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.propertyTycoon,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: compact ? 21 : 28,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: compact ? 2 : 3,
                                          shadows: const [
                                            Shadow(
                                              color: Colors.black26,
                                              offset: Offset(2, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 8 : 12),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: compact ? 14 : 20,
                                      vertical: compact ? 6 : 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0x4035D5C5),
                                          Color(0x1A35D5C5),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0x8035D5C5),
                                      ),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.familyEdition,
                                      style: TextStyle(
                                        color: const Color(0xFFB9F7F0),
                                        fontSize: compact ? 11 : 14,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: compact ? 2 : 3,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: compact ? 18 : 30),
                                  _buildLoadingDots(compact: compact),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildColorfulLetter(
    String letter,
    Color color, {
    double fontSize = 42,
  }) {
    return Text(
      letter,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        shadows: [
          Shadow(
            color: color.withValues(alpha: 0.5),
            offset: const Offset(2, 2),
            blurRadius: 8,
          ),
          const Shadow(
            color: Colors.black26,
            offset: Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDots({required bool compact}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _bounceController,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = math.sin(
              (_bounceController.value + delay) * math.pi * 2,
            );
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.translate(
                offset: Offset(0, value * 8),
                child: Container(
                  width: compact ? 9 : 12,
                  height: compact ? 9 : 12,
                  decoration: BoxDecoration(
                    color:
                        [
                          const Color(0xFFFF6B6B),
                          const Color(0xFFFFE66D),
                          const Color(0xFF4ECDC4),
                        ][index],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: [
                          const Color(0xFFFF6B6B),
                          const Color(0xFFFFE66D),
                          const Color(0xFF4ECDC4),
                        ][index].withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
