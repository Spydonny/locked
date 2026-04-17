import 'package:flutter/cupertino.dart';

enum ExerciseMuscleGroup {
  chest('Chest'),
  back('Back'),
  legs('Legs'),
  shoulders('Shoulders'),
  arms('Arms'),
  core('Core');

  const ExerciseMuscleGroup(this.label);

  final String label;
}

@immutable
class MemberAvatar {
  const MemberAvatar({
    required this.name,
    required this.handle,
    required this.color,
    this.isActive = false,
  });

  final String name;
  final String handle;
  final Color color;
  final bool isActive;

  String get initials {
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

@immutable
class StreakSummary {
  const StreakSummary({
    required this.currentDays,
    required this.weeklySessions,
    required this.weeklyGoal,
    required this.focusLabel,
  });

  final int currentDays;
  final int weeklySessions;
  final int weeklyGoal;
  final String focusLabel;
}

@immutable
class WorkoutFeedItem {
  const WorkoutFeedItem({
    required this.author,
    required this.timeAgo,
    required this.title,
    required this.durationMinutes,
    required this.volumeKg,
    required this.personalRecords,
    required this.likes,
    required this.comments,
    required this.reposts,
    this.imageLabel,
    this.imageGradient,
  });

  final MemberAvatar author;
  final String timeAgo;
  final String title;
  final int durationMinutes;
  final int volumeKg;
  final int personalRecords;
  final int likes;
  final int comments;
  final int reposts;
  final String? imageLabel;
  final Gradient? imageGradient;
}

@immutable
class RoutineSummary {
  const RoutineSummary({
    required this.name,
    required this.subtitle,
    required this.exerciseCount,
    required this.estimatedMinutes,
    required this.lastPerformed,
  });

  final String name;
  final String subtitle;
  final int exerciseCount;
  final int estimatedMinutes;
  final String lastPerformed;
}

@immutable
class ExerciseTemplate {
  const ExerciseTemplate({
    required this.name,
    required this.focus,
    required this.muscleGroup,
    required this.thumbnailColor,
    required this.thumbnailIcon,
    required this.sets,
  });

  final String name;
  final String focus;
  final ExerciseMuscleGroup muscleGroup;
  final Color thumbnailColor;
  final IconData thumbnailIcon;
  final List<WorkoutSetTemplate> sets;
}

@immutable
class WorkoutSetTemplate {
  const WorkoutSetTemplate({
    required this.weightKg,
    required this.reps,
  });

  final double weightKg;
  final int reps;
}

@immutable
class ProgressPoint {
  const ProgressPoint({required this.label, required this.value});

  final String label;
  final double value;
}

@immutable
class HeatmapDay {
  const HeatmapDay({required this.intensity, required this.label});

  final int intensity;
  final String label;
}

@immutable
class PersonalRecord {
  const PersonalRecord({
    required this.lift,
    required this.result,
    required this.achievedAt,
  });

  final String lift;
  final String result;
  final String achievedAt;
}

@immutable
class ProfileSummary {
  const ProfileSummary({
    required this.athlete,
    required this.bio,
    required this.followers,
    required this.following,
    required this.currentStreak,
    required this.totalSessions,
    required this.totalVolumeKg,
  });

  final MemberAvatar athlete;
  final String bio;
  final int followers;
  final int following;
  final int currentStreak;
  final int totalSessions;
  final int totalVolumeKg;
}

@immutable
class HomeDashboardData {
  const HomeDashboardData({
    required this.streak,
    required this.crew,
    required this.feed,
  });

  final StreakSummary streak;
  final List<MemberAvatar> crew;
  final List<WorkoutFeedItem> feed;
}

@immutable
class ProgressDashboardData {
  const ProgressDashboardData({
    required this.weeklyVolume,
    required this.workoutsPerWeek,
    required this.heatmap,
    required this.personalRecords,
  });

  final List<ProgressPoint> weeklyVolume;
  final List<ProgressPoint> workoutsPerWeek;
  final List<HeatmapDay> heatmap;
  final List<PersonalRecord> personalRecords;
}

@immutable
class ProfileDashboardData {
  const ProfileDashboardData({
    required this.profile,
    required this.heatmap,
    required this.recentWorkouts,
  });

  final ProfileSummary profile;
  final List<HeatmapDay> heatmap;
  final List<WorkoutFeedItem> recentWorkouts;
}
