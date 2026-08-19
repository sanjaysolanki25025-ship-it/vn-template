part of 'native_ad_onboarding_bloc.dart';

abstract class NativeAdOnboardingEvent {}

class ShowNativeAdOnboardingEvent extends NativeAdOnboardingEvent {
  final bool isShowNative;

  ShowNativeAdOnboardingEvent({required this.isShowNative});
}
