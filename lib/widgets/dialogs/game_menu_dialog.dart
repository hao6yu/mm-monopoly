import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

enum GameMenuAction { resume, save, load, rules, restart, quit }

typedef GameMenuCallback = FutureOr<void> Function();

/// In-game menu that remains active while nested confirmations are shown.
class GameMenuDialog extends StatelessWidget {
  final bool canSave;
  final bool canLoad;
  final bool canShowRules;

  const GameMenuDialog({
    super.key,
    this.canSave = false,
    this.canLoad = false,
    this.canShowRules = false,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final compactHeight = mediaQuery.size.height < 520;
    final availableHeight =
        mediaQuery.size.height - mediaQuery.padding.vertical - 24;

    return SafeArea(
      minimum: const EdgeInsets.all(12),
      child: Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: compactHeight ? 640 : 360,
            maxHeight: availableHeight.clamp(240, double.infinity),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF17355D), Color(0xFF10233F)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF35D5CF).withValues(alpha: 0.45),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.38),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context, compact: compactHeight),
                Flexible(
                  child: _buildMenuItems(context, compact: compactHeight),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required bool compact}) {
    final l10n = AppLocalizations.of(context)!;
    final icon = Container(
      width: compact ? 40 : 56,
      height: compact ? 40 : 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.sports_esports_rounded,
        color: Colors.white,
        size: compact ? 24 : 32,
      ),
    );
    final title = Text(
      l10n.gameMenu,
      style: TextStyle(
        color: Colors.white,
        fontSize: compact ? 20 : 24,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
    );

    return Container(
      width: double.infinity,
      padding: compact
          ? const EdgeInsets.symmetric(vertical: 12, horizontal: 18)
          : const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17BEBB), Color(0xFF0B8E91)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: compact
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [icon, const SizedBox(width: 12), title],
            )
          : Column(children: [icon, const SizedBox(height: 12), title]),
    );
  }

  Widget _buildMenuItems(BuildContext context, {required bool compact}) {
    final l10n = AppLocalizations.of(context)!;
    final items = <_GameMenuItem>[
      _GameMenuItem(
        icon: Icons.play_arrow_rounded,
        label: l10n.backToGame,
        colors: const [Color(0xFF4ECDC4), Color(0xFF2FA79C)],
        onTap: () => _finish(context, GameMenuAction.resume),
      ),
      if (canSave)
        _GameMenuItem(
          icon: Icons.save_rounded,
          label: l10n.saveGame,
          colors: const [Color(0xFF56CCF2), Color(0xFF2F80ED)],
          onTap: () => _finish(context, GameMenuAction.save),
        ),
      if (canLoad)
        _GameMenuItem(
          icon: Icons.folder_open_rounded,
          label: l10n.loadGame,
          colors: const [Color(0xFF8F7CF6), Color(0xFF5567D5)],
          onTap: () async {
            final confirmed = await _showConfirmDialog(
              context,
              l10n.loadSavedGame,
              l10n.currentProgressLost,
            );
            if (confirmed && context.mounted) {
              _finish(context, GameMenuAction.load);
            }
          },
        ),
      if (canShowRules)
        _GameMenuItem(
          icon: Icons.help_outline_rounded,
          label: l10n.howToPlay,
          colors: const [Color(0xFF58A6FF), Color(0xFF5567D5)],
          onTap: () => _finish(context, GameMenuAction.rules),
        ),
      _GameMenuItem(
        icon: Icons.refresh_rounded,
        label: l10n.restartGame,
        colors: const [Color(0xFFFFD166), Color(0xFFFFA62B)],
        onTap: () async {
          final confirmed = await _showConfirmDialog(
            context,
            '${l10n.restartGame}?',
            l10n.allProgressLost,
          );
          if (confirmed && context.mounted) {
            _finish(context, GameMenuAction.restart);
          }
        },
      ),
      _GameMenuItem(
        icon: Icons.coffee_rounded,
        label: l10n.buyMeACoffee,
        colors: const [Color(0xFFFFA07A), Color(0xFFFF7C5C)],
        onTap: () => _showExternalLinkDialog(context),
      ),
      _GameMenuItem(
        icon: Icons.exit_to_app_rounded,
        label: l10n.quitToMenu,
        colors: const [Color(0xFFFF6B6B), Color(0xFFEE4D5A)],
        onTap: () async {
          final confirmed = await _showConfirmDialog(
            context,
            l10n.quitGame,
            l10n.allProgressLost,
          );
          if (confirmed && context.mounted) {
            _finish(context, GameMenuAction.quit);
          }
        },
      ),
    ];

    final textScale = MediaQuery.textScalerOf(context).scale(1);
    if (compact && textScale <= 1.3) {
      return GridView.builder(
        key: const Key('game-menu-grid'),
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 58,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) =>
            _buildMenuItem(items[index], compact: true),
      );
    }

    return ListView.separated(
      key: const Key('game-menu-list'),
      padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildMenuItem(items[index]),
    );
  }

  Widget _buildMenuItem(_GameMenuItem item, {bool compact = false}) {
    return Semantics(
      button: true,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: compact
                ? const EdgeInsets.symmetric(horizontal: 10, vertical: 7)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF081B33).withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: compact ? 36 : 44,
                  height: compact ? 36 : 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: item.colors),
                    borderRadius: BorderRadius.circular(compact ? 10 : 12),
                  ),
                  child: Icon(
                    item.icon,
                    color: Colors.white,
                    size: compact ? 21 : 24,
                  ),
                ),
                SizedBox(width: compact ? 10 : 16),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: compact ? 2 : null,
                    overflow: compact ? TextOverflow.ellipsis : null,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 14 : 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!compact)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white54,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _finish(BuildContext context, GameMenuAction action) {
    Navigator.of(context).pop(action);
  }

  Future<void> _showExternalLinkDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _AdaptiveConfirmationDialog(
        icon: Icons.coffee_rounded,
        iconColor: const Color(0xFFFFD166),
        title: l10n.openExternalLink,
        message: l10n.openBuyMeACoffeeDesc,
        confirmLabel: l10n.open,
        cancelLabel: l10n.cancel,
      ),
    );
    if (shouldOpen != true) return;
    final uri = Uri.parse('https://buymeacoffee.com/hao_yu');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<bool> _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => _AdaptiveConfirmationDialog(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFFF6B6B),
            title: title,
            message: message,
            confirmLabel: l10n.confirm,
            cancelLabel: l10n.cancel,
          ),
        ) ??
        false;
  }
}

class _GameMenuItem {
  final IconData icon;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;

  const _GameMenuItem({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
  });
}

class _AdaptiveConfirmationDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  const _AdaptiveConfirmationDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF10233F),
      surfaceTintColor: Colors.transparent,
      scrollable: true,
      icon: Icon(icon, color: iconColor, size: 36),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: iconColor,
            foregroundColor:
                ThemeData.estimateBrightnessForColor(iconColor) ==
                    Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

/// Shows the pause menu and runs exactly one resulting action. Confirmations
/// stay nested above the menu, so dismissing them never resumes the game.
Future<void> showGameMenuDialog({
  required BuildContext context,
  required GameMenuCallback onClose,
  required GameMenuCallback onRestart,
  required GameMenuCallback onQuit,
  GameMenuCallback? onRules,
  GameMenuCallback? onSave,
  GameMenuCallback? onLoad,
}) async {
  final action = await showDialog<GameMenuAction>(
    context: context,
    barrierDismissible: true,
    builder: (context) => GameMenuDialog(
      canSave: onSave != null,
      canLoad: onLoad != null,
      canShowRules: onRules != null,
    ),
  );

  switch (action) {
    case GameMenuAction.save:
      await onSave?.call();
      await onClose();
    case GameMenuAction.load:
      await onLoad?.call();
      await onClose();
    case GameMenuAction.rules:
      await onClose();
      await onRules?.call();
    case GameMenuAction.restart:
      await onRestart();
    case GameMenuAction.quit:
      await onQuit();
    case GameMenuAction.resume:
    case null:
      await onClose();
  }
}
