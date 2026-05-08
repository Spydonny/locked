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
import '../widgets/auth_social_button.dart';
import '../widgets/auth_surface.dart';
import '../widgets/auth_text_field.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    final success = await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  void _showSocialMessage(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider sign in is not wired in this environment yet.'),
      ),
    );
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
                  title: 'Sign in to your private training OS.',
                  subtitle:
                      'Track workouts, nutrition, physique and sync everything through a calm premium mobile experience.',
                ),
                const SizedBox(height: 18),
                AuthSurface(
                  child: AutofillGroup(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.9,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Use your email credentials to continue.',
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
                            hintText: 'Minimum 8 characters',
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _submit(),
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
                                return 'Enter your password.';
                              }
                              if (password.length < 8) {
                                return 'Password must be at least 8 characters.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          AuthPrimaryButton(
                            label: 'Continue',
                            isLoading: authState.isSubmitting,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withValues(alpha: 0.12),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'or',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withValues(alpha: 0.12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              AuthSocialButton(
                                label: 'Apple',
                                leading: const SocialGlyph.apple(),
                                onPressed: () => _showSocialMessage('Apple'),
                              ),
                              const SizedBox(width: 12),
                              AuthSocialButton(
                                label: 'Google',
                                leading: const SocialGlyph.google(),
                                onPressed: () => _showSocialMessage('Google'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Center(
                  child: TextButton(
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).clearError();
                      context.push('/auth/register');
                    },
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        children: [
                          TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: 'Create one',
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
