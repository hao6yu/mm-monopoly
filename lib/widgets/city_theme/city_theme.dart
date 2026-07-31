import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shared visual language for the 3D city boards and the Flutter shell around
/// them. The miniature world is drawn in Flutter so menu screens load instantly
/// without booting a second Godot surface.
class CityThemeBackground extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Color accent;
  final String? imageAsset;
  final Alignment imageAlignment;

  const CityThemeBackground({
    super.key,
    required this.animation,
    required this.child,
    this.accent = const Color(0xFF35D5C5),
    this.imageAsset,
    this.imageAlignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF071427), Color(0xFF0D3150), Color(0xFF116D83)],
              stops: [0, 0.52, 1],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageAsset != null)
                IgnorePointer(
                  child: Transform.scale(
                    scale:
                        1.035 + math.sin(animation.value * math.pi * 2) * 0.004,
                    child: Transform.translate(
                      offset: Offset(
                        math.sin(animation.value * math.pi * 2) * 3,
                        math.cos(animation.value * math.pi * 2) * 2,
                      ),
                      child: Image.asset(
                        imageAsset!,
                        fit: BoxFit.cover,
                        alignment: imageAlignment,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                )
              else
                IgnorePointer(
                  child: CustomPaint(
                    painter: _MiniatureCityPainter(
                      progress: animation.value,
                      accent: accent,
                    ),
                  ),
                ),
              if (imageAsset != null)
                const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0x87030A16),
                          Color(0x16030A16),
                          Color(0x24030A16),
                          Color(0x5C030A16),
                        ],
                        stops: [0, 0.38, 0.67, 1],
                      ),
                    ),
                  ),
                ),
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x35000000),
                        Color(0x00101B2C),
                        Color(0x7A030A14),
                      ],
                      stops: [0, 0.58, 1],
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        );
      },
    );
  }
}

class CityGlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? accent;

  const CityGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = accent ?? const Color(0xFF6A8AA7);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xEE111D33), Color(0xD9081224)],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor.withValues(alpha: 0.55)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x73000000),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
          BoxShadow(color: Color(0x1835D5C5), blurRadius: 18, spreadRadius: -4),
        ],
      ),
      child: child,
    );
  }
}

class CityChromeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final Color accent;

  const CityChromeButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.accent = const Color(0xFF35D5C5),
  });

  @override
  Widget build(BuildContext context) {
    final foreground = primary ? const Color(0xFF122039) : Colors.white;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 62,
          decoration: BoxDecoration(
            gradient:
                primary
                    ? const LinearGradient(
                      colors: [Color(0xFFFFD86B), Color(0xFFF1AD35)],
                    )
                    : const LinearGradient(
                      colors: [Color(0xFF20304F), Color(0xFF15223D)],
                    ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  primary
                      ? const Color(0xFFFFE6A1)
                      : accent.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: (primary ? const Color(0xFFF1AD35) : accent).withValues(
                  alpha: 0.22,
                ),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: foreground.withValues(alpha: primary ? 0.12 : 0.08),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: foreground, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      color: foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: foreground.withValues(alpha: 0.75),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CitySectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const CitySectionLabel({
    super.key,
    required this.icon,
    required this.label,
    this.color = const Color(0xFF8CEDE2),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniatureCityPainter extends CustomPainter {
  final double progress;
  final Color accent;

  const _MiniatureCityPainter({required this.progress, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final wave = math.sin(progress * math.pi * 2);
    final horizon = size.height * 0.42;

    _paintSun(canvas, size, shortest, wave);
    _paintClouds(canvas, size, shortest);
    _paintWater(canvas, size, horizon, wave);
    _paintIsland(canvas, size, shortest, horizon);
    _paintSkyline(canvas, size, shortest, horizon);
    _paintRoute(canvas, size, shortest, horizon);
    _paintBoats(canvas, size, shortest, horizon);
  }

  void _paintSun(Canvas canvas, Size size, double shortest, double wave) {
    final center = Offset(size.width * 0.78, size.height * 0.2 + wave * 3);
    final glow =
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xB0FFE09A),
              const Color(0x28FFE09A),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(center: center, radius: shortest * 0.16),
          );
    canvas.drawCircle(center, shortest * 0.16, glow);
    canvas.drawCircle(
      center,
      shortest * 0.035,
      Paint()..color = const Color(0xFFFFE8AF),
    );
  }

  void _paintClouds(Canvas canvas, Size size, double shortest) {
    final paint = Paint()..color = const Color(0x88EAFBFF);
    for (var index = 0; index < 5; index++) {
      final travel = (progress * (0.035 + index * 0.006) + index * 0.23) % 1.2;
      final x = (travel - 0.1) * size.width;
      final y = size.height * (0.11 + (index % 3) * 0.095);
      final radius = shortest * (0.012 + (index % 2) * 0.004);
      canvas.drawCircle(Offset(x, y), radius, paint);
      canvas.drawCircle(
        Offset(x + radius, y + radius * 0.1),
        radius * 0.8,
        paint,
      );
      canvas.drawCircle(
        Offset(x - radius, y + radius * 0.2),
        radius * 0.66,
        paint,
      );
    }
  }

  void _paintWater(Canvas canvas, Size size, double horizon, double wave) {
    final waterRect = Rect.fromLTRB(0, horizon, size.width, size.height);
    canvas.drawRect(
      waterRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1689A6), Color(0xFF063D5B)],
        ).createShader(waterRect),
    );
    final ripple =
        Paint()
          ..color = const Color(0x247CDAEA)
          ..strokeWidth = 1.2;
    for (var index = 0; index < 10; index++) {
      final y = horizon + (index + 1) * (size.height - horizon) / 11;
      canvas.drawLine(
        Offset(size.width * 0.05, y + wave * 1.2),
        Offset(size.width * 0.95, y - wave * 1.2),
        ripple,
      );
    }
  }

  void _paintIsland(Canvas canvas, Size size, double shortest, double horizon) {
    final center = Offset(size.width * 0.48, horizon + shortest * 0.22);
    final islandWidth = math.min(size.width * 0.78, shortest * 1.28);
    final islandHeight = shortest * 0.32;
    final shadowPath =
        Path()
          ..moveTo(center.dx, center.dy - islandHeight * 0.47)
          ..lineTo(center.dx + islandWidth * 0.5, center.dy)
          ..lineTo(center.dx, center.dy + islandHeight * 0.58)
          ..lineTo(center.dx - islandWidth * 0.5, center.dy)
          ..close();
    canvas.save();
    canvas.translate(0, shortest * 0.035);
    canvas.drawPath(shadowPath, Paint()..color = const Color(0x6F02080F));
    canvas.restore();
    canvas.drawPath(
      shadowPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF78B978), Color(0xFF2E6E59)],
        ).createShader(shadowPath.getBounds()),
    );
    canvas.drawPath(
      shadowPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = shortest * 0.008
        ..color = const Color(0xFFD8B551),
    );
  }

  void _paintSkyline(
    Canvas canvas,
    Size size,
    double shortest,
    double horizon,
  ) {
    final base = Offset(size.width * 0.48, horizon + shortest * 0.19);
    final positions = <Offset>[
      const Offset(-0.29, -0.03),
      const Offset(-0.18, 0.07),
      const Offset(-0.08, -0.04),
      const Offset(0.03, 0.04),
      const Offset(0.13, -0.06),
      const Offset(0.23, 0.035),
      const Offset(0.31, -0.01),
    ];
    for (var index = 0; index < positions.length; index++) {
      final point = positions[index];
      final buildingBase = Offset(
        base.dx + point.dx * shortest,
        base.dy + point.dy * shortest,
      );
      final buildingWidth = shortest * (0.035 + (index % 3) * 0.008);
      final buildingHeight = shortest * (0.1 + (index % 4) * 0.035);
      _paintBuilding(
        canvas,
        buildingBase,
        buildingWidth,
        buildingHeight,
        index.isEven ? const Color(0xFFBFD5DE) : const Color(0xFF6FA4BB),
      );
    }

    final treePaint = Paint()..color = const Color(0xFF1F6649);
    for (var index = 0; index < 14; index++) {
      final angle = index * 0.91;
      final center = Offset(
        base.dx + math.cos(angle) * shortest * (0.16 + (index % 3) * 0.025),
        base.dy + math.sin(angle) * shortest * 0.08,
      );
      canvas.drawCircle(center, shortest * 0.012, treePaint);
    }
  }

  void _paintBuilding(
    Canvas canvas,
    Offset base,
    double width,
    double height,
    Color color,
  ) {
    final rise = height * (0.92 + math.sin(progress * math.pi) * 0.04);
    final front = Rect.fromLTWH(
      base.dx - width / 2,
      base.dy - rise,
      width,
      rise,
    );
    canvas.drawRect(front, Paint()..color = color);
    final side =
        Path()
          ..moveTo(front.right, front.top)
          ..lineTo(front.right + width * 0.28, front.top - width * 0.2)
          ..lineTo(front.right + width * 0.28, front.bottom - width * 0.2)
          ..lineTo(front.right, front.bottom)
          ..close();
    canvas.drawPath(side, Paint()..color = color.withValues(alpha: 0.62));
    final top =
        Path()
          ..moveTo(front.left, front.top)
          ..lineTo(front.left + width * 0.28, front.top - width * 0.2)
          ..lineTo(front.right + width * 0.28, front.top - width * 0.2)
          ..lineTo(front.right, front.top)
          ..close();
    canvas.drawPath(top, Paint()..color = color.withValues(alpha: 0.92));
    final windows = Paint()..color = const Color(0xB0FFE19A);
    for (var floor = 1; floor < 5; floor++) {
      final y = front.bottom - rise * floor / 5;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(front.center.dx, y),
          width: width * 0.5,
          height: math.max(1, width * 0.07),
        ),
        windows,
      );
    }
  }

  void _paintRoute(Canvas canvas, Size size, double shortest, double horizon) {
    final center = Offset(size.width * 0.48, horizon + shortest * 0.22);
    final routeRect = Rect.fromCenter(
      center: center,
      width: math.min(size.width * 0.72, shortest * 1.14),
      height: shortest * 0.25,
    );
    final routePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, shortest * 0.008)
          ..color = const Color(0xFFEBEFEA);
    canvas.drawOval(routeRect, routePaint);

    for (var index = 0; index < 30; index++) {
      final angle = index / 30 * math.pi * 2;
      final position = Offset(
        center.dx + math.cos(angle) * routeRect.width / 2,
        center.dy + math.sin(angle) * routeRect.height / 2,
      );
      canvas.drawCircle(
        position,
        shortest * 0.006,
        Paint()
          ..color =
              index % 5 == 0
                  ? const Color(0xFFFFCF59)
                  : accent.withValues(alpha: 0.82),
      );
    }
  }

  void _paintBoats(Canvas canvas, Size size, double shortest, double horizon) {
    for (var index = 0; index < 3; index++) {
      final travel = (progress * (0.08 + index * 0.018) + index * 0.36) % 1.0;
      final position = Offset(
        size.width * (0.12 + travel * 0.76),
        horizon + shortest * (0.38 + index * 0.065),
      );
      final hull =
          Path()
            ..moveTo(position.dx - shortest * 0.016, position.dy)
            ..lineTo(position.dx + shortest * 0.018, position.dy)
            ..lineTo(
              position.dx + shortest * 0.01,
              position.dy + shortest * 0.01,
            )
            ..lineTo(
              position.dx - shortest * 0.009,
              position.dy + shortest * 0.01,
            )
            ..close();
      canvas.drawPath(hull, Paint()..color = const Color(0xFFE7F3F5));
    }
  }

  @override
  bool shouldRepaint(covariant _MiniatureCityPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.accent != accent;
  }
}
