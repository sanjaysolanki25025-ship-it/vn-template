part of 'feedback_center_bloc.dart';

@immutable
abstract class FeedbackCenterEvent {}

class SelectedFeedbackOptionEvent extends FeedbackCenterEvent {
  final String selectedOption;

  SelectedFeedbackOptionEvent({required this.selectedOption});
}

class CheckedTermConditionEvent extends FeedbackCenterEvent {
  final bool isChecked;

  CheckedTermConditionEvent({required this.isChecked});
}

class SelectedUploadImageEvent extends FeedbackCenterEvent {}

class RemoveReferenceImageEvent extends FeedbackCenterEvent {}

class SubmitFeedbackEvent extends FeedbackCenterEvent {
  final FeedbackModel model;

  SubmitFeedbackEvent({required this.model});
}
