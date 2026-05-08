import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_surface.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    final success = await ref.read(authControllerProvider.notifier).register(
          displayName: _displayNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return AuthScaffold(
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeader(
                  title: 'Create your premium fitness workspace.',
                  subtitle:
                      'Everything from sessions to analytics, synced into a calm and private system built for consistency.',
                ),
                const SizedBox(height: 18),
                AuthSurface(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start with a clean account',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.9,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We will sign you in immediately after registration.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 20),
                        if (authState.errorMessage case final message?)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AuthErrorBanner(message: message),
                          ),
                        AuthTextField(
                          controller: _displayNameController,
                          label: 'Display name',
                          hintText: 'How should we greet you?',
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final displayName = value?.trim() ?? '';
                            if (displayName.isEmpty) {
                              return 'Enter a display name.';
                            }
                            if (displayName.length < 2) {
                              return 'Display name must be at least 2 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        AuthTextField(
                          controller: _emailController,
                          label: 'Email',
                          hintText: 'you@locked.app',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty) {
                              return 'Enter your email.';
                            }
                            final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                            if (!regex.hasMatch(email)) {
                              return 'Enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        AuthTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hintText: 'Use 8+ characters',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          suffix: IconButton(
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                            ),
                          ),
                          validator: (value) {
                            final password = value ?? '';
                            if (password.isEmpty) {
                              return 'Enter a password.';
                            }
                            if (password.length < 8) {
                              return 'Password must be at least 8 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        AuthTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm password',
                          hintText: 'Repeat your password',
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          suffix: IconButton(
                            onPressed: () {
                              setState(
                                () => _obscureConfirmPassword = !_obscureConfirmPassword,
                              );
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                            ),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        AuthPrimaryButton(
                          label: 'Create account',
                          isLoading: authState.isSubmitting,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Center(
                  child: TextButton(
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).clearError();
                      context.pop();
                    },
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        children: [
                          TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
