import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/mock/mock_feature_repository.dart';
import '../../../../data/mock/mock_models.dart';
import 'workout_state.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  WorkoutCubit(MockFeatureRepository repository)
      : _repository = repository,
        _recentRoutines = repository.getRecentRoutines(),
        _exerciseLibrary = repository.getExerciseLibrary(),
        _historyMaxWeights = repository.getExerciseHistoryMaxWeights(),
        super(
          WorkoutState.initial(
            recentRoutines: repository.getRecentRoutines(),
            exerciseLibrary: repository.getExerciseLibrary(),
            historyMaxWeights: repository.getExerciseHistoryMaxWeights(),
          ),
        );

  final MockFeatureRepository _repository;
  final List<RoutineSummary> _recentRoutines;
  final List<ExerciseTemplate> _exerciseLibrary;
  final Map<String, double> _historyMaxWeights;

  Timer? _workoutTimer;
  Timer? _restTimer;

  void startWorkout([RoutineSummary? routine]) {
    _workoutTimer?.cancel();
    _stopRestTimer();

    final exercises = _buildExercises(_repository.createWorkoutExercises(routine));

    emit(
      WorkoutState.initial(
        recentRoutines: _recentRoutines,
        exerciseLibrary: _exerciseLibrary,
        historyMaxWeights: _historyMaxWeights,
      ).copyWith(
        stage: WorkoutFlowStage.active,
        workoutName: routine?.name ?? 'Workout',
        exercises: exercises,
        isPaused: false,
        personalRecordSetKeys: _calculatePersonalRecordSetKeys(exercises),
      ),
    );

    _startTimer();
  }

  void startEmptyWorkout() {
    _workoutTimer?.cancel();
    _stopRestTimer();

    emit(
      WorkoutState.initial(
        recentRoutines: _recentRoutines,
        exerciseLibrary: _exerciseLibrary,
        historyMaxWeights: _historyMaxWeights,
      ).copyWith(
        stage: WorkoutFlowStage.active,
        workoutName: 'Empty Workout',
        isPaused: false,
      ),
    );

    _startTimer();
  }

  void toggleTimer() {
    if (state.stage != WorkoutFlowStage.active) {
      return;
    }

    if (!state.isPaused) {
      _workoutTimer?.cancel();
      emit(state.copyWith(isPaused: true));
      return;
    }

    emit(state.copyWith(isPaused: false));
    _startTimer();
  }

  void updateWorkoutName(String name) {
    emit(state.copyWith(workoutName: name));
  }

  void addExercise() {
    if (state.exerciseLibrary.isEmpty) {
      return;
    }

    final nextTemplate =
        state.exerciseLibrary[state.exercises.length % state.exerciseLibrary.length];

    addExerciseFromTemplate(nextTemplate);
  }

  void addExerciseFromTemplate(ExerciseTemplate template) {
    _emitWithExercises([...state.exercises, _exerciseFromTemplate(template)]);
  }

  void addSet(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= state.exercises.length) {
      return;
    }

    final exercise = state.exercises[exerciseIndex];
    final previous = exercise.sets.isEmpty
        ? const ExerciseSet(weight: 40, reps: 10, isCompleted: false)
        : exercise.sets.last;

    final updatedExercise = exercise.copyWith(
      sets: [
        ...exercise.sets,
        ExerciseSet(
          weight: previous.weight,
          reps: previous.reps,
          isCompleted: false,
        ),
      ],
    );

    final exercises = [...state.exercises];
    exercises[exerciseIndex] = updatedExercise;
    _emitWithExercises(exercises);
  }

  void updateSetWeight(int exerciseIndex, int setIndex, String value) {
    final parsed = double.tryParse(value);
    if (parsed == null && value.isNotEmpty) {
      return;
    }

    _updateSet(
      exerciseIndex,
      setIndex,
      (set) => set.copyWith(weight: parsed ?? 0),
    );
  }

  void updateSetReps(int exerciseIndex, int setIndex, String value) {
    final parsed = int.tryParse(value);
    if (parsed == null && value.isNotEmpty) {
      return;
    }

    _updateSet(exerciseIndex, setIndex, (set) => set.copyWith(reps: parsed ?? 0));
  }

  void toggleSetComplete(int exerciseIndex, int setIndex) {
    if (
        exerciseIndex < 0 ||
        exerciseIndex >= state.exercises.length ||
        setIndex < 0 ||
        setIndex >= state.exercises[exerciseIndex].sets.length) {
      return;
    }

    final currentSet = state.exercises[exerciseIndex].sets[setIndex];
    final willComplete = !currentSet.isCompleted;

    _updateSet(
      exerciseIndex,
      setIndex,
      (set) => set.copyWith(isCompleted: !set.isCompleted),
    );

    if (willComplete) {
      startRestTimer();
    }
  }

  void startRestTimer([Duration? duration]) {
    if (state.stage != WorkoutFlowStage.active) {
      return;
    }

    final nextDuration = duration ?? state.restTimer.selectedDuration;

    _restTimer?.cancel();
    emit(
      state.copyWith(
        restTimer: state.restTimer.copyWith(
          isVisible: true,
          selectedDuration: nextDuration,
          remaining: nextDuration,
        ),
      ),
    );

    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = state.restTimer.remaining - const Duration(seconds: 1);

      if (remaining.inSeconds <= 0) {
        dismissRestTimer();
        return;
      }

      emit(
        state.copyWith(
          restTimer: state.restTimer.copyWith(remaining: remaining),
        ),
      );
    });
  }

  void dismissRestTimer() {
    _stopRestTimer();
    emit(
      state.copyWith(
        restTimer: state.restTimer.copyWith(
          isVisible: false,
          remaining: Duration.zero,
        ),
      ),
    );
  }

  void changeRestDuration(Duration duration) {
    if (state.restTimer.isVisible) {
      startRestTimer(duration);
      return;
    }

    emit(
      state.copyWith(
        restTimer: state.restTimer.copyWith(selectedDuration: duration),
      ),
    );
  }

  void finishWorkout() {
    _workoutTimer?.cancel();
    _stopRestTimer();

    emit(
      state.copyWith(
        stage: WorkoutFlowStage.finished,
        isPaused: true,
        summary: WorkoutSummary(
          elapsedSeconds: state.elapsedSeconds,
          volumeKg: state.totalVolumeKg,
          completedSets: state.completedSetCount,
          personalRecordHighlights: state.personalRecordHighlights,
        ),
        caption: state.caption.isEmpty
            ? 'Locked in on ${state.workoutName.toLowerCase()}.'
            : state.caption,
        restTimer: state.restTimer.copyWith(
          isVisible: false,
          remaining: Duration.zero,
        ),
      ),
    );
  }

  void togglePhotoAttachment(bool value) {
    emit(state.copyWith(attachPhoto: value));
  }

  void updateCaption(String caption) {
    emit(state.copyWith(caption: caption));
  }

  void completeFlow() {
    _workoutTimer?.cancel();
    _stopRestTimer();
    emit(
      WorkoutState.initial(
        recentRoutines: _recentRoutines,
        exerciseLibrary: _exerciseLibrary,
        historyMaxWeights: _historyMaxWeights,
      ),
    );
  }

  void _updateSet(
    int exerciseIndex,
    int setIndex,
    ExerciseSet Function(ExerciseSet set) update,
  ) {
    if (
        exerciseIndex < 0 ||
        exerciseIndex >= state.exercises.length ||
        setIndex < 0 ||
        setIndex >= state.exercises[exerciseIndex].sets.length) {
      return;
    }

    final exercises = [...state.exercises];
    final exercise = exercises[exerciseIndex];
    final sets = [...exercise.sets];
    sets[setIndex] = update(sets[setIndex]);
    exercises[exerciseIndex] = exercise.copyWith(sets: sets);
    _emitWithExercises(exercises);
  }

  void _emitWithExercises(List<Exercise> exercises) {
    emit(
      state.copyWith(
        exercises: exercises,
        personalRecordSetKeys: _calculatePersonalRecordSetKeys(exercises),
      ),
    );
  }

  void _startTimer() {
    _workoutTimer?.cancel();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.stage != WorkoutFlowStage.active || state.isPaused) {
        return;
      }

      emit(state.copyWith(elapsedSeconds: state.elapsedSeconds + 1));
    });
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    _restTimer = null;
  }

  List<Exercise> _buildExercises(List<ExerciseTemplate> templates) =>
      templates.map(_exerciseFromTemplate).toList();

  Exercise _exerciseFromTemplate(ExerciseTemplate template) {
    return Exercise(
      name: template.name,
      sets: template.sets
          .map(
            (set) => ExerciseSet(
              weight: set.weightKg,
              reps: set.reps,
              isCompleted: false,
            ),
          )
          .toList(),
    );
  }

  Set<String> _calculatePersonalRecordSetKeys(List<Exercise> exercises) {
    final runningMax = Map<String, double>.from(_historyMaxWeights);
    final keys = <String>{};

    for (var exerciseIndex = 0; exerciseIndex < exercises.length; exerciseIndex++) {
      final exercise = exercises[exerciseIndex];

      for (var setIndex = 0; setIndex < exercise.sets.length; setIndex++) {
        final set = exercise.sets[setIndex];
        if (!set.isCompleted) {
          continue;
        }

        final previousMax = runningMax[exercise.name] ?? 0;
        if (set.weight > previousMax) {
          keys.add(personalRecordKey(exerciseIndex, setIndex));
          runningMax[exercise.name] = set.weight;
        }
      }
    }

    return keys;
  }

  @override
  Future<void> close() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    return super.close();
  }
}
