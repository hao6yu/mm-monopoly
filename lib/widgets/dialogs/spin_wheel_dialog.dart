import 'package:flutter/material.dart';
import '../../models/spin_prize.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../spin_wheel/spin_wheel_widget.dart';
import '../effects/confetti.dart';
import 'animated_dialog.dart';
import '../../services/audio_service.dart';

/// Dialog containing the spin wheel
class SpinWheelDialog extends StatefulWidget {
  final String playerName;
  final Future<void> Function(SpinPrize) onPrizeWon;

  const SpinWheelDialog({
    super.key,
    required this.playerName,
    required this.onPrizeWon,
  });

  @override
  State<SpinWheelDialog> createState() => _SpinWheelDialogState();
}

class _SpinWheelDialogState extends State<SpinWheelDialog> {
  final GlobalKey<SpinWheelWidgetState> _wheelKey = GlobalKey();
  SpinPrize? _wonPrize;
  bool _hasSpun = false;
  bool _showResult = false;
  bool _isCollecting = false;

  void _onSpinStarted() {
    if (_hasSpun || !mounted) return;
    setState(() => _hasSpun = true);
  }

  void _onPrizeWon(SpinPrize prize) {
    if (_wonPrize != null || !mounted) return;
    AudioService.instance.onSpinResult();
    setState(() {
      _hasSpun = true;
      _wonPrize = prize;
      _showResult = true;
    });

    // Show confetti for jackpot or big prizes
    if (prize.type == SpinPrizeType.jackpot || (prize.value ?? 0) >= 200) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null) {
            final center = box.localToGlobal(
              Offset(box.size.width / 2, box.size.height / 2),
            );
            ConfettiManager.show(
              context,
              position: center,
              primaryColor: prize.color,
              particleCount: 50,
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final compactHeight = mediaQuery.size.height < 520;
    final maxHeight = mediaQuery.size.height - mediaQuery.padding.vertical - 32;
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: 380, maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(compact: compactHeight),
            Flexible(
              child: SingleChildScrollView(
                key: const Key('spin-wheel-content-scroll'),
                padding: EdgeInsets.only(
                  top: compactHeight ? 10 : 16,
                  bottom: compactHeight ? 12 : 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildWheel(size: compactHeight ? 170 : 280),
                    SizedBox(height: compactHeight ? 10 : 16),
                    if (_showResult) _buildResult() else _buildInstructions(),
                    SizedBox(height: compactHeight ? 10 : 16),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({required bool compact}) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: compact ? 10 : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.amber.shade500],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          Icon(Icons.casino, color: Colors.white, size: compact ? 26 : 36),
          SizedBox(height: compact ? 3 : 8),
          Text(
            l10n.luckySpinTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 20 : 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.playerTurnToSpin(widget.playerName),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel({required double size}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SpinWheelWidget(
        key: _wheelKey,
        prizes: SpinPrizes.all,
        onPrizeWon: _onPrizeWon,
        onSpinStarted: _onSpinStarted,
        enabled: !_hasSpun,
        size: size,
      ),
    );
  }

  Widget _buildInstructions() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        _hasSpun ? l10n.spinning : l10n.spinInstructions,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildResult() {
    final l10n = AppLocalizations.of(context)!;
    if (_wonPrize == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _wonPrize!.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _wonPrize!.color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_wonPrize!.icon, color: _wonPrize!.color, size: 32),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.youWonPrize(_wonPrize!.name),
                  style: TextStyle(
                    color: _wonPrize!.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _wonPrize!.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: _showResult
            ? ElevatedButton(
                key: const Key('spin-wheel-collect'),
                onPressed: _isCollecting ? null : _collectPrize,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _wonPrize!.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCollecting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.collectPrize,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              )
            : OutlinedButton(
                onPressed: _hasSpun
                    ? null
                    : () {
                        _onSpinStarted();
                        _wheelKey.currentState?.spin();
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.amber,
                  side: BorderSide(color: Colors.amber.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _hasSpun ? l10n.goodLuck : l10n.orTapToSpin,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
      ),
    );
  }

  Future<void> _collectPrize() async {
    final prize = _wonPrize;
    if (_isCollecting || prize == null) return;
    setState(() => _isCollecting = true);
    try {
      await widget.onPrizeWon(prize);
      if (mounted) Navigator.of(context).pop(prize);
    } finally {
      if (mounted) setState(() => _isCollecting = false);
    }
  }
}

/// Show the spin wheel dialog
Future<SpinPrize?> showSpinWheelDialog({
  required BuildContext context,
  required String playerName,
  required Future<void> Function(SpinPrize) onPrizeWon,
}) {
  return showAnimatedDialog<SpinPrize>(
    context: context,
    barrierDismissible: false,
    animationType: DialogAnimationType.scale,
    builder: (context) =>
        SpinWheelDialog(playerName: playerName, onPrizeWon: onPrizeWon),
  );
}
