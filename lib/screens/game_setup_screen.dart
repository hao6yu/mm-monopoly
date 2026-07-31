import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/player.dart';
import '../models/avatar.dart';
import '../models/country.dart';
import '../models/city_board.dart';
import '../config/city_board_registry.dart';
import '../config/constants.dart' hide Offset;
import '../widgets/avatar/avatar_selector.dart';
import '../widgets/avatar/avatar_widget.dart';
import '../widgets/city_theme/city_theme.dart';

/// Game setup screen for configuring players before starting
class GameSetupScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(List<PlayerConfig>, {int diceCount, CityBoard cityBoard})
  onStartGame;

  const GameSetupScreen({
    super.key,
    required this.onBack,
    required this.onStartGame,
  });

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen>
    with SingleTickerProviderStateMixin {
  int _playerCount = 2;
  int _diceCount = 2;
  Country _selectedCountry = Country.usa;
  CityBoard _selectedCityBoard = CityBoardRegistry.defaultForCountry(
    Country.usa,
  );
  final List<PlayerConfig> _playerConfigs = [];
  final List<TextEditingController> _nameControllers = [];
  final ScrollController _setupScrollController = ScrollController();
  int _currentStep = 0;
  late AnimationController _floatController;
  bool _didInitConfigs = false;

  static const List<Color> _availableColors = [
    Color(0xFFFF6B6B), // Coral Red
    Color(0xFF4ECDC4), // Teal
    Color(0xFF45B7D1), // Sky Blue
    Color(0xFFFFBE0B), // Yellow
    Color(0xFFFF006E), // Pink
    Color(0xFF8338EC), // Purple
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitConfigs) {
      _didInitConfigs = true;
      _initializeConfigs();
    }
  }

  void _initializeConfigs() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    _nameControllers.clear();
    _playerConfigs.clear();

    for (int i = 0; i < _playerCount; i++) {
      final name = AppLocalizations.of(context)!.playerN(i + 1);
      _playerConfigs.add(
        PlayerConfig(
          name: name,
          color: _availableColors[i % _availableColors.length],
          icon: PlayerIcon.values[i % PlayerIcon.values.length],
          isAI: false,
          avatar: Avatars.forPlayerIndex(i),
        ),
      );
      _nameControllers.add(TextEditingController(text: name));
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _setupScrollController.dispose();
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updatePlayerCount(int count) {
    setState(() {
      _playerCount = count;
      _initializeConfigs();
    });
  }

  void _nextStep() {
    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
    } else {
      if (_validateConfigs()) {
        widget.onStartGame(
          _playerConfigs,
          diceCount: _diceCount,
          cityBoard: _selectedCityBoard,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      widget.onBack();
    }
  }

  bool _validateConfigs() {
    final names = _playerConfigs.map((c) => c.name.trim()).toSet();
    if (names.length != _playerConfigs.length) {
      _showError(AppLocalizations.of(context)!.uniqueNameError);
      return false;
    }
    if (_playerConfigs.any((c) => c.name.trim().isEmpty)) {
      _showError(AppLocalizations.of(context)!.allPlayersNeedName);
      return false;
    }
    final colors = _playerConfigs.map((c) => c.color.toARGB32()).toSet();
    if (colors.length != _playerConfigs.length) {
      _showError(AppLocalizations.of(context)!.uniqueColorError);
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071427),
      body: CityThemeBackground(
        animation: _floatController,
        imageAsset: 'assets/images/home_city_dusk.jpg',
        imageAlignment: const Alignment(0.08, 0),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressIndicator(),
              Expanded(
                child:
                    _currentStep == 0
                        ? _buildPlayerCountStep()
                        : _buildPlayerConfigStep(),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final screenSize = MediaQuery.sizeOf(context);
    final isCompactLandscape =
        screenSize.width > screenSize.height && screenSize.height < 500;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding:
          isCompactLandscape
              ? const EdgeInsets.fromLTRB(12, 8, 12, 3)
              : const EdgeInsets.fromLTRB(20, 18, 20, 5),
      child: CityGlassPanel(
        padding: EdgeInsets.symmetric(
          horizontal: isCompactLandscape ? 7 : 12,
          vertical: isCompactLandscape ? 5 : 10,
        ),
        radius: isCompactLandscape ? 16 : 22,
        child: Row(
          children: [
            _buildBackButton(compact: isCompactLandscape),
            SizedBox(width: isCompactLandscape ? 11 : 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentStep == 0 ? l10n.gameSetupTitle : l10n.playerSetup,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isCompactLandscape ? 17 : 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (!isCompactLandscape) ...[
                    const SizedBox(height: 3),
                    Text(
                      _currentStep == 0
                          ? l10n.gameSetupSubtitle
                          : l10n.playerSetupSubtitle,
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
            SizedBox(width: isCompactLandscape ? 8 : 12),
            _buildHeaderStepBadge(compact: isCompactLandscape),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStepBadge({required bool compact}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF172640),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0x6635D5C5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFFFFD86B),
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            '${_currentStep + 1} / 2',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton({bool compact = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _previousStep,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: compact ? 38 : 48,
          height: compact ? 38 : 48,
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

  Widget _buildProgressIndicator() {
    final screenSize = MediaQuery.sizeOf(context);
    if (screenSize.width > screenSize.height && screenSize.height < 500) {
      return const SizedBox(height: 4);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 7, 20, 8),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 540),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xD90A1426),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x3D8CB4CC)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStepIndicator(
                  0,
                  AppLocalizations.of(context)!.chooseBoard,
                  Icons.map_rounded,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _buildStepIndicator(
                  1,
                  AppLocalizations.of(context)!.playerSetup,
                  Icons.groups_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isSelected = _currentStep == step;
    final isComplete = _currentStep > step;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        gradient:
            isSelected
                ? const LinearGradient(
                  colors: [Color(0xFF1C786F), Color(0xFF185A61)],
                )
                : null,
        color: isSelected ? null : const Color(0x4DFFFFFF),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isSelected ? const Color(0xFF6BE2D7) : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color:
                  isSelected || isComplete
                      ? const Color(0xFF35D5C5)
                      : Colors.white12,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isComplete ? Icons.check_rounded : icon,
              size: 14,
              color:
                  isSelected || isComplete
                      ? const Color(0xFF071427)
                      : Colors.white54,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCountStep() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        final isLandscape = availableWidth > availableHeight;
        final isCompact = availableHeight < 500 || availableWidth < 500;

        if (isLandscape) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 7, bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 11,
                      child: _buildDestinationPanel(isCompact: true),
                    ),
                    const SizedBox(width: 14),
                    Expanded(flex: 9, child: _buildRulesPanel(isCompact: true)),
                  ],
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Scrollbar(
            controller: _setupScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _setupScrollController,
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                children: [
                  SizedBox(height: isCompact ? 6 : 12),
                  _buildDestinationPanel(isCompact: isCompact),
                  SizedBox(height: isCompact ? 10 : 14),
                  _buildRulesPanel(isCompact: isCompact),
                  SizedBox(height: isCompact ? 10 : 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDestinationPanel({required bool isCompact}) {
    final l10n = AppLocalizations.of(context)!;
    return _buildSectionContainer(
      key: const Key('setup-destination-panel'),
      isCompact: isCompact,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelHeading(
            icon: Icons.location_city_rounded,
            title: l10n.chooseBoard,
            value:
                '${_selectedCountry.flag} ${_selectedCityBoard.localizedDisplayName(l10n)}',
          ),
          SizedBox(height: isCompact ? 12 : 18),
          _buildCountrySection(isCompact: isCompact),
          SizedBox(height: isCompact ? 12 : 18),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          SizedBox(height: isCompact ? 12 : 18),
          _buildCitySection(isCompact: isCompact),
        ],
      ),
    );
  }

  Widget _buildRulesPanel({required bool isCompact}) {
    final l10n = AppLocalizations.of(context)!;
    return _buildSectionContainer(
      key: const Key('setup-rules-panel'),
      isCompact: isCompact,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelHeading(
            icon: Icons.tune_rounded,
            title: l10n.setupStep,
            value:
                '$_playerCount ${l10n.players} · ${_diceCount == 1 ? l10n.oneDie : l10n.twoDice}',
          ),
          SizedBox(height: isCompact ? 12 : 18),
          _buildPlayersSection(isCompact: isCompact),
          SizedBox(height: isCompact ? 12 : 18),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          SizedBox(height: isCompact ? 12 : 18),
          _buildDiceSection(isCompact: isCompact),
        ],
      ),
    );
  }

  Widget _buildPanelHeading({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2A756F), Color(0xFF1B4B5B)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF9AF1E8), size: 21),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFAEC4D5),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionContainer({
    Key? key,
    required Widget child,
    required bool isCompact,
    double borderRadius = 24,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 14 : 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xF2182741), Color(0xF20A1426)],
        ),
        borderRadius: BorderRadius.circular(borderRadius + 2),
        border: Border.all(color: const Color(0x596B9CB8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x73000000),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCountrySection({required bool isCompact}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CitySectionLabel(
          icon: Icons.public_rounded,
          label: AppLocalizations.of(context)!.chooseBoard,
        ),
        SizedBox(height: isCompact ? 9 : 13),
        ..._buildCountryRows(isCompact),
      ],
    );
  }

  List<Widget> _buildCountryRows(bool isCompact) {
    final countries = Country.values;
    final columns = MediaQuery.sizeOf(context).width < 500 ? 2 : 3;
    final List<Widget> rows = [];
    for (int rowStart = 0; rowStart < countries.length; rowStart += columns) {
      final rowEnd = (rowStart + columns).clamp(0, countries.length);
      final rowCountries = countries.sublist(rowStart, rowEnd);
      if (rowStart > 0) rows.add(SizedBox(height: isCompact ? 6 : 8));
      rows.add(
        Row(
          children: [
            for (int i = 0; i < rowCountries.length; i++) ...[
              if (i > 0) SizedBox(width: isCompact ? 6 : 8),
              Expanded(child: _buildCountryCard(rowCountries[i], isCompact)),
            ],
            // Keep the final row aligned with the selected column count.
            for (int i = rowCountries.length; i < columns; i++) ...[
              SizedBox(width: isCompact ? 6 : 8),
              const Expanded(child: SizedBox()),
            ],
          ],
        ),
      );
    }
    return rows;
  }

  Widget _buildCountryCard(Country country, bool isCompact) {
    final isSelected = _selectedCountry == country;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap:
            () => setState(() {
              _selectedCountry = country;
              _selectedCityBoard = CityBoardRegistry.defaultForCountry(country);
            }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            vertical: isCompact ? 9 : 11,
            horizontal: isCompact ? 8 : 10,
          ),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? const LinearGradient(
                      colors: [Color(0xFF247C73), Color(0xFF185963)],
                    )
                    : null,
            color: isSelected ? null : const Color(0x8F22314B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFF6BE2D7) : Colors.white12,
              width: isSelected ? 2 : 1,
            ),
            boxShadow:
                isSelected
                    ? const [
                      BoxShadow(
                        color: Color(0x4535D5C5),
                        blurRadius: 13,
                        offset: Offset(0, 5),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            children: [
              Text(
                country.flag,
                style: TextStyle(fontSize: isCompact ? 20 : 24),
              ),
              SizedBox(width: isCompact ? 7 : 9),
              Expanded(
                child: Text(
                  country.localizedDisplayName(AppLocalizations.of(context)!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 11 : 13,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF9AF1E8),
                  size: 17,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCitySection({required bool isCompact}) {
    final cities = CityBoardRegistry.forCountry(_selectedCountry);
    final isNarrow = MediaQuery.sizeOf(context).width < 500;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CitySectionLabel(
          icon: Icons.place_rounded,
          label: AppLocalizations.of(context)!.chooseCity,
          color: const Color(0xFFFFD86B),
        ),
        SizedBox(height: isCompact ? 9 : 13),
        if (isNarrow)
          SizedBox(
            height: isCompact ? 58 : 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cities.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder:
                  (_, index) => SizedBox(
                    width: 150,
                    child: _buildCityCard(cities[index], isCompact),
                  ),
            ),
          )
        else
          Row(
            children: [
              for (var index = 0; index < cities.length; index++) ...[
                if (index > 0) const SizedBox(width: 8),
                Expanded(child: _buildCityCard(cities[index], isCompact)),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildCityCard(CityBoard city, bool isCompact) {
    final isSelected = _selectedCityBoard == city;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _selectedCityBoard = city),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: isCompact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? const LinearGradient(
                      colors: [Color(0xFFF2C452), Color(0xFFD98B2D)],
                    )
                    : null,
            color: isSelected ? null : const Color(0x8F22314B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFFFFE6A1) : Colors.white12,
              width: isSelected ? 2 : 1,
            ),
            boxShadow:
                isSelected
                    ? const [
                      BoxShadow(
                        color: Color(0x55F1AD35),
                        blurRadius: 13,
                        offset: Offset(0, 5),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color(0x24FFFFFF)
                          : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  city.emoji,
                  style: TextStyle(fontSize: isCompact ? 16 : 18),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  city.localizedDisplayName(AppLocalizations.of(context)!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF15213A) : Colors.white,
                    fontSize: isCompact ? 11 : 12,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF15213A),
                  size: 17,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersSection({required bool isCompact}) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CitySectionLabel(
          icon: Icons.groups_rounded,
          label: l10n.numberOfPlayers,
        ),
        SizedBox(height: isCompact ? 9 : 13),
        Row(
          children: List.generate(GameConstants.maxPlayers - 1, (index) {
            final count = index + 2;
            final isSelected = _playerCount == count;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _updatePlayerCount(count),
                    child: AnimatedContainer(
                      key: Key('setup-player-count-$count'),
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        vertical: isCompact ? 10 : 14,
                        horizontal: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient:
                            isSelected
                                ? const LinearGradient(
                                  colors: [
                                    Color(0xFFF2C452),
                                    Color(0xFFD98B2D),
                                  ],
                                )
                                : null,
                        color: isSelected ? null : const Color(0x8F22314B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isSelected
                                  ? const Color(0xFFFFE6A1)
                                  : Colors.white12,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow:
                            isSelected
                                ? const [
                                  BoxShadow(
                                    color: Color(0x55F1AD35),
                                    blurRadius: 14,
                                    offset: Offset(0, 6),
                                  ),
                                ]
                                : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            count == 2
                                ? Icons.people_alt_rounded
                                : Icons.groups_rounded,
                            color:
                                isSelected
                                    ? const Color(0xFF15213A)
                                    : Colors.white70,
                            size: isCompact ? 20 : 24,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$count',
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? const Color(0xFF15213A)
                                      : Colors.white,
                              fontSize: isCompact ? 25 : 31,
                              height: 1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            l10n.players,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? const Color(0xCC15213A)
                                      : Colors.white54,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDiceSection({required bool isCompact}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CitySectionLabel(
          icon: Icons.casino_rounded,
          label: AppLocalizations.of(context)!.numberOfDice,
          color: const Color(0xFFFFD86B),
        ),
        SizedBox(height: isCompact ? 9 : 13),
        Row(
          children: [
            Expanded(
              child: _buildDiceCard(
                1,
                '🎲',
                AppLocalizations.of(context)!.oneDie,
                AppLocalizations.of(context)!.classicStyle,
                const Color(0xFF35D5C5),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDiceCard(
                2,
                '🎲🎲',
                AppLocalizations.of(context)!.twoDice,
                AppLocalizations.of(context)!.standardRules,
                const Color(0xFFF2C452),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiceCard(
    int count,
    String emoji,
    String label,
    String subtitle,
    Color color,
  ) {
    final isSelected = _diceCount == count;
    final foreground =
        isSelected ? const Color(0xFF15213A) : const Color(0xFFF3F7FB);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _diceCount = count),
        child: AnimatedContainer(
          key: Key('setup-dice-count-$count'),
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? LinearGradient(
                      colors: [color, color.withValues(alpha: 0.76)],
                    )
                    : null,
            color: isSelected ? null : const Color(0x8F22314B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isSelected ? color.withValues(alpha: 0.95) : Colors.white12,
              width: isSelected ? 2 : 1,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 25)),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground.withValues(alpha: 0.7),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: foreground, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerConfigStep() {
    final count = _playerConfigs.length;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 2x2 grid for 4 players, 2 columns for 2-3 players
          if (count == 4) {
            return Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildPlayerCard(0)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildPlayerCard(1)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildPlayerCard(2)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildPlayerCard(3)),
                    ],
                  ),
                ),
              ],
            );
          } else if (count == 3) {
            return Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildPlayerCard(0)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildPlayerCard(1)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Expanded(flex: 2, child: _buildPlayerCard(2)),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // 2 players - side by side
            return Row(
              children: [
                Expanded(child: _buildPlayerCard(0)),
                const SizedBox(width: 10),
                Expanded(child: _buildPlayerCard(1)),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildPlayerCard(int index) {
    final config = _playerConfigs[index];
    final screenSize = MediaQuery.sizeOf(context);
    final isCompactLandscape =
        screenSize.width > screenSize.height && screenSize.height < 500;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            config.color.withValues(alpha: 0.3),
            const Color(0xFF101C33).withValues(alpha: 0.96),
            const Color(0xFF071223).withValues(alpha: 0.96),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: config.color.withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: config.color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isCompactLandscape ? 6 : 12),
        child: Column(
          children: [
            // Header row: Player number + AI toggle
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        config.color,
                        config.color.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'P${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (index == 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.you,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.ai,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 28,
                        child: Transform.scale(
                          scale: 0.7,
                          child: Switch(
                            value: config.isAI,
                            onChanged:
                                (value) => setState(
                                  () =>
                                      _playerConfigs[index] = config.copyWith(
                                        isAI: value,
                                      ),
                                ),
                            activeThumbColor: const Color(0xFF4ECDC4),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            SizedBox(height: isCompactLandscape ? 1 : 4),

            // Avatar - centered and tappable, fills available space
            Expanded(
              child: GestureDetector(
                onTap: () => _showAvatarSelector(index),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Use most of the available space for the avatar
                    final avatarSize = (constraints.maxHeight * 0.85).clamp(
                      isCompactLandscape ? 38.0 : 60.0,
                      isCompactLandscape ? 88.0 : 140.0,
                    );
                    return Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: config.color.withValues(alpha: 0.6),
                                  blurRadius: 20,
                                  spreadRadius: 6,
                                ),
                              ],
                            ),
                            child: AvatarWidget(
                              avatar:
                                  config.avatar ??
                                  Avatars.forPlayerIndex(index),
                              size: avatarSize,
                              borderColor: config.color,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    config.color,
                                    config.color.withValues(alpha: 0.7),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: isCompactLandscape ? 1 : 4),

            // Name input
            SizedBox(
              height: isCompactLandscape ? 34 : 44,
              child: TextField(
                controller: _nameControllers[index],
                onChanged:
                    (value) =>
                        _playerConfigs[index] = config.copyWith(name: value),
                onTap: () {
                  // Select all text when tapped so kids can easily replace the default name
                  _nameControllers[index].selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _nameControllers[index].text.length,
                  );
                },
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isCompactLandscape ? 14 : 16,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.name,
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: config.color, width: 2),
                  ),
                ),
              ),
            ),

            SizedBox(height: isCompactLandscape ? 4 : 10),

            // Color selector row
            LayoutBuilder(
              builder: (context, constraints) {
                final dotSize =
                    ((constraints.maxWidth / _availableColors.length) - 6)
                        .clamp(18.0, 28.0);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      _availableColors.map((color) {
                        final isSelected = config.color == color;
                        final isUsed = _playerConfigs
                            .where((c) => c != config)
                            .any((c) => c.color == color);
                        return GestureDetector(
                          onTap:
                              isUsed
                                  ? null
                                  : () => setState(
                                    () =>
                                        _playerConfigs[index] = config.copyWith(
                                          color: color,
                                        ),
                                  ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: dotSize,
                            height: dotSize,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withValues(alpha: 0.7)],
                              ),
                              shape: BoxShape.circle,
                              border:
                                  isSelected
                                      ? Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      )
                                      : null,
                              boxShadow:
                                  isSelected
                                      ? [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.6),
                                          blurRadius: 8,
                                        ),
                                      ]
                                      : null,
                            ),
                            child:
                                isUsed && !isSelected
                                    ? Icon(
                                      Icons.close,
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      size: dotSize * 0.5,
                                    )
                                    : isSelected
                                    ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: dotSize * 0.58,
                                    )
                                    : null,
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarSelector(int playerIndex) {
    final config = _playerConfigs[playerIndex];
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    if (isLandscape) {
      // Use dialog for landscape mode - better use of horizontal space
      showDialog(
        context: context,
        builder:
            (context) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 24,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: screenSize.width * 0.8,
                  maxHeight: screenSize.height * 0.85,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1B3150), Color(0xFF081426)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: ShaderMask(
                              shaderCallback:
                                  (bounds) => const LinearGradient(
                                    colors: [Colors.white, Color(0xFFFFE66D)],
                                  ).createShader(bounds),
                              child: Text(
                                AppLocalizations.of(context)!.chooseYourAvatar,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: AvatarSelector(
                          selectedAvatar: config.avatar,
                          onAvatarSelected: (avatar) {
                            setState(
                              () =>
                                  _playerConfigs[playerIndex] = config.copyWith(
                                    avatar: avatar,
                                  ),
                            );
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );
    } else {
      // Use bottom sheet for portrait mode
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder:
            (context) => DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder:
                  (context, scrollController) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1B3150), Color(0xFF081426)],
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: ShaderMask(
                            shaderCallback:
                                (bounds) => const LinearGradient(
                                  colors: [Colors.white, Color(0xFFFFE66D)],
                                ).createShader(bounds),
                            child: Text(
                              AppLocalizations.of(context)!.chooseYourAvatar,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: AvatarSelector(
                            selectedAvatar: config.avatar,
                            onAvatarSelected: (avatar) {
                              setState(
                                () =>
                                    _playerConfigs[playerIndex] = config
                                        .copyWith(avatar: avatar),
                              );
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
      );
    }
  }

  Widget _buildNavigationButtons() {
    final screenSize = MediaQuery.sizeOf(context);
    final isCompactLandscape =
        screenSize.width > screenSize.height && screenSize.height < 500;
    final isWide = screenSize.width >= 720;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding:
          isCompactLandscape
              ? const EdgeInsets.fromLTRB(12, 3, 12, 8)
              : const EdgeInsets.fromLTRB(20, 8, 20, 18),
      child: Container(
        key: const Key('setup-summary'),
        padding: EdgeInsets.all(isCompactLandscape ? 6 : 9),
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
        child: Row(
          children: [
            if (isWide)
              SizedBox(
                width: 138,
                child: _buildNavigationAction(
                  icon: Icons.arrow_back_rounded,
                  label: _currentStep == 0 ? l10n.back : l10n.previous,
                  onTap: _previousStep,
                  compact: isCompactLandscape,
                ),
              )
            else
              Expanded(
                child: _buildNavigationAction(
                  icon: Icons.arrow_back_rounded,
                  label: _currentStep == 0 ? l10n.back : l10n.previous,
                  onTap: _previousStep,
                  compact: isCompactLandscape,
                ),
              ),
            if (!isWide) const SizedBox(width: 9),
            if (isWide) ...[
              const SizedBox(width: 14),
              Expanded(child: _buildGameSummary()),
              const SizedBox(width: 14),
            ],
            if (isWide)
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 230, maxWidth: 280),
                child: _buildNavigationAction(
                  icon:
                      _currentStep == 0
                          ? Icons.arrow_forward_rounded
                          : Icons.rocket_launch_rounded,
                  label: _currentStep == 0 ? l10n.next : l10n.startGame,
                  onTap: _nextStep,
                  primary: true,
                  compact: isCompactLandscape,
                ),
              )
            else
              Expanded(
                child: _buildNavigationAction(
                  icon:
                      _currentStep == 0
                          ? Icons.arrow_forward_rounded
                          : Icons.rocket_launch_rounded,
                  label: _currentStep == 0 ? l10n.next : l10n.startGame,
                  onTap: _nextStep,
                  primary: true,
                  compact: isCompactLandscape,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameSummary() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentStep == 0 ? l10n.gameSummary : l10n.readyToPlay,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF8CEDE2),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${_selectedCountry.flag} ${_selectedCityBoard.localizedDisplayName(l10n)}  ·  $_playerCount ${l10n.players}  ·  ${_diceCount == 1 ? l10n.oneDie : l10n.twoDice}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool primary = false,
    bool compact = false,
  }) {
    final foreground = primary ? const Color(0xFF122039) : Colors.white;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 11 : 16,
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
              if (!primary) ...[
                Icon(icon, color: foreground, size: 19),
                const SizedBox(width: 7),
              ],
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
              if (primary) ...[
                const SizedBox(width: 8),
                Icon(icon, color: foreground, size: 19),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Configuration for a player before game starts
class PlayerConfig {
  final String name;
  final Color color;
  final PlayerIcon icon;
  final bool isAI;
  final Avatar? avatar;

  const PlayerConfig({
    required this.name,
    required this.color,
    required this.icon,
    required this.isAI,
    this.avatar,
  });

  PlayerConfig copyWith({
    String? name,
    Color? color,
    PlayerIcon? icon,
    bool? isAI,
    Avatar? avatar,
  }) {
    return PlayerConfig(
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isAI: isAI ?? this.isAI,
      avatar: avatar ?? this.avatar,
    );
  }
}
