import 'package:flutter_localization/flutter_localization.dart';
import 'package:vn_template/core/utils/app_logger.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad_onboarding/bloc/native_ad_onboarding_bloc.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/common_widgets/shimmer/native_medium_ad_shimmer.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/core/utils/native_ad_manager.dart';

class NativeAdOnboardingWidget extends StatefulWidget {
  final int index;

  const NativeAdOnboardingWidget({super.key, this.index = 0});

  @override
  State<NativeAdOnboardingWidget> createState() => _NativeAdOnboardingWidgetState();
}

class _NativeAdOnboardingWidgetState extends State<NativeAdOnboardingWidget> {
  NativeAd? _nativeAd;

  static final List<String> onboardingNativeAds = [
    AppAdIdString.onBoarding1NativeAd,
    AppAdIdString.onBoarding2NativeAd,
  ];

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void didUpdateWidget(covariant NativeAdOnboardingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.index != oldWidget.index) {
      _nativeAd?.dispose();
      _nativeAd = null;

      context.read<NativeAdOnboardingBloc>().add(ShowNativeAdOnboardingEvent(isShowNative: false));

      _loadAd();
    }
  }

  void _loadAd() {
    int adIndex = widget.index;

    if (adIndex >= onboardingNativeAds.length) {
      adIndex = onboardingNativeAds.length - 1;
    }

    final adId = onboardingNativeAds[adIndex];

    AppLogger.log('🔍 NativeAdOnboardingWidget [index: ${widget.index}, adIndex: $adIndex]');

    _nativeAd = NativeAdManager().getMediumAd(adId);

    if (_nativeAd != null) {
      AppLogger.log('✅ Native ad received from manager');

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.read<NativeAdOnboardingBloc>().add(ShowNativeAdOnboardingEvent(isShowNative: true));
        }
      });
    } else {
      AppLogger.log('🔄 Loading native ad manually');

      _nativeAd = NativeAd(
        adUnitId: adId,
        request: const AdRequest(),
        factoryId: 'medium_native_ad',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            AppLogger.log('✅ Native ad loaded');

            if (mounted) {
              context.read<NativeAdOnboardingBloc>().add(ShowNativeAdOnboardingEvent(isShowNative: true));
            }
          },
          onAdFailedToLoad: (ad, error) {
            AppLogger.log('❌ Native ad failed: ${error.message}');

            ad.dispose();
          },
        ),
      )..load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NativeAdOnboardingBloc, NativeAdOnboardingState>(
      builder: (context, state) {
        if (!state.isShowNative || _nativeAd == null) {
          return SizedBox(
            height: 380,
            child: const Center(child: NativeMediumAdShimmer())
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Platform.isIOS ? 10.w : 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.info, size: 18, color: AppColors.greyColor),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: CommonTextWidget(
                      text: AppStrings.txtSponsored.getString(context),
                      textStyle: size12TextStyle(textColor: AppColors.greyColor, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 380,
              width: double.infinity,
              alignment: Alignment.center,
              child: AdWidget(ad: _nativeAd!),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }
}
