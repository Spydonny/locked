import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bootstrap/providers.dart';
import '../../../../features/workout/domain/entities/workout_session.dart';
import '../../../../shared/widgets/app_page_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../theme/app_colors.dart';

class WorkoutPage extends ConsumerWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(activeWorkoutProvider);

    return AppPageScaffold(
      child: workout.when(
        data: (session) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                            letterSpacing: -1.5,
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
                            letterSpacing: 1.5,
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
              ).animate().fadeIn(duration: 450.ms),
              const SizedBox(height: 14),
              GlassCard(
                child: Row(
                  children: [
                    _WorkoutMeta(label: 'Duration', value: session.durationLabel),
                    _WorkoutMeta(label: 'Supersets', value: '2'),
                    _WorkoutMeta(label: 'Notes', value: 'Live'),
                  ],
                ),
              ).animate(delay: 90.ms).fadeIn(duration: 500.ms),
              const SizedBox(height: 24),
              const SectionTitle(
                title: 'Exercises',
                subtitle: 'Swipe to mark sets complete with haptics feedback',
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.builder(
                  itemCount: session.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = session.exercises[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ExerciseCard(exercise: exercise),
                    ).animate(delay: (120 + (index * 60)).ms).fadeIn();
                  },
                ),
              ),
              const SizedBox(height: 10),
              GlassCard(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        onPressed: () async {
                          HapticFeedback.heavyImpact();
                          await showCupertinoDialog<void>(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text('Coming soon'),
                              content: const Text('Exercise picker is next.'),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () => context.pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
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
                        onPressed: () async {
                          HapticFeedback.mediumImpact();
                          await ref.read(activeWorkoutProvider.notifier).finishWorkout();
                          if (context.mounted) {
                            context.go('/dashboard');
                          }
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

class _ExerciseCard extends ConsumerWidget {
  const _ExerciseCard({required this.exercise});

  final WorkoutExercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      '${exercise.muscleGroup}  •  ${exercise.notes}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.line_horizontal_3,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...exercise.sets.map((set) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Dismissible(
                key: ValueKey(set.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  HapticFeedback.mediumImpact();
                  await ref
                      .read(activeWorkoutProvider.notifier)
                      .toggleSet(exerciseId: exercise.id, setId: set.id);
                  return false;
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 18),
                  decoration: BoxDecoration(
                    color: const Color(0x22FFFFFF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    CupertinoIcons.check_mark_circled_solid,
                    color: AppColors.white,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: set.isCompleted
                        ? const Color(0x22FFFFFF)
                        : const Color(0x12FFFFFF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0x18FFFFFF)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          set.label,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(child: Text('${set.weight.toStringAsFixed(0)} kg')),
                      Expanded(child: Text('${set.reps} reps')),
                      Expanded(child: Text('RPE ${set.rpe}')),
                      Icon(
                        set.isCompleted
                            ? CupertinoIcons.check_mark_circled_solid
                            : CupertinoIcons.circle,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
