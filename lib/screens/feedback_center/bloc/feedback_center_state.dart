part of 'feedback_center_bloc.dart';

enum FeedbackCenterStatus { initial, submitLoading, submitLoaded, submitError, error }

class FeedbackCenterState {
  final FeedbackCenterStatus status;
  final String? selectedOption;
  final bool? isChecked;
  final File? imageFile;
  final String? errorMessage;

  FeedbackCenterState({
    required this.status,
    this.selectedOption,
    this.isChecked,
    this.imageFile,
    this.errorMessage,
  });

  factory FeedbackCenterState.initial() {
    return FeedbackCenterState(
      status: FeedbackCenterStatus.initial,
      selectedOption: null,
      isChecked: false,
      imageFile: null,
      errorMessage: null,
    );
  }

  FeedbackCenterState copyWith({
    FeedbackCenterStatus? status,
    String? selectedOption,
    bool? isChecked,
    File? imageFile,
    String? errorMessage,
  }) {
    return FeedbackCenterState(
      status: status ?? this.status,
      selectedOption: selectedOption ?? this.selectedOption,
      isChecked: isChecked ?? this.isChecked,
      imageFile: imageFile ?? this.imageFile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
