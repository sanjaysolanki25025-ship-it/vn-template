part of 'native_ad_bloc.dart';

abstract class NativeAdEvent {}

class ShowNativeAdEvent extends NativeAdEvent {
  final bool isShowNative;

  ShowNativeAdEvent({required this.isShowNative});
}
