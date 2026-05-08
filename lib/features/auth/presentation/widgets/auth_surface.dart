import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class AuthSurface extends StatelessWidget {
  const AuthSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = AppTheme.radiusLg,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: padding,
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.72)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}
