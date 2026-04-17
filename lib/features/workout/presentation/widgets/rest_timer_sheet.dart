import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../cubit/workout_state.dart';

class RestTimerSheet extends StatelessWidget {
  const RestTimerSheet({
    required this.restTimer,
    required this.onDismiss,
    required this.onSelectDuration,
    super.key,
  });

  final WorkoutRestTimerState restTimer;
  final VoidCallback onDismiss;
  final ValueChanged<Duration> onSelectDuration;

  static const _presetDurations = [
    Duration(seconds: 60),
    Duration(seconds: 90),
    Duration(seconds: 120),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppSpacing.radiusLarge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Rest Timer',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 44,
                onPressed: onDismiss,
                child: const Text(
                  'Dismiss',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Started after your completed set. Keep moving while it counts down.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            formatRestTimer(restTimer.remaining),
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Change duration',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presetDurations.map((duration) {
              final isSelected = duration == restTimer.selectedDuration;

              return CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 36,
                onPressed: () => onSelectDuration(duration),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.surfaceMuted : AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.gradientStart
                          : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    '${duration.inSeconds}s',
                    style: TextStyle(
                      color: isSelected
                          ? CupertinoColors.white
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
