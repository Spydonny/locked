import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_gradient_button.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';
import '../widgets/routine_card.dart';
import 'active_workout_page.dart';
import 'finish_workout_page.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  Future<void> _openActiveWorkout(BuildContext context) {
    return Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => const ActiveWorkoutPage()),
    );
  }

  Future<void> _openFinishWorkout(BuildContext context) {
    return Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => const FinishWorkoutPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutCubit, WorkoutState>(
      builder: (context, state) {
        final primaryRoutine = state.recentRoutines.first;

        return CupertinoPageScaffold(
          child: CustomScrollView(
            slivers: [
              const CupertinoSliverNavigationBar(largeTitle: Text('Workout')),
              SliverSafeArea(
                top: false,
                sliver: SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    8,
                    AppSpacing.page,
                    120,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (state.hasCurrentWorkout) ...[
                        FadeSlideIn(
                          child: AppCard(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.surface,
                                AppColors.gradientMiddle.withOpacity(0.28),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () {
                              if (state.stage == WorkoutFlowStage.finished) {
                                _openFinishWorkout(context);
                              } else {
                                _openActiveWorkout(context);
                              }
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.white.withOpacity(
                                      0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    state.stage == WorkoutFlowStage.finished
                                        ? CupertinoIcons.check_mark_circled
                                        : CupertinoIcons.play_circle,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.stage == WorkoutFlowStage.finished
                                            ? 'Workout summary ready'
                                            : 'Resume current workout',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        state.workoutName,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  CupertinoIcons.chevron_right,
                                  color: AppColors.textSecondary,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 40),
                        child: AppGradientButton(
                          label: 'Start Workout',
                          subtitle:
                              '${primaryRoutine.name} - ${primaryRoutine.estimatedMinutes} min',
                          onPressed: () {
                            context.read<WorkoutCubit>().startWorkout(primaryRoutine);
                            _openActiveWorkout(context);
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 80),
                        child: AppCard(
                          onTap: () {
                            context.read<WorkoutCubit>().startEmptyWorkout();
                            _openActiveWorkout(context);
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  CupertinoIcons.add,
                                  color: CupertinoColors.white,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Empty workout',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Start with a blank session and add exercises on the fly.',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.section),
                      const FadeSlideIn(
                        delay: Duration(milliseconds: 120),
                        child: AppSectionHeader(
                          title: 'Recent routines',
                          subtitle: 'Jump back into a structure you already know',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...state.recentRoutines.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: FadeSlideIn(
                            delay: Duration(milliseconds: 140 + (entry.key * 40)),
                            child: RoutineCard(
                              routine: entry.value,
                              onPressed: () {
                                context.read<WorkoutCubit>().startWorkout(
                                  entry.value,
                                );
                                _openActiveWorkout(context);
                              },
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
