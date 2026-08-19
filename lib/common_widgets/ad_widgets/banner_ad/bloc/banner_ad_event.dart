part of 'banner_ad_bloc.dart';

abstract class BannerAdEvent {}

class ShowBannerAdEvent extends BannerAdEvent {
  final BannerAd? bannerAd;
  final bool isShowBanner;

  ShowBannerAdEvent({required this.isShowBanner, required this.bannerAd});
}
