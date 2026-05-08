import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
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
                    ? _EmptyExerciseList(
                        onAddExercise: _showExercisePicker,
                      )
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
                              onUpdateSet: ({
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
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        onPressed: _showExercisePicker,
                        child: const Text(
                          'Add Exercise',
                          style: TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: const Color(0x14FFFFFF),
                        borderRadius: BorderRadius.circular(20),
                        onPressed: session.exercises.isEmpty
                            ? null
                            : () async {
                                HapticFeedback.heavyImpact();
                                await _showFinishSheet(session);
                              },
                        child: const Text(
                          'Finish Workout',
                          style: TextStyle(
                            color: AppColors.white,
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
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => _FinishWorkoutSheet(
        onSubmit: ({
          required String caption,
          Uint8List? photoBytes,
          String? filename,
          String? contentType,
        }) async {
          await ref.read(activeWorkoutProvider.notifier).completeWorkout(
                caption: caption,
                photoBytes: photoBytes,
                filename: filename,
                contentType: contentType,
              );
          if (mounted) {
            Navigator.of(context).pop();
            context.go('/dashboard');
          }
        },
      ),
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
                style: TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                onPressed: onStart,
                child: const Text(
                  'Start Workout',
                  style: TextStyle(
                    color: AppColors.black,
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
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          CupertinoButton(
            color: const Color(0x16FFFFFF),
            borderRadius: BorderRadius.circular(18),
            onPressed: onAddExercise,
            child: const Text(
              'Choose Exercise',
              style: TextStyle(
                color: AppColors.white,
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
  }) onUpdateSet;
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
                minSize: 0,
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
                onWeightChanged: (value) => onUpdateSet(
                  setId: set.id,
                  weight: value,
                ),
                onRepsChanged: (value) => onUpdateSet(
                  setId: set.id,
                  reps: value,
                ),
                onRpeChanged: (value) => onUpdateSet(
                  setId: set.id,
                  rpe: value,
                ),
              ),
            );
          }),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onAddSet,
            child: const Text(
              '+ Add Set',
              style: TextStyle(
                color: AppColors.white,
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: set.isCompleted ? const Color(0x20FFFFFF) : const Color(0x12FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x18FFFFFF)),
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
                minSize: 0,
                padding: const EdgeInsets.only(right: 10),
                onPressed: onRemove,
                child: const Icon(
                  CupertinoIcons.minus_circle,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              CupertinoButton(
                minSize: 0,
                padding: EdgeInsets.zero,
                onPressed: onToggleCompleted,
                child: Icon(
                  set.isCompleted
                      ? CupertinoIcons.check_mark_circled_solid
                      : CupertinoIcons.circle,
                  color: AppColors.white,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x10FFFFFF),
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
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 28,
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
                  minSize: 28,
                  onPressed: onIncrease,
                  child: const Icon(
                    CupertinoIcons.plus_circle_fill,
                    color: AppColors.white,
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

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.78,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: const BoxDecoration(
            color: Color(0xFF111111),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0x32FFFFFF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pick Exercise',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Search your library and drop an exercise straight into the active session.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              CupertinoSearchTextField(
                controller: _searchController,
                backgroundColor: const Color(0x14FFFFFF),
                style: const TextStyle(color: AppColors.white),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: exercises.when(
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
                      return const Center(
                        child: Text(
                          'No exercises match this search yet.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            color: AppColors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${item.category} / ${item.equipment}',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    CupertinoIcons.add_circled_solid,
                                    color: AppColors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CupertinoActivityIndicator()),
                  error: (error, _) => Center(child: Text('$error')),
                ),
              ),
            ],
          ),
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
  }) onSubmit;

  @override
  State<_FinishWorkoutSheet> createState() => _FinishWorkoutSheetState();
}

class _FinishWorkoutSheetState extends State<_FinishWorkoutSheet> {
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Uint8List? _photoBytes;
  String? _filename;
  String? _contentType;
  bool _submitting = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: const BoxDecoration(
            color: Color(0xFF111111),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0x32FFFFFF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Finish Workout',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Persist the completed workout, then attach a progress photo and a short caption.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 18),
                CupertinoTextField(
                  controller: _captionController,
                  maxLines: 3,
                  padding: const EdgeInsets.all(14),
                  placeholder: 'Caption for this session',
                  placeholderStyle: const TextStyle(
                    color: AppColors.textTertiary,
                  ),
                  style: const TextStyle(color: AppColors.white),
                  decoration: BoxDecoration(
                    color: const Color(0x14FFFFFF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                const SizedBox(height: 16),
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
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        color: const Color(0x16FFFFFF),
                        borderRadius: BorderRadius.circular(18),
                        onPressed: _pickImage,
                        child: Text(
                          _photoBytes == null ? 'Pick Photo' : 'Replace Photo',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (_photoBytes != null) ...[
                      const SizedBox(width: 10),
                      CupertinoButton(
                        color: const Color(0x10FFFFFF),
                        borderRadius: BorderRadius.circular(18),
                        onPressed: () {
                          setState(() {
                            _photoBytes = null;
                            _filename = null;
                            _contentType = null;
                          });
                        },
                        child: const Icon(
                          CupertinoIcons.delete,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ],
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
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const CupertinoActivityIndicator(
                            color: AppColors.black,
                          )
                        : const Text(
                            'Complete & Save',
                            style: TextStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
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
    setState(() {
      _submitting = true;
    });

    try {
      await widget.onSubmit(
        caption: _captionController.text.trim(),
        photoBytes: _photoBytes,
        filename: _filename,
        contentType: _contentType,
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
