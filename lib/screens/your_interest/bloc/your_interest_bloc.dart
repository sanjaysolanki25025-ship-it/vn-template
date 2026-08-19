import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_template/core/constant/app_string.dart';

part 'your_interest_event.dart';
part 'your_interest_state.dart';

class YourInterestBloc extends Bloc<YourInterestEvent, YourInterestState> {
  YourInterestBloc() : super(YourInterestState.initial()) {
    on<ToggleInterestEvent>(_onToggleInterestEvent);
    on<SubmitInterestsEvent>(_onSubmitInterestsEvent);
  }

  void _onToggleInterestEvent(
    ToggleInterestEvent event,
    Emitter<YourInterestState> emit,
  ) {
    final currentList = List<String>.from(state.selectedInterests);
    if (currentList.contains(event.interest)) {
      currentList.remove(event.interest);
    } else {
      currentList.add(event.interest);
    }
    emit(state.copyWith(
      selectedInterests: currentList,
      status: YourInterestStatus.updated,
    ));
  }

  void _onSubmitInterestsEvent(
    SubmitInterestsEvent event,
    Emitter<YourInterestState> emit,
  ) {
    if (state.selectedInterests.isEmpty) {
      emit(state.copyWith(
        status: YourInterestStatus.error,
        errorMessage: AppStrings.txtAtLeastOneInterest,
      ));
      // Revert status to updated so it can trigger again
      emit(state.copyWith(status: YourInterestStatus.updated, errorMessage: null));
    } else {
      emit(state.copyWith(status: YourInterestStatus.success));
    }
  }
}
