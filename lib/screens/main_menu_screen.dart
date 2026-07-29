import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/city_theme/city_theme.dart';

/// Main menu presented as the entrance to the same miniature city world used
/// by the playable 3D boards.
class MainMenuScreen extends StatefulWidget {
  final VoidCallback onNewGame;
  final VoidCallback? onContinue;
  final VoidCallback onHowToPlay;
  final VoidCallback onSettings;
  final VoidCallback? onShop;

  const MainMenuScreen({
    super.key,
    required this.onNewGame,
    this.onContinue,
    required this.onHowToPlay,
    required this.onSettings,
    this.onShop,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _worldController;
  late final Animation<double> _heroAnimation;
  late final Animation<double> _menuAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _worldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _heroAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.66, curve: Curves.easeOutCubic),
    );
    _menuAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 1, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _worldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071427),
      body: CityThemeBackground(
        animation: _worldController,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide =
                  constraints.maxWidth >= 760 &&
                  constraints.maxWidth > constraints.maxHeight * 1.12;
              final horizontalPadding =
                  constraints.maxWidth < 500 ? 18.0 : 34.0;
              final content = ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child:
                    isWide
                        ? Row(
                          children: [
                            Expanded(flex: 6, child: _buildHero(isWide: true)),
                            const SizedBox(width: 28),
                            Expanded(flex: 5, child: _buildMenuPanel()),
                          ],
                        )
                        : Column(
                          children: [
                            Expanded(
                              flex: constraints.maxHeight < 700 ? 4 : 5,
                              child: _buildHero(isWide: false),
                            ),
                            const SizedBox(height: 16),
                            Flexible(
                              flex: 5,
                              child: SingleChildScrollView(
                                child: _buildMenuPanel(),
                              ),
                            ),
                          ],
                        ),
              );
              return Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    20,
                  ),
                  child: content,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHero({required bool isWide}) {
    return FadeTransition(
      opacity: _heroAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.06, 0.04),
          end: Offset.zero,
        ).animate(_heroAnimation),
        child: Align(
          alignment: isWide ? Alignment.centerLeft : Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              _buildWorldTourBadge(),
              SizedBox(height: isWide ? 22 : 10),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  AnimatedBuilder(
                    animation: _worldController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          0,
                          math.sin(_worldController.value * math.pi * 2) * 4,
                        ),
                        child: child,
                      );
                    },
                    child: Container(
                      width: isWide ? 96 : 72,
                      height: isWide ? 96 : 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(isWide ? 22 : 18),
                        border: Border.all(
                          color: const Color(0xFFFFD86B),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x6635D5C5),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/icon/icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: isWide ? 20 : 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'M&M',
                          style: TextStyle(
                            color: const Color(0xFFFFD86B),
                            fontSize: isWide ? 42 : 30,
                            height: 0.95,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            shadows: const [
                              Shadow(color: Color(0x8035D5C5), blurRadius: 18),
                            ],
                          ),
                        ),
                        const SizedBox(height: 7),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context)!.propertyTycoon,
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isWide ? 26 : 19,
                              fontWeight: FontWeight.w900,
                              letterSpacing: isWide ? 2.2 : 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isWide ? 22 : 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  AppLocalizations.of(context)!.familyEdition.toUpperCase(),
                  textAlign: isWide ? TextAlign.left : TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFD8E7F4).withOpacity(0.86),
                    fontSize: isWide ? 15 : 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
              ),
              SizedBox(height: isWide ? 24 : 14),
              Wrap(
                alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _WorldChip(icon: Icons.location_city_rounded, label: '18'),
                  _WorldChip(icon: Icons.view_in_ar_rounded, label: '3D'),
                  _WorldChip(icon: Icons.groups_rounded, label: '2–4'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorldTourBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xD9111D33),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0x6635D5C5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.public_rounded, color: Color(0xFF8CEDE2), size: 17),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.worldCityEdition.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF8CEDE2),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuPanel() {
    final localizations = AppLocalizations.of(context)!;
    return FadeTransition(
      opacity: _menuAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.08, 0.05),
          end: Offset.zero,
        ).animate(_menuAnimation),
        child: CityGlassPanel(
          accent: const Color(0xFF35D5C5),
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CitySectionLabel(
                icon: Icons.explore_rounded,
                label: localizations.chooseNextMove,
              ),
              const SizedBox(height: 16),
              CityChromeButton(
                icon: Icons.play_arrow_rounded,
                label: localizations.newGame,
                onPressed: widget.onNewGame,
                primary: true,
              ),
              if (widget.onContinue != null) ...[
                const SizedBox(height: 10),
                CityChromeButton(
                  icon: Icons.restore_rounded,
                  label: localizations.continueGame,
                  onPressed: widget.onContinue!,
                ),
              ],
              const SizedBox(height: 10),
              CityChromeButton(
                icon: Icons.map_outlined,
                label: localizations.howToPlay,
                onPressed: widget.onHowToPlay,
              ),
              const SizedBox(height: 10),
              CityChromeButton(
                icon: Icons.tune_rounded,
                label: localizations.settings,
                onPressed: widget.onSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorldChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _WorldChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xDD1D2B48), Color(0xCC101B30)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x405F91B5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFFD86B), size: 17),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
