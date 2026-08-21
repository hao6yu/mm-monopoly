import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import 'animated_dialog.dart';

/// Type of rent being paid - affects how the calculation is displayed
enum RentType {
  property,   // Standard property rent
  railroad,   // Railroad rent (depends on count owned)
  utility,    // Utility rent (depends on dice roll)
}

/// Dialog showing rent payment
class RentPaymentDialog extends StatelessWidget {
  final String propertyName;
  final int amount;
  final Player owner;
  final Player payer;
  final bool isBankruptcy;
  final VoidCallback onConfirm;
  final RentType rentType;
  final int? diceRoll;        // For utilities: the dice roll used
  final int? ownedCount;      // For utilities/railroads: count owned by owner

  const RentPaymentDialog({
    super.key,
    required this.propertyName,
    required this.amount,
    required this.owner,
    required this.payer,
    this.isBankruptcy = false,
    required this.onConfirm,
    this.rentType = RentType.property,
    this.diceRoll,
    this.ownedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isBankruptcy ? AppTheme.error : Colors.white24,
            width: 2,
          ),
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
            _buildHeader(context),
            _buildContent(context),
            _buildAction(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isBankruptcy ? AppTheme.error : owner.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        children: [
          Icon(
            isBankruptcy ? Icons.warning : Icons.attach_money,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            isBankruptcy ? l10n.bankruptcy : l10n.payRent,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
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
            l10n.landedOnProperty(propertyName),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Owner info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: owner.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    owner.effectiveAvatar.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                owner.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.ownsThisProperty,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          // Amount with calculation breakdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  l10n.rentDue,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$$amount',
                  style: TextStyle(
                    color: isBankruptcy ? AppTheme.error : AppTheme.warning,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Show calculation breakdown for utilities and railroads
                if (rentType == RentType.utility && diceRoll != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.casino, color: Colors.amber, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          l10n.diceRentCalc(diceRoll!, ownedCount == 2 ? 10 : 4, amount),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ownedCount == 2 ? l10n.ownerHasBothUtilities : l10n.ownerHasOneUtility,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
                if (rentType == RentType.railroad && ownedCount != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.train, color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          l10n.ownerHasRailroads(ownedCount!, ownedCount! > 1 ? 's' : ''),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isBankruptcy) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.error),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppTheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.bankruptMessage,
                      style: TextStyle(
                        color: AppTheme.error.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAction(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isBankruptcy ? AppTheme.error : AppTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isBankruptcy ? l10n.acceptBankruptcy : l10n.payAmount(amount),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

/// Show the rent payment dialog with slide-up animation
Future<void> showRentPaymentDialog({
  required BuildContext context,
  required String propertyName,
  required int amount,
  required Player owner,
  required Player payer,
  bool isBankruptcy = false,
  required VoidCallback onConfirm,
  RentType rentType = RentType.property,
  int? diceRoll,
  int? ownedCount,
}) {
  return showAnimatedDialog(
    context: context,
    barrierDismissible: false,
    animationType: DialogAnimationType.slideUp,
    builder: (context) => RentPaymentDialog(
      propertyName: propertyName,
      amount: amount,
      owner: owner,
      payer: payer,
      isBankruptcy: isBankruptcy,
      onConfirm: onConfirm,
      rentType: rentType,
      diceRoll: diceRoll,
      ownedCount: ownedCount,
    ),
  );
}
