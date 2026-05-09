import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, this.height = 10});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final safeValue = value < 0 ? 0.0 : (value > 1 ? 1.0 : value);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: height,
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.7)
            : colorScheme.surfaceContainerHighest,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: safeValue,
          child: Container(color: colorScheme.primary),
        ),
      ),
    );
  }
}
