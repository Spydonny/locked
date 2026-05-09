import 'dart:typed_data';

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

final socialFeedProvider =
    FutureProvider.family<SocialFeedSnapshot, SocialFeedScope>((
      ref,
      scope,
    ) async {
      final api = ref.watch(appApiProvider);
      return api.fetchSocialFeed(scope: scope);
    });

class ActiveWorkoutController extends AsyncNotifier<WorkoutSession?> {
  @override
  Future<WorkoutSession?> build() async {
    final api = ref.watch(appApiProvider);
    return api.fetchActiveWorkout();
  }

  Future<void> startWorkout() async {
    final current = state.value;
    if (current != null && current.isActive) {
      return;
    }

    final api = ref.read(appApiProvider);
    final created = await api.createWorkout(title: _defaultWorkoutTitle());
    state = AsyncData(created);
    ref.invalidate(dashboardProvider);
  }

  Future<void> completeWorkout({
    String? caption,
    List<int>? photoBytes,
    String? filename,
    String? contentType,
    bool shareToFeed = false,
  }) async {
    final current = state.value;
    if (current == null) {
      return;
    }
    final api = ref.read(appApiProvider);
    await api.completeWorkout(
      workoutId: current.id,
      caption: caption,
      photoBytes: photoBytes == null ? null : Uint8List.fromList(photoBytes),
      filename: filename,
      contentType: contentType,
      shareToFeed: shareToFeed,
    );
    state = const AsyncData(null);
    ref.invalidate(dashboardProvider);
    ref.invalidate(socialFeedProvider(SocialFeedScope.all));
    ref.invalidate(socialFeedProvider(SocialFeedScope.following));
  }

  Future<void> addExercise(ExerciseLibraryItem item) async {
    final current = await _requireWorkout();
    if (current == null) {
      return;
    }

    final exerciseIndex = current.exercises.length + 1;
    final exercise = WorkoutExercise(
      id: _createId('exercise'),
      exerciseId: item.id,
      name: item.name,
      muscleGroup: item.category,
      equipment: item.equipment,
      notes: '',
      sets: List.generate(
        3,
        (index) => WorkoutSetEntry(
          id: _createId('set'),
          label: 'Set ${index + 1}',
          weight: 0,
          reps: 10,
          rpe: 8,
        ),
      ),
    );

    await _persist(
      current.copyWith(
        title: current.title.isEmpty ? 'Workout $exerciseIndex' : current.title,
        exercises: [...current.exercises, exercise],
      ),
    );
  }

  Future<void> removeExercise(String exerciseId) async {
    final current = state.value;
    if (current == null) {
      return;
    }

    final updatedExercises = current.exercises
        .where((exercise) => exercise.id != exerciseId)
        .toList();
    await _persist(current.copyWith(exercises: updatedExercises));
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

    await _persist(current.copyWith(exercises: updatedExercises));
  }

  Future<void> addSet(String exerciseId) async {
    final current = state.value;
    if (current == null) {
      return;
    }

    final updatedExercises = current.exercises.map((exercise) {
      if (exercise.id != exerciseId) {
        return exercise;
      }

      final nextNumber = exercise.sets.length + 1;
      return exercise.copyWith(
        sets: [
          ...exercise.sets,
          WorkoutSetEntry(
            id: _createId('set'),
            label: 'Set $nextNumber',
            weight: 0,
            reps: 10,
            rpe: 8,
          ),
        ],
      );
    }).toList();

    await _persist(current.copyWith(exercises: updatedExercises));
  }

  Future<void> removeSet({
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

      final filtered = exercise.sets.where((set) => set.id != setId).toList();
      return exercise.copyWith(sets: _renumberSets(filtered));
    }).toList();

    await _persist(current.copyWith(exercises: updatedExercises));
  }

  Future<void> updateSet({
    required String exerciseId,
    required String setId,
    double? weight,
    int? reps,
    int? rpe,
    bool? isCompleted,
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

          return set.copyWith(
            weight: weight ?? set.weight,
            reps: reps ?? set.reps,
            rpe: rpe ?? set.rpe,
            isCompleted: isCompleted ?? set.isCompleted,
          );
        }).toList(),
      );
    }).toList();

    await _persist(current.copyWith(exercises: updatedExercises));
  }

  Future<WorkoutSession?> _requireWorkout() async {
    final current = state.value;
    if (current != null) {
      return current;
    }

    final api = ref.read(appApiProvider);
    final created = await api.createWorkout(title: _defaultWorkoutTitle());
    state = AsyncData(created);
    ref.invalidate(dashboardProvider);
    return created;
  }

  Future<void> _persist(WorkoutSession session) async {
    final api = ref.read(appApiProvider);
    final saved = await api.saveWorkout(session);
    state = AsyncData(saved);
    ref.invalidate(dashboardProvider);
  }
}

final activeWorkoutProvider =
    AsyncNotifierProvider<ActiveWorkoutController, WorkoutSession?>(
      ActiveWorkoutController.new,
    );

String _defaultWorkoutTitle() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return 'Workout $month/$day';
}

String _createId(String prefix) {
  return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
}

List<WorkoutSetEntry> _renumberSets(List<WorkoutSetEntry> sets) {
  return [
    for (var index = 0; index < sets.length; index += 1)
      sets[index].copyWith(label: 'Set ${index + 1}'),
  ];
}
