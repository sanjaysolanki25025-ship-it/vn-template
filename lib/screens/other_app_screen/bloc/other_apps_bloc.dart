import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/other_app_model.dart';
import '../repository/other_app_repository.dart';

part 'other_apps_event.dart';
part 'other_apps_state.dart';

class OtherAppsBloc extends Bloc<OtherAppsEvent, OtherAppsState> {
  OtherAppsBloc({OtherAppRepository? repository})
    : _repository = repository ?? OtherAppRepository(),
      super(OtherAppsState.initial()) {
    on<FetchOtherAppsEvent>(_fetchOtherAppsEvent);
  }

  final OtherAppRepository _repository;

  FutureOr<void> _fetchOtherAppsEvent(
    FetchOtherAppsEvent event,
    Emitter<OtherAppsState> emit,
  ) async {
    emit(state.copyWith(status: OtherAppsStatus.loading));

    final result = await _repository.fetchOtherApps();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OtherAppsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (apps) => emit(
        state.copyWith(
          status: OtherAppsStatus.loaded,
          apps: apps,
          errorMessage: null,
        ),
      ),
    );
  }
}
