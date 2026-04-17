import 'package:flutter/foundation.dart';

import '../../../../data/mock/mock_models.dart';

enum WorkoutFlowStage { start, active, finished }

@immutable
class ExerciseSet {
  const ExerciseSet({
    required this.weight,
    required this.reps,
    required this.isCompleted,
  });

  final double weight;
  final int reps;
  final bool isCompleted;

  ExerciseSet copyWith({
    double? weight,
    int? reps,
    bool? isCompleted,
  }) {
    return ExerciseSet(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

@immutable
class Exercise {
  const Exercise({
    required this.name,
    required this.sets,
  });

  final String name;
  final List<ExerciseSet> sets;

  Exercise copyWith({
    String? name,
    List<ExerciseSet>? sets,
  }) {
    return Exercise(
      name: name ?? this.name,
      sets: sets ?? this.sets,
    );
  }
}

@immutable
class WorkoutSummary {
  const WorkoutSummary({
    required this.elapsedSeconds,
    required this.volumeKg,
    required this.completedSets,
    required this.personalRecordHighlights,
  });

  final int elapsedSeconds;
  final int volumeKg;
  final int completedSets;
  final List<String> personalRecordHighlights;
}

@immutable
class WorkoutRestTimerState {
  const WorkoutRestTimerState({
    required this.isVisible,
    required this.selectedDuration,
    required this.remaining,
  });

  const WorkoutRestTimerState.hidden({
    this.selectedDuration = const Duration(seconds: 90),
  }) : isVisible = false,
       remaining = Duration.zero;

  final bool isVisible;
  final Duration selectedDuration;
  final Duration remaining;

  WorkoutRestTimerState copyWith({
    bool? isVisible,
    Duration? selectedDuration,
    Duration? remaining,
  }) {
    return WorkoutRestTimerState(
      isVisible: isVisible ?? this.isVisible,
      selectedDuration: selectedDuration ?? this.selectedDuration,
      remaining: remaining ?? this.remaining,
    );
  }
}

@immutable
class WorkoutState {
  const WorkoutState({
    required this.stage,
    required this.recentRoutines,
    required this.exerciseLibrary,
    required this.workoutName,
    required this.elapsedSeconds,
    required this.isPaused,
    required this.exercises,
    required this.attachPhoto,
    required this.caption,
    required this.restTimer,
    required this.historyMaxWeights,
    required this.personalRecordSetKeys,
    this.summary,
  });

  final WorkoutFlowStage stage;
  final List<RoutineSummary> recentRoutines;
  final List<ExerciseTemplate> exerciseLibrary;
  final String workoutName;
  final int elapsedSeconds;
  final bool isPaused;
  final List<Exercise> exercises;
  final bool attachPhoto;
  final String caption;
  final WorkoutRestTimerState restTimer;
  final Map<String, double> historyMaxWeights;
  final Set<String> personalRecordSetKeys;
  final WorkoutSummary? summary;

  factory WorkoutState.initial({
    required List<RoutineSummary> recentRoutines,
    required List<ExerciseTemplate> exerciseLibrary,
    required Map<String, double> historyMaxWeights,
  }) {
    return WorkoutState(
      stage: WorkoutFlowStage.start,
      recentRoutines: recentRoutines,
      exerciseLibrary: exerciseLibrary,
      workoutName: 'Evening Lift',
      elapsedSeconds: 0,
      isPaused: true,
      exercises: const [],
      attachPhoto: true,
      caption: '',
      restTimer: const WorkoutRestTimerState.hidden(),
      historyMaxWeights: historyMaxWeights,
      personalRecordSetKeys: const <String>{},
    );
  }

  bool get hasCurrentWorkout => stage != WorkoutFlowStage.start;

  int get completedSetCount => exercises
      .expand((exercise) => exercise.sets)
      .where((set) => set.isCompleted)
      .length;

  int get totalVolumeKg => exercises
      .expand((exercise) => exercise.sets)
      .where((set) => set.isCompleted)
      .fold<double>(0, (total, set) => total + (set.weight * set.reps))
      .round();

  ExerciseTemplate? exerciseTemplateForName(String name) {
    for (final template in exerciseLibrary) {
      if (template.name == name) {
        return template;
      }
    }

    return null;
  }

  bool isSetPersonalRecord(int exerciseIndex, int setIndex) {
    return personalRecordSetKeys.contains(_personalRecordKey(exerciseIndex, setIndex));
  }

  bool exerciseHasPersonalRecord(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= exercises.length) {
      return false;
    }

    for (var setIndex = 0; setIndex < exercises[exerciseIndex].sets.length; setIndex++) {
      if (isSetPersonalRecord(exerciseIndex, setIndex)) {
        return true;
      }
    }

    return false;
  }

  List<String> get personalRecordHighlights {
    final highlights = <String>[];

    for (var exerciseIndex = 0; exerciseIndex < exercises.length; exerciseIndex++) {
      final exercise = exercises[exerciseIndex];
      for (var setIndex = 0; setIndex < exercise.sets.length; setIndex++) {
        final set = exercise.sets[setIndex];
        if (isSetPersonalRecord(exerciseIndex, setIndex)) {
          highlights.add(
            '${exercise.name}: ${formatWeightValue(set.weight)} kg x ${set.reps}',
          );
        }
      }
    }

    return highlights;
  }

  WorkoutState copyWith({
    WorkoutFlowStage? stage,
    List<RoutineSummary>? recentRoutines,
    List<ExerciseTemplate>? exerciseLibrary,
    String? workoutName,
    int? elapsedSeconds,
    bool? isPaused,
    List<Exercise>? exercises,
    bool? attachPhoto,
    String? caption,
    WorkoutRestTimerState? restTimer,
    Map<String, double>? historyMaxWeights,
    Set<String>? personalRecordSetKeys,
    WorkoutSummary? summary,
    bool clearSummary = false,
  }) {
    return WorkoutState(
      stage: stage ?? this.stage,
      recentRoutines: recentRoutines ?? this.recentRoutines,
      exerciseLibrary: exerciseLibrary ?? this.exerciseLibrary,
      workoutName: workoutName ?? this.workoutName,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isPaused: isPaused ?? this.isPaused,
      exercises: exercises ?? this.exercises,
      attachPhoto: attachPhoto ?? this.attachPhoto,
      caption: caption ?? this.caption,
      restTimer: restTimer ?? this.restTimer,
      historyMaxWeights: historyMaxWeights ?? this.historyMaxWeights,
      personalRecordSetKeys:
          personalRecordSetKeys ?? this.personalRecordSetKeys,
      summary: clearSummary ? null : (summary ?? this.summary),
    );
  }
}

String formatWorkoutDuration(int elapsedSeconds) {
  final duration = Duration(seconds: elapsedSeconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

String formatWeightValue(double weight) {
  if (weight == weight.roundToDouble()) {
    return weight.toInt().toString();
  }

  return weight.toStringAsFixed(1);
}

String formatRestTimer(Duration duration) {
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

String personalRecordKey(int exerciseIndex, int setIndex) =>
    _personalRecordKey(exerciseIndex, setIndex);

String _personalRecordKey(int exerciseIndex, int setIndex) =>
    '$exerciseIndex:$setIndex';
