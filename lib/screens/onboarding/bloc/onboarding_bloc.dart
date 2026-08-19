import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingState(isLoading: true)) {
    on<OnboardingInitialEvent>(_onInitial);
    on<PageChangedEvent>(_onPageChanged);
  }

  Future<void> _onInitial(OnboardingInitialEvent event, Emitter<OnboardingState> emit) async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(seconds: 4));
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _onPageChanged(PageChangedEvent event, Emitter<OnboardingState> emit) async {
    emit(state.copyWith(currentPage: event.pageIndex, isLoading: true));
    await Future.delayed(const Duration(seconds: 4));
    emit(state.copyWith(isLoading: false));
  }
}
