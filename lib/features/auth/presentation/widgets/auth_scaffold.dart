import 'package:flutter/material.dart';

import 'auth_background.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AuthBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth > 420 ? 28.0 : 20.0;

                return AnimatedPadding(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    top: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: child,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
