import 'package:flutter_bloc/flutter_bloc.dart';

import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingState.initial());

  static const int totalPages = 4;

  void setPage(int index) {
    if (index == state.pageIndex) {
      return;
    }

    emit(state.copyWith(pageIndex: index));
  }

  void nextPage() {
    if (state.pageIndex >= totalPages - 1) {
      return;
    }

    emit(state.copyWith(pageIndex: state.pageIndex + 1));
  }

  void previousPage() {
    if (state.pageIndex <= 0) {
      return;
    }

    emit(state.copyWith(pageIndex: state.pageIndex - 1));
  }

  void updateDisplayName(String value) {
    emit(state.copyWith(displayName: value));
  }

  void updateUsername(String value) {
    emit(
      state.copyWith(
        username: value.replaceAll('@', '').replaceAll(' ', '').toLowerCase(),
      ),
    );
  }

  void complete() {
    if (!state.canContinueFromForm) {
      return;
    }

    emit(state.copyWith(hasCompleted: true));
  }
}
