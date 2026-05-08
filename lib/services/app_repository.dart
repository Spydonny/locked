import '../features/dashboard/domain/entities/dashboard_snapshot.dart';
import '../features/workout/domain/entities/workout_session.dart';
import '../shared/models/app_models.dart';

abstract interface class AppRepository {
  Future<DashboardSnapshot> fetchDashboard();
  Future<WorkoutSession> fetchActiveWorkout();
  Future<List<ExerciseLibraryItem>> fetchExercises();
  Future<List<RoutinePlan>> fetchRoutines();
  Future<AnalyticsSnapshot> fetchAnalytics();
  Future<NutritionSnapshot> fetchNutrition();
  Future<PhysiqueSnapshot> fetchPhysique();
  Future<List<SyncImportJob>> fetchImports();

  Future<void> createWorkout({required String title, String? notes});
  Future<void> finishWorkout(String workoutId);
  Future<void> createRoutine({
    required String title,
    required String subtitle,
    required List<String> scheduleDays,
  });
  Future<void> createNutritionEntry({
    required String mealType,
    required String title,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  });
  Future<void> createBodyMetric({
    required double weight,
    double? bodyFat,
    double? chest,
    double? waist,
  });
}
