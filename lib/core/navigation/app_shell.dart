import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/workout/presentation/pages/workout_page.dart';
import '../theme/app_colors.dart';
import 'app_shell_cubit.dart';
import 'app_tab.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppShellCubit, int>(
      builder: (context, currentIndex) {
        return CupertinoTabScaffold(
          backgroundColor: AppColors.background,
          tabBar: CupertinoTabBar(
            backgroundColor: AppColors.surface,
            activeColor: AppColors.gradientStart,
            inactiveColor: AppColors.textSecondary,
            border: const Border(
              top: BorderSide(color: AppColors.divider, width: 0.8),
            ),
            currentIndex: currentIndex,
            onTap: context.read<AppShellCubit>().setTab,
            items: AppTab.values
                .map(
                  (tab) => BottomNavigationBarItem(
                    icon: Icon(tab.icon),
                    label: tab.label,
                  ),
                )
                .toList(),
          ),
          tabBuilder: (context, index) {
            final tab = AppTab.values[index];

            return CupertinoTabView(
              builder: (_) => switch (tab) {
                AppTab.home => const HomePage(),
                AppTab.workout => const WorkoutPage(),
                AppTab.progress => const ProgressPage(),
                AppTab.profile => const ProfilePage(),
              },
            );
          },
        );
      },
    );
  }
}
