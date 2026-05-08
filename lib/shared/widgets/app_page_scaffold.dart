import 'package:flutter/material.dart';

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 120),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF141519), Color(0xFF111214)]
                : const [Color(0xFFF7F7FA), Color(0xFFF0F1F6)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -10,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      isDark
                          ? const Color(0x14FFFFFF)
                          : const Color(0x88FFFFFF),
                      const Color(0x00000000),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -40,
              top: 180,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(44),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
