import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/mock/mock_feature_repository.dart';
import '../../../../data/mock/mock_models.dart';
import 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit(MockFeatureRepository repository)
    : _dashboard = repository.getProgressDashboard(),
      super(
        ProgressState(
          selectedFilter: ProgressFilter.oneMonth,
          weeklyVolume: _slice(
            repository.getProgressDashboard().weeklyVolume,
            ProgressFilter.oneMonth,
          ),
          workoutsPerWeek: _slice(
            repository.getProgressDashboard().workoutsPerWeek,
            ProgressFilter.oneMonth,
          ),
          heatmap: repository.getProgressDashboard().heatmap,
          personalRecords: repository.getProgressDashboard().personalRecords,
        ),
      );

  final ProgressDashboardData _dashboard;

  void selectFilter(ProgressFilter filter) {
    emit(
      state.copyWith(
        selectedFilter: filter,
        weeklyVolume: _slice(_dashboard.weeklyVolume, filter),
        workoutsPerWeek: _slice(_dashboard.workoutsPerWeek, filter),
      ),
    );
  }

  static List<ProgressPoint> _slice(
    List<ProgressPoint> points,
    ProgressFilter filter,
  ) {
    if (filter == ProgressFilter.all) {
      return points;
    }

    final startIndex = points.length > filter.visibleWeeks
        ? points.length - filter.visibleWeeks
        : 0;

    return points.skip(startIndex).toList();
  }
}
