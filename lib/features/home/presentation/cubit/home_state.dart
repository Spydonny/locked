import 'package:flutter/foundation.dart';

import '../../../../data/mock/mock_models.dart';

@immutable
class HomeState {
  const HomeState({required this.dashboard});

  final HomeDashboardData dashboard;
}
