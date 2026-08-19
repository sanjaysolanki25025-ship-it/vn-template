part of 'native_ad_bloc.dart';

// class NativeAdState {
//   final List<NativeAd> nativeAds;
//   final bool isLoading;
//
//   NativeAdState({required this.nativeAds, required this.isLoading});
//
//   factory NativeAdState.initial() {
//     return NativeAdState(nativeAds: [], isLoading: false);
//   }
//
//   NativeAdState copyWith({List<NativeAd>? nativeAds, bool? isLoading}) {
//     return NativeAdState(
//       nativeAds: nativeAds ?? this.nativeAds,
//       isLoading: isLoading ?? this.isLoading,
//     );
//   }
// }

// class NativeAdState {
//   final bool isShowNative;
//
//   NativeAdState({required this.isShowNative});
//
//   NativeAdState copyWith({bool? isShowNative}) {
//     return NativeAdState(isShowNative: isShowNative ?? this.isShowNative);
//   }
//
//   factory NativeAdState.initial() {
//     return NativeAdState(isShowNative: false);
//   }
// }

class NativeAdState {
  final bool isShowNative;
  // This Map allows us to store different ad objects for different screens
  final Map<String, NativeAd> ads;

  NativeAdState({
    required this.isShowNative,
    required this.ads,
  });

  factory NativeAdState.initial() => NativeAdState(
    isShowNative: false,
    ads: {},
  );

  NativeAdState copyWith({
    bool? isShowNative,
    Map<String, NativeAd>? ads,
  }) {
    return NativeAdState(
      isShowNative: isShowNative ?? this.isShowNative,
      ads: ads ?? this.ads,
    );
  }
}

