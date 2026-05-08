import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../theme/app_colors.dart';
import 'auth_surface.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: 'locked-brand-pill',
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
                  letterSpacing: 3.4,
                ),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
        const SizedBox(height: 24),
        Text(
          title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -1.6,
                height: 0.98,
              ),
        ).animate(delay: 80.ms).fadeIn(duration: 420.ms).slideY(begin: 0.18),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
        ).animate(delay: 150.ms).fadeIn(duration: 420.ms).slideY(begin: 0.14),
        const SizedBox(height: 20),
        Row(
          children: const [
            Expanded(
              child: _FeatureCard(
                title: 'Private by design',
                subtitle: 'Secure session vault and seamless refresh logic.',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                title: 'Synced instantly',
                subtitle: 'Auth state survives restarts and network edges.',
              ),
            ),
          ],
        ).animate(delay: 220.ms).fadeIn(duration: 460.ms).slideY(begin: 0.1),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AuthSurface(
      padding: const EdgeInsets.all(18),
      radius: 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}
