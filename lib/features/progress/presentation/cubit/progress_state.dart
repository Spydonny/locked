import 'package:flutter/foundation.dart';

import '../../../../data/mock/mock_models.dart';

enum ProgressFilter {
  oneWeek('1W', 1),
  oneMonth('1M', 4),
  threeMonths('3M', 8),
  oneYear('1Y', 8),
  all('All', 8);

  const ProgressFilter(this.label, this.visibleWeeks);

  final String label;
  final int visibleWeeks;
}

@immutable
class ProgressState {
  const ProgressState({
    required this.selectedFilter,
    required this.weeklyVolume,
    required this.workoutsPerWeek,
    required this.heatmap,
    required this.personalRecords,
  });

  final ProgressFilter selectedFilter;
  final List<ProgressPoint> weeklyVolume;
  final List<ProgressPoint> workoutsPerWeek;
  final List<HeatmapDay> heatmap;
  final List<PersonalRecord> personalRecords;

  ProgressState copyWith({
    ProgressFilter? selectedFilter,
    List<ProgressPoint>? weeklyVolume,
    List<ProgressPoint>? workoutsPerWeek,
    List<HeatmapDay>? heatmap,
    List<PersonalRecord>? personalRecords,
  }) {
    return ProgressState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      weeklyVolume: weeklyVolume ?? this.weeklyVolume,
      workoutsPerWeek: workoutsPerWeek ?? this.workoutsPerWeek,
      heatmap: heatmap ?? this.heatmap,
      personalRecords: personalRecords ?? this.personalRecords,
    );
  }
}
