import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.black,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        elevation: 0,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: isLoading
            ? const SizedBox(
                key: ValueKey('loading'),
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                key: const ValueKey('label'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
