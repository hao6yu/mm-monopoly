import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../services/audio_service.dart';
import '../services/game_content_loader.dart';
import '../services/locale_service.dart';
import '../utils/currency_utils.dart';
import '../widgets/city_theme/city_theme.dart';

/// Settings for the shared 2D and 3D game experience.
class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final GameSettings settings;
  final ValueChanged<GameSettings> onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.onBack,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late GameSettings _settings;
  late final AnimationController _worldController;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
    _worldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _worldController.dispose();
    super.dispose();
  }

  void _updateSettings(GameSettings newSettings) {
    setState(() => _settings = newSettings);
    widget.onSettingsChanged(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF071427),
      body: CityThemeBackground(
        animation: _worldController,
        imageAsset: 'assets/images/home_city_dusk.jpg',
        imageAlignment: const Alignment(0.08, 0),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compactLandscape =
                  constraints.maxWidth > constraints.maxHeight &&
                  constraints.maxHeight < 500;
              final horizontalPadding = compactLandscape ? 12.0 : 20.0;

              return Column(
                children: [
                  _buildHeader(l10n, compact: compactLandscape),
                  Expanded(
                    child: SingleChildScrollView(
                      key: const Key('settings-scroll-view'),
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        compactLandscape ? 4 : 9,
                        horizontalPadding,
                        compactLandscape ? 6 : 12,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1120),
                          child: LayoutBuilder(
                            builder: (context, contentConstraints) {
                              final useColumns =
                                  contentConstraints.maxWidth >= 720;
                              final leftColumn = Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildStartingCashPanel(l10n),
                                  const SizedBox(height: 14),
                                  _buildGameOptionsPanel(l10n),
                                ],
                              );
                              final rightColumn = Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildSoundAndLanguagePanel(l10n),
                                  const SizedBox(height: 14),
                                  _buildSupportPanel(l10n),
                                ],
                              );

                              if (useColumns) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: leftColumn),
                                    const SizedBox(width: 16),
                                    Expanded(child: rightColumn),
                                  ],
                                );
                              }

                              return Column(
                                children: [
                                  leftColumn,
                                  const SizedBox(height: 14),
                                  rightColumn,
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildFooter(l10n, compact: compactLandscape),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, {required bool compact}) {
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
        accent: const Color(0xFF35D5C5),
        child: Row(
          children: [
            _buildHeaderBackButton(compact: compact),
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
              child: const Icon(Icons.tune_rounded, color: Color(0xFF9AF1E8)),
            ),
            SizedBox(width: compact ? 10 : 13),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settings,
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
                      l10n.settingsSubtitle,
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
              child: const Icon(
                Icons.apartment_rounded,
                color: Color(0xFFFFD86B),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBackButton({required bool compact}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('settings-header-back-button'),
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

  Widget _buildStartingCashPanel(AppLocalizations l10n) {
    return CityGlassPanel(
      padding: const EdgeInsets.all(18),
      radius: 22,
      accent: const Color(0xFFF2C452),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CitySectionLabel(
            icon: Icons.account_balance_wallet_rounded,
            label: l10n.startingCash,
            color: const Color(0xFFFFD86B),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0x24FFD86B),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0x66FFD86B)),
                ),
                child: Text(
                  CurrencyUtils.symbolForLocale(
                    Localizations.localeOf(context),
                  ),
                  style: const TextStyle(
                    color: Color(0xFFFFD86B),
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0x40FFD86B), Color(0x1AF1AD35)],
                  ),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0x80FFD86B)),
                ),
                child: Text(
                  CurrencyUtils.format(context, _settings.startingCash),
                  key: const Key('settings-starting-cash-value'),
                  style: const TextStyle(
                    color: Color(0xFFFFD86B),
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFFF2C452),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
              thumbColor: const Color(0xFFFFD86B),
              overlayColor: const Color(0x26FFD86B),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
            ),
            child: Slider(
              key: const Key('settings-starting-cash-slider'),
              value: _settings.startingCash.toDouble(),
              min: 500,
              max: 3000,
              divisions: 10,
              onChanged:
                  (value) => _updateSettings(
                    _settings.copyWith(startingCash: value.toInt()),
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CurrencyUtils.format(context, 500),
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  CurrencyUtils.format(context, 3000),
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOptionsPanel(AppLocalizations l10n) {
    return CityGlassPanel(
      padding: const EdgeInsets.all(14),
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 4, 5, 8),
            child: CitySectionLabel(
              icon: Icons.dashboard_customize_rounded,
              label: l10n.gameOptions,
            ),
          ),
          _buildSettingTile(
            key: const Key('settings-trading-tile'),
            switchKey: const Key('settings-trading-switch'),
            icon: Icons.swap_horiz_rounded,
            label: l10n.playerTrading,
            value: _settings.tradingEnabled,
            onChanged:
                (value) =>
                    _updateSettings(_settings.copyWith(tradingEnabled: value)),
          ),
          const SizedBox(height: 8),
          _buildSettingTile(
            key: const Key('settings-bank-tile'),
            switchKey: const Key('settings-bank-switch'),
            icon: Icons.account_balance_rounded,
            label: l10n.bankFeatures,
            value: _settings.bankEnabled,
            onChanged:
                (value) =>
                    _updateSettings(_settings.copyWith(bankEnabled: value)),
          ),
          const SizedBox(height: 8),
          _buildSettingTile(
            key: const Key('settings-auction-tile'),
            switchKey: const Key('settings-auction-switch'),
            icon: Icons.gavel_rounded,
            label: l10n.propertyAuctions,
            value: _settings.auctionEnabled,
            onChanged:
                (value) =>
                    _updateSettings(_settings.copyWith(auctionEnabled: value)),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundAndLanguagePanel(AppLocalizations l10n) {
    return CityGlassPanel(
      padding: const EdgeInsets.all(14),
      radius: 22,
      accent: const Color(0xFF59B8F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 4, 5, 8),
            child: CitySectionLabel(
              icon: Icons.spatial_audio_off_rounded,
              label: l10n.soundAndLanguage,
              color: const Color(0xFF8ED2FF),
            ),
          ),
          _buildSettingTile(
            key: const Key('settings-music-tile'),
            switchKey: const Key('settings-music-switch'),
            icon: Icons.music_note_rounded,
            label: l10n.backgroundMusic,
            value: _settings.musicEnabled,
            color: const Color(0xFF59B8F5),
            onChanged: (value) {
              _updateSettings(_settings.copyWith(musicEnabled: value));
              AudioService.instance.setMusicEnabled(value);
            },
          ),
          const SizedBox(height: 8),
          _buildSettingTile(
            key: const Key('settings-sfx-tile'),
            switchKey: const Key('settings-sfx-switch'),
            icon: Icons.volume_up_rounded,
            label: l10n.gameSounds,
            value: _settings.sfxEnabled,
            color: const Color(0xFF59B8F5),
            onChanged: (value) {
              _updateSettings(_settings.copyWith(sfxEnabled: value));
              AudioService.instance.setSfxEnabled(value);
            },
          ),
          const SizedBox(height: 8),
          _buildLanguageTile(l10n),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required Key key,
    required Key switchKey,
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color color = const Color(0xFF35D5C5),
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: key,
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color:
                value ? color.withValues(alpha: 0.12) : const Color(0x7A22314B),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: value ? color.withValues(alpha: 0.55) : Colors.white10,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: value ? 0.22 : 0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: value ? color : Colors.white54,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: value ? Colors.white : Colors.white70,
                    fontSize: 14,
                    fontWeight: value ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              Switch.adaptive(
                key: switchKey,
                value: value,
                onChanged: onChanged,
                activeTrackColor: color.withValues(alpha: 0.5),
                activeThumbColor: color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile(AppLocalizations l10n) {
    final localeService = LocaleService.instance;
    return ValueListenableBuilder<Locale>(
      valueListenable: localeService.localeNotifier,
      builder: (context, _, __) {
        final selectedCode = localeService.selectedCode;
        final dropdown = Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF172640),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x6659B8F5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: const Key('settings-language-dropdown'),
              value: selectedCode,
              isExpanded: true,
              isDense: true,
              dropdownColor: const Color(0xFF172640),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF8ED2FF),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              items: [
                DropdownMenuItem(
                  value: LocaleService.systemLocaleCode,
                  child: Text(
                    localeService.getDisplayName(
                      LocaleService.systemLocaleCode,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ...LocaleService.supportedLocales.map(
                  (locale) => DropdownMenuItem(
                    value: locale.languageCode,
                    child: Text(
                      localeService.getDisplayName(locale.languageCode),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (code) {
                if (code == null) return;
                GameContentLoader.instance.clearCache();
                if (code == LocaleService.systemLocaleCode) {
                  localeService.setSystemLocale();
                } else {
                  localeService.setLocale(Locale(code));
                }
              },
            ),
          ),
        );

        return Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0x7A22314B),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white10),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 360;
              final label = Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0x1859B8F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      color: Color(0xFF8ED2FF),
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.language,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              );

              if (stacked) {
                return Column(
                  children: [
                    label,
                    const SizedBox(height: 9),
                    SizedBox(width: double.infinity, child: dropdown),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: label),
                  const SizedBox(width: 12),
                  SizedBox(width: 175, child: dropdown),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSupportPanel(AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('settings-support-button'),
        onTap: () => _showExternalLinkDialog(context),
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xE629251D), Color(0xE6161D2C)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0x80FFD86B)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x59000000),
                blurRadius: 22,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0x24FFD86B),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text('☕', style: TextStyle(fontSize: 27)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.buyMeACoffee,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.buyMeACoffeeDesc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.open_in_new_rounded,
                color: Color(0xFFFFD86B),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n, {required bool compact}) {
    return Padding(
      padding:
          compact
              ? const EdgeInsets.fromLTRB(12, 3, 12, 8)
              : const EdgeInsets.fromLTRB(20, 6, 20, 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
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
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    key: const Key('settings-reset-button'),
                    icon: Icons.restart_alt_rounded,
                    label: l10n.reset,
                    compact: compact,
                    onTap: () => _resetSettings(l10n),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _buildActionButton(
                    key: const Key('settings-done-button'),
                    icon: Icons.arrow_back_rounded,
                    label: l10n.backToMenu,
                    compact: compact,
                    primary: true,
                    onTap: widget.onBack,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required Key key,
    required IconData icon,
    required String label,
    required bool compact,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    final foreground = primary ? const Color(0xFF122039) : Colors.white;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 9 : 14,
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
              Icon(icon, color: foreground, size: 19),
              const SizedBox(width: 8),
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
            ],
          ),
        ),
      ),
    );
  }

  void _resetSettings(AppLocalizations l10n) {
    const defaults = GameSettings();
    _updateSettings(defaults);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.settingsReset,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFF208F83),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showExternalLinkDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => Dialog(
            backgroundColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: CityGlassPanel(
                accent: const Color(0xFFF2C452),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0x24FFD86B),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('☕', style: TextStyle(fontSize: 31)),
                    ),
                    const SizedBox(height: 17),
                    Text(
                      l10n.openExternalLink,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.openBuyMeACoffeeDesc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDialogButton(
                            label: l10n.cancel,
                            onTap: () => Navigator.of(dialogContext).pop(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDialogButton(
                            label: l10n.open,
                            primary: true,
                            onTap: () async {
                              Navigator.of(dialogContext).pop();
                              await launchUrl(
                                Uri.parse('https://buymeacoffee.com/hao_yu'),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildDialogButton({
    required String label,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            color: primary ? const Color(0xFFFFD86B) : const Color(0xFF20304F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primary ? const Color(0xFFFFE6A1) : Colors.white24,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: primary ? const Color(0xFF122039) : Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

/// Game settings shared across menu setup and active games.
class GameSettings {
  final int startingCash;
  final bool tradingEnabled;
  final bool bankEnabled;
  final bool auctionEnabled;
  final bool musicEnabled;
  final bool sfxEnabled;
  final double musicVolume;
  final double sfxVolume;

  const GameSettings({
    this.startingCash = 2000,
    this.tradingEnabled = false,
    this.bankEnabled = false,
    this.auctionEnabled = false,
    this.musicEnabled = true,
    this.sfxEnabled = true,
    this.musicVolume = 0.5,
    this.sfxVolume = 0.7,
  });

  GameSettings copyWith({
    int? startingCash,
    bool? tradingEnabled,
    bool? bankEnabled,
    bool? auctionEnabled,
    bool? musicEnabled,
    bool? sfxEnabled,
    double? musicVolume,
    double? sfxVolume,
  }) {
    return GameSettings(
      startingCash: startingCash ?? this.startingCash,
      tradingEnabled: tradingEnabled ?? this.tradingEnabled,
      bankEnabled: bankEnabled ?? this.bankEnabled,
      auctionEnabled: auctionEnabled ?? this.auctionEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
    );
  }
}
