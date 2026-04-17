import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/mock/mock_models.dart';

class RoutineCard extends StatelessWidget {
  const RoutineCard({
    required this.routine,
    required this.onPressed,
    super.key,
  });

  final RoutineSummary routine;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onPressed,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.list_bullet,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  routine.subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${routine.exerciseCount} exercises - ${routine.estimatedMinutes} min - ${routine.lastPerformed}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            CupertinoIcons.chevron_right,
            color: AppColors.textSecondary,
            size: 18,
          ),
        ],
      ),
    );
  }
}
