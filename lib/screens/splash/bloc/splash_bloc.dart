import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashState.initial()) {
    on<SplashInitialEvent>(_splashInitialEvent);
  }

  Future<void> _splashInitialEvent(
      SplashInitialEvent event, Emitter<SplashState> emit) async {
    // 6 second delay
    await Future.delayed(const Duration(seconds: 6));
    emit(state.copyWith(status: SplashStatus.loaded));
  }
}
