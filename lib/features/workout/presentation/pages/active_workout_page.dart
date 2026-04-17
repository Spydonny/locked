import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';
import '../widgets/exercise_card.dart';
import '../widgets/exercise_picker_sheet.dart';
import '../widgets/rest_timer_sheet.dart';
import 'finish_workout_page.dart';

class ActiveWorkoutPage extends StatelessWidget {
  const ActiveWorkoutPage({super.key});

  Future<void> _openFinishWorkout(BuildContext context) {
    return Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => const FinishWorkoutPage()),
    );
  }

  Future<void> _openExercisePicker(BuildContext context) {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<WorkoutCubit>(),
        child: const ExercisePickerSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Active Workout'),
        trailing: BlocBuilder<WorkoutCubit, WorkoutState>(
          builder: (context, state) {
            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: state.stage == WorkoutFlowStage.finished
                  ? null
                  : () {
                      context.read<WorkoutCubit>().finishWorkout();
                      _openFinishWorkout(context);
                    },
              child: const Text('Finish'),
            );
          },
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<WorkoutCubit, WorkoutState>(
          builder: (context, state) {
            final bottomInset = MediaQuery.of(context).padding.bottom;

            return Stack(
              children: [
                ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    16,
                    AppSpacing.page,
                    state.restTimer.isVisible ? 280.0 + bottomInset : 120.0,
                  ),
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _WorkoutNameField(initialValue: state.workoutName),
                          const SizedBox(height: 18),
                          Text(
                            formatWorkoutDuration(state.elapsedSeconds),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.isPaused
                                ? 'Session paused'
                                : 'Session live',
                            style: TextStyle(
                              color: state.isPaused
                                  ? AppColors.warning
                                  : AppColors.success,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _ControlButton(
                                  label: state.isPaused
                                      ? 'Resume'
                                      : 'Pause',
                                  color: AppColors.surfaceMuted,
                                  onPressed: context
                                      .read<WorkoutCubit>()
                                      .toggleTimer,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ControlButton(
                                  label: 'Finish',
                                  color: AppColors.gradientMiddle,
                                  onPressed: () {
                                    context.read<WorkoutCubit>().finishWorkout();
                                    _openFinishWorkout(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    if (state.exercises.isEmpty)
                      AppCard(
                        child: Column(
                          children: [
                            const Text(
                              'No exercises yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Start by adding your first movement to this session.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _ControlButton(
                              label: 'Add exercise',
                              color: AppColors.surfaceMuted,
                              onPressed: () => _openExercisePicker(context),
                            ),
                          ],
                        ),
                      ),
                    ...state.exercises.asMap().entries.map((entry) {
                      final exerciseIndex = entry.key;
                      final exercise = entry.value;
                      final template = state.exerciseTemplateForName(exercise.name);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ExerciseCard(
                          exercise: exercise,
                          subtitle:
                              template?.focus ?? template?.muscleGroup.label ?? 'Exercise',
                          hasPersonalRecord: state.exerciseHasPersonalRecord(
                            exerciseIndex,
                          ),
                          isSetPersonalRecord: (setIndex) =>
                              state.isSetPersonalRecord(exerciseIndex, setIndex),
                          onAddSet: () => context.read<WorkoutCubit>().addSet(
                                exerciseIndex,
                              ),
                          onWeightChanged: (setIndex, value) => context
                              .read<WorkoutCubit>()
                              .updateSetWeight(exerciseIndex, setIndex, value),
                          onRepsChanged: (setIndex, value) => context
                              .read<WorkoutCubit>()
                              .updateSetReps(exerciseIndex, setIndex, value),
                          onToggleCompleted: (setIndex) => context
                              .read<WorkoutCubit>()
                              .toggleSetComplete(exerciseIndex, setIndex),
                        ),
                      );
                    }),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 44,
                      onPressed: () => _openExercisePicker(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMedium,
                          ),
                          border: Border.all(color: AppColors.divider),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Add exercise',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: AppSpacing.page,
                  right: AppSpacing.page,
                  bottom: 16 + bottomInset,
                  child: IgnorePointer(
                    ignoring: !state.restTimer.isVisible,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      offset: state.restTimer.isVisible
                          ? Offset.zero
                          : const Offset(0, 1.2),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 220),
                        opacity: state.restTimer.isVisible ? 1 : 0,
                        child: RestTimerSheet(
                          restTimer: state.restTimer,
                          onDismiss: context.read<WorkoutCubit>().dismissRestTimer,
                          onSelectDuration: context
                              .read<WorkoutCubit>()
                              .changeRestDuration,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WorkoutNameField extends StatefulWidget {
  const _WorkoutNameField({required this.initialValue});

  final String initialValue;

  @override
  State<_WorkoutNameField> createState() => _WorkoutNameFieldState();
}

class _WorkoutNameFieldState extends State<_WorkoutNameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _WorkoutNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: _controller,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      placeholder: 'Workout name',
      onChanged: context.read<WorkoutCubit>().updateWorkoutName,
      style: const TextStyle(
        color: CupertinoColors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 44,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
