import '../../features/workout/domain/entities/workout_session.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.streak,
  });

  final String id;
  final String displayName;
  final String email;
  final int streak;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      displayName: (json['display_name'] ?? json['displayName'] ?? '')
          .toString(),
      email: (json['email'] ?? '').toString(),
      streak: (json['streak'] as num?)?.toInt() ?? 0,
    );
  }
}

class ChartDatum {
  const ChartDatum({required this.label, required this.value});

  final String label;
  final double value;

  factory ChartDatum.fromJson(Map<String, dynamic> json) {
    return ChartDatum(
      label: (json['label'] ?? '').toString(),
      value: (json['value'] as num?)?.toDouble() ?? 0,
    );
  }
}

class StatMetric {
  const StatMetric({
    required this.label,
    required this.value,
    required this.delta,
  });

  final String label;
  final String value;
  final String delta;

  factory StatMetric.fromJson(Map<String, dynamic> json) {
    return StatMetric(
      label: (json['label'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
      delta: (json['delta'] ?? json['sublabel'] ?? '').toString(),
    );
  }
}

class RecoveryMetric {
  const RecoveryMetric({required this.label, required this.recoveryPercent});

  final String label;
  final int recoveryPercent;

  factory RecoveryMetric.fromJson(Map<String, dynamic> json) {
    return RecoveryMetric(
      label: (json['label'] ?? '').toString(),
      recoveryPercent:
          (json['recoveryPercent'] as num?)?.toInt() ??
          (json['recovery_percent'] as num?)?.toInt() ??
          (json['value'] as num?)?.toInt() ??
          0,
    );
  }
}

class QuickActionItem {
  const QuickActionItem({required this.label, required this.route});

  final String label;
  final String route;

  factory QuickActionItem.fromJson(Map<String, dynamic> json) {
    return QuickActionItem(
      label: (json['label'] ?? json['title'] ?? '').toString(),
      route: (json['route'] ?? '').toString(),
    );
  }
}

class ExerciseLibraryItem {
  const ExerciseLibraryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.equipment,
    required this.personalRecord,
  });

  final String id;
  final String name;
  final String category;
  final String equipment;
  final String personalRecord;

  factory ExerciseLibraryItem.fromJson(Map<String, dynamic> json) {
    return ExerciseLibraryItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category:
          (json['category'] ??
                  json['muscle_group'] ??
                  json['muscleGroup'] ??
                  '')
              .toString(),
      equipment: (json['equipment'] ?? '').toString(),
      personalRecord: (json['personalRecord'] ?? json['personal_record'] ?? '')
          .toString(),
    );
  }
}

class RoutinePlan {
  const RoutinePlan({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.daysPerWeek,
  });

  final String id;
  final String title;
  final String subtitle;
  final int daysPerWeek;

  factory RoutinePlan.fromJson(Map<String, dynamic> json) {
    final scheduleDays =
        (json['schedule_days'] as List?)?.cast<dynamic>() ?? const [];
    return RoutinePlan(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      daysPerWeek: scheduleDays.length,
    );
  }
}

class AnalyticsSnapshot {
  const AnalyticsSnapshot({
    required this.consistencyScore,
    required this.fatigueScore,
    required this.focusDistribution,
    required this.volumeTrend,
  });

  final int consistencyScore;
  final int fatigueScore;
  final List<ChartDatum> focusDistribution;
  final List<ChartDatum> volumeTrend;

  factory AnalyticsSnapshot.fromJson(Map<String, dynamic> json) {
    final focus =
        (json['muscle_focus'] ??
                json['focusDistribution'] ??
                json['focus_distribution'])
            as List? ??
        const [];
    final trend =
        (json['volume_trend'] ?? json['volumeTrend'] ?? json['volume_trend'])
            as List? ??
        const [];
    return AnalyticsSnapshot(
      consistencyScore:
          (json['consistency_score'] as num?)?.toInt() ??
          (json['consistencyScore'] as num?)?.toInt() ??
          0,
      fatigueScore:
          (json['fatigue_score'] as num?)?.toInt() ??
          (json['fatigueScore'] as num?)?.toInt() ??
          0,
      focusDistribution: focus
          .whereType<Map>()
          .map((e) => ChartDatum.fromJson(e.cast<String, dynamic>()))
          .toList(),
      volumeTrend: trend
          .whereType<Map>()
          .map((e) => ChartDatum.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}

class MealEntry {
  const MealEntry({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  factory MealEntry.fromJson(Map<String, dynamic> json) {
    return MealEntry(
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
    );
  }
}

class NutritionSnapshot {
  const NutritionSnapshot({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.hydrationLiters,
    required this.meals,
  });

  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final double hydrationLiters;
  final List<MealEntry> meals;

  factory NutritionSnapshot.fromJson(Map<String, dynamic> json) {
    final mealsJson = (json['meals'] as List?) ?? const [];
    return NutritionSnapshot(
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      carbs: (json['carbs'] as num?)?.toInt() ?? 0,
      fat: (json['fat'] as num?)?.toInt() ?? 0,
      hydrationLiters:
          (json['hydrationLiters'] as num?)?.toDouble() ??
          (json['hydration_liters'] as num?)?.toDouble() ??
          0,
      meals: mealsJson
          .whereType<Map>()
          .map((e) => MealEntry.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}

class PhysiqueSnapshot {
  const PhysiqueSnapshot({
    required this.currentWeight,
    required this.bodyFat,
    required this.chest,
    required this.waist,
    required this.trend,
  });

  final double currentWeight;
  final double bodyFat;
  final int chest;
  final int waist;
  final List<ChartDatum> trend;

  factory PhysiqueSnapshot.fromJson(Map<String, dynamic> json) {
    final trendJson = (json['trend'] as List?) ?? const [];
    return PhysiqueSnapshot(
      currentWeight:
          (json['currentWeight'] as num?)?.toDouble() ??
          (json['current_weight'] as num?)?.toDouble() ??
          0,
      bodyFat:
          (json['bodyFat'] as num?)?.toDouble() ??
          (json['body_fat'] as num?)?.toDouble() ??
          0,
      chest: (json['chest'] as num?)?.toInt() ?? 0,
      waist: (json['waist'] as num?)?.toInt() ?? 0,
      trend: trendJson
          .whereType<Map>()
          .map((e) => ChartDatum.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}

class SyncImportJob {
  const SyncImportJob({
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final String title;
  final String subtitle;
  final String status;

  factory SyncImportJob.fromJson(Map<String, dynamic> json) {
    return SyncImportJob(
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }
}

enum SocialFeedScope {
  all,
  following;

  String get apiValue => switch (this) {
    SocialFeedScope.all => 'all',
    SocialFeedScope.following => 'following',
  };

  String get label => switch (this) {
    SocialFeedScope.all => 'All',
    SocialFeedScope.following => 'Friends',
  };
}

class SocialAuthor {
  const SocialAuthor({
    required this.id,
    required this.displayName,
    required this.isFollowing,
  });

  final String id;
  final String displayName;
  final bool isFollowing;

  factory SocialAuthor.fromJson(Map<String, dynamic> json) {
    return SocialAuthor(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      displayName: (json['display_name'] ?? json['displayName'] ?? '')
          .toString(),
      isFollowing:
          (json['is_following'] as bool?) ??
          (json['isFollowing'] as bool?) ??
          false,
    );
  }

  SocialAuthor copyWith({String? id, String? displayName, bool? isFollowing}) {
    return SocialAuthor(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

class SocialWorkoutPreview {
  const SocialWorkoutPreview({
    required this.id,
    required this.title,
    required this.durationSeconds,
    this.completedAt,
  });

  final String id;
  final String title;
  final int durationSeconds;
  final DateTime? completedAt;

  factory SocialWorkoutPreview.fromJson(Map<String, dynamic> json) {
    return SocialWorkoutPreview(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      completedAt: _parseAppDate(json['completed_at']?.toString()),
    );
  }
}

class SocialPost {
  const SocialPost({
    required this.id,
    required this.author,
    required this.createdAt,
    this.caption,
    this.photo,
    this.workout,
  });

  final String id;
  final SocialAuthor author;
  final DateTime createdAt;
  final String? caption;
  final WorkoutCompletionPhoto? photo;
  final SocialWorkoutPreview? workout;

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      author: SocialAuthor.fromJson(
        (json['author'] as Map? ?? const {}).cast<String, dynamic>(),
      ),
      createdAt:
          _parseAppDate(json['created_at']?.toString()) ??
          DateTime.now().toUtc(),
      caption: json['caption']?.toString(),
      photo: json['photo'] is Map
          ? WorkoutCompletionPhoto.fromJson(
              (json['photo'] as Map).cast<String, dynamic>(),
            )
          : null,
      workout: json['workout'] is Map
          ? SocialWorkoutPreview.fromJson(
              (json['workout'] as Map).cast<String, dynamic>(),
            )
          : null,
    );
  }
}

class SocialFeedSnapshot {
  const SocialFeedSnapshot({
    required this.scope,
    required this.availableTabs,
    required this.followingCount,
    required this.items,
  });

  final SocialFeedScope scope;
  final List<String> availableTabs;
  final int followingCount;
  final List<SocialPost> items;

  factory SocialFeedSnapshot.fromJson(Map<String, dynamic> json) {
    final scopeValue = (json['scope'] ?? 'all').toString();
    final itemsJson = (json['items'] as List?) ?? const [];
    final tabsJson = (json['available_tabs'] as List?) ?? const [];

    return SocialFeedSnapshot(
      scope: scopeValue == 'following'
          ? SocialFeedScope.following
          : SocialFeedScope.all,
      availableTabs: tabsJson.map((item) => item.toString()).toList(),
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
      items: itemsJson
          .whereType<Map>()
          .map((item) => SocialPost.fromJson(item.cast<String, dynamic>()))
          .toList(),
    );
  }
}

DateTime? _parseAppDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  final normalized = value.endsWith('Z')
      ? '${value.substring(0, value.length - 1)}+00:00'
      : value;
  return DateTime.tryParse(normalized);
}
