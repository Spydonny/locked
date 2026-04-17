import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../cubit/workout_state.dart';
import 'workout_set_row.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    required this.exercise,
    required this.subtitle,
    required this.hasPersonalRecord,
    required this.isSetPersonalRecord,
    required this.onAddSet,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onToggleCompleted,
    super.key,
  });

  final Exercise exercise;
  final String subtitle;
  final bool hasPersonalRecord;
  final bool Function(int setIndex) isSetPersonalRecord;
  final VoidCallback onAddSet;
  final void Function(int setIndex, String value) onWeightChanged;
  final void Function(int setIndex, String value) onRepsChanged;
  final void Function(int setIndex) onToggleCompleted;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (hasPersonalRecord)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'PR',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  'SET',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'WEIGHT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'REPS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 46),
            ],
          ),
          const SizedBox(height: 10),
          ...exercise.sets.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: WorkoutSetRow(
                index: entry.key,
                set: entry.value,
                isPersonalRecord: isSetPersonalRecord(entry.key),
                onWeightChanged: (value) => onWeightChanged(entry.key, value),
                onRepsChanged: (value) => onRepsChanged(entry.key, value),
                onToggleCompleted: () => onToggleCompleted(entry.key),
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 44,
            onPressed: onAddSet,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                border: Border.all(color: AppColors.divider),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Add set',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
