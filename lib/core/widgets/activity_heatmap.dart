import 'package:flutter/cupertino.dart';

import '../../data/mock/mock_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ActivityHeatmap extends StatelessWidget {
  const ActivityHeatmap({
    required this.days,
    super.key,
    this.columns = 8,
  });

  final List<HeatmapDay> days;
  final int columns;

  Color _cellColor(int intensity) {
    switch (intensity) {
      case 4:
        return AppColors.gradientStart;
      case 3:
        return AppColors.gradientMiddle;
      case 2:
        return AppColors.gradientEnd;
      case 1:
        return AppColors.warning;
      default:
        return AppColors.surfaceMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize =
            (constraints.maxWidth - ((columns - 1) * AppSpacing.small)) /
            columns;

        return Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: days
              .map(
                (day) => Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    color: _cellColor(day.intensity)
                        .withOpacity(day.intensity == 0 ? 0.35 : 0.95),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
