class OnboardingState {
  final int currentPage;
  final bool isLoading;

  OnboardingState({this.currentPage = 0, this.isLoading = true});

  OnboardingState copyWith({int? currentPage, bool? isLoading}) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
