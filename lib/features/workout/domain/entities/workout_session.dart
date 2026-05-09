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
      rpe: (json['rpe'] as num?)?.toInt() ?? 8,
      isCompleted:
          (json['is_completed'] as bool?) ??
          (json['isCompleted'] as bool?) ??
          false,
    );
  }

  Map<String, dynamic> toJson(String exerciseId) {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'label': label,
      'weight': weight,
      'reps': reps,
      'rpe': rpe,
      'is_completed': isCompleted,
    };
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
    required this.exerciseId,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.notes,
    required this.sets,
  });

  final String id;
  final String exerciseId;
  final String name;
  final String muscleGroup;
  final String equipment;
  final String notes;
  final List<WorkoutSetEntry> sets;

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    final setsJson = (json['sets'] as List?) ?? const [];
    return WorkoutExercise(
      id: (json['id'] ?? '').toString(),
      exerciseId:
          (json['exercise_id'] ?? json['exerciseId'] ?? json['id'] ?? '')
              .toString(),
      name: (json['name'] ?? '').toString(),
      muscleGroup: (json['muscleGroup'] ?? json['muscle_group'] ?? '')
          .toString(),
      equipment: (json['equipment'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
      sets: setsJson
          .whereType<Map>()
          .map((e) => WorkoutSetEntry.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'name': name,
      'muscle_group': muscleGroup,
      'equipment': equipment,
      'notes': notes.isEmpty ? null : notes,
      'sets': sets.map((set) => set.toJson(id)).toList(),
    };
  }

  WorkoutExercise copyWith({
    String? id,
    String? exerciseId,
    String? name,
    String? muscleGroup,
    String? equipment,
    String? notes,
    List<WorkoutSetEntry>? sets,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      equipment: equipment ?? this.equipment,
      notes: notes ?? this.notes,
      sets: sets ?? this.sets,
    );
  }
}

class WorkoutCompletionPhoto {
  const WorkoutCompletionPhoto({
    required this.fileId,
    required this.filename,
    required this.contentType,
    required this.sizeBytes,
    required this.downloadUrl,
    this.caption,
  });

  final String fileId;
  final String filename;
  final String contentType;
  final int sizeBytes;
  final String downloadUrl;
  final String? caption;

  factory WorkoutCompletionPhoto.fromJson(Map<String, dynamic> json) {
    return WorkoutCompletionPhoto(
      fileId: (json['file_id'] ?? json['fileId'] ?? '').toString(),
      filename: (json['filename'] ?? '').toString(),
      contentType: (json['content_type'] ?? json['contentType'] ?? '')
          .toString(),
      sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? 0,
      downloadUrl: (json['download_url'] ?? json['downloadUrl'] ?? '')
          .toString(),
      caption: json['caption']?.toString(),
    );
  }
}

class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.title,
    required this.status,
    required this.durationSeconds,
    required this.startedAt,
    required this.restTimerSeconds,
    required this.exercises,
    this.notes,
    this.endedAt,
    this.completedAt,
    this.completionPhoto,
    this.completionPostId,
  });

  final String id;
  final String title;
  final String status;
  final int durationSeconds;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime? completedAt;
  final int restTimerSeconds;
  final String? notes;
  final List<WorkoutExercise> exercises;
  final WorkoutCompletionPhoto? completionPhoto;
  final String? completionPostId;

  bool get isActive => status == 'active';

  String get durationLabel => formatDuration(durationSeconds);

  int get completedSetCount => exercises.fold<int>(
    0,
    (total, exercise) =>
        total + exercise.sets.where((set) => set.isCompleted).length,
  );

  int get totalSetCount =>
      exercises.fold<int>(0, (total, exercise) => total + exercise.sets.length);

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    final exercisesJson = (json['exercises'] as List?) ?? const [];
    final completionPhotoJson = json['completion_photo'];

    if (exercisesJson.isEmpty) {
      final legacySets = (json['sets'] as List?) ?? const [];
      final byExercise = <String, List<WorkoutSetEntry>>{};
      for (final item in legacySets.whereType<Map>()) {
        final map = item.cast<String, dynamic>();
        final exerciseId = (map['exercise_id'] ?? '').toString();
        if (exerciseId.isEmpty) {
          continue;
        }
        byExercise.putIfAbsent(exerciseId, () => []);
        byExercise[exerciseId]!.add(WorkoutSetEntry.fromJson(map));
      }

      return WorkoutSession(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        status: (json['status'] ?? 'active').toString(),
        durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
        startedAt: _parseDate(json['started_at']?.toString()),
        endedAt: _parseDate(json['ended_at']?.toString()),
        completedAt: _parseDate(json['completed_at']?.toString()),
        restTimerSeconds: (json['rest_timer_seconds'] as num?)?.toInt() ?? 75,
        notes: json['notes']?.toString(),
        exercises: byExercise.entries
            .map(
              (entry) => WorkoutExercise(
                id: entry.key,
                exerciseId: entry.key,
                name: entry.key,
                muscleGroup: '',
                equipment: '',
                notes: '',
                sets: entry.value,
              ),
            )
            .toList(),
        completionPhoto: completionPhotoJson is Map
            ? WorkoutCompletionPhoto.fromJson(
                completionPhotoJson.cast<String, dynamic>(),
              )
            : null,
        completionPostId: json['completion_post_id']?.toString(),
      );
    }

    return WorkoutSession(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      status: (json['status'] ?? 'active').toString(),
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      startedAt: _parseDate(json['started_at']?.toString()),
      endedAt: _parseDate(json['ended_at']?.toString()),
      completedAt: _parseDate(json['completed_at']?.toString()),
      restTimerSeconds: (json['rest_timer_seconds'] as num?)?.toInt() ?? 75,
      notes: json['notes']?.toString(),
      exercises: exercisesJson
          .whereType<Map>()
          .map((e) => WorkoutExercise.fromJson(e.cast<String, dynamic>()))
          .toList(),
      completionPhoto: completionPhotoJson is Map
          ? WorkoutCompletionPhoto.fromJson(
              completionPhotoJson.cast<String, dynamic>(),
            )
          : null,
      completionPostId: json['completion_post_id']?.toString(),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'notes': notes,
      'rest_timer_seconds': restTimerSeconds,
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
    };
  }

  WorkoutSession copyWith({
    String? id,
    String? title,
    String? status,
    int? durationSeconds,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? completedAt,
    int? restTimerSeconds,
    String? notes,
    List<WorkoutExercise>? exercises,
    WorkoutCompletionPhoto? completionPhoto,
    String? completionPostId,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      completedAt: completedAt ?? this.completedAt,
      restTimerSeconds: restTimerSeconds ?? this.restTimerSeconds,
      notes: notes ?? this.notes,
      exercises: exercises ?? this.exercises,
      completionPhoto: completionPhoto ?? this.completionPhoto,
      completionPostId: completionPostId ?? this.completionPostId,
    );
  }
}

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  final normalized = value.endsWith('Z')
      ? '${value.substring(0, value.length - 1)}+00:00'
      : value;
  return DateTime.tryParse(normalized);
}

String formatDuration(int totalSeconds) {
  final safeTotal = totalSeconds < 0 ? 0 : totalSeconds;
  final hours = safeTotal ~/ 3600;
  final minutes = (safeTotal % 3600) ~/ 60;
  final seconds = safeTotal % 60;

  String two(int value) => value.toString().padLeft(2, '0');

  return '${two(hours)}:${two(minutes)}:${two(seconds)}';
}
