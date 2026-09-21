class SubscriptionState {
  final bool isTermsAccepted;

  const SubscriptionState({
    required this.isTermsAccepted,
  });

  factory SubscriptionState.initial() {
    return const SubscriptionState(
      isTermsAccepted: false,
    );
  }

  SubscriptionState copyWith({
    bool? isTermsAccepted,
  }) {
    return SubscriptionState(
      isTermsAccepted: isTermsAccepted ?? this.isTermsAccepted,
    );
  }
}
