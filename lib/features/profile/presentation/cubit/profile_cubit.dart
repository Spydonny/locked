import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/mock/mock_feature_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(MockFeatureRepository repository)
    : super(ProfileState(dashboard: repository.getProfileDashboard()));
}
