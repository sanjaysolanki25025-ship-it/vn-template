part of 'banner_ad_bloc.dart';

class BannerAdState {
  final bool? isShowBanner;
  final BannerAd? bannerAd;

  BannerAdState({this.isShowBanner, this.bannerAd});

  BannerAdState copyWith({bool? isShowBanner, BannerAd? bannerAd}) {
    return BannerAdState(
      isShowBanner: isShowBanner ?? this.isShowBanner,
      bannerAd: bannerAd ?? this.bannerAd,
    );
  }

  factory BannerAdState.initial() {
    return BannerAdState(isShowBanner: false, bannerAd: null);
  }
}
