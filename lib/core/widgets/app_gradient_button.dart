import 'package:flutter/cupertino.dart';

import '../theme/app_spacing.dart';

class AppGradientButton extends StatelessWidget {
  const AppGradientButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.subtitle,
    this.icon = CupertinoIcons.play_fill,
  });

  final String label;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.55 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFD297B), Color(0xFFFF655B), Color(0xFFFF8C59)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.card,
            vertical: 18,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          minSize: 48,
          onPressed: onPressed,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: Icon(icon, color: CupertinoColors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: CupertinoColors.white.withOpacity(0.82),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_right,
                color: CupertinoColors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
