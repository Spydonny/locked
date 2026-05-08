import 'package:flutter/cupertino.dart';

import '../../theme/app_colors.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.height = 10,
  });

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final safeValue = value < 0 ? 0.0 : (value > 1 ? 1.0 : value);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: height,
        color: const Color(0x14FFFFFF),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: safeValue,
          child: Container(color: AppColors.white),
        ),
      ),
    );
  }
}
