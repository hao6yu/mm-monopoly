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
    final colors = _playerConfigs.map((c) => c.color.value).toSet();
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
    return Padding(
      padding:
          isCompactLandscape
              ? const EdgeInsets.fromLTRB(10, 6, 10, 2)
              : const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: CityGlassPanel(
        padding: EdgeInsets.symmetric(
          horizontal: isCompactLandscape ? 6 : 10,
          vertical: isCompactLandscape ? 4 : 8,
        ),
        radius: isCompactLandscape ? 14 : 18,
        child: Row(
          children: [
            _buildBackButton(compact: isCompactLandscape),
            SizedBox(width: isCompactLandscape ? 10 : 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCompactLandscape) ...[
                    CitySectionLabel(
                      icon:
                          _currentStep == 0
                              ? Icons.public_rounded
                              : Icons.groups_rounded,
                      label:
                          _currentStep == 0
                              ? AppLocalizations.of(context)!.chooseBoard
                              : AppLocalizations.of(context)!.setupStep,
                    ),
                    const SizedBox(height: 3),
                  ],
                  Text(
                    _currentStep == 0
                        ? AppLocalizations.of(context)!.howManyPlayers
                        : AppLocalizations.of(context)!.playerSetup,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isCompactLandscape ? 16 : 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompactLandscape ? 9 : 12,
                vertical: isCompactLandscape ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2B48),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x5535D5C5)),
              ),
              child: Text(
                '${_currentStep + 1}/2',
                style: const TextStyle(
                  color: Color(0xFFFFD86B),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          _buildStepIndicator(0, AppLocalizations.of(context)!.playersStep),
          Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color:
                    _currentStep >= 1
                        ? const Color(0xFF4ECDC4)
                        : Colors.white.withOpacity(0.3),
              ),
            ),
          ),
          _buildStepIndicator(1, AppLocalizations.of(context)!.setupStep),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    final color =
        isActive ? const Color(0xFF4ECDC4) : Colors.white.withOpacity(0.5);
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color : Colors.white.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
            boxShadow:
                isActive
                    ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                    : null,
          ),
          child: Center(
            child:
                isActive
                    ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    )
                    : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCountStep() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        final isLandscape = availableWidth > availableHeight;
        final isCompact = availableHeight < 500;

        // In landscape, use a two-column layout
        if (isLandscape) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column: Board + City
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildCountrySection(isCompact: true),
                          const SizedBox(height: 8),
                          _buildCitySection(isCompact: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right column: Players + Dice
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildPlayersSection(isCompact: true),
                          const SizedBox(height: 8),
                          _buildDiceSection(isCompact: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Portrait layout - single column, scrollable
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: isCompact ? 8 : 16),
                _buildCountrySection(isCompact: isCompact),
                SizedBox(height: isCompact ? 6 : 10),
                _buildCitySection(isCompact: isCompact),
                SizedBox(height: isCompact ? 6 : 10),
                _buildPlayersSection(isCompact: isCompact),
                SizedBox(height: isCompact ? 8 : 16),
                _buildDiceSection(isCompact: isCompact),
                SizedBox(height: isCompact ? 8 : 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionContainer({
    required Widget child,
    required bool isCompact,
    double borderRadius = 24,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 12 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF14223B).withOpacity(0.95),
            const Color(0xFF091426).withOpacity(0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0x665F91B5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCountrySection({required bool isCompact}) {
    return _buildSectionContainer(
      isCompact: isCompact,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🌍', style: TextStyle(fontSize: isCompact ? 18 : 24)),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.chooseBoard,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isCompact ? 15 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 8 : 16),
          ..._buildCountryRows(isCompact),
        ],
      ),
    );
  }

  List<Widget> _buildCountryRows(bool isCompact) {
    final countries = Country.values;
    final List<Widget> rows = [];
    for (int rowStart = 0; rowStart < countries.length; rowStart += 3) {
      final rowEnd = (rowStart + 3).clamp(0, countries.length);
      final rowCountries = countries.sublist(rowStart, rowEnd);
      if (rowStart > 0) rows.add(SizedBox(height: isCompact ? 6 : 8));
      rows.add(
        Row(
          children: [
            for (int i = 0; i < rowCountries.length; i++) ...[
              if (i > 0) SizedBox(width: isCompact ? 6 : 8),
              Expanded(child: _buildCountryCard(rowCountries[i], isCompact)),
            ],
            // Fill remaining space if row has < 3 items
            for (int i = rowCountries.length; i < 3; i++) ...[
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
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
    ];
    final color = colors[country.index % colors.length];
    return GestureDetector(
      onTap:
          () => setState(() {
            _selectedCountry = country;
            _selectedCityBoard = CityBoardRegistry.defaultForCountry(country);
          }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 8 : 10,
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? LinearGradient(colors: [color, color.withOpacity(0.7)])
                  : null,
          color: isSelected ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: isSelected ? 3 : 2,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(country.flag, style: TextStyle(fontSize: isCompact ? 22 : 28)),
            SizedBox(width: isCompact ? 6 : 8),
            Flexible(
              child: Text(
                country.localizedDisplayName(AppLocalizations.of(context)!),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isCompact ? 12 : 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCitySection({required bool isCompact}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 16,
        vertical: isCompact ? 8 : 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF14223B).withOpacity(0.95),
            const Color(0xFF091426).withOpacity(0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x665F91B5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🏙️', style: TextStyle(fontSize: isCompact ? 14 : 16)),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.chooseCity,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isCompact ? 13 : 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 6 : 8),
          Row(
            children:
                CityBoardRegistry.forCountry(_selectedCountry).map((city) {
                  final isSelected = _selectedCityBoard == city;
                  final color = const Color(0xFFFFBE0B);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCityBoard = city),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            vertical: isCompact ? 8 : 10,
                          ),
                          decoration: BoxDecoration(
                            gradient:
                                isSelected
                                    ? LinearGradient(
                                      colors: [color, color.withOpacity(0.7)],
                                    )
                                    : null,
                            color:
                                isSelected
                                    ? null
                                    : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? color : Colors.white24,
                              width: isSelected ? 2.5 : 1.5,
                            ),
                            boxShadow:
                                isSelected
                                    ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                    : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                city.emoji,
                                style: TextStyle(fontSize: isCompact ? 14 : 16),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  city.localizedDisplayName(
                                    AppLocalizations.of(context)!,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isCompact ? 11 : 13,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersSection({required bool isCompact}) {
    return _buildSectionContainer(
      isCompact: isCompact,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_alt_rounded,
                color: Colors.white70,
                size: isCompact ? 20 : 24,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppLocalizations.of(context)!.numberOfPlayers,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isCompact ? 15 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 10 : 20),
          IntrinsicHeight(
            child: Row(
              children: List.generate(GameConstants.maxPlayers - 1, (index) {
                final count = index + 2;
                final isSelected = _playerCount == count;
                final colors = [
                  const Color(0xFFFF6B6B),
                  const Color(0xFF4ECDC4),
                  const Color(0xFFFFE66D),
                ];
                final color = colors[index % colors.length];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 0 : 6,
                      right: index == 2 ? 0 : 6,
                    ),
                    child: GestureDetector(
                      onTap: () => _updatePlayerCount(count),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          vertical: isCompact ? 10 : 16,
                        ),
                        decoration: BoxDecoration(
                          gradient:
                              isSelected
                                  ? LinearGradient(
                                    colors: [color, color.withOpacity(0.7)],
                                  )
                                  : null,
                          color:
                              isSelected ? null : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? color : Colors.white24,
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.5),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isCompact ? 32 : 48,
                              fontWeight: FontWeight.bold,
                              shadows:
                                  isSelected
                                      ? [
                                        const Shadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(1, 1),
                                        ),
                                      ]
                                      : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiceSection({required bool isCompact}) {
    return _buildSectionContainer(
      isCompact: isCompact,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🎲', style: TextStyle(fontSize: isCompact ? 16 : 20)),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.numberOfDice,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isCompact ? 14 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 8 : 12),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildDiceCard(
                    1,
                    '🎲',
                    AppLocalizations.of(context)!.oneDie,
                    AppLocalizations.of(context)!.classicStyle,
                    const Color(0xFF95E1D3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDiceCard(
                    2,
                    '🎲🎲',
                    AppLocalizations.of(context)!.twoDice,
                    AppLocalizations.of(context)!.standardRules,
                    const Color(0xFFFFB347),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
    return GestureDetector(
      onTap: () => setState(() => _diceCount = count),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? LinearGradient(colors: [color, color.withOpacity(0.7)])
                  : null,
          color: isSelected ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: isSelected ? 3 : 2,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 36))),
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
            config.color.withOpacity(0.3),
            const Color(0xFF101C33).withOpacity(0.96),
            const Color(0xFF071223).withOpacity(0.96),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color.withOpacity(0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: config.color.withOpacity(0.3),
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
                      colors: [config.color, config.color.withOpacity(0.7)],
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
                          color: Colors.white.withOpacity(0.7),
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
                            activeColor: const Color(0xFF4ECDC4),
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
                                  color: config.color.withOpacity(0.6),
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
                                    config.color.withOpacity(0.7),
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
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2),
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
                                colors: [color, color.withOpacity(0.7)],
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
                                          color: color.withOpacity(0.6),
                                          blurRadius: 8,
                                        ),
                                      ]
                                      : null,
                            ),
                            child:
                                isUsed && !isSelected
                                    ? Icon(
                                      Icons.close,
                                      color: Colors.white.withOpacity(0.5),
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
                            color: Colors.white.withOpacity(0.3),
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
    return Padding(
      padding:
          isCompactLandscape
              ? const EdgeInsets.fromLTRB(10, 4, 10, 7)
              : const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _previousStep,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: isCompactLandscape ? 10 : 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF243657), Color(0xFF162541)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x555F91B5)),
                  ),
                  child: Center(
                    child: Text(
                      _currentStep == 0
                          ? AppLocalizations.of(context)!.back
                          : AppLocalizations.of(context)!.previous,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _nextStep,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: isCompactLandscape ? 10 : 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD86B), Color(0xFFF1AD35)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFE6A1)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55F1AD35),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _currentStep == 0
                          ? AppLocalizations.of(context)!.next
                          : AppLocalizations.of(context)!.startGame,
                      style: const TextStyle(
                        color: Color(0xFF122039),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
