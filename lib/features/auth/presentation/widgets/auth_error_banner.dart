import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0x33FF6B6B)
            : const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF8F1C1C),
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1);
  }
}
