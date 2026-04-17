import 'package:flutter/cupertino.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFF0A0A0A);
  static const card = Color(0xFF1A1A1A);
  static const surface = Color(0xFF141414);
  static const surfaceMuted = Color(0xFF202020);
  static const divider = Color(0x22FFFFFF);
  static const textPrimary = CupertinoColors.white;
  static const textSecondary = Color(0xFF9A9A9A);
  static const textTertiary = Color(0xFF6B6B6B);
  static const success = Color(0xFF34C759);
  static const warning = Color(0xFFFF9F0A);

  static const gradientStart = Color(0xFFFD297B);
  static const gradientMiddle = Color(0xFFFF655B);
  static const gradientEnd = Color(0xFFFF8C59);

  static const accentGradient = LinearGradient(
    colors: [gradientStart, gradientMiddle, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
