import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/banner_ad/bloc/banner_ad_bloc.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';

class BannerAdWidget extends StatefulWidget {
  final String adId;

  const BannerAdWidget({super.key, required this.adId});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _didLoadOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isSubscribed = AppPreferences().getBool(AppPreferences.subscriptionPlan) ?? false;
    if (isSubscribed) return;

    if (!_didLoadOnce) {
      _didLoadOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadBannerAd();
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() async {
    final isSubscribed = AppPreferences().getBool(AppPreferences.subscriptionPlan) ?? false;
    if (isSubscribed) return;

    final AdSize? adaptiveSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate());

    _bannerAd = BannerAd(
      adUnitId: widget.adId,
      request: const AdRequest(),
      size: adaptiveSize ?? AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          context.read<BannerAdBloc>().add(ShowBannerAdEvent(isShowBanner: true, bannerAd: ad as BannerAd));
        },
        onAdFailedToLoad: (ad, error) {
          context.read<BannerAdBloc>().add(ShowBannerAdEvent(isShowBanner: false, bannerAd: null));
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    return (AppPreferences().getBool(AppPreferences.subscriptionPlan) ?? false)
        ? SizedBox()
        : BlocBuilder<BannerAdBloc, BannerAdState>(
      builder: (context, state) {
        if (state.isShowBanner == true && state.bannerAd != null) {
          return Container(
            color: AppColors.primaryColor,
            alignment: Alignment.center,
            width: double.infinity,
            height: state.bannerAd!.size.height.toDouble(),
            child: SizedBox(
              width: state.bannerAd!.size.width.toDouble(),
              height: state.bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: state.bannerAd!),
            ),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}
