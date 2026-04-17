import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/activity_heatmap.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/simple_bar_chart.dart';
import '../cubit/progress_cubit.dart';
import '../cubit/progress_state.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  String _volumeSummary(List<double> values) {
    final total = values.fold<double>(0, (sum, value) => sum + value);
    return '${(total / 1000).toStringAsFixed(1)}k kg in the selected window';
  }

  String _workoutSummary(List<double> values) {
    if (values.isEmpty) {
      return 'No sessions logged yet';
    }

    final average = values.fold<double>(0, (sum, value) => sum + value) /
        values.length;
    return '${average.toStringAsFixed(1)} workouts per week on average';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressCubit, ProgressState>(
      builder: (context, state) {
        return CupertinoPageScaffold(
          child: CustomScrollView(
            slivers: [
              const CupertinoSliverNavigationBar(largeTitle: Text('Progress')),
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
                      FadeSlideIn(
                        child: CupertinoSlidingSegmentedControl<ProgressFilter>(
                          backgroundColor: AppColors.card,
                          thumbColor: AppColors.surfaceMuted,
                          groupValue: state.selectedFilter,
                          children: {
                            for (final filter in ProgressFilter.values)
                              filter: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                child: Text(filter.label),
                              ),
                          },
                          onValueChanged: (filter) {
                            if (filter != null) {
                              context.read<ProgressCubit>().selectFilter(filter);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.section),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Column(
                          key: ValueKey(state.selectedFilter),
                          children: [
                            FadeSlideIn(
                              child: SimpleBarChart(
                                title: 'Weekly volume',
                                summary: _volumeSummary(
                                  state.weeklyVolume
                                      .map((point) => point.value)
                                      .toList(),
                                ),
                                points: state.weeklyVolume,
                                valueLabelBuilder: (value) =>
                                    '${(value / 1000).toStringAsFixed(1)}k',
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeSlideIn(
                              delay: const Duration(milliseconds: 40),
                              child: SimpleBarChart(
                                title: 'Workouts per week',
                                summary: _workoutSummary(
                                  state.workoutsPerWeek
                                      .map((point) => point.value)
                                      .toList(),
                                ),
                                points: state.workoutsPerWeek,
                                valueLabelBuilder: (value) => value.toInt().toString(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.section),
                      const FadeSlideIn(
                        delay: Duration(milliseconds: 80),
                        child: AppSectionHeader(
                          title: 'Streak heatmap',
                          subtitle: 'Consistency over the last eight weeks',
                        ),
                      ),
                      const SizedBox(height: 14),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 120),
                        child: AppCard(child: ActivityHeatmap(days: state.heatmap)),
                      ),
                      const SizedBox(height: AppSpacing.section),
                      const FadeSlideIn(
                        delay: Duration(milliseconds: 160),
                        child: AppSectionHeader(
                          title: 'PR highlights',
                          subtitle: 'Recent bests worth keeping in view',
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...state.personalRecords.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FadeSlideIn(
                            delay: Duration(milliseconds: 180 + (entry.key * 40)),
                            child: AppCard(
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.gradientStart,
                                          AppColors.gradientEnd,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      CupertinoIcons.star_fill,
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.value.lift,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          entry.value.result,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    entry.value.achievedAt,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
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
