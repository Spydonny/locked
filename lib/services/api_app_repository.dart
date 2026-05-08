import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../features/dashboard/domain/entities/dashboard_snapshot.dart';
import '../features/workout/domain/entities/workout_session.dart';
import '../shared/models/app_models.dart';
import 'app_repository.dart';

class ApiAppRepository implements AppRepository {
  ApiAppRepository(this._client);

  final ApiClient _client;

  Dio get _dio => _client.dio;

  @override
  Future<DashboardSnapshot> fetchDashboard() async {
    final response = await _dio.get<dynamic>('/dashboard');
    final data = (response.data as Map).cast<String, dynamic>();
    return DashboardSnapshot.fromJson(data);
  }

  @override
  Future<WorkoutSession> fetchActiveWorkout() async {
    final response = await _dio.get<dynamic>('/workouts');
    final items = (response.data as List?) ?? const [];
    if (items.isEmpty) {
      return const WorkoutSession(
        id: 'none',
        title: 'No active workout',
        durationLabel: '00:00:00',
        restTimerSeconds: 75,
        exercises: [],
      );
    }

    final latest = (items.first as Map).cast<String, dynamic>();
    return WorkoutSession.fromJson(latest);
  }

  @override
  Future<List<ExerciseLibraryItem>> fetchExercises() async {
    final response = await _dio.get<dynamic>('/exercises');
    final items = (response.data as List?) ?? const [];
    return items
        .whereType<Map>()
        .map((e) => ExerciseLibraryItem.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<List<RoutinePlan>> fetchRoutines() async {
    final response = await _dio.get<dynamic>('/routines');
    final items = (response.data as List?) ?? const [];
    return items
        .whereType<Map>()
        .map((e) => RoutinePlan.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<AnalyticsSnapshot> fetchAnalytics() async {
    final response = await _dio.get<dynamic>('/analytics/summary');
    final data = (response.data as Map).cast<String, dynamic>();
    return AnalyticsSnapshot.fromJson(data);
  }

  @override
  Future<NutritionSnapshot> fetchNutrition() async {
    final response = await _dio.get<dynamic>('/nutrition');
    final items = (response.data as List?) ?? const [];

    int calories = 0;
    int protein = 0;
    int carbs = 0;
    int fat = 0;

    final meals = <MealEntry>[];
    for (final entry in items.whereType<Map>()) {
      final m = entry.cast<String, dynamic>();
      calories += (m['calories'] as num?)?.toInt() ?? 0;
      protein += (m['protein'] as num?)?.toInt() ?? 0;
      carbs += (m['carbs'] as num?)?.toInt() ?? 0;
      fat += (m['fat'] as num?)?.toInt() ?? 0;

      meals.add(
        MealEntry(
          title: (m['meal_type'] ?? 'Meal').toString(),
          subtitle: (m['title'] ?? '').toString(),
        ),
      );
    }

    return NutritionSnapshot(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      hydrationLiters: 0,
      meals: meals,
    );
  }

  @override
  Future<PhysiqueSnapshot> fetchPhysique() async {
    final response = await _dio.get<dynamic>('/physique');
    final items = (response.data as List?) ?? const [];

    double currentWeight = 0;
    double bodyFat = 0;
    int chest = 0;
    int waist = 0;

    if (items.isNotEmpty) {
      final latest = (items.first as Map).cast<String, dynamic>();
      currentWeight = (latest['weight'] as num?)?.toDouble() ?? 0;
      bodyFat = (latest['body_fat'] as num?)?.toDouble() ?? 0;
      chest = (latest['chest'] as num?)?.toInt() ?? 0;
      waist = (latest['waist'] as num?)?.toInt() ?? 0;
    }

    final trend = <ChartDatum>[];
    for (final entry in items.whereType<Map>()) {
      final m = entry.cast<String, dynamic>();
      final measuredAt = (m['measured_at'] ?? '').toString();
      final label = measuredAt.length >= 7 ? measuredAt.substring(5, 7) : measuredAt;
      trend.add(
        ChartDatum(
          label: label.isEmpty ? '—' : label,
          value: (m['weight'] as num?)?.toDouble() ?? 0,
        ),
      );
      if (trend.length >= 5) break;
    }

    return PhysiqueSnapshot(
      currentWeight: currentWeight,
      bodyFat: bodyFat,
      chest: chest,
      waist: waist,
      trend: trend.reversed.toList(),
    );
  }

  @override
  Future<List<SyncImportJob>> fetchImports() async {
    final response = await _dio.get<dynamic>('/sync/status');
    final items = (response.data as List?) ?? const [];
    return items.whereType<Map>().map((e) {
      final m = e.cast<String, dynamic>();
      return SyncImportJob(
        title: (m['provider'] ?? '').toString(),
        subtitle: (m['message'] ?? '').toString(),
        status: (m['status'] ?? '').toString(),
      );
    }).toList();
  }

  @override
  Future<void> createWorkout({required String title, String? notes}) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _dio.post<dynamic>(
      '/workouts',
      data: {
        'title': title,
        'notes': notes,
        'started_at': now,
      },
    );
  }

  @override
  Future<void> finishWorkout(String workoutId) async {
    await _dio.post<dynamic>('/workouts/$workoutId/finish');
  }

  @override
  Future<void> createRoutine({
    required String title,
    required String subtitle,
    required List<String> scheduleDays,
  }) async {
    await _dio.post<dynamic>(
      '/routines',
      data: {
        'title': title,
        'subtitle': subtitle,
        'schedule_days': scheduleDays,
      },
    );
  }

  @override
  Future<void> createNutritionEntry({
    required String mealType,
    required String title,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _dio.post<dynamic>(
      '/nutrition',
      data: {
        'meal_type': mealType,
        'title': title,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'consumed_at': now,
      },
    );
  }

  @override
  Future<void> createBodyMetric({
    required double weight,
    double? bodyFat,
    double? chest,
    double? waist,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _dio.post<dynamic>(
      '/physique',
      data: {
        'weight': weight,
        'body_fat': bodyFat,
        'chest': chest,
        'waist': waist,
        'measured_at': now,
      },
    );
  }
}

