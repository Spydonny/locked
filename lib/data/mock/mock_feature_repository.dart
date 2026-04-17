import 'package:flutter/cupertino.dart';

import '../../core/theme/app_colors.dart';
import 'mock_models.dart';

class MockFeatureRepository {
  const MockFeatureRepository();

  HomeDashboardData getHomeDashboard() => HomeDashboardData(
    streak: const StreakSummary(
      currentDays: 18,
      weeklySessions: 4,
      weeklyGoal: 5,
      focusLabel: 'Pushing toward a 100 kg bench',
    ),
    crew: _crew,
    feed: _feed,
  );

  ProgressDashboardData getProgressDashboard() => const ProgressDashboardData(
    weeklyVolume: [
      ProgressPoint(label: 'W1', value: 5200),
      ProgressPoint(label: 'W2', value: 6100),
      ProgressPoint(label: 'W3', value: 5800),
      ProgressPoint(label: 'W4', value: 7200),
      ProgressPoint(label: 'W5', value: 7600),
      ProgressPoint(label: 'W6', value: 8100),
      ProgressPoint(label: 'W7', value: 8600),
      ProgressPoint(label: 'W8', value: 9300),
    ],
    workoutsPerWeek: [
      ProgressPoint(label: 'W1', value: 3),
      ProgressPoint(label: 'W2', value: 4),
      ProgressPoint(label: 'W3', value: 3),
      ProgressPoint(label: 'W4', value: 4),
      ProgressPoint(label: 'W5', value: 5),
      ProgressPoint(label: 'W6', value: 5),
      ProgressPoint(label: 'W7', value: 4),
      ProgressPoint(label: 'W8', value: 5),
    ],
    heatmap: _heatmap,
    personalRecords: [
      PersonalRecord(
        lift: 'Bench Press',
        result: '92.5 kg x 3',
        achievedAt: '2 days ago',
      ),
      PersonalRecord(
        lift: 'Back Squat',
        result: '145 kg x 2',
        achievedAt: 'Last week',
      ),
      PersonalRecord(
        lift: 'Weighted Pull-up',
        result: '+30 kg x 5',
        achievedAt: 'Last week',
      ),
    ],
  );

  ProfileDashboardData getProfileDashboard() => ProfileDashboardData(
    profile: const ProfileSummary(
      athlete: MemberAvatar(
        name: 'Mila Hart',
        handle: '@milalifts',
        color: AppColors.gradientStart,
        isActive: true,
      ),
      bio:
          'Strength athlete building clean reps, steady volume, and a long run of disciplined days.',
      followers: 1840,
      following: 231,
      currentStreak: 18,
      totalSessions: 146,
      totalVolumeKg: 287400,
    ),
    heatmap: _heatmap,
    recentWorkouts: _feed.take(2).toList(),
  );

  List<RoutineSummary> getRecentRoutines() => const [
    RoutineSummary(
      name: 'Upper Power',
      subtitle: 'Bench, rows, pull-ups',
      exerciseCount: 4,
      estimatedMinutes: 52,
      lastPerformed: 'Yesterday',
    ),
    RoutineSummary(
      name: 'Lower Strength',
      subtitle: 'Squat focus with accessories',
      exerciseCount: 5,
      estimatedMinutes: 58,
      lastPerformed: '3 days ago',
    ),
    RoutineSummary(
      name: 'Push Hypertrophy',
      subtitle: 'Chest, delts, triceps',
      exerciseCount: 4,
      estimatedMinutes: 45,
      lastPerformed: 'Last week',
    ),
  ];

  Map<String, double> getExerciseHistoryMaxWeights() => const {
    'Bench Press': 85,
    'Cable Fly': 20,
    'Lat Pulldown': 58,
    'Chest Supported Row': 52.5,
    'Weighted Pull-up': 22.5,
    'Back Squat': 135,
    'Romanian Deadlift': 92.5,
    'Bulgarian Split Squat': 18,
    'Incline Dumbbell Press': 30,
    'Seated Shoulder Press': 45,
    'Lateral Raise': 10,
    'Hammer Curl': 15,
    'Triceps Pushdown': 27.5,
    'Cable Crunch': 32.5,
    'Hanging Knee Raise': 0,
  };

  List<ExerciseTemplate> createWorkoutExercises([RoutineSummary? routine]) {
    switch (routine?.name) {
      case 'Lower Strength':
        return const [
          ExerciseTemplate(
            name: 'Back Squat',
            focus: 'Strength',
            muscleGroup: ExerciseMuscleGroup.legs,
            thumbnailColor: AppColors.gradientMiddle,
            thumbnailIcon: CupertinoIcons.rectangle_stack_fill,
            sets: [
              WorkoutSetTemplate(weightKg: 120, reps: 5),
              WorkoutSetTemplate(weightKg: 130, reps: 4),
              WorkoutSetTemplate(weightKg: 140, reps: 3),
            ],
          ),
          ExerciseTemplate(
            name: 'Romanian Deadlift',
            focus: 'Posterior chain',
            muscleGroup: ExerciseMuscleGroup.legs,
            thumbnailColor: AppColors.warning,
            thumbnailIcon: CupertinoIcons.arrow_down_circle_fill,
            sets: [
              WorkoutSetTemplate(weightKg: 90, reps: 8),
              WorkoutSetTemplate(weightKg: 95, reps: 8),
              WorkoutSetTemplate(weightKg: 95, reps: 6),
            ],
          ),
        ];
      case 'Push Hypertrophy':
        return const [
          ExerciseTemplate(
            name: 'Incline Dumbbell Press',
            focus: 'Chest',
            muscleGroup: ExerciseMuscleGroup.chest,
            thumbnailColor: AppColors.gradientStart,
            thumbnailIcon: CupertinoIcons.heart_fill,
            sets: [
              WorkoutSetTemplate(weightKg: 30, reps: 12),
              WorkoutSetTemplate(weightKg: 32.5, reps: 10),
              WorkoutSetTemplate(weightKg: 32.5, reps: 9),
            ],
          ),
          ExerciseTemplate(
            name: 'Seated Shoulder Press',
            focus: 'Shoulders',
            muscleGroup: ExerciseMuscleGroup.shoulders,
            thumbnailColor: AppColors.gradientEnd,
            thumbnailIcon: CupertinoIcons.arrow_up_circle_fill,
            sets: [
              WorkoutSetTemplate(weightKg: 45, reps: 10),
              WorkoutSetTemplate(weightKg: 47.5, reps: 8),
              WorkoutSetTemplate(weightKg: 47.5, reps: 8),
            ],
          ),
        ];
      default:
        return const [
          ExerciseTemplate(
            name: 'Bench Press',
            focus: 'Main lift',
            muscleGroup: ExerciseMuscleGroup.chest,
            thumbnailColor: AppColors.gradientStart,
            thumbnailIcon: CupertinoIcons.heart_fill,
            sets: [
              WorkoutSetTemplate(weightKg: 70, reps: 8),
              WorkoutSetTemplate(weightKg: 80, reps: 5),
              WorkoutSetTemplate(weightKg: 87.5, reps: 3),
            ],
          ),
          ExerciseTemplate(
            name: 'Chest Supported Row',
            focus: 'Upper back',
            muscleGroup: ExerciseMuscleGroup.back,
            thumbnailColor: AppColors.gradientMiddle,
            thumbnailIcon: CupertinoIcons.arrow_uturn_left_circle_fill,
            sets: [
              WorkoutSetTemplate(weightKg: 50, reps: 12),
              WorkoutSetTemplate(weightKg: 55, reps: 10),
              WorkoutSetTemplate(weightKg: 55, reps: 10),
            ],
          ),
          ExerciseTemplate(
            name: 'Weighted Pull-up',
            focus: 'Lats',
            muscleGroup: ExerciseMuscleGroup.back,
            thumbnailColor: AppColors.success,
            thumbnailIcon: CupertinoIcons.chevron_up_circle_fill,
            sets: [
              WorkoutSetTemplate(weightKg: 15, reps: 8),
              WorkoutSetTemplate(weightKg: 20, reps: 6),
              WorkoutSetTemplate(weightKg: 25, reps: 5),
            ],
          ),
        ];
    }
  }

  List<ExerciseTemplate> getExerciseLibrary() => const [
    ExerciseTemplate(
      name: 'Bench Press',
      focus: 'Barbell press',
      muscleGroup: ExerciseMuscleGroup.chest,
      thumbnailColor: AppColors.gradientStart,
      thumbnailIcon: CupertinoIcons.heart_fill,
      sets: [
        WorkoutSetTemplate(weightKg: 70, reps: 8),
        WorkoutSetTemplate(weightKg: 75, reps: 6),
      ],
    ),
    ExerciseTemplate(
      name: 'Cable Fly',
      focus: 'Stretch-focused chest work',
      muscleGroup: ExerciseMuscleGroup.chest,
      thumbnailColor: AppColors.gradientEnd,
      thumbnailIcon: CupertinoIcons.star_fill,
      sets: [
        WorkoutSetTemplate(weightKg: 20, reps: 15),
        WorkoutSetTemplate(weightKg: 22.5, reps: 12),
      ],
    ),
    ExerciseTemplate(
      name: 'Lat Pulldown',
      focus: 'Vertical pull',
      muscleGroup: ExerciseMuscleGroup.back,
      thumbnailColor: AppColors.gradientMiddle,
      thumbnailIcon: CupertinoIcons.arrow_down_circle_fill,
      sets: [
        WorkoutSetTemplate(weightKg: 55, reps: 12),
        WorkoutSetTemplate(weightKg: 60, reps: 10),
      ],
    ),
    ExerciseTemplate(
      name: 'Chest Supported Row',
      focus: 'Upper back pull',
      muscleGroup: ExerciseMuscleGroup.back,
      thumbnailColor: AppColors.success,
      thumbnailIcon: CupertinoIcons.arrow_uturn_left_circle_fill,
      sets: [
        WorkoutSetTemplate(weightKg: 50, reps: 12),
        WorkoutSetTemplate(weightKg: 55, reps: 10),
      ],
    ),
    ExerciseTemplate(
      name: 'Weighted Pull-up',
      focus: 'Bodyweight plus load',
      muscleGroup: ExerciseMuscleGroup.back,
      thumbnailColor: AppColors.success,
      thumbnailIcon: CupertinoIcons.chevron_up_circle_fill,
      sets: [
        WorkoutSetTemplate(weightKg: 15, reps: 8),
        WorkoutSetTemplate(weightKg: 20, reps: 6),
      ],
    ),
    ExerciseTemplate(
      name: 'Back Squat',
      focus: 'Primary strength lift',
      muscleGroup: ExerciseMuscleGroup.legs,
      thumbnailColor: AppColors.warning,
      thumbnailIcon: CupertinoIcons.rectangle_stack_fill,
      sets: [
        WorkoutSetTemplate(weightKg: 100, reps: 6),
        WorkoutSetTemplate(weightKg: 110, reps: 5),
      ],
    ),
    ExerciseTemplate(
      name: 'Bulgarian Split Squat',
      focus: 'Single-leg stability',
      muscleGroup: ExerciseMuscleGroup.legs,
      thumbnailColor: AppColors.gradientMiddle,
      thumbnailIcon: CupertinoIcons.square_fill,
      sets: [
        WorkoutSetTemplate(weightKg: 18, reps: 10),
        WorkoutSetTemplate(weightKg: 18, reps: 10),
      ],
    ),
    ExerciseTemplate(
      name: 'Romanian Deadlift',
      focus: 'Posterior chain hinge',
      muscleGroup: ExerciseMuscleGroup.legs,
      thumbnailColor: AppColors.warning,
      thumbnailIcon: CupertinoIcons.arrow_down_circle_fill,
      sets: [
        WorkoutSetTemplate(weightKg: 90, reps: 8),
        WorkoutSetTemplate(weightKg: 95, reps: 8),
      ],
    ),
    ExerciseTemplate(
      name: 'Incline Dumbbell Press',
      focus: 'Upper chest press',
      muscleGroup: ExerciseMuscleGroup.chest,
      thumbnailColor: AppColors.gradientStart,
      thumbnailIcon: CupertinoIcons.heart_fill,
      sets: [
        WorkoutSetTemplate(weightKg: 30, reps: 12),
        WorkoutSetTemplate(weightKg: 32.5, reps: 10),
      ],
    ),
    ExerciseTemplate(
      name: 'Seated Shoulder Press',
      focus: 'Pressing pattern',
      muscleGroup: ExerciseMuscleGroup.shoulders,
      thumbnailColor: AppColors.gradientEnd,
      thumbnailIcon: CupertinoIcons.arrow_up_circle_fill,
      sets: [
        WorkoutSetTemplate(weightKg: 45, reps: 10),
        WorkoutSetTemplate(weightKg: 47.5, reps: 8),
      ],
    ),
    ExerciseTemplate(
      name: 'Lateral Raise',
      focus: 'Deltoid isolation',
      muscleGroup: ExerciseMuscleGroup.shoulders,
      thumbnailColor: AppColors.textSecondary,
      thumbnailIcon: CupertinoIcons.triangle_fill,
      sets: [
        WorkoutSetTemplate(weightKg: 10, reps: 15),
        WorkoutSetTemplate(weightKg: 12, reps: 12),
      ],
    ),
    ExerciseTemplate(
      name: 'Hammer Curl',
      focus: 'Biceps and brachialis',
      muscleGroup: ExerciseMuscleGroup.arms,
      thumbnailColor: AppColors.success,
      thumbnailIcon: CupertinoIcons.bolt_fill,
      sets: [
        WorkoutSetTemplate(weightKg: 14, reps: 12),
        WorkoutSetTemplate(weightKg: 16, reps: 10),
      ],
    ),
    ExerciseTemplate(
      name: 'Triceps Pushdown',
      focus: 'Cable triceps work',
      muscleGroup: ExerciseMuscleGroup.arms,
      thumbnailColor: AppColors.gradientStart,
      thumbnailIcon: CupertinoIcons.minus_circle_fill,
      sets: [
        WorkoutSetTemplate(weightKg: 25, reps: 12),
        WorkoutSetTemplate(weightKg: 30, reps: 10),
      ],
    ),
    ExerciseTemplate(
      name: 'Cable Crunch',
      focus: 'Weighted core flexion',
      muscleGroup: ExerciseMuscleGroup.core,
      thumbnailColor: AppColors.warning,
      thumbnailIcon: CupertinoIcons.circle_grid_hex_fill,
      sets: [
        WorkoutSetTemplate(weightKg: 30, reps: 15),
        WorkoutSetTemplate(weightKg: 35, reps: 12),
      ],
    ),
    ExerciseTemplate(
      name: 'Hanging Knee Raise',
      focus: 'Lower ab control',
      muscleGroup: ExerciseMuscleGroup.core,
      thumbnailColor: AppColors.gradientMiddle,
      thumbnailIcon: CupertinoIcons.circle_fill,
      sets: [
        WorkoutSetTemplate(weightKg: 0, reps: 15),
        WorkoutSetTemplate(weightKg: 0, reps: 15),
      ],
    ),
  ];

  static const _crew = [
    MemberAvatar(
      name: 'Mila Hart',
      handle: '@milalifts',
      color: AppColors.gradientStart,
      isActive: true,
    ),
    MemberAvatar(
      name: 'Noah Vale',
      handle: '@novalift',
      color: AppColors.gradientMiddle,
      isActive: true,
    ),
    MemberAvatar(
      name: 'Ari Stone',
      handle: '@aristone',
      color: AppColors.gradientEnd,
    ),
    MemberAvatar(
      name: 'Jae Moon',
      handle: '@jaemoves',
      color: AppColors.warning,
    ),
    MemberAvatar(
      name: 'Lena Cruz',
      handle: '@lenacruz',
      color: AppColors.success,
    ),
  ];

  static final _feed = [
    WorkoutFeedItem(
      author: _crew[1],
      timeAgo: '42m ago',
      title:
          'Upper power day felt locked in. Top set moved faster than expected.',
      durationMinutes: 56,
      volumeKg: 8340,
      personalRecords: 2,
      likes: 126,
      comments: 19,
      reposts: 6,
      imageLabel: 'Bench focus',
      imageGradient: const LinearGradient(
        colors: [AppColors.gradientStart, AppColors.gradientMiddle],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    WorkoutFeedItem(
      author: _crew[4],
      timeAgo: '3h ago',
      title:
          'Recovery circuit and long incline walk. Keeping the streak calm and steady.',
      durationMinutes: 38,
      volumeKg: 2640,
      personalRecords: 0,
      likes: 84,
      comments: 8,
      reposts: 2,
    ),
    WorkoutFeedItem(
      author: _crew[2],
      timeAgo: 'Yesterday',
      title: 'Squat singles, tempo work, and a little bit of suffering.',
      durationMinutes: 64,
      volumeKg: 10240,
      personalRecords: 1,
      likes: 204,
      comments: 27,
      reposts: 11,
      imageLabel: 'Heavy lower',
      imageGradient: const LinearGradient(
        colors: [AppColors.surfaceMuted, AppColors.gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  static const _heatmap = [
    HeatmapDay(intensity: 1, label: 'D1'),
    HeatmapDay(intensity: 0, label: 'D2'),
    HeatmapDay(intensity: 2, label: 'D3'),
    HeatmapDay(intensity: 3, label: 'D4'),
    HeatmapDay(intensity: 1, label: 'D5'),
    HeatmapDay(intensity: 4, label: 'D6'),
    HeatmapDay(intensity: 0, label: 'D7'),
    HeatmapDay(intensity: 1, label: 'D8'),
    HeatmapDay(intensity: 2, label: 'D9'),
    HeatmapDay(intensity: 1, label: 'D10'),
    HeatmapDay(intensity: 0, label: 'D11'),
    HeatmapDay(intensity: 3, label: 'D12'),
    HeatmapDay(intensity: 4, label: 'D13'),
    HeatmapDay(intensity: 1, label: 'D14'),
    HeatmapDay(intensity: 0, label: 'D15'),
    HeatmapDay(intensity: 2, label: 'D16'),
    HeatmapDay(intensity: 3, label: 'D17'),
    HeatmapDay(intensity: 4, label: 'D18'),
    HeatmapDay(intensity: 1, label: 'D19'),
    HeatmapDay(intensity: 0, label: 'D20'),
    HeatmapDay(intensity: 2, label: 'D21'),
    HeatmapDay(intensity: 1, label: 'D22'),
    HeatmapDay(intensity: 0, label: 'D23'),
    HeatmapDay(intensity: 3, label: 'D24'),
    HeatmapDay(intensity: 4, label: 'D25'),
    HeatmapDay(intensity: 2, label: 'D26'),
    HeatmapDay(intensity: 1, label: 'D27'),
    HeatmapDay(intensity: 0, label: 'D28'),
    HeatmapDay(intensity: 1, label: 'D29'),
    HeatmapDay(intensity: 2, label: 'D30'),
    HeatmapDay(intensity: 4, label: 'D31'),
    HeatmapDay(intensity: 3, label: 'D32'),
    HeatmapDay(intensity: 2, label: 'D33'),
    HeatmapDay(intensity: 1, label: 'D34'),
    HeatmapDay(intensity: 0, label: 'D35'),
    HeatmapDay(intensity: 1, label: 'D36'),
    HeatmapDay(intensity: 2, label: 'D37'),
    HeatmapDay(intensity: 3, label: 'D38'),
    HeatmapDay(intensity: 4, label: 'D39'),
    HeatmapDay(intensity: 1, label: 'D40'),
    HeatmapDay(intensity: 0, label: 'D41'),
    HeatmapDay(intensity: 2, label: 'D42'),
    HeatmapDay(intensity: 3, label: 'D43'),
    HeatmapDay(intensity: 4, label: 'D44'),
    HeatmapDay(intensity: 1, label: 'D45'),
    HeatmapDay(intensity: 0, label: 'D46'),
    HeatmapDay(intensity: 1, label: 'D47'),
    HeatmapDay(intensity: 2, label: 'D48'),
    HeatmapDay(intensity: 3, label: 'D49'),
    HeatmapDay(intensity: 4, label: 'D50'),
    HeatmapDay(intensity: 2, label: 'D51'),
    HeatmapDay(intensity: 1, label: 'D52'),
    HeatmapDay(intensity: 0, label: 'D53'),
    HeatmapDay(intensity: 1, label: 'D54'),
    HeatmapDay(intensity: 2, label: 'D55'),
    HeatmapDay(intensity: 3, label: 'D56'),
  ];
}
