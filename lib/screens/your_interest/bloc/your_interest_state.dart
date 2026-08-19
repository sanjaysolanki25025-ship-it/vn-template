part of 'your_interest_bloc.dart';

enum YourInterestStatus { initial, updated, error, success }

class YourInterestState {
  final List<String> selectedInterests;
  final YourInterestStatus status;
  final String? errorMessage;

  const YourInterestState({
    required this.selectedInterests,
    this.status = YourInterestStatus.initial,
    this.errorMessage,
  });

  factory YourInterestState.initial() {
    return const YourInterestState(
      selectedInterests: [],
      status: YourInterestStatus.initial,
    );
  }

  YourInterestState copyWith({
    List<String>? selectedInterests,
    YourInterestStatus? status,
    String? errorMessage,
  }) {
    return YourInterestState(
      selectedInterests: selectedInterests ?? this.selectedInterests,
      status: status ?? this.status,
      errorMessage: errorMessage, // We don't always keep old error message
    );
  }
}
