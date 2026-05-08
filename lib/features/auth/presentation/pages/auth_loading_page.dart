import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../widgets/auth_background.dart';

class AuthLoadingPage extends StatelessWidget {
  const AuthLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : AppColors.black,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'LOCKED',
                    style: TextStyle(
                      color: isDark ? AppColors.black : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3.2,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
