import 'package:flutter/foundation.dart';

import '../../../../data/mock/mock_models.dart';

@immutable
class ProfileState {
  const ProfileState({
    required this.dashboard,
  });

  final ProfileDashboardData dashboard;
}
