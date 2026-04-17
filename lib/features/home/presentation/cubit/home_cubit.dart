import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/mock/mock_feature_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(MockFeatureRepository repository)
    : super(HomeState(dashboard: repository.getHomeDashboard()));
}
