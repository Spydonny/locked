import 'package:flutter_bloc/flutter_bloc.dart';

class AppShellCubit extends Cubit<int> {
  AppShellCubit() : super(0);

  void setTab(int index) => emit(index);
}
