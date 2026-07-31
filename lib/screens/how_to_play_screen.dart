import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/city_theme/city_theme.dart';

/// A short, visual walkthrough of the core game loop.
class HowToPlayScreen extends StatefulWidget {
  final VoidCallback onBack;

  const HowToPlayScreen({super.key, required this.onBack});

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _worldController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _worldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _worldController.dispose();
    super.dispose();
  }

  List<_TutorialLesson> _buildLessons(AppLocalizations l10n) {
    return [
      _TutorialLesson(
        icon: Icons.casino_rounded,
        title: l10n.tutorialRollMove,
        description: l10n.tutorialRollMoveDesc,
        color: const Color(0xFF35D5C5),
        visual: _TutorialVisual.roll,
      ),
      _TutorialLesson(
        icon: Icons.home_work_rounded,
        title: l10n.tutorialBuyProperties,
        description: l10n.tutorialBuyPropertiesDesc,
        color: const Color(0xFFF2C452),
        visual: _TutorialVisual.buy,
      ),
      _TutorialLesson(
        icon: Icons.payments_rounded,
        title: l10n.tutorialCollectRent,
        description: l10n.tutorialCollectRentDesc,
        color: const Color(0xFF73D6A7),
        visual: _TutorialVisual.rent,
      ),
      _TutorialLesson(
        icon: Icons.auto_awesome_rounded,
        title: l10n.tutorialSpecialSpaces,
        description: l10n.tutorialSpecialSpacesDesc,
        color: const Color(0xFFB991EE),
        visual: _TutorialVisual.special,
      ),
      _TutorialLesson(
        icon: Icons.emoji_events_rounded,
        title: l10n.tutorialWinGame,
        description: l10n.tutorialWinGameDesc,
        color: const Color(0xFFFF7B68),
        visual: _TutorialVisual.win,
      ),
    ];
  }

  Future<void> _goToPage(int page) async {
    if (_currentPage != page && mounted) {
      setState(() => _currentPage = page);
    }
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lessons = _buildLessons(l10n);

    return Scaffold(
      backgroundColor: const Color(0xFF071427),
      body: CityThemeBackground(
        animation: _worldController,
        imageAsset: 'assets/images/home_city_dusk.jpg',
        imageAlignment: const Alignment(0.08, 0),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;
              final isCompactLandscape =
                  isLandscape && constraints.maxHeight < 500;
              final showLessonRail =
                  constraints.maxWidth >= 820 && constraints.maxHeight >= 520;

              return Column(
                children: [
                  _buildHeader(
                    l10n,
                    lessons.length,
                    compact: isCompactLandscape,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isCompactLandscape ? 12 : 20,
                        isCompactLandscape ? 4 : 8,
                        isCompactLandscape ? 12 : 20,
                        isCompactLandscape ? 4 : 8,
                      ),
                      child:
                          showLessonRail
                              ? Row(
                                children: [
                                  SizedBox(
                                    width: 260,
                                    child: _buildLessonRail(lessons, l10n),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildPageView(lessons)),
                                ],
                              )
                              : Column(
                                children: [
                                  _buildCompactLessonStrip(lessons),
                                  const SizedBox(height: 8),
                                  Expanded(child: _buildPageView(lessons)),
                                ],
                              ),
                    ),
                  ),
                  _buildFooter(
                    l10n,
                    lessons.length,
                    compact: isCompactLandscape,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    AppLocalizations l10n,
    int lessonCount, {
    required bool compact,
  }) {
    return Padding(
      padding:
          compact
              ? const EdgeInsets.fromLTRB(12, 8, 12, 3)
              : const EdgeInsets.fromLTRB(20, 18, 20, 5),
      child: CityGlassPanel(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 7 : 12,
          vertical: compact ? 5 : 10,
        ),
        radius: compact ? 16 : 22,
        child: Row(
          children: [
            _buildBackButton(compact: compact),
            SizedBox(width: compact ? 11 : 16),
            Container(
              width: compact ? 36 : 42,
              height: compact ? 36 : 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A756F), Color(0xFF1B4B5B)],
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFF9AF1E8),
              ),
            ),
            SizedBox(width: compact ? 10 : 13),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.howToPlay,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 17 : 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 3),
                    Text(
                      lessonsSummary(l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 9 : 12,
                vertical: compact ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF172640),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: const Color(0x6635D5C5)),
              ),
              child: Text(
                '${_currentPage + 1} / $lessonCount',
                style: const TextStyle(
                  color: Color(0xFFFFD86B),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String lessonsSummary(AppLocalizations l10n) {
    return '${l10n.tutorialRollMove}  ·  ${l10n.tutorialBuyProperties}  ·  ${l10n.tutorialWinGame}';
  }

  Widget _buildBackButton({required bool compact}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onBack,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: compact ? 38 : 46,
          height: compact ? 38 : 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF243657), Color(0xFF162541)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x555F91B5)),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildLessonRail(
    List<_TutorialLesson> lessons,
    AppLocalizations l10n,
  ) {
    return CityGlassPanel(
      padding: const EdgeInsets.all(11),
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 5, 7, 9),
            child: CitySectionLabel(
              icon: Icons.route_rounded,
              label: l10n.howToPlay,
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: lessons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder:
                  (context, index) => _buildLessonButton(
                    lesson: lessons[index],
                    index: index,
                    horizontal: false,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLessonStrip(List<_TutorialLesson> lessons) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: lessons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder:
            (context, index) => SizedBox(
              width: 152,
              child: _buildLessonButton(
                lesson: lessons[index],
                index: index,
                horizontal: true,
              ),
            ),
      ),
    );
  }

  Widget _buildLessonButton({
    required _TutorialLesson lesson,
    required int index,
    required bool horizontal,
  }) {
    final isSelected = index == _currentPage;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('tutorial-lesson-$index'),
        onTap: () => _goToPage(index),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(
            horizontal: horizontal ? 10 : 11,
            vertical: horizontal ? 7 : 11,
          ),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? LinearGradient(
                      colors: [
                        lesson.color.withValues(alpha: 0.42),
                        const Color(0xFF172640),
                      ],
                    )
                    : null,
            color: isSelected ? null : const Color(0x7A22314B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  isSelected
                      ? lesson.color.withValues(alpha: 0.85)
                      : Colors.white10,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: horizontal ? 30 : 36,
                height: horizontal ? 30 : 36,
                decoration: BoxDecoration(
                  color: lesson.color.withValues(
                    alpha: isSelected ? 0.24 : 0.11,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  lesson.icon,
                  color: isSelected ? lesson.color : Colors.white54,
                  size: horizontal ? 17 : 20,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}',
                      style: TextStyle(
                        color:
                            isSelected
                                ? lesson.color
                                : Colors.white.withValues(alpha: 0.4),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      lesson.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontSize: horizontal ? 11 : 12,
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (!horizontal && isSelected)
                Icon(
                  Icons.chevron_right_rounded,
                  color: lesson.color,
                  size: 19,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageView(List<_TutorialLesson> lessons) {
    return PageView.builder(
      key: const Key('tutorial-page-view'),
      controller: _pageController,
      itemCount: lessons.length,
      onPageChanged: (index) => setState(() => _currentPage = index),
      itemBuilder:
          (context, index) => _buildLessonCard(
            lesson: lessons[index],
            index: index,
            total: lessons.length,
          ),
    );
  }

  Widget _buildLessonCard({
    required _TutorialLesson lesson,
    required int index,
    required int total,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useSideBySide =
              constraints.maxWidth >= 590 && constraints.maxHeight >= 150;
          final useCompactCopy = constraints.maxHeight < 320;
          final visual = _buildLessonVisual(lesson);
          final copy = _buildLessonCopy(
            lesson,
            index,
            total,
            compact: useCompactCopy,
          );

          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xF2182741), Color(0xF20A1426)],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: lesson.color.withValues(alpha: 0.58)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x73000000),
                  blurRadius: 26,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            padding: EdgeInsets.all(useSideBySide ? 22 : 14),
            child:
                useSideBySide
                    ? Row(
                      children: [
                        Expanded(flex: 10, child: visual),
                        const SizedBox(width: 24),
                        Expanded(flex: 11, child: copy),
                      ],
                    )
                    : Column(
                      children: [
                        Expanded(flex: 11, child: visual),
                        const SizedBox(height: 12),
                        Flexible(flex: 8, child: copy),
                      ],
                    ),
          );
        },
      ),
    );
  }

  Widget _buildLessonCopy(
    _TutorialLesson lesson,
    int index,
    int total, {
    required bool compact,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: lesson.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: lesson.color.withValues(alpha: 0.35)),
            ),
            child: Text(
              '${index + 1} / $total',
              style: TextStyle(
                color: lesson.color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 13),
        ],
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            lesson.title,
            maxLines: 1,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 24 : 30,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(height: compact ? 7 : 13),
        Text(
          lesson.description.replaceAll('\n', ' '),
          maxLines: compact ? 3 : 4,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFFC8D6E2),
            fontSize: compact ? 13.5 : 17,
            height: compact ? 1.3 : 1.45,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLessonVisual(_TutorialLesson lesson) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            lesson.color.withValues(alpha: 0.28),
            const Color(0xFF0A1830),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: lesson.color.withValues(alpha: 0.32)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: [
            Positioned(
              right: -26,
              top: -32,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: lesson.color.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -38,
              bottom: -52,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: lesson.color.withValues(alpha: 0.12),
                    width: 18,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 360,
                  height: 220,
                  child: _buildVisualContent(lesson),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualContent(_TutorialLesson lesson) {
    return switch (lesson.visual) {
      _TutorialVisual.roll => _buildRollVisual(lesson.color),
      _TutorialVisual.buy => _buildBuyVisual(lesson.color),
      _TutorialVisual.rent => _buildRentVisual(lesson.color),
      _TutorialVisual.special => _buildSpecialVisual(lesson.color),
      _TutorialVisual.win => _buildWinVisual(lesson.color),
    };
  }

  Widget _buildRollVisual(Color color) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDie('⚄', color),
              const SizedBox(width: 12),
              _buildDie('⚂', color),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(7, (index) {
              final active = index <= 4;
              return Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: index == 4 ? 30 : 16,
                    height: index == 4 ? 30 : 16,
                    decoration: BoxDecoration(
                      color:
                          active ? color : Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child:
                        index == 4
                            ? const Icon(
                              Icons.person_pin_circle_rounded,
                              color: Color(0xFF071427),
                              size: 21,
                            )
                            : null,
                  ),
                  if (index < 6)
                    Container(
                      width: 10,
                      height: 2,
                      color:
                          active
                              ? color.withValues(alpha: 0.72)
                              : Colors.white12,
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDie(String face, Color color) {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color, width: 3),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 18),
        ],
      ),
      child: Text(
        face,
        style: const TextStyle(
          color: Color(0xFF142039),
          fontSize: 43,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildBuyVisual(Color color) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPropertyCard(color),
          const SizedBox(width: 18),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(
                  Icons.add_home_work_rounded,
                  color: Color(0xFF142039),
                  size: 32,
                ),
              ),
              const SizedBox(height: 9),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF142039),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: color),
                ),
                child: Text(
                  r'$220',
                  style: TextStyle(color: color, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Color color) {
    return Container(
      width: 118,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 16)],
      ),
      child: Column(
        children: [
          Container(
            height: 34,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
            ),
          ),
          Expanded(
            child: Icon(Icons.apartment_rounded, color: color, size: 58),
          ),
          Container(
            height: 20,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF20304F),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRentVisual(Color color) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPlayerMarker(const Color(0xFF59B8F5), Icons.person_rounded),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_forward_rounded, color: color, size: 36),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    r'$40',
                    style: TextStyle(
                      color: Color(0xFF142039),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildPlayerMarker(color, Icons.home_rounded),
        ],
      ),
    );
  }

  Widget _buildPlayerMarker(Color color, IconData icon) {
    return Container(
      width: 78,
      height: 94,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, color: color, size: 45),
    );
  }

  Widget _buildSpecialVisual(Color color) {
    const tiles = [
      ('?', Color(0xFFF3A43B)),
      ('🚂', Color(0xFF536B94)),
      ('🚔', Color(0xFFE2A94A)),
      ('★', Color(0xFFB991EE)),
    ];
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        spacing: 11,
        runSpacing: 11,
        children:
            tiles
                .map(
                  (tile) => Container(
                    width: 88,
                    height: 88,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tile.$2.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: tile.$2, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: tile.$2.withValues(alpha: 0.2),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Text(
                      tile.$1,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: tile.$1.length == 1 ? 36 : 31,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildWinVisual(Color color) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.38), blurRadius: 26),
              ],
            ),
            child: Icon(Icons.emoji_events_rounded, color: color, size: 70),
          ),
          const SizedBox(height: 17),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCoin(const Color(0xFFF2C452), r'$'),
              const SizedBox(width: 8),
              _buildCoin(const Color(0xFF35D5C5), '✓'),
              const SizedBox(width: 8),
              _buildCoin(const Color(0xFF73D6A7), r'$'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoin(Color color, String label) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white70),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF142039),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildFooter(
    AppLocalizations l10n,
    int lessonCount, {
    required bool compact,
  }) {
    final isFirst = _currentPage == 0;
    final isLast = _currentPage == lessonCount - 1;

    return Padding(
      padding:
          compact
              ? const EdgeInsets.fromLTRB(12, 3, 12, 8)
              : const EdgeInsets.fromLTRB(20, 8, 20, 18),
      child: Container(
        padding: EdgeInsets.all(compact ? 6 : 9),
        decoration: BoxDecoration(
          color: const Color(0xF20A1426),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x596B9CB8)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x73000000),
              blurRadius: 22,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 500;
            return Row(
              children: [
                SizedBox(
                  width: narrow ? 48 : 150,
                  child: _buildFooterButton(
                    key: const Key('tutorial-previous-button'),
                    icon: Icons.arrow_back_rounded,
                    label: l10n.previous,
                    enabled: !isFirst,
                    compact: compact || narrow,
                    iconOnly: narrow,
                    onTap: () => _goToPage(_currentPage - 1),
                  ),
                ),
                SizedBox(width: narrow ? 8 : 12),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(lessonCount, (index) {
                      final selected = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: selected ? 22 : 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color:
                              selected
                                  ? const Color(0xFF35D5C5)
                                  : Colors.white24,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(width: narrow ? 8 : 12),
                Expanded(
                  flex: narrow ? 2 : 1,
                  child: _buildFooterButton(
                    key:
                        isLast
                            ? const Key('tutorial-finish-button')
                            : const Key('tutorial-next-button'),
                    icon:
                        isLast
                            ? Icons.rocket_launch_rounded
                            : Icons.arrow_forward_rounded,
                    label: isLast ? l10n.letsPlay : l10n.next,
                    enabled: true,
                    primary: true,
                    compact: compact || narrow,
                    onTap:
                        isLast
                            ? widget.onBack
                            : () => _goToPage(_currentPage + 1),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooterButton({
    required Key key,
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    required bool compact,
    bool primary = false,
    bool iconOnly = false,
  }) {
    final foreground = primary ? const Color(0xFF122039) : Colors.white;
    return Opacity(
      opacity: enabled ? 1 : 0.38,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: key,
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 16,
              vertical: compact ? 9 : 13,
            ),
            decoration: BoxDecoration(
              gradient:
                  primary
                      ? const LinearGradient(
                        colors: [Color(0xFFFFD86B), Color(0xFFF1AD35)],
                      )
                      : const LinearGradient(
                        colors: [Color(0xFF243657), Color(0xFF162541)],
                      ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    primary ? const Color(0xFFFFE6A1) : const Color(0x555F91B5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!primary || iconOnly) ...[
                  Icon(icon, color: foreground, size: 19),
                  if (!iconOnly) const SizedBox(width: 7),
                ],
                if (!iconOnly)
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground,
                        fontSize: compact ? 13 : 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                if (primary && !iconOnly) ...[
                  const SizedBox(width: 8),
                  Icon(icon, color: foreground, size: 19),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _TutorialVisual { roll, buy, rent, special, win }

class _TutorialLesson {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final _TutorialVisual visual;

  const _TutorialLesson({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.visual,
  });
}
