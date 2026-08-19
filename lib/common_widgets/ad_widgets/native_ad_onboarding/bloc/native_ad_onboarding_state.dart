part of 'native_ad_onboarding_bloc.dart';

class NativeAdOnboardingState {
  final bool isShowNative;

  NativeAdOnboardingState({required this.isShowNative});

  NativeAdOnboardingState copyWith({bool? isShowNative}) {
    return NativeAdOnboardingState(
      isShowNative: isShowNative ?? this.isShowNative,
    );
  }

  factory NativeAdOnboardingState.initial() {
    return NativeAdOnboardingState(isShowNative: false);
  }
}
