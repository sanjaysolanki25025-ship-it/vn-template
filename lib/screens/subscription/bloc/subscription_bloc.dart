import 'package:flutter_bloc/flutter_bloc.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc() : super(SubscriptionState.initial()) {
    on<ToggleTermsAcceptedEvent>(_onToggleTermsAccepted);
  }

  void _onToggleTermsAccepted(ToggleTermsAcceptedEvent event, Emitter<SubscriptionState> emit) {
    emit(state.copyWith(isTermsAccepted: !state.isTermsAccepted));
  }
}
