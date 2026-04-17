import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_stat_pill.dart';
import '../../../../data/mock/mock_models.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({required this.streak, super.key});

  final StreakSummary streak;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: LinearGradient(
        colors: [
          AppColors.surface,
          AppColors.surface.withOpacity(0.94),
          AppColors.gradientStart.withOpacity(0.38),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: CupertinoColors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Current streak',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${streak.currentDays}',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'days',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            streak.focusLabel,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.item),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: [
              AppStatPill(
                icon: CupertinoIcons.flame,
                label: '${streak.weeklySessions}/${streak.weeklyGoal} this week',
                color: AppColors.warning,
              ),
              const AppStatPill(
                icon: CupertinoIcons.arrow_up_right,
                label: 'Momentum building',
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
