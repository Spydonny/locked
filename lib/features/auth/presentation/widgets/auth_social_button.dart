import 'package:flutter/material.dart';

class AuthSocialButton extends StatelessWidget {
  const AuthSocialButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.leading,
  });

  final String label;
  final VoidCallback onPressed;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          side: BorderSide.none,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SocialGlyph extends StatelessWidget {
  const SocialGlyph.apple({super.key})
      : label = null,
        icon = Icons.apple;

  const SocialGlyph.google({super.key})
      : label = 'G',
        icon = null;

  final String? label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isDark ? Colors.white : Colors.black,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(
              icon,
              size: 15,
              color: isDark ? Colors.black : Colors.white,
            )
          : Text(
              label!,
              style: TextStyle(
                color: isDark ? Colors.black : Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}
