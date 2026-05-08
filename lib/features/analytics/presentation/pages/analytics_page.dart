import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/bootstrap/providers.dart';
import '../../../../shared/widgets/app_page_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/metric_tile.dart';
import '../../../../shared/widgets/monochrome_chart.dart';
import '../../../../shared/widgets/progress_bar.dart';
import '../../../../theme/app_colors.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);

    return AppPageScaffold(
      child: analytics.when(
        data: (data) {
          return ListView(
            children: [
              const Text(
                'Analytics',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'Strength progression, muscle focus, fatigue tracking and consistency scoring.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: MetricTile(
                      label: 'Consistency',
                      value: '${data.consistencyScore}%',
                      delta: 'Last 30 days',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricTile(
                      label: 'Fatigue',
                      value: '${data.fatigueScore}',
                      delta: 'System load',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              MonochromeChart(
                title: 'Volume Trend',
                subtitle: 'Weekly tonnage progression',
                points: data.volumeTrend,
              ),
              const SizedBox(height: 22),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Muscle Focus',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...data.focusDistribution.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 88,
                              child: Text(
                                item.label,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ProgressBar(value: item.value / 30),
                            ),
                            const SizedBox(width: 12),
                            Text('${item.value.toStringAsFixed(0)}%'),
                          ],
                        ),
                      );
                    }),
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
