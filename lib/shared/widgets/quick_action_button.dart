import 'package:flutter/cupertino.dart';

import '../../theme/app_colors.dart';

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: AppColors.cardStrong,
      borderRadius: BorderRadius.circular(18),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
