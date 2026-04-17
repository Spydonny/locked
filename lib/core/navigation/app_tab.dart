import 'package:flutter/cupertino.dart';

enum AppTab {
  home('Home', CupertinoIcons.home),
  workout('Workout', CupertinoIcons.flame),
  progress('Progress', CupertinoIcons.chart_bar),
  profile('Profile', CupertinoIcons.person);

  const AppTab(this.label, this.icon);

  final String label;
  final IconData icon;
}
