import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  Color(0xFF161719),
                  Color(0xFF101113),
                ]
              : const [
                  Color(0xFFF6F6F8),
                  Color(0xFFEDEEF2),
                ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -60,
            right: -30,
            child: _GlowOrb(
              size: 220,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFFFFFFF),
            ),
          ),
          Positioned(
            left: -70,
            top: 180,
            child: _GlowOrb(
              size: 180,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : const Color(0xFFF9FAFB),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 140,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(42),
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : AppColors.surfaceMuted,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
