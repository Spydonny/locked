import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../cubit/workout_state.dart';

class WorkoutSetRow extends StatefulWidget {
  const WorkoutSetRow({
    required this.index,
    required this.set,
    required this.isPersonalRecord,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onToggleCompleted,
    super.key,
  });

  final int index;
  final ExerciseSet set;
  final bool isPersonalRecord;
  final ValueChanged<String> onWeightChanged;
  final ValueChanged<String> onRepsChanged;
  final VoidCallback onToggleCompleted;

  @override
  State<WorkoutSetRow> createState() => _WorkoutSetRowState();
}

class _WorkoutSetRowState extends State<WorkoutSetRow> {
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: formatWeightValue(widget.set.weight),
    );
    _repsController = TextEditingController(text: widget.set.reps.toString());
  }

  @override
  void didUpdateWidget(covariant WorkoutSetRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextWeight = formatWeightValue(widget.set.weight);
    if (_weightController.text != nextWeight) {
      _weightController.text = nextWeight;
    }

    final nextReps = widget.set.reps.toString();
    if (_repsController.text != nextReps) {
      _repsController.text = nextReps;
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: widget.set.isCompleted
            ? AppColors.success.withOpacity(0.12)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(
          color: widget.set.isCompleted ? AppColors.success : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${widget.index + 1}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (widget.isPersonalRecord) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
            const SizedBox(width: 8),
          ],
          Expanded(
            child: _CompactNumberField(
              controller: _weightController,
              placeholder: 'kg',
              onChanged: widget.onWeightChanged,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _CompactNumberField(
              controller: _repsController,
              placeholder: 'reps',
              onChanged: widget.onRepsChanged,
            ),
          ),
          const SizedBox(width: 10),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 44,
            onPressed: widget.onToggleCompleted,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.set.isCompleted
                    ? AppColors.success
                    : CupertinoColors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.check_mark,
                size: 18,
                color: widget.set.isCompleted
                    ? CupertinoColors.white
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactNumberField extends StatelessWidget {
  const _CompactNumberField({
    required this.controller,
    required this.placeholder,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      onChanged: onChanged,
      style: const TextStyle(
        color: CupertinoColors.white,
        fontWeight: FontWeight.w600,
      ),
      placeholder: placeholder,
      decoration: BoxDecoration(
        color: CupertinoColors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
