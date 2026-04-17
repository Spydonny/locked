import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/navigation/app_shell.dart';
import 'core/navigation/app_shell_cubit.dart';
import 'core/theme/app_theme.dart';
import 'data/mock/mock_feature_repository.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'features/onboarding/presentation/cubit/onboarding_state.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/progress/presentation/cubit/progress_cubit.dart';
import 'features/workout/presentation/cubit/workout_cubit.dart';

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => const MockFeatureRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => OnboardingCubit()),
          BlocProvider(create: (_) => AppShellCubit()),
          BlocProvider(
            create: (context) =>
                HomeCubit(context.read<MockFeatureRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                WorkoutCubit(context.read<MockFeatureRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                ProgressCubit(context.read<MockFeatureRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                ProfileCubit(context.read<MockFeatureRepository>()),
          ),
        ],
        child: CupertinoApp(
          debugShowCheckedModeBanner: false,
          title: 'Locked',
          theme: AppTheme.cupertinoTheme,
          home: BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: state.hasCompleted
                    ? const AppShell(key: ValueKey('app-shell'))
                    : const OnboardingPage(key: ValueKey('onboarding')),
              );
            },
          ),
        ),
      ),
    );
  }
}
