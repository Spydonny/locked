import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/bootstrap/providers.dart';
import '../../../../features/workout/domain/entities/workout_session.dart';
import '../../../../shared/models/app_models.dart';
import '../../../../shared/widgets/app_page_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../theme/app_colors.dart';

class WorkoutPage extends ConsumerStatefulWidget {
  const WorkoutPage({super.key});

  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(activeWorkoutProvider);

    return AppPageScaffold(
      child: workout.when(
        data: (session) {
          if (session == null) {
            return _EmptyWorkoutState(
              onStart: () async {
                HapticFeedback.mediumImpact();
                await ref.read(activeWorkoutProvider.notifier).startWorkout();
                if (mounted) {
                  _showExercisePicker();
                }
              },
            );
          }

          final liveDuration = _visibleDuration(session);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Active Workout',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          session.title,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          session.exercises.isEmpty
                              ? 'Pick your first exercise and start logging sets.'
                              : '${session.completedSetCount}/${session.totalSetCount} sets completed',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'REST',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${session.restTimerSeconds}s',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 14),
              GlassCard(
                child: Row(
                  children: [
                    _WorkoutMeta(
                      label: 'Duration',
                      value: formatDuration(liveDuration),
                    ),
                    _WorkoutMeta(
                      label: 'Exercises',
                      value: '${session.exercises.length}',
                    ),
                    _WorkoutMeta(
                      label: 'Sets',
                      value: '${session.totalSetCount}',
                    ),
                  ],
                ),
              ).animate(delay: 80.ms).fadeIn(duration: 450.ms),
              const SizedBox(height: 24),
              const SectionTitle(
                title: 'Exercises',
                subtitle:
                    'Pick from the library, tune weights and reps inline, then finish with a progress photo.',
              ),
              const SizedBox(height: 14),
              Expanded(
                child: session.exercises.isEmpty
                    ? _EmptyExerciseList(onAddExercise: _showExercisePicker)
                    : ListView.builder(
                        itemCount: session.exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = session.exercises[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ExerciseCard(
                              exercise: exercise,
                              onDelete: () async {
                                HapticFeedback.mediumImpact();
                                await ref
                                    .read(activeWorkoutProvider.notifier)
                                    .removeExercise(exercise.id);
                              },
                              onAddSet: () async {
                                HapticFeedback.selectionClick();
                                await ref
                                    .read(activeWorkoutProvider.notifier)
                                    .addSet(exercise.id);
                              },
                              onToggleSet: (setId) async {
                                HapticFeedback.selectionClick();
                                await ref
                                    .read(activeWorkoutProvider.notifier)
                                    .toggleSet(
                                      exerciseId: exercise.id,
                                      setId: setId,
                                    );
                              },
                              onUpdateSet:
                                  ({
                                    required String setId,
                                    double? weight,
                                    int? reps,
                                    int? rpe,
                                    bool? isCompleted,
                                  }) async {
                                    await ref
                                        .read(activeWorkoutProvider.notifier)
                                        .updateSet(
                                          exerciseId: exercise.id,
                                          setId: setId,
                                          weight: weight,
                                          reps: reps,
                                          rpe: rpe,
                                          isCompleted: isCompleted,
                                        );
                                  },
                              onRemoveSet: (setId) async {
                                HapticFeedback.lightImpact();
                                await ref
                                    .read(activeWorkoutProvider.notifier)
                                    .removeSet(
                                      exerciseId: exercise.id,
                                      setId: setId,
                                    );
                              },
                            ),
                          ).animate(delay: (120 + (index * 50)).ms).fadeIn();
                        },
                      ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: _primaryButtonColor(context),
                        borderRadius: BorderRadius.circular(20),
                        onPressed: _showExercisePicker,
                        child: Text(
                          'Add Exercise',
                          style: TextStyle(
                            color: _primaryButtonForeground(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: _secondarySurfaceColor(context),
                        borderRadius: BorderRadius.circular(20),
                        onPressed: session.exercises.isEmpty
                            ? null
                            : () async {
                                HapticFeedback.heavyImpact();
                                await _showFinishSheet(session);
                              },
                        child: Text(
                          'Finish Workout',
                          style: TextStyle(
                            color: _secondaryButtonForeground(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
    );
  }

  int _visibleDuration(WorkoutSession session) {
    if (!session.isActive || session.startedAt == null) {
      return session.durationSeconds;
    }

    final now = DateTime.now().toUtc();
    final startedAt = session.startedAt!.toUtc();
    final liveDuration = now.difference(startedAt).inSeconds;
    return liveDuration > session.durationSeconds
        ? liveDuration
        : session.durationSeconds;
  }

  Future<void> _showExercisePicker() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => _ExercisePickerSheet(
        onSelect: (item) async {
          Navigator.of(context).pop();
          await ref.read(activeWorkoutProvider.notifier).addExercise(item);
        },
      ),
    );
  }

  Future<void> _showFinishSheet(WorkoutSession session) async {
    final router = GoRouter.of(context);
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) {
        final navigator = Navigator.of(sheetContext);
        return _FinishWorkoutSheet(
          onSubmit:
              ({
                required String caption,
                Uint8List? photoBytes,
                String? filename,
                String? contentType,
                required bool shareToFeed,
              }) async {
                await ref
                    .read(activeWorkoutProvider.notifier)
                    .completeWorkout(
                      caption: caption,
                      photoBytes: photoBytes,
                      filename: filename,
                      contentType: contentType,
                      shareToFeed: shareToFeed,
                    );
                if (!mounted) {
                  return;
                }

                navigator.pop();
                router.go(shareToFeed ? '/social' : '/dashboard');
              },
        );
      },
    );
  }
}

class _EmptyWorkoutState extends StatelessWidget {
  const _EmptyWorkoutState({required this.onStart});

  final Future<void> Function() onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Start a Workout',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Create an active session, pick exercises from your library, edit sets and weights, then finish with a photo and caption saved in MongoDB.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 22),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                color: _primaryButtonColor(context),
                borderRadius: BorderRadius.circular(20),
                onPressed: onStart,
                child: Text(
                  'Start Workout',
                  style: TextStyle(
                    color: _primaryButtonForeground(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.08),
      ),
    );
  }
}

class _EmptyExerciseList extends StatelessWidget {
  const _EmptyExerciseList({required this.onAddExercise});

  final Future<void> Function() onAddExercise;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.add_circled,
            color: AppColors.textSecondary,
            size: 42,
          ),
          const SizedBox(height: 14),
          const Text(
            'No exercises yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pick an exercise and we will scaffold a few starter sets for you.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 18),
          CupertinoButton(
            color: _secondarySurfaceColor(context),
            borderRadius: BorderRadius.circular(18),
            onPressed: onAddExercise,
            child: Text(
              'Choose Exercise',
              style: TextStyle(
                color: _secondaryButtonForeground(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutMeta extends StatelessWidget {
  const _WorkoutMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.onDelete,
    required this.onAddSet,
    required this.onToggleSet,
    required this.onUpdateSet,
    required this.onRemoveSet,
  });

  final WorkoutExercise exercise;
  final Future<void> Function() onDelete;
  final Future<void> Function() onAddSet;
  final Future<void> Function(String setId) onToggleSet;
  final Future<void> Function({
    required String setId,
    double? weight,
    int? reps,
    int? rpe,
    bool? isCompleted,
  })
  onUpdateSet;
  final Future<void> Function(String setId) onRemoveSet;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (exercise.muscleGroup.isNotEmpty) exercise.muscleGroup,
      if (exercise.equipment.isNotEmpty) exercise.equipment,
    ].join(' / ');

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle.isEmpty ? 'Custom exercise block' : subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                onPressed: onDelete,
                child: const Icon(
                  CupertinoIcons.trash,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...exercise.sets.map((set) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SetCard(
                set: set,
                onToggleCompleted: () => onToggleSet(set.id),
                onRemove: () => onRemoveSet(set.id),
                onWeightChanged: (value) =>
                    onUpdateSet(setId: set.id, weight: value),
                onRepsChanged: (value) =>
                    onUpdateSet(setId: set.id, reps: value),
                onRpeChanged: (value) => onUpdateSet(setId: set.id, rpe: value),
              ),
            );
          }),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onAddSet,
            child: Text(
              '+ Add Set',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetCard extends StatelessWidget {
  const _SetCard({
    required this.set,
    required this.onToggleCompleted,
    required this.onRemove,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onRpeChanged,
  });

  final WorkoutSetEntry set;
  final Future<void> Function() onToggleCompleted;
  final Future<void> Function() onRemove;
  final Future<void> Function(double value) onWeightChanged;
  final Future<void> Function(int value) onRepsChanged;
  final Future<void> Function(int value) onRpeChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: set.isCompleted
            ? colorScheme.primary.withValues(
                alpha: _isDarkMode(context) ? 0.18 : 0.12,
              )
            : _secondarySurfaceColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _strokeColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                set.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              CupertinoButton(
                minimumSize: Size.zero,
                padding: const EdgeInsets.only(right: 10),
                onPressed: onRemove,
                child: const Icon(
                  CupertinoIcons.minus_circle,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              CupertinoButton(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                onPressed: onToggleCompleted,
                child: Icon(
                  set.isCompleted
                      ? CupertinoIcons.check_mark_circled_solid
                      : CupertinoIcons.circle,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StepperMetric(
                  label: 'Weight',
                  value: '${set.weight.toStringAsFixed(1)} kg',
                  onDecrease: () async {
                    await onWeightChanged(_clampWeight(set.weight - 2.5));
                  },
                  onIncrease: () async {
                    await onWeightChanged(_clampWeight(set.weight + 2.5));
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StepperMetric(
                  label: 'Reps',
                  value: '${set.reps}',
                  onDecrease: () async {
                    await onRepsChanged(set.reps <= 0 ? 0 : set.reps - 1);
                  },
                  onIncrease: () async {
                    await onRepsChanged(set.reps + 1);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StepperMetric(
                  label: 'RPE',
                  value: '${set.rpe}',
                  onDecrease: () async {
                    await onRpeChanged(set.rpe <= 1 ? 1 : set.rpe - 1);
                  },
                  onIncrease: () async {
                    await onRpeChanged(set.rpe >= 10 ? 10 : set.rpe + 1);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperMetric extends StatelessWidget {
  const _StepperMetric({
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final String value;
  final Future<void> Function() onDecrease;
  final Future<void> Function() onIncrease;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _secondarySurfaceColor(
          context,
          darkAlpha: 0.08,
          lightAlpha: 0.92,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(28, 28),
                  onPressed: onDecrease,
                  child: const Icon(
                    CupertinoIcons.minus_circle_fill,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              ),
              Expanded(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(28, 28),
                  onPressed: onIncrease,
                  child: Icon(
                    CupertinoIcons.plus_circle_fill,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExercisePickerSheet extends ConsumerStatefulWidget {
  const _ExercisePickerSheet({required this.onSelect});

  final Future<void> Function(ExerciseLibraryItem item) onSelect;

  @override
  ConsumerState<_ExercisePickerSheet> createState() =>
      _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<_ExercisePickerSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exerciseLibraryProvider);
    final query = _searchController.text.trim().toLowerCase();

    return _BottomSheetFrame(
      maxHeightFactor: 0.82,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 16),
          const Text(
            'Pick Exercise',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Search your library and drop an exercise straight into the active session.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          CupertinoSearchTextField(
            controller: _searchController,
            backgroundColor: _secondarySurfaceColor(context),
            style: TextStyle(color: _secondaryButtonForeground(context)),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          exercises.when(
            data: (items) {
              final filtered = items.where((item) {
                if (query.isEmpty) {
                  return true;
                }

                final haystack =
                    '${item.name} ${item.category} ${item.equipment}'
                        .toLowerCase();
                return haystack.contains(query);
              }).toList();

              if (filtered.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No exercises match this search yet.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 4),
                itemCount: filtered.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => widget.onSelect(item),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      color: _secondaryButtonForeground(
                                        context,
                                      ),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.category} / ${item.equipment}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              CupertinoIcons.add_circled_solid,
                              color: Theme.of(context).colorScheme.primary,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CupertinoActivityIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('$error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: _sheetHandleColor(context),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _FinishWorkoutSheet extends StatefulWidget {
  const _FinishWorkoutSheet({required this.onSubmit});

  final Future<void> Function({
    required String caption,
    Uint8List? photoBytes,
    String? filename,
    String? contentType,
    required bool shareToFeed,
  })
  onSubmit;

  @override
  State<_FinishWorkoutSheet> createState() => _FinishWorkoutSheetState();
}

class _FinishWorkoutSheetState extends State<_FinishWorkoutSheet> {
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Uint8List? _photoBytes;
  String? _filename;
  String? _contentType;
  bool _shareToFeed = true;
  bool _submitting = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetFrame(
      maxHeightFactor: 0.9,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 16),
          const Text(
            'Finish Workout',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Wrap the session, attach a progress photo, and optionally publish it to your feed.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _secondarySurfaceColor(context),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Post to feed',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Share this completed workout to the All and Friends tabs.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                CupertinoSwitch(
                  value: _shareToFeed,
                  onChanged: (value) {
                    setState(() {
                      _shareToFeed = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Caption',
            style: TextStyle(
              color: _secondaryButtonForeground(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: _captionController,
            maxLines: 3,
            padding: const EdgeInsets.all(14),
            placeholder: _shareToFeed
                ? 'Say something about this session'
                : 'Optional workout note',
            placeholderStyle: const TextStyle(color: AppColors.textTertiary),
            style: TextStyle(
              color: _secondaryButtonForeground(context),
              fontSize: 14,
            ),
            decoration: BoxDecoration(
              color: _secondarySurfaceColor(context),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Progress photo',
            style: TextStyle(
              color: _secondaryButtonForeground(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          if (_photoBytes != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.memory(
                _photoBytes!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
          ],
          _PhotoActionButtons(
            hasPhoto: _photoBytes != null,
            onCameraPressed: () => _pickImage(ImageSource.camera),
            onGalleryPressed: () => _pickImage(ImageSource.gallery),
            onRemovePressed: () {
              setState(() {
                _photoBytes = null;
                _filename = null;
                _contentType = null;
              });
            },
          ),
          if (_filename != null) ...[
            const SizedBox(height: 10),
            Text(
              _filename!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: _primaryButtonColor(context),
              borderRadius: BorderRadius.circular(20),
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? CupertinoActivityIndicator(
                      color: _primaryButtonForeground(context),
                    )
                  : Text(
                      _shareToFeed ? 'Complete & Post' : 'Complete Workout',
                      style: TextStyle(
                        color: _primaryButtonForeground(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null) {
      return;
    }

    final bytes = await file.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      _photoBytes = bytes;
      _filename = file.name;
      _contentType = _guessContentType(file.name);
    });
  }

  Future<void> _submit() async {
    if (_shareToFeed && _photoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a progress photo before posting this workout.'),
        ),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      await widget.onSubmit(
        caption: _captionController.text.trim(),
        photoBytes: _photoBytes,
        filename: _filename,
        contentType: _contentType,
        shareToFeed: _shareToFeed,
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

class _PhotoActionButtons extends StatelessWidget {
  const _PhotoActionButtons({
    required this.hasPhoto,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onRemovePressed,
  });

  final bool hasPhoto;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onRemovePressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final actionCount = hasPhoto ? 3 : 2;
        final buttonWidth =
            (constraints.maxWidth - (spacing * (actionCount - 1))) /
            actionCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: buttonWidth,
              child: _SheetActionButton(
                label: hasPhoto ? 'Retake' : 'Take Photo',
                icon: CupertinoIcons.camera,
                onPressed: onCameraPressed,
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: _SheetActionButton(
                label: 'Gallery',
                icon: CupertinoIcons.photo_on_rectangle,
                onPressed: onGalleryPressed,
                subtle: true,
              ),
            ),
            if (hasPhoto)
              SizedBox(
                width: buttonWidth,
                child: _SheetActionButton(
                  label: 'Remove',
                  icon: CupertinoIcons.delete,
                  onPressed: onRemovePressed,
                  subtle: true,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SheetActionButton extends StatelessWidget {
  const _SheetActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.subtle = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      color: subtle
          ? _secondarySurfaceColor(context, darkAlpha: 0.08, lightAlpha: 0.68)
          : _secondarySurfaceColor(context),
      borderRadius: BorderRadius.circular(18),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _secondaryButtonForeground(context), size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryButtonForeground(context),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetFrame extends StatelessWidget {
  const _BottomSheetFrame({required this.child, this.maxHeightFactor = 0.85});

  final Widget child;
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final bottomSafeArea = mediaQuery.padding.bottom;
    final size = mediaQuery.size;
    final isCompactWidth = size.width < 390;
    final isCompactHeight = size.height < 760;
    final textScale = isCompactWidth
        ? 0.92
        : isCompactHeight
        ? 0.96
        : 1.0;
    final horizontalPadding = isCompactWidth ? 14.0 : 18.0;
    final outerMargin = size.width < 640 ? 8.0 : 0.0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: outerMargin),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 560,
                  maxHeight: mediaQuery.size.height * maxHeightFactor,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _sheetBackgroundColor(context),
                    border: Border.all(color: _strokeColor(context)),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 34,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          child: IgnorePointer(
                            child: Container(
                              height: 72,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.08),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        MediaQuery(
                          data: mediaQuery.copyWith(
                            textScaler: TextScaler.linear(textScale),
                          ),
                          child: Scrollbar(
                            thumbVisibility: false,
                            child: SingleChildScrollView(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                16,
                                horizontalPadding,
                                math.max(18, bottomSafeArea + 12),
                              ),
                              child: child,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double _clampWeight(double value) {
  if (value < 0) {
    return 0;
  }
  return double.parse(value.toStringAsFixed(1));
}

String _guessContentType(String filename) {
  final lower = filename.toLowerCase();
  if (lower.endsWith('.png')) {
    return 'image/png';
  }
  if (lower.endsWith('.webp')) {
    return 'image/webp';
  }
  if (lower.endsWith('.gif')) {
    return 'image/gif';
  }
  return 'image/jpeg';
}

bool _isDarkMode(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

Color _primaryButtonColor(BuildContext context) {
  return Theme.of(context).colorScheme.primary;
}

Color _primaryButtonForeground(BuildContext context) {
  return Theme.of(context).colorScheme.onPrimary;
}

Color _secondaryButtonForeground(BuildContext context) {
  return _isDarkMode(context)
      ? AppColors.white
      : Theme.of(context).colorScheme.onSurface;
}

Color _secondarySurfaceColor(
  BuildContext context, {
  double darkAlpha = 0.12,
  double lightAlpha = 0.82,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return _isDarkMode(context)
      ? Colors.white.withValues(alpha: darkAlpha)
      : colorScheme.surfaceContainerHighest.withValues(alpha: lightAlpha);
}

Color _strokeColor(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return _isDarkMode(context)
      ? Colors.white.withValues(alpha: 0.1)
      : colorScheme.outlineVariant.withValues(alpha: 0.5);
}

Color _sheetBackgroundColor(BuildContext context) {
  return _isDarkMode(context)
      ? const Color(0xFF111111)
      : Theme.of(context).colorScheme.surface;
}

Color _sheetHandleColor(BuildContext context) {
  return _isDarkMode(context)
      ? const Color(0x32FFFFFF)
      : Colors.black.withValues(alpha: 0.14);
}
