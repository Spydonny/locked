class WorkoutSetEntry {
  const WorkoutSetEntry({
    required this.id,
    required this.label,
    required this.weight,
    required this.reps,
    required this.rpe,
    this.isCompleted = false,
  });

  final String id;
  final String label;
  final double weight;
  final int reps;
  final int rpe;
  final bool isCompleted;

  factory WorkoutSetEntry.fromJson(Map<String, dynamic> json) {
    return WorkoutSetEntry(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      reps: (json['reps'] as num?)?.toInt() ?? 0,
      rpe: (json['rpe'] as num?)?.toInt() ?? 0,
      isCompleted: (json['is_completed'] as bool?) ?? (json['isCompleted'] as bool?) ?? false,
    );
  }

  WorkoutSetEntry copyWith({
    String? id,
    String? label,
    double? weight,
    int? reps,
    int? rpe,
    bool? isCompleted,
  }) {
    return WorkoutSetEntry(
      id: id ?? this.id,
      label: label ?? this.label,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class WorkoutExercise {
  const WorkoutExercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.notes,
    required this.sets,
  });

  final String id;
  final String name;
  final String muscleGroup;
  final String notes;
  final List<WorkoutSetEntry> sets;

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    final setsJson = (json['sets'] as List?) ?? const [];
    return WorkoutExercise(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      muscleGroup: (json['muscleGroup'] ?? json['muscle_group'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
      sets: setsJson.whereType<Map>().map((e) => WorkoutSetEntry.fromJson(e.cast<String, dynamic>())).toList(),
    );
  }

  WorkoutExercise copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    String? notes,
    List<WorkoutSetEntry>? sets,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      notes: notes ?? this.notes,
      sets: sets ?? this.sets,
    );
  }
}

class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.title,
    required this.durationLabel,
    required this.restTimerSeconds,
    required this.exercises,
  });

  final String id;
  final String title;
  final String durationLabel;
  final int restTimerSeconds;
  final List<WorkoutExercise> exercises;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    final setsJson = (json['sets'] as List?) ?? const [];
    final durationSeconds = (json['duration_seconds'] as num?)?.toInt() ?? 0;

    final Map<String, List<WorkoutSetEntry>> byExercise = {};
    for (final item in setsJson.whereType<Map>()) {
      final m = item.cast<String, dynamic>();
      final exerciseId = (m['exercise_id'] ?? '').toString();
      byExercise.putIfAbsent(exerciseId, () => []);
      byExercise[exerciseId]!.add(WorkoutSetEntry.fromJson(m));
    }

    String formatDuration(int total) {
      final h = total ~/ 3600;
      final m = (total % 3600) ~/ 60;
      final s = total % 60;
      String two(int v) => v.toString().padLeft(2, '0');
      return '${two(h)}:${two(m)}:${two(s)}';
    }

    return WorkoutSession(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      durationLabel: formatDuration(durationSeconds),
      restTimerSeconds: (json['rest_timer_seconds'] as num?)?.toInt() ?? 75,
      exercises: byExercise.entries
          .map(
            (e) => WorkoutExercise(
              id: e.key,
              name: e.key,
              muscleGroup: '',
              notes: '',
              sets: e.value,
            ),
          )
          .toList(),
    );
  }

  WorkoutSession copyWith({
    String? id,
    String? title,
    String? durationLabel,
    int? restTimerSeconds,
    List<WorkoutExercise>? exercises,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      title: title ?? this.title,
      durationLabel: durationLabel ?? this.durationLabel,
      restTimerSeconds: restTimerSeconds ?? this.restTimerSeconds,
      exercises: exercises ?? this.exercises,
    );
  }
}
