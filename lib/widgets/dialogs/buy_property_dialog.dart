import 'package:flutter/material.dart';
import '../../models/tile.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import 'animated_dialog.dart';
import '../effects/confetti.dart';

enum BuyPropertyDecision { buy, skip }

/// Dialog for buying a property
class BuyPropertyDialog extends StatelessWidget {
  final TileData tile;
  final int playerCash;
  final int? purchasePrice;

  const BuyPropertyDialog({
    super.key,
    required this.tile,
    required this.playerCash,
    this.purchasePrice,
  });

  int get _price {
    if (purchasePrice != null) return purchasePrice!;
    if (tile is PropertyTileData) return (tile as PropertyTileData).price;
    if (tile is RailroadTileData) return (tile as RailroadTileData).price;
    if (tile is UtilityTileData) return (tile as UtilityTileData).price;
    return 0;
  }

  int get _baseRent {
    if (tile is PropertyTileData) {
      return (tile as PropertyTileData).rentLevels.first;
    }
    if (tile is RailroadTileData) return 25;
    if (tile is UtilityTileData) return 0; // Depends on dice
    return 0;
  }

  Color? get _color {
    if (tile is PropertyTileData) return (tile as PropertyTileData).groupColor;
    return null;
  }

  bool get _canAfford => playerCash >= _price;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height - mediaQuery.padding.vertical - 32;
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: 350, maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                key: const Key('buy-property-content-scroll'),
                child: _buildContent(context),
              ),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _color ?? AppTheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        children: [
          const Icon(Icons.home, color: Colors.white, size: 40),
          const SizedBox(height: 8),
          Text(
            tile.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            l10n.propertyAvailable,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Fun fact section
          if (tile.funFact != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tile.funFact!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          _buildInfoRow(l10n.price, '\$$_price', AppTheme.warning),
          const SizedBox(height: 8),
          if (tile is! UtilityTileData)
            _buildInfoRow(l10n.baseRent, '\$$_baseRent', AppTheme.cashGreen),
          if (tile is UtilityTileData)
            _buildInfoRow(l10n.rent, l10n.utilityRentDesc, AppTheme.cashGreen),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.yourCash,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '\$$playerCash',
                  style: TextStyle(
                    color: _canAfford ? AppTheme.cashGreen : AppTheme.error,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (!_canAfford) ...[
            const SizedBox(height: 12),
            Text(
              l10n.notEnoughCash,
              style: const TextStyle(
                color: AppTheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final useStacked =
        MediaQuery.sizeOf(context).height < 520 ||
        MediaQuery.textScalerOf(context).scale(1) > 1.2;
    final skipButton = OutlinedButton(
      onPressed: () => Navigator.of(context).pop(BuyPropertyDecision.skip),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white70,
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(l10n.skip, style: const TextStyle(fontSize: 16)),
    );
    final buyButton = Builder(
      builder: (buttonContext) => ElevatedButton(
        onPressed: _canAfford
            ? () {
                final box = buttonContext.findRenderObject() as RenderBox?;
                if (box != null) {
                  final position = box.localToGlobal(
                    Offset(box.size.width / 2, box.size.height / 2),
                  );
                  ConfettiManager.show(
                    context,
                    position: position,
                    primaryColor: _color ?? AppTheme.cashGreen,
                  );
                }
                Navigator.of(context).pop(BuyPropertyDecision.buy);
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.cashGreen,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          l10n.buyForAmount('$_price'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: useStacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [buyButton, const SizedBox(height: 8), skipButton],
            )
          : Row(
              children: [
                Expanded(child: skipButton),
                const SizedBox(width: 12),
                Expanded(child: buyButton),
              ],
            ),
    );
  }
}

/// Show the buy property dialog with animation
Future<BuyPropertyDecision?> showBuyPropertyDialog({
  required BuildContext context,
  required TileData tile,
  required int playerCash,
  int? purchasePrice,
}) {
  return showAnimatedDialog<BuyPropertyDecision>(
    context: context,
    barrierDismissible: false,
    animationType: DialogAnimationType.scale,
    builder: (context) => BuyPropertyDialog(
      tile: tile,
      playerCash: playerCash,
      purchasePrice: purchasePrice,
    ),
  );
}
