import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.card,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
