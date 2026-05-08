import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/domain/entities/dashboard_snapshot.dart';
import '../../features/workout/domain/entities/workout_session.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../services/app_repository.dart';
import '../../services/api_app_repository.dart';
import '../../shared/models/app_models.dart';

final appRepositoryProvider = Provider<AppRepository>((ref) {
  return ApiAppRepository(ref.watch(apiClientProvider));
});

class CurrentUserController extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  void signIn(AppUser user) {
    state = user;
  }

  void signOut() {
    state = null;
  }
}

final currentUserProvider = NotifierProvider<CurrentUserController, AppUser?>(
  CurrentUserController.new,
);

final dashboardProvider = FutureProvider<DashboardSnapshot>((ref) async {
  final repository = ref.watch(appRepositoryProvider);
  return repository.fetchDashboard();
});

final exerciseLibraryProvider = FutureProvider<List<ExerciseLibraryItem>>((
  ref,
) async {
  final repository = ref.watch(appRepositoryProvider);
  return repository.fetchExercises();
});

final routinesProvider = FutureProvider<List<RoutinePlan>>((ref) async {
  final repository = ref.watch(appRepositoryProvider);
  return repository.fetchRoutines();
});

final analyticsProvider = FutureProvider<AnalyticsSnapshot>((ref) async {
  final repository = ref.watch(appRepositoryProvider);
  return repository.fetchAnalytics();
});

final nutritionProvider = FutureProvider<NutritionSnapshot>((ref) async {
  final repository = ref.watch(appRepositoryProvider);
  return repository.fetchNutrition();
});

final physiqueProvider = FutureProvider<PhysiqueSnapshot>((ref) async {
  final repository = ref.watch(appRepositoryProvider);
  return repository.fetchPhysique();
});

final syncImportsProvider = FutureProvider<List<SyncImportJob>>((ref) async {
  final repository = ref.watch(appRepositoryProvider);
  return repository.fetchImports();
});

class ActiveWorkoutController extends AsyncNotifier<WorkoutSession> {
  @override
  Future<WorkoutSession> build() async {
    final repository = ref.watch(appRepositoryProvider);
    return repository.fetchActiveWorkout();
  }

  Future<void> finishWorkout() async {
    final current = state.value;
    if (current == null) {
      return;
    }
    final repository = ref.read(appRepositoryProvider);
    await repository.finishWorkout(current.id);
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
