import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.onFieldSubmitted,
    this.validator,
    this.suffix,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        suffixIcon: suffix,
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFF7F7FA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
