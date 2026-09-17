import 'dart:io';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/game_state.dart';
import '../../models/player.dart';
import '../../utils/currency_utils.dart';

/// Compact multiplayer context that stays visible over the 3D board.
///
/// The rail deliberately owns presentation only. The board remains the source
/// of truth for the turn and decides whether portfolio inspection is allowed.
class GameStatusRail extends StatefulWidget {
  const GameStatusRail({
    super.key,
    required this.gameState,
    required this.boardReady,
    required this.isProcessingTurn,
    required this.interactionsEnabled,
    this.onPlayerTap,
    this.maxWidth = 760,
    this.initiallyExpanded = true,
  });

  final GameState gameState;
  final bool boardReady;
  final bool isProcessingTurn;
  final bool interactionsEnabled;
  final ValueChanged<Player>? onPlayerTap;
  final double maxWidth;
  final bool initiallyExpanded;

  @override
  State<GameStatusRail> createState() => _GameStatusRailState();
}

class _GameStatusRailState extends State<GameStatusRail> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final cardHeight = textScaler.scale(58).clamp(58.0, 88.0);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: Material(
        key: const Key('3d-player-status-rail'),
        color: const Color(0xEB111A33),
        elevation: 10,
        shadowColor: Colors.black54,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (!_isExpanded) return _buildCollapsedSummary(context);

                if (constraints.maxWidth >= 480) {
                  return SizedBox(
                    height: cardHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: (constraints.maxWidth * 0.24).clamp(
                            154.0,
                            184.0,
                          ),
                          child: _buildTurnSummary(context, compact: true),
                        ),
                        const VerticalDivider(
                          width: 13,
                          thickness: 1,
                          color: Colors.white12,
                        ),
                        for (
                          var index = 0;
                          index < widget.gameState.players.length;
                          index++
                        ) ...[
                          if (index > 0) const SizedBox(width: 5),
                          Expanded(
                            child: _PlayerStatusCard(
                              player: widget.gameState.players[index],
                              isCurrent:
                                  widget.gameState.players[index].id ==
                                  widget.gameState.currentPlayer.id,
                              interactionsEnabled: widget.interactionsEnabled,
                              onTap: widget.onPlayerTap,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTurnSummary(context),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: cardHeight,
                      child: ListView.separated(
                        key: const Key('3d-player-status-list'),
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.gameState.players.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (context, index) {
                          final player = widget.gameState.players[index];
                          return SizedBox(
                            width: 154,
                            child: _PlayerStatusCard(
                              player: player,
                              isCurrent:
                                  player.id ==
                                  widget.gameState.currentPlayer.id,
                              interactionsEnabled: widget.interactionsEnabled,
                              onTap: widget.onPlayerTap,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedSummary(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildPhaseLabel(context, maxLines: 1)),
        const SizedBox(width: 8),
        _RoundBadge(roundNumber: widget.gameState.roundNumber),
        const SizedBox(width: 3),
        _buildExpansionButton(),
      ],
    );
  }

  Widget _buildTurnSummary(BuildContext context, {bool compact = false}) {
    if (compact) {
      return Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPhaseLabel(context, maxLines: 2),
                const SizedBox(height: 4),
                _RoundBadge(roundNumber: widget.gameState.roundNumber),
              ],
            ),
          ),
          _buildExpansionButton(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildPhaseLabel(context, maxLines: 2)),
        const SizedBox(width: 8),
        _RoundBadge(roundNumber: widget.gameState.roundNumber),
        const SizedBox(width: 3),
        _buildExpansionButton(),
      ],
    );
  }

  Widget _buildPhaseLabel(BuildContext context, {required int maxLines}) {
    final player = widget.gameState.currentPlayer;
    final phase = _turnPresentation(context);
    return Semantics(
      liveRegion: true,
      label: phase.label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: player.color.withValues(alpha: 0.22),
              shape: BoxShape.circle,
              border: Border.all(color: player.color.withValues(alpha: 0.75)),
            ),
            child: Icon(phase.icon, color: player.color, size: 17),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: Text(
                phase.label,
                key: ValueKey(phase.label),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _TurnPresentation _turnPresentation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = widget.gameState;
    final player = state.currentPlayer;

    if (!widget.boardReady) {
      return _TurnPresentation(
        label: l10n.preparingGame,
        icon: Icons.hourglass_top_rounded,
      );
    }

    switch (state.animationState) {
      case TurnAnimationState.rollingDice:
        return _TurnPresentation(
          label: player.isAI
              ? l10n.aiRolling(player.name)
              : l10n.playerRolling(player.name),
          icon: Icons.casino_rounded,
        );
      case TurnAnimationState.movingToken:
        return _TurnPresentation(
          label: l10n.playerMoving(player.name),
          icon: Icons.directions_walk_rounded,
        );
      case TurnAnimationState.showingDialog:
      case TurnAnimationState.processingEffect:
        return _TurnPresentation(
          label: player.isAI
              ? l10n.aiResolving(player.name)
              : l10n.resolvingPlayerTurn(player.name),
          icon: Icons.auto_awesome_rounded,
        );
      case TurnAnimationState.idle:
        break;
    }

    final isResolving =
        widget.isProcessingTurn || state.logicPhase != TurnLogicPhase.preRoll;
    if (isResolving) {
      return _TurnPresentation(
        label: player.isAI
            ? l10n.aiResolving(player.name)
            : l10n.resolvingPlayerTurn(player.name),
        icon: Icons.sync_rounded,
      );
    }

    if (player.isAI) {
      return _TurnPresentation(
        label: l10n.aiThinking(player.name),
        icon: Icons.smart_toy_rounded,
      );
    }

    final humanCount = state.players
        .where((candidate) => !candidate.isAI)
        .length;
    return _TurnPresentation(
      label: humanCount > 1 ? l10n.passToPlayer(player.name) : l10n.yourTurn,
      icon: Icons.pan_tool_alt_rounded,
    );
  }

  Widget _buildExpansionButton() {
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      key: const Key('3d-player-status-toggle'),
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
      padding: EdgeInsets.zero,
      tooltip: _isExpanded ? l10n.hidePlayerStatus : l10n.showPlayerStatus,
      onPressed: () => setState(() => _isExpanded = !_isExpanded),
      icon: Icon(
        _isExpanded
            ? Icons.keyboard_arrow_up_rounded
            : Icons.keyboard_arrow_down_rounded,
        color: Colors.white70,
      ),
    );
  }
}

class _PlayerStatusCard extends StatelessWidget {
  const _PlayerStatusCard({
    required this.player,
    required this.isCurrent,
    required this.interactionsEnabled,
    required this.onTap,
  });

  final Player player;
  final bool isCurrent;
  final bool interactionsEnabled;
  final ValueChanged<Player>? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = _statusLabel(l10n);
    final statusColor = _statusColor;
    final tap = interactionsEnabled && onTap != null
        ? () => onTap!(player)
        : null;
    final cash = CurrencyUtils.format(context, player.cash);
    final identity = player.isAI ? l10n.ai : l10n.humanPlayer;

    return Semantics(
      container: true,
      button: tap != null,
      enabled: tap != null,
      selected: isCurrent,
      label: '${player.name}, $identity, $cash, $status',
      child: Material(
        color: isCurrent
            ? player.color.withValues(alpha: 0.2)
            : const Color(0xA6142038),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: Key('3d-status-player-${player.id}'),
          onTap: tap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrent ? player.color : Colors.white12,
                width: isCurrent ? 2 : 1,
              ),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: player.color.withValues(alpha: 0.22),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  key: Key('3d-status-player-name-${player.id}'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    _RailPlayerIdentity(player: player),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  cash,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF6DE2A1),
                                    fontSize: 10,
                                    height: 1,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  status,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 9,
                                    height: 1,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          _IdentityBadge(
                            key: Key('3d-status-player-identity-${player.id}'),
                            isAI: player.isAI,
                          ),
                        ],
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

  String _statusLabel(AppLocalizations l10n) {
    if (player.status == PlayerStatus.bankrupt) return l10n.bankruptcy;
    if (player.status == PlayerStatus.skipped ||
        player.skipTurnsRemaining > 0) {
      return l10n.skip;
    }
    if (player.jailTurnsRemaining > 0) return l10n.inJail;
    return isCurrent ? l10n.activePlayer : l10n.waitingPlayer;
  }

  Color get _statusColor {
    if (player.status == PlayerStatus.bankrupt) return Colors.redAccent;
    if (player.status == PlayerStatus.skipped ||
        player.skipTurnsRemaining > 0) {
      return Colors.orangeAccent;
    }
    if (player.jailTurnsRemaining > 0) return Colors.amber;
    return isCurrent ? player.color : Colors.white54;
  }
}

class _IdentityBadge extends StatelessWidget {
  const _IdentityBadge({super.key, required this.isAI});

  final bool isAI;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isAI
            ? Colors.deepPurpleAccent.withValues(alpha: 0.28)
            : Colors.lightBlueAccent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAI ? Icons.smart_toy_rounded : Icons.person_rounded,
            size: 8,
            color: isAI ? Colors.purpleAccent.shade100 : Colors.lightBlueAccent,
          ),
          const SizedBox(width: 2),
          Text(
            isAI ? l10n.ai : l10n.humanPlayer,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 7,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundBadge extends StatelessWidget {
  const _RoundBadge({required this.roundNumber});

  final int roundNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('3d-round-label'),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x24FFD96A),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x55FFD96A)),
      ),
      child: Text(
        AppLocalizations.of(context)!.roundNumber(roundNumber),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFFFFD96A),
          fontSize: 9,
          height: 1,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.25,
        ),
      ),
    );
  }
}

class _TurnPresentation {
  const _TurnPresentation({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// The custom photo path when the player's effective avatar is a photo,
/// otherwise null. The rail renders the photo instead of an emoji glyph;
/// exposed for tests because pixel rendering belongs to the framework.
String? railAvatarPhotoPath(Player player) {
  final avatar = player.effectiveAvatar;
  if (!avatar.isCustom) return null;
  return avatar.customImagePath;
}

/// The player's effective identity in the 24px rail slot (3D-05): a custom
/// photo when the player chose one, otherwise the avatar emoji. Matches the
/// identity surfaces used by the portfolio, cards, and victory screens.
class _RailPlayerIdentity extends StatelessWidget {
  const _RailPlayerIdentity({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    final avatar = player.effectiveAvatar;
    final photoPath = railAvatarPhotoPath(player);
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: player.color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: photoPath != null
          ? Image.file(
              File(photoPath),
              width: 24,
              height: 24,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Text(
                avatar.emoji,
                style: const TextStyle(fontSize: 13),
              ),
            )
          : Text(
              avatar.emoji,
              style: const TextStyle(fontSize: 13),
            ),
    );
  }
}
