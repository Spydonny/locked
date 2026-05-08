import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_colors.dart';

class ShimmerBlock extends StatelessWidget {
  const ShimmerBlock({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.radius = 22,
  });

  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardStrong,
        borderRadius: BorderRadius.circular(radius),
      ),
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(
      duration: 1400.ms,
      color: const Color(0x33FFFFFF),
    );
  }
}
