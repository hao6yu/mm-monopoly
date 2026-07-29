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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
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
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_controller, _bounceController]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: CityGlassPanel(
                    accent: const Color(0xFF35D5C5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 44,
                      vertical: 34,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Bouncing Logo
                        Transform.translate(
                          offset: Offset(0, -_bounceAnimation.value),
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.asset(
                                'assets/icon/icon.png',
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // M&M Title with fun colors
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildColorfulLetter('M', const Color(0xFFFF6B6B)),
                            _buildColorfulLetter(
                              '&',
                              const Color(0xFFFFE66D),
                              fontSize: 32,
                            ),
                            _buildColorfulLetter('M', const Color(0xFF4ECDC4)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // PROPERTY TYCOON with gradient effect
                        ShaderMask(
                          shaderCallback:
                              (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFFFFFFFF),
                                  Color(0xFFFFE66D),
                                  Color(0xFFFFFFFF),
                                ],
                              ).createShader(bounds),
                          child: Text(
                            AppLocalizations.of(context)!.propertyTycoon,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Family Edition badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.familyEdition,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        // Fun loading dots
                        _buildLoadingDots(),
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
            color: color.withOpacity(0.5),
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

  Widget _buildLoadingDots() {
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
                  width: 12,
                  height: 12,
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
                        ][index].withOpacity(0.5),
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
