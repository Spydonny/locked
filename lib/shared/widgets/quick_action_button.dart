import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: isDark
          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.75)
          : colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
