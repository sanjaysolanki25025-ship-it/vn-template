import 'package:flutter_bloc/flutter_bloc.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardState.initial()) {
    on<OnTapDashboardEvent>((event, emit) {
      emit(state.copyWith(currentIndex: event.index));
    });
  }
}
