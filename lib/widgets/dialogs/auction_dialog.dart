import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/tile.dart';
import '../../models/player.dart';
import '../../models/auction.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import 'animated_dialog.dart';

/// Dialog for property auctions
class AuctionDialog extends StatefulWidget {
  final TileData property;
  final List<Player> participants;
  final Function(Player winner, int amount) onAuctionComplete;
  final VoidCallback onNoWinner;

  const AuctionDialog({
    super.key,
    required this.property,
    required this.participants,
    required this.onAuctionComplete,
    required this.onNoWinner,
  });

  @override
  State<AuctionDialog> createState() => _AuctionDialogState();
}

class _AuctionDialogState extends State<AuctionDialog>
    with SingleTickerProviderStateMixin {
  late AuctionState _auction;
  late AnimationController _pulseController;
  int _customBidAmount = 0;
  bool _isProcessingAI = false;

  @override
  void initState() {
    super.initState();
    _auction = AuctionState(
      property: widget.property,
      participants: widget.participants
          .where((p) => p.status == PlayerStatus.active)
          .toList(),
    );
    _customBidAmount = _auction.minimumNextBid;

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    // Start with first player (if AI, process their bid)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processCurrentBidder();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _processCurrentBidder() async {
    if (_auction.isComplete) return;

    final currentBidder = _auction.currentBidder;

    if (currentBidder.isAI && !_isProcessingAI) {
      _isProcessingAI = true;
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      // AI decides to bid or pass
      final aiBid = AIAuctionStrategy.determineBid(currentBidder, _auction);

      setState(() {
        if (aiBid != null) {
          _auction.placeBid(currentBidder, aiBid);
        } else {
          _auction.pass(currentBidder);
        }
        _isProcessingAI = false;
      });

      // Check if auction is complete
      if (_auction.checkComplete()) {
        _finishAuction();
        return;
      }

      // Move to next bidder
      _auction.nextBidder();
      _customBidAmount = _auction.minimumNextBid;

      // Continue processing
      _processCurrentBidder();
    }
  }

  void _placeBid(int amount) {
    final player = _auction.currentBidder;
    if (!_auction.canBid(player, amount)) return;

    setState(() {
      _auction.placeBid(player, amount);
    });

    if (_auction.checkComplete()) {
      _finishAuction();
      return;
    }

    _auction.nextBidder();
    _customBidAmount = _auction.minimumNextBid;
    _processCurrentBidder();
  }

  void _pass() {
    final player = _auction.currentBidder;

    setState(() {
      _auction.pass(player);
    });

    if (_auction.checkComplete()) {
      _finishAuction();
      return;
    }

    _auction.nextBidder();
    _processCurrentBidder();
  }

  void _finishAuction() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Navigator.of(context).pop();

    final winner = _auction.getWinner();
    if (winner != null) {
      widget.onAuctionComplete(winner, _auction.currentBid);
    } else {
      widget.onNoWinner();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height - mediaQuery.padding.vertical - 32;
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: 400, maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.3),
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
                key: const Key('auction-content-scroll'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildBidInfo(),
                    _buildParticipants(),
                    if (!_auction.currentBidder.isAI && !_auction.isComplete)
                      _buildBidControls(),
                    if (_auction.isComplete) _buildResult(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    Color? propertyColor;
    if (widget.property is PropertyTileData) {
      propertyColor = (widget.property as PropertyTileData).groupColor;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: propertyColor ?? Colors.amber,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
      ),
      child: Column(
        children: [
          const Icon(Icons.gavel, color: Colors.white, size: 36),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.auction,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.property.name,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          Text(
            AppLocalizations.of(context)!.propertyValue(_auction.propertyPrice),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.currentBid,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Text(
                      _auction.currentBid == 0
                          ? AppLocalizations.of(context)!.noBidsYet
                          : '\$${_auction.currentBid}',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: _auction.currentBid == 0
                            ? Colors.white54
                            : Color.lerp(
                                AppTheme.cashGreen,
                                Colors.white,
                                _pulseController.value,
                              ),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_auction.currentBidderId != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Leading Bidder:',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    widget.participants
                        .firstWhere((p) => p.id == _auction.currentBidderId)
                        .name,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParticipants() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bidders:',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _auction.participants.map((player) {
              final isCurrentBidder = player.id == _auction.currentBidder.id;
              final hasPassed = _auction.passedPlayers.contains(player.id);
              final isLeading = player.id == _auction.currentBidderId;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: hasPassed
                      ? Colors.grey.withValues(alpha: 0.3)
                      : isCurrentBidder
                      ? player.color.withValues(alpha: 0.8)
                      : player.color.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: isLeading
                      ? Border.all(color: Colors.amber, width: 2)
                      : isCurrentBidder
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLeading)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                    Text(
                      player.name,
                      style: TextStyle(
                        color: hasPassed ? Colors.white38 : Colors.white,
                        fontWeight: isCurrentBidder
                            ? FontWeight.bold
                            : FontWeight.normal,
                        decoration: hasPassed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$${player.cash}',
                      style: TextStyle(
                        color: hasPassed ? Colors.white24 : Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBidControls() {
    final player = _auction.currentBidder;
    final minBid = _auction.minimumNextBid;
    final canAffordMin = player.cash >= minBid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: player.color.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(17)),
      ),
      child: Column(
        children: [
          Text(
            "${player.name}'s Turn",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Quick bid buttons
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickBidButton(minBid, canAffordMin),
              _buildQuickBidButton(minBid + 50, player.cash >= minBid + 50),
              _buildQuickBidButton(minBid + 100, player.cash >= minBid + 100),
            ],
          ),
          const SizedBox(height: 12),
          // Custom bid slider (only show if player can afford to bid)
          if (canAffordMin)
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _customBidAmount.toDouble().clamp(
                      minBid.toDouble(),
                      player.cash.toDouble(),
                    ),
                    min: minBid.toDouble(),
                    max: player.cash.toDouble(),
                    divisions: ((player.cash - minBid) / 10).ceil().clamp(
                      1,
                      100,
                    ),
                    activeColor: Colors.amber,
                    onChanged: (value) {
                      setState(() {
                        _customBidAmount = value.round();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    '\$$_customBidAmount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Not enough cash to bid",
                style: TextStyle(
                  color: Colors.red.shade300,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 12),
          OverflowBar(
            alignment: MainAxisAlignment.center,
            overflowAlignment: OverflowBarAlignment.center,
            spacing: 12,
            overflowSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: _pass,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.pass),
              ),
              ElevatedButton(
                onPressed: canAffordMin
                    ? () => _placeBid(_customBidAmount)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  canAffordMin ? 'Bid \$$_customBidAmount' : 'Not enough cash',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBidButton(int amount, bool canAfford) {
    return ElevatedButton(
      onPressed: canAfford ? () => _placeBid(amount) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber.withValues(alpha: 0.8),
        foregroundColor: Colors.black,
        disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        '\$$amount',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildResult() {
    final winner = _auction.getWinner();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            winner != null ? Icons.celebration : Icons.cancel,
            color: winner != null ? Colors.amber : Colors.grey,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            winner != null
                ? '${winner.name} wins the auction!'
                : 'No winner - property returns to bank',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (winner != null) ...[
            const SizedBox(height: 8),
            Text(
              'Final bid: \$${_auction.currentBid}',
              style: TextStyle(
                color: AppTheme.cashGreen,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Show the auction dialog
Future<void> showAuctionDialog({
  required BuildContext context,
  required TileData property,
  required List<Player> participants,
  required Function(Player winner, int amount) onAuctionComplete,
  required VoidCallback onNoWinner,
}) {
  return showAnimatedDialog(
    context: context,
    barrierDismissible: false,
    animationType: DialogAnimationType.scale,
    builder: (context) => AuctionDialog(
      property: property,
      participants: participants,
      onAuctionComplete: onAuctionComplete,
      onNoWinner: onNoWinner,
    ),
  );
}
