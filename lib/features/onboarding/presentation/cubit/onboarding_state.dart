import 'package:flutter/foundation.dart';

@immutable
class OnboardingState {
  const OnboardingState({
    required this.pageIndex,
    required this.displayName,
    required this.username,
    required this.hasCompleted,
  });

  factory OnboardingState.initial() {
    return const OnboardingState(
      pageIndex: 0,
      displayName: '',
      username: '',
      hasCompleted: false,
    );
  }

  final int pageIndex;
  final String displayName;
  final String username;
  final bool hasCompleted;

  bool get isLastPage => pageIndex == 3;

  bool get canContinueFromForm =>
      displayName.trim().isNotEmpty && username.trim().isNotEmpty;

  OnboardingState copyWith({
    int? pageIndex,
    String? displayName,
    String? username,
    bool? hasCompleted,
  }) {
    return OnboardingState(
      pageIndex: pageIndex ?? this.pageIndex,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      hasCompleted: hasCompleted ?? this.hasCompleted,
    );
  }
}
