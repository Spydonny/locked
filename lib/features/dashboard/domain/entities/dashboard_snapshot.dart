import '../../../../shared/models/app_models.dart';

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.greeting,
    required this.user,
    required this.weeklyGoalProgress,
    required this.recovery,
    required this.quickActions,
    required this.headlineMetrics,
    required this.chartPoints,
  });

  final String greeting;
  final AppUser user;
  final double weeklyGoalProgress;
  final List<RecoveryMetric> recovery;
  final List<QuickActionItem> quickActions;
  final List<StatMetric> headlineMetrics;
  final List<ChartDatum> chartPoints;

  factory DashboardSnapshot.fromJson(Map<String, dynamic> json) {
    final weekly = (json['weekly_progress'] as Map?)?.cast<String, dynamic>() ?? const {};
    final completed = (weekly['completed_workouts'] as num?)?.toInt() ?? 0;
    final goal = (weekly['goal_workouts'] as num?)?.toInt() ?? 0;

    final quickActionsJson = (json['quick_actions'] as List?) ?? const [];
    final headlineJson = (json['headline_metrics'] as List?) ?? const [];
    final chartJson = (json['chart_points'] as List?) ?? const [];

    final recoveryObj = (json['recovery'] as Map?)?.cast<String, dynamic>();

    return DashboardSnapshot(
      greeting: (json['greeting'] ?? '').toString(),
      user: AppUser.fromJson(((json['user'] as Map?) ?? const {}).cast<String, dynamic>()),
      weeklyGoalProgress: goal == 0 ? 0 : (completed / goal),
      recovery: [
        if (recoveryObj != null)
          RecoveryMetric.fromJson({
            'label': recoveryObj['label'] ?? 'Recovery',
            'value': recoveryObj['value'],
          }),
      ],
      quickActions: quickActionsJson
          .whereType<Map>()
          .map((e) => QuickActionItem.fromJson(e.cast<String, dynamic>()))
          .toList(),
      headlineMetrics:
          headlineJson.whereType<Map>().map((e) => StatMetric.fromJson(e.cast<String, dynamic>())).toList(),
      chartPoints: chartJson.whereType<Map>().map((e) => ChartDatum.fromJson(e.cast<String, dynamic>())).toList(),
    );
  }
}
