import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../shared/widgets/app_page_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../theme/app_colors.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final currentUser = authState.snapshot.user;
    final surfaceTextColor = Theme.of(context).colorScheme.onSurface;

    return AppPageScaffold(
      child: ListView(
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          const Text(
            'Privacy, notifications, units, Apple Health and secure account management.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 22),
          if (currentUser != null) ...[
            GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      currentUser.displayName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser.displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentUser.email,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          const _SettingsToggleRow(
            title: 'Apple Health Sync',
            subtitle: 'Calories, workouts, steps, bodyweight and heart rate',
            value: true,
          ),
          const SizedBox(height: 12),
          const _SettingsToggleRow(
            title: 'Biometric Login',
            subtitle: 'Face ID / Touch ID protected session restore',
            value: true,
          ),
          const SizedBox(height: 12),
          const _SettingsToggleRow(
            title: 'Metric Units',
            subtitle: 'Switch between kg / cm and lb / inches',
            value: true,
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                HapticFeedback.selectionClick();
                context.push('/sync');
              },
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Import & Sync Center',
                          style: TextStyle(
                            color: surfaceTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Hevy / Strong CSV import, duplicate detection, background sync queue',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(CupertinoIcons.chevron_right, color: surfaceTextColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: authState.isSubmitting
                  ? null
                  : () async {
                      HapticFeedback.mediumImpact();
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/auth/login');
                      }
                    },
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Log out',
                          style: TextStyle(
                            color: surfaceTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Clear your secure session and return to authentication.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  authState.isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CupertinoActivityIndicator(),
                        )
                      : Icon(
                          CupertinoIcons.square_arrow_right,
                          color: surfaceTextColor,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final String title;
  final String subtitle;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          CupertinoSwitch(value: value, onChanged: (_) {}),
        ],
      ),
    );
  }
}
