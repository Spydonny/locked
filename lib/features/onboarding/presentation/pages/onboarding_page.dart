import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_gradient_button.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/onboarding_page_dots.dart';
import '../widgets/onboarding_slide_view.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) => previous.pageIndex != current.pageIndex,
      listener: (context, state) {
        _pageController.animateToPage(
          state.pageIndex,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      },
      child: CupertinoPageScaffold(
        backgroundColor: AppColors.background,
        child: SafeArea(
          child: BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              return Stack(
                children: [
                  const _OnboardingBackdrop(),
                  Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: context.read<OnboardingCubit>().setPage,
                          children: const [
                            OnboardingSlideView(
                              eyebrow: 'INTRO',
                              title: 'Train. Track. Grow.',
                              description:
                                  'A focused place to log the work, keep your momentum visible, and stay connected to the people pushing with you.',
                              accentLabel: 'Strength training, stripped down to what matters',
                            ),
                            OnboardingSlideView(
                              eyebrow: 'PROGRESSION',
                              title: 'Progressive overload, made clear.',
                              description:
                                  'See weight, reps, and volume build over time so every session has a purpose and every small jump gets counted.',
                              accentLabel: 'Small increases. Real compounding.',
                            ),
                            OnboardingSlideView(
                              eyebrow: 'SOCIAL',
                              title: 'Train with your circle.',
                              description:
                                  'Share sessions, react to PRs, and keep the feed full of real effort instead of empty noise.',
                              accentLabel: 'A training network, not another distraction',
                            ),
                            _ProfileSetupStep(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.page,
                          12,
                          AppSpacing.page,
                          AppSpacing.page,
                        ),
                        child: Column(
                          children: [
                            OnboardingPageDots(
                              currentIndex: state.pageIndex,
                              total: OnboardingCubit.totalPages,
                            ),
                            const SizedBox(height: 18),
                            if (state.isLastPage)
                              AppGradientButton(
                                label: state.displayName.trim().isEmpty
                                    ? 'Create Your Space'
                                    : 'Enter Locked, ${state.displayName.trim()}',
                                subtitle: state.canContinueFromForm
                                    ? '@${state.username.trim()} is ready'
                                    : 'Add your name and username to continue',
                                icon: CupertinoIcons.arrow_right_circle,
                                onPressed: state.canContinueFromForm
                                    ? context.read<OnboardingCubit>().complete
                                    : null,
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: _BottomButton(
                                      label: state.pageIndex == 0 ? 'Skip' : 'Back',
                                      isSecondary: true,
                                      onPressed: state.pageIndex == 0
                                          ? () => context
                                                .read<OnboardingCubit>()
                                                .setPage(
                                                  OnboardingCubit.totalPages - 1,
                                                )
                                          : context
                                                .read<OnboardingCubit>()
                                                .previousPage,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: _BottomButton(
                                      label: 'Continue',
                                      onPressed: context
                                          .read<OnboardingCubit>()
                                          .nextPage,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileSetupStep extends StatefulWidget {
  const _ProfileSetupStep();

  @override
  State<_ProfileSetupStep> createState() => _ProfileSetupStepState();
}

class _ProfileSetupStepState extends State<_ProfileSetupStep> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    final state = context.read<OnboardingCubit>().state;
    _nameController = TextEditingController(text: state.displayName);
    _usernameController = TextEditingController(text: state.username);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) =>
          previous.displayName != current.displayName ||
          previous.username != current.username,
      listener: (context, state) {
        if (_nameController.text != state.displayName) {
          _nameController.text = state.displayName;
          _nameController.selection = TextSelection.collapsed(
            offset: _nameController.text.length,
          );
        }

        if (_usernameController.text != state.username) {
          _usernameController.text = state.username;
          _usernameController.selection = TextSelection.collapsed(
            offset: _usernameController.text.length,
          );
        }
      },
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: BlocBuilder<OnboardingCubit, OnboardingState>(
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Set up your profile.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'A clean start. Pick the name people see and the username they follow.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _InputBlock(
                      label: 'Name',
                      controller: _nameController,
                      placeholder: 'Mila Hart',
                      onChanged: context.read<OnboardingCubit>().updateDisplayName,
                    ),
                    const SizedBox(height: 14),
                    _InputBlock(
                      label: 'Username',
                      controller: _usernameController,
                      placeholder: 'milalifts',
                      prefix: '@',
                      onChanged: context.read<OnboardingCubit>().updateUsername,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMedium,
                        ),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        state.canContinueFromForm
                            ? 'Profile ready for ${state.displayName.trim()} (@${state.username.trim()})'
                            : 'Add both fields to unlock the app.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _InputBlock extends StatelessWidget {
  const _InputBlock({
    required this.label,
    required this.controller,
    required this.placeholder,
    required this.onChanged,
    this.prefix,
  });

  final String label;
  final TextEditingController controller;
  final String placeholder;
  final String? prefix;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          onChanged: onChanged,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          placeholder: placeholder,
          prefix: prefix == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Text(
                    prefix!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(color: AppColors.divider),
          ),
        ),
      ],
    );
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton({
    required this.label,
    required this.onPressed,
    this.isSecondary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 48,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSecondary ? AppColors.surface : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: isSecondary ? AppColors.divider : AppColors.surfaceMuted,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _OnboardingBackdrop extends StatelessWidget {
  const _OnboardingBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gradientStart.withOpacity(0.24),
                    AppColors.gradientStart.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -90,
            bottom: 60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gradientEnd.withOpacity(0.18),
                    AppColors.gradientEnd.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
