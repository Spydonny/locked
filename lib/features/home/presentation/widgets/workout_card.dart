import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_stat_pill.dart';
import '../../../../data/mock/mock_models.dart';

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({required this.workout, super.key});

  final WorkoutFeedItem workout;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: workout.author.color,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  workout.author.initials,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.author.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${workout.author.handle} - ${workout.timeAgo}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.ellipsis,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.item),
          Text(
            workout.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: [
              AppStatPill(
                icon: CupertinoIcons.time,
                label: '${workout.durationMinutes} min',
              ),
              AppStatPill(
                icon: CupertinoIcons.chart_bar,
                label: '${workout.volumeKg} kg',
              ),
              AppStatPill(
                icon: CupertinoIcons.star_fill,
                label: '${workout.personalRecords} PR',
                color: AppColors.warning,
              ),
            ],
          ),
          if (workout.imageLabel != null) ...[
            const SizedBox(height: AppSpacing.item),
            Container(
              height: 168,
              decoration: BoxDecoration(
                gradient:
                    workout.imageGradient ??
                    const LinearGradient(
                      colors: [AppColors.surfaceMuted, AppColors.card],
                    ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              padding: const EdgeInsets.all(AppSpacing.card),
              alignment: Alignment.bottomLeft,
              child: Text(
                workout.imageLabel!,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.item),
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ActionChip(
                icon: CupertinoIcons.heart,
                label: '${workout.likes}',
              ),
              _ActionChip(
                icon: CupertinoIcons.chat_bubble,
                label: '${workout.comments}',
              ),
              _ActionChip(
                icon: CupertinoIcons.repeat,
                label: '${workout.reposts}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      minSize: 44,
      onPressed: () {},
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
