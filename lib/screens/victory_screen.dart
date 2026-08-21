import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/avatar/avatar_widget.dart';
import '../widgets/effects/fireworks.dart';
import '../services/audio_service.dart';

/// Full-screen victory celebration
class VictoryScreen extends StatefulWidget {
  final Player winner;
  final List<Player> allPlayers;
  final int gameTurns;
  final FutureOr<void> Function() onPlayAgain;
  final VoidCallback onGoHome;

  const VictoryScreen({
    super.key,
    required this.winner,
    required this.allPlayers,
    required this.gameTurns,
    required this.onPlayAgain,
    required this.onGoHome,
  });

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _shineController;
  late AnimationController _buttonController;

  late Animation<double> _titleScale;
  late Animation<double> _avatarScale;
  late Animation<double> _statsSlide;
  late Animation<double> _buttonSlide;

  bool _showFireworks = true;
  final bool _showConfetti = true;
  Timer? _fireworksTimer;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _shineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _titleScale =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(
              begin: 0.0,
              end: 1.2,
            ).chain(CurveTween(curve: Curves.easeOut)),
            weight: 40,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: 1.2,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.elasticOut)),
            weight: 60,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0, 0.5),
          ),
        );

    _avatarScale =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.1), weight: 50),
          TweenSequenceItem(
            tween: Tween(
              begin: 1.1,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.bounceOut)),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.2, 0.7),
          ),
        );

    _statsSlide = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    _buttonSlide = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _entranceController.forward();

    // Play victory sound and music
    AudioService.instance.onVictory();
    AudioService.instance.playVictoryMusic();

    // Stop fireworks after a while
    _fireworksTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) setState(() => _showFireworks = false);
    });
  }

  @override
  void dispose() {
    _fireworksTimer?.cancel();
    _entranceController.dispose();
    _shineController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.background, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Fireworks
              if (_showFireworks)
                Positioned.fill(
                  child: FireworksWidget(
                    duration: const Duration(seconds: 8),
                    burstCount: 12,
                  ),
                ),

              // Confetti
              if (_showConfetti) Positioned.fill(child: _FallingConfetti()),

              // Main content
              AnimatedBuilder(
                animation: _entranceController,
                builder: (context, child) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // Title
                        Transform.scale(
                          scale: _titleScale.value,
                          child: _buildTitle(),
                        ),
                        const SizedBox(height: 32),

                        // Winner avatar
                        Transform.scale(
                          scale: _avatarScale.value,
                          child: _buildWinnerAvatar(),
                        ),
                        const SizedBox(height: 24),

                        // Winner name
                        Opacity(
                          opacity: _avatarScale.value.clamp(0, 1),
                          child: Text(
                            widget.winner.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Stats card
                        Transform.translate(
                          offset: Offset(0, _statsSlide.value),
                          child: Opacity(
                            opacity: (1 - _statsSlide.value / 100).clamp(0, 1),
                            child: _buildStatsCard(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Leaderboard
                        Transform.translate(
                          offset: Offset(0, _statsSlide.value),
                          child: Opacity(
                            opacity: (1 - _statsSlide.value / 100).clamp(0, 1),
                            child: _buildLeaderboard(),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Buttons
                        Transform.translate(
                          offset: Offset(0, _buttonSlide.value),
                          child: Opacity(
                            opacity: (1 - _buttonSlide.value / 100).clamp(0, 1),
                            child: _buildButtons(),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        // Trophy icon
        AnimatedBuilder(
          animation: _shineController,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.amber.shade300,
                    Colors.amber.shade600,
                    Colors.amber.shade300,
                  ],
                  stops: [0, _shineController.value, 1],
                ).createShader(bounds);
              },
              child: const Icon(
                Icons.emoji_events,
                size: 80,
                color: Colors.white,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        // Winner text with glow
        Stack(
          children: [
            // Glow
            Text(
              AppLocalizations.of(context)!.winnerTitle,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = Colors.amber.withValues(alpha: 0.5),
              ),
            ),
            // Text
            Text(
              AppLocalizations.of(context)!.winnerTitle,
              style: TextStyle(
                color: Colors.amber,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.orange, blurRadius: 20)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWinnerAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow ring
        AnimatedBuilder(
          animation: _shineController,
          builder: (context, child) {
            return Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(
                      alpha: 0.3 + _shineController.value * 0.3,
                    ),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
            );
          },
        ),
        // Avatar
        VictoryAvatarWidget(avatar: widget.winner.effectiveAvatar, size: 140),
        // Crown
        Positioned(
          top: -10,
          child: Transform.rotate(
            angle: -0.2,
            child: const Text('👑', style: TextStyle(fontSize: 40)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.gameStats,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.attach_money,
                  value: '\$${widget.winner.cash}',
                  label: AppLocalizations.of(context)!.finalCash,
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.home,
                  value: '${widget.winner.propertyIds.length}',
                  label: AppLocalizations.of(context)!.properties,
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.replay,
                  value: '${widget.gameTurns}',
                  label: AppLocalizations.of(context)!.turns,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    // Sort players by cash (descending)
    final sortedPlayers = List<Player>.from(widget.allPlayers)
      ..sort((a, b) => b.cash.compareTo(a.cash));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.finalStandings,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ...sortedPlayers.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            final isWinner = player.id == widget.winner.id;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  // Rank
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${index + 1}.',
                      style: TextStyle(
                        color: isWinner ? Colors.amber : Colors.white54,
                        fontSize: 16,
                        fontWeight: isWinner
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  // Avatar
                  AvatarWidget(
                    avatar: player.effectiveAvatar,
                    size: 32,
                    isSelected: isWinner,
                  ),
                  const SizedBox(width: 12),
                  // Name
                  Expanded(
                    child: Text(
                      player.name,
                      style: TextStyle(
                        color: isWinner ? Colors.amber : Colors.white,
                        fontSize: 16,
                        fontWeight: isWinner
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  // Cash
                  Text(
                    '\$${player.cash}',
                    style: TextStyle(
                      color: player.cash > 0 ? Colors.green : Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Winner badge
                  if (isWinner) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        // Play Again button (bouncy)
        AnimatedBuilder(
          animation: _buttonController,
          builder: (context, child) {
            final scale = 1.0 + _buttonController.value * 0.05;
            return Transform.scale(
              scale: scale,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const Key('victory-play-again-button'),
                  onPressed: () async {
                    await widget.onPlayAgain();
                  },
                  icon: const Icon(Icons.replay, size: 24),
                  label: Text(
                    AppLocalizations.of(context)!.playAgain,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Home button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('victory-home-button'),
            onPressed: widget.onGoHome,
            icon: const Icon(Icons.home, size: 24),
            label: Text(
              AppLocalizations.of(context)!.backToMenu,
              style: const TextStyle(fontSize: 18),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white30),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}

/// Falling confetti effect
class _FallingConfetti extends StatefulWidget {
  @override
  State<_FallingConfetti> createState() => _FallingConfettiState();
}

class _FallingConfettiState extends State<_FallingConfetti>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiPiece> _pieces = [];
  final Random _random = Random();
  Size _screenSize = Size.zero;
  bool _hasSeededPieces = false;

  static const List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          // Add new pieces occasionally
          if (_random.nextDouble() < 0.2) {
            _addPiece();
          }

          // Update pieces
          for (final piece in _pieces) {
            piece.update(1 / 60);
          }

          // Remove off-screen pieces
          _pieces.removeWhere((p) => p.y > _screenSize.height + 50);
        });
      }
    });

    _controller.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.sizeOf(context);
    if (!_hasSeededPieces) {
      _hasSeededPieces = true;
      for (int i = 0; i < 30; i++) {
        _addPiece(initialSpread: true);
      }
    }
  }

  void _addPiece({bool initialSpread = false}) {
    final screenWidth = _screenSize.width;
    final screenHeight = _screenSize.height;

    _pieces.add(
      _ConfettiPiece(
        x: _random.nextDouble() * screenWidth,
        y: initialSpread ? _random.nextDouble() * screenHeight : -20,
        velocityX: (_random.nextDouble() - 0.5) * 50,
        velocityY: 80 + _random.nextDouble() * 100,
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 5,
        color: _colors[_random.nextInt(_colors.length)],
        width: 6 + _random.nextDouble() * 6,
        height: 4 + _random.nextDouble() * 4,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ConfettiPainter(pieces: _pieces),
      size: Size.infinite,
    );
  }
}

class _ConfettiPiece {
  double x, y;
  double velocityX, velocityY;
  double rotation, rotationSpeed;
  Color color;
  double width, height;

  _ConfettiPiece({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.width,
    required this.height,
  });

  void update(double dt) {
    // Gentle sway
    velocityX += (Random().nextDouble() - 0.5) * 30 * dt;
    velocityX = velocityX.clamp(-40, 40);

    x += velocityX * dt;
    y += velocityY * dt;
    rotation += rotationSpeed * dt;
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;

  _ConfettiPainter({required this.pieces});

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final paint = Paint()
        ..color = piece.color.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(piece.x, piece.y);
      canvas.rotate(piece.rotation);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: piece.width,
        height: piece.height,
      );
      canvas.drawRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}
