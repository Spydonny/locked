import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bootstrap/providers.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../shared/widgets/app_page_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/metric_tile.dart';
import '../../../../shared/widgets/monochrome_chart.dart';
import '../../../../shared/widgets/progress_bar.dart';
import '../../../../shared/widgets/quick_action_button.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../shared/widgets/shimmer_block.dart';
import '../../../../theme/app_colors.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(dashboardProvider);
    final authUser = ref.watch(authControllerProvider).snapshot.user;

    return AppPageScaffold(
      child: snapshot.when(
        data: (data) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.greeting}, ${authUser?.displayName ?? data.user.displayName}',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.6,
                      ),
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.15),
                    const SizedBox(height: 10),
                    const Text(
                      'Your recovery looks strong. One good session keeps the streak alive tonight.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ).animate(delay: 100.ms).fadeIn(duration: 550.ms),
                    const SizedBox(height: 22),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Weekly Goal',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ProgressBar(
                                  value: data.weeklyGoalProgress,
                                  height: 12,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                '${(data.weeklyGoalProgress * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            '4 of 5 workouts logged this week',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ).animate(delay: 140.ms).fadeIn(duration: 550.ms),
                    const SizedBox(height: 22),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.headlineMetrics.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.15,
                          ),
                      itemBuilder: (context, index) {
                        final metric = data.headlineMetrics[index];
                        return MetricTile(
                          label: metric.label,
                          value: metric.value,
                          delta: metric.delta,
                        ).animate(delay: (180 + (index * 60)).ms).fadeIn();
                      },
                    ),
                    const SizedBox(height: 28),
                    const SectionTitle(
                      title: 'Quick Actions',
                      subtitle: 'Everything you need within thumb reach',
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: data.quickActions.map((action) {
                        return QuickActionButton(
                          label: action.label,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            context.push(action.route);
                          },
                        );
                      }).toList(),
                    ).animate(delay: 260.ms).fadeIn(),
                    const SizedBox(height: 28),
                    MonochromeChart(
                      title: 'Volume Trend',
                      subtitle: 'Weekly workload progression',
                      points: data.chartPoints,
                    ).animate(delay: 320.ms).fadeIn(duration: 550.ms),
                    const SizedBox(height: 28),
                    const SectionTitle(
                      title: 'Muscle Recovery',
                      subtitle: 'Auto-estimated readiness by target region',
                    ),
                    const SizedBox(height: 14),
                    ...data.recovery.asMap().entries.map((entry) {
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.label,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: ProgressBar(
                                        value: item.recoveryPercent / 100,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${item.recoveryPercent}%',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ).animate(delay: (360 + (entry.key * 50)).ms).fadeIn(),
                      );
                    }),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const _DashboardSkeleton(),
        error: (error, _) => Center(child: Text('$error')),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBlock(height: 44, width: 250),
        SizedBox(height: 14),
        ShimmerBlock(height: 18, width: 320),
        SizedBox(height: 24),
        ShimmerBlock(height: 112),
        SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: ShimmerBlock(height: 150)),
            SizedBox(width: 12),
            Expanded(child: ShimmerBlock(height: 150)),
          ],
        ),
      ],
    );
  }
}
