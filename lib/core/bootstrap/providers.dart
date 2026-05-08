import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/app_api.dart';
import '../../features/dashboard/domain/entities/dashboard_snapshot.dart';
import '../../features/workout/domain/entities/workout_session.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../shared/models/app_models.dart';

final appApiProvider = Provider<AppApi>((ref) {
  return AppApi(ref.watch(apiClientProvider));
});

final dashboardProvider = FutureProvider<DashboardSnapshot>((ref) async {
  final api = ref.watch(appApiProvider);
  return api.fetchDashboard();
});

final exerciseLibraryProvider = FutureProvider<List<ExerciseLibraryItem>>((
  ref,
) async {
  final api = ref.watch(appApiProvider);
  return api.fetchExercises();
});

final routinesProvider = FutureProvider<List<RoutinePlan>>((ref) async {
  final api = ref.watch(appApiProvider);
  return api.fetchRoutines();
});

final analyticsProvider = FutureProvider<AnalyticsSnapshot>((ref) async {
  final api = ref.watch(appApiProvider);
  return api.fetchAnalytics();
});

final nutritionProvider = FutureProvider<NutritionSnapshot>((ref) async {
  final api = ref.watch(appApiProvider);
  return api.fetchNutrition();
});

final physiqueProvider = FutureProvider<PhysiqueSnapshot>((ref) async {
  final api = ref.watch(appApiProvider);
  return api.fetchPhysique();
});

final syncImportsProvider = FutureProvider<List<SyncImportJob>>((ref) async {
  final api = ref.watch(appApiProvider);
  return api.fetchImports();
});

class ActiveWorkoutController extends AsyncNotifier<WorkoutSession> {
  @override
  Future<WorkoutSession> build() async {
    final api = ref.watch(appApiProvider);
    return api.fetchActiveWorkout();
  }

  Future<void> finishWorkout() async {
    final current = state.value;
    if (current == null) {
      return;
    }
    final api = ref.read(appApiProvider);
    await api.finishWorkout(current.id);
    ref.invalidateSelf();
    ref.invalidate(dashboardProvider);
  }

  Future<void> toggleSet({
    required String exerciseId,
    required String setId,
  }) async {
    final current = state.value;
    if (current == null) {
      return;
    }

    final updatedExercises = current.exercises.map((exercise) {
      if (exercise.id != exerciseId) {
        return exercise;
      }

      return exercise.copyWith(
        sets: exercise.sets.map((set) {
          if (set.id != setId) {
            return set;
          }

          return set.copyWith(isCompleted: !set.isCompleted);
        }).toList(),
      );
    }).toList();

    state = AsyncData(current.copyWith(exercises: updatedExercises));
  }
}

final activeWorkoutProvider =
    AsyncNotifierProvider<ActiveWorkoutController, WorkoutSession>(
      ActiveWorkoutController.new,
    );
