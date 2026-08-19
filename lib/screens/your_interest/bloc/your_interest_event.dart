part of 'your_interest_bloc.dart';

abstract class YourInterestEvent {}

class ToggleInterestEvent extends YourInterestEvent {
  final String interest;
  ToggleInterestEvent(this.interest);
}

class SubmitInterestsEvent extends YourInterestEvent {}
