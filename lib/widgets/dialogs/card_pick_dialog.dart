import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import 'animated_dialog.dart';

/// A card in the card pick dialog
class PickableCard {
  final String text;
  final String effect;
  final String action;

  const PickableCard({
    required this.text,
    required this.effect,
    required this.action,
  });
}

/// Dialog for picking a card from a fanned deck
class CardPickDialog extends StatefulWidget {
  final bool isChance;
  final List<PickableCard> cards;
  final void Function(PickableCard card) onCardPicked;

  const CardPickDialog({
    super.key,
    required this.isChance,
    required this.cards,
    required this.onCardPicked,
  });

  @override
  State<CardPickDialog> createState() => _CardPickDialogState();
}

class _CardPickDialogState extends State<CardPickDialog>
    with TickerProviderStateMixin {
  int? _selectedIndex;
  bool _canClose = false;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late AnimationController _moveController;
  late Animation<double> _moveAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Flip animation for the selected card
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );

    // Move animation to bring card to center
    _moveController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _moveAnimation = CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeOutBack,
    );

    // Scale animation to enlarge the card
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    _moveController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onCardTap(int index) async {
    if (_selectedIndex != null) return; // Already selected

    setState(() {
      _selectedIndex = index;
    });

    // Animate card to center and scale up
    _moveController.forward();
    _scaleController.forward();

    // Wait for move animation
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Flip the card
    await _flipController.forward();
    if (!mounted) return;

    // Small delay before allowing close
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() {
      _canClose = true;
    });
  }

  void _onCloseDialog() {
    if (!_canClose || _selectedIndex == null) return;

    widget.onCardPicked(widget.cards[_selectedIndex!]);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isChance ? Colors.orange : Colors.blue.shade600;
    final mediaQuery = MediaQuery.of(context);
    final compactHeight = mediaQuery.size.height < 520;
    final maxHeight = mediaQuery.size.height - mediaQuery.padding.vertical - 32;

    return GestureDetector(
      onTap: _canClose ? _onCloseDialog : null,
      behavior: HitTestBehavior.opaque,
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxWidth: 400, maxHeight: maxHeight),
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
              _buildHeader(color, compact: compactHeight),
              Flexible(
                child: SingleChildScrollView(
                  key: const Key('card-pick-content-scroll'),
                  padding: EdgeInsets.symmetric(
                    vertical: compactHeight ? 8 : 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildResponsiveCardArea(color, compact: compactHeight),
                      SizedBox(height: compactHeight ? 8 : 16),
                      _buildInstructions(),
                      if (_canClose) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              key: const Key('card-pick-continue'),
                              onPressed: _onCloseDialog,
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: Text(
                                AppLocalizations.of(context)!.continueGame,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color color, {required bool compact}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: compact ? 8 : 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        children: [
          Icon(
            widget.isChance ? Icons.help_outline : Icons.inventory_2,
            color: Colors.white,
            size: compact ? 26 : 36,
          ),
          SizedBox(height: compact ? 3 : 8),
          Text(
            widget.isChance
                ? AppLocalizations.of(context)!.chanceExcl
                : AppLocalizations.of(context)!.communityChestExcl,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 18 : 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardArea(Color color) {
    final totalCards = widget.cards.length;
    const cardSpread = 45.0; // Horizontal spacing between cards

    return SizedBox(
      height: 280,
      child: Center(
        child: SizedBox(
          width: 350, // Fixed width for card area
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Render all cards
              ...List.generate(totalCards, (index) {
                // Skip selected card here, we'll render it on top
                if (_selectedIndex == index) return const SizedBox.shrink();
                return _buildFannedCard(index, color, totalCards, cardSpread);
              }),
              // Selected card on top (always rendered last)
              if (_selectedIndex != null)
                _buildSelectedCard(
                  _selectedIndex!,
                  color,
                  totalCards,
                  cardSpread,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveCardArea(Color color, {required bool compact}) {
    final cardArea = _buildCardArea(color);
    if (!compact) return cardArea;

    return SizedBox(
      width: double.infinity,
      height: 180,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(width: 350, height: 280, child: cardArea),
      ),
    );
  }

  Widget _buildFannedCard(
    int index,
    Color color,
    int totalCards,
    double cardSpread,
  ) {
    final middleIndex = (totalCards - 1) / 2;
    final offset = index - middleIndex;
    final angle = offset * 0.12; // Rotation angle
    final xOffset = offset * cardSpread;
    final yOffset = (offset.abs() * 8).toDouble(); // Arc effect

    // Fade out other cards when one is selected
    final opacity = _selectedIndex != null ? 0.3 : 1.0;

    return Positioned(
      left: 175 + xOffset - 50, // Center (175) + offset - half card width
      top: 30 + yOffset,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: opacity,
        child: Semantics(
          button: true,
          label:
              '${widget.isChance ? AppLocalizations.of(context)!.chance : AppLocalizations.of(context)!.chestShort} ${index + 1}',
          child: GestureDetector(
            onTap: _selectedIndex == null ? () => _onCardTap(index) : null,
            behavior: HitTestBehavior.opaque,
            child: Transform.rotate(
              angle: angle,
              child: _buildCardBack(color, false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedCard(
    int index,
    Color color,
    int totalCards,
    double cardSpread,
  ) {
    final middleIndex = (totalCards - 1) / 2;
    final offset = index - middleIndex;
    final startAngle = offset * 0.12;
    final startXOffset = offset * cardSpread;
    final startYOffset = (offset.abs() * 8).toDouble();

    return AnimatedBuilder(
      animation: Listenable.merge([
        _moveAnimation,
        _flipAnimation,
        _scaleAnimation,
      ]),
      builder: (context, child) {
        // Interpolate position from fan to center
        final currentXOffset = startXOffset * (1 - _moveAnimation.value);
        final currentYOffset = startYOffset * (1 - _moveAnimation.value);
        final currentAngle = startAngle * (1 - _moveAnimation.value);
        final currentScale = _scaleAnimation.value;

        final flipValue = _flipAnimation.value;
        final isShowingFront = flipValue > 0.5;

        return Positioned(
          left: 175 + currentXOffset - 50, // Center + offset - half card width
          top: 30 + currentYOffset,
          child: Transform.rotate(
            angle: currentAngle,
            child: Transform.scale(
              scale: currentScale,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(flipValue * pi),
                child: isShowingFront
                    ? _buildCardFront(index, color)
                    : _buildCardBack(color, true),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardBack(Color color, bool isSelected) {
    return Container(
      width: 100,
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? Colors.amber
              : Colors.white.withValues(alpha: 0.5),
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Colors.amber.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.3),
            blurRadius: isSelected ? 15 : 8,
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Pattern on card back
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomPaint(
                painter: _CardBackPatternPainter(color: color),
              ),
            ),
          ),
          // Center icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.isChance ? Icons.question_mark : Icons.card_giftcard,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          // Shimmer effect for selected card
          if (isSelected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.2),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardFront(int index, Color color) {
    final card = widget.cards[index];

    // Mirror the content since the card is flipped
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: Container(
        width: 100,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(9),
                ),
              ),
              child: Text(
                widget.isChance
                    ? AppLocalizations.of(context)!.chance
                    : AppLocalizations.of(context)!.chestShort,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card.text,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: card.effect.startsWith('+')
                            ? Colors.green.withValues(alpha: 0.2)
                            : card.effect.startsWith('-')
                            ? Colors.red.withValues(alpha: 0.2)
                            : Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        card.effect,
                        style: TextStyle(
                          color: card.effect.startsWith('+')
                              ? Colors.green.shade700
                              : card.effect.startsWith('-')
                              ? Colors.red.shade700
                              : Colors.blue.shade700,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    if (_canClose) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Text(
              '👆 ${AppLocalizations.of(context)!.tapToContinue}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.amber,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (_selectedIndex != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          '✨ ${AppLocalizations.of(context)!.revealingCard} ✨',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.amber,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        '👆 ${AppLocalizations.of(context)!.tapCardToPick}',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 16,
        ),
      ),
    );
  }
}

/// Custom painter for card back pattern
class _CardBackPatternPainter extends CustomPainter {
  final Color color;

  _CardBackPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw diagonal lines pattern
    const spacing = 8.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    // Draw border decoration
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final borderRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
      const Radius.circular(6),
    );
    canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Show the card pick dialog
Future<void> showCardPickDialog({
  required BuildContext context,
  required bool isChance,
  required List<PickableCard> cards,
  required void Function(PickableCard card) onCardPicked,
}) {
  return showAnimatedDialog(
    context: context,
    barrierDismissible: false,
    animationType: DialogAnimationType.scale,
    builder: (context) => CardPickDialog(
      isChance: isChance,
      cards: cards,
      onCardPicked: onCardPicked,
    ),
  );
}
