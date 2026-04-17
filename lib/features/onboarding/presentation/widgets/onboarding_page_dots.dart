import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';

class OnboardingPageDots extends StatelessWidget {
  const OnboardingPageDots({
    required this.currentIndex,
    required this.total,
    super.key,
  });

  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: isActive ? 28 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.gradientStart : AppColors.divider,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
