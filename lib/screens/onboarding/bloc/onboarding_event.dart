abstract class OnboardingEvent {}

class OnboardingInitialEvent extends OnboardingEvent {}

class PageChangedEvent extends OnboardingEvent {
  final int pageIndex;
  PageChangedEvent(this.pageIndex);
}
