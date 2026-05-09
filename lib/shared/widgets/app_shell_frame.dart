import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';

class AppShellFrame extends StatelessWidget {
  const AppShellFrame({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(child: navigationShell),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.18 : 0.05,
                        ),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: CupertinoTabBar(
                    currentIndex: navigationShell.currentIndex,
                    backgroundColor: const Color(0x00000000),
                    activeColor: isDark ? AppColors.white : AppColors.black,
                    inactiveColor: AppColors.textSecondary,
                    border: Border.all(color: const Color(0x00000000)),
                    onTap: (index) {
                      navigationShell.goBranch(
                        index,
                        initialLocation: index == navigationShell.currentIndex,
                      );
                    },
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.house_fill),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.person_2_fill),
                        label: 'Feed',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.play_circle_fill),
                        label: 'Workout',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.chart_bar_alt_fill),
                        label: 'Analytics',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.gear_alt_fill),
                        label: 'Settings',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
