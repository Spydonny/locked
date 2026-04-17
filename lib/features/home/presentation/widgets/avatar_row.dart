import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/mock/mock_models.dart';

class AvatarRow extends StatelessWidget {
  const AvatarRow({required this.avatars, super.key});

  final List<MemberAvatar> avatars;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final avatar = avatars[index];
          return Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: avatar.color,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      avatar.initials,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (avatar.isActive)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.background,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                avatar.name.split(' ').first,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemCount: avatars.length,
      ),
    );
  }
}
