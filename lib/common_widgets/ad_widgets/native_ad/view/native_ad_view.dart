import 'package:flutter_localization/flutter_localization.dart';
import 'dart:io';
import 'package:vn_template/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/common_widgets/shimmer/native_ad_shimmer.dart';
import 'package:vn_template/common_widgets/shimmer/native_medium_ad_shimmer.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/core/utils/native_ad_manager.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';
import 'package:vn_template/routes/app_route_string.dart';

class NativeAdView extends StatefulWidget {
  final String adId;
  final bool isSplash;
  final bool isSmallAd;

  const NativeAdView({
    super.key,
    this.isSplash = false,
    this.isSmallAd = false,
    required this.adId,
  });

  @override
  State<NativeAdView> createState() => _NativeAdViewState();
}

class _NativeAdViewState extends State<NativeAdView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static bool get _isUserSubscribed {
    return AppPreferences().getBool(AppPreferences.subscriptionPlan) ?? false;
  }

  /// Logic to decide whether ad should show or not
  bool get _shouldShowAd {
    if (widget.isSplash) return true;
    return !_isUserSubscribed;
  }

  NativeAd? _nativeAd;

  @override
  void initState() {
    super.initState();

    if (_shouldShowAd) {
      loadNativeAd();
    }
  }

  void loadNativeAd() {
    AppLogger.log(
      '🔍 NativeAdView: Requesting ad... '
      '(isSmallAd: ${widget.isSmallAd}, adId: ${widget.adId})',
    );

    _nativeAd = widget.isSmallAd
        ? NativeAdManager().getAd(widget.adId)
        : NativeAdManager().getMediumAd(widget.adId);

    if (_nativeAd != null) {
      AppLogger.log('✅ NativeAdView: Ad received from manager.');

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.read<NativeAdBloc>().add(
            ShowNativeAdEvent(isShowNative: true),
          );
        }
      });
    } else {
      AppLogger.log('🔄 NativeAdView: No cached ad. Loading manually...');
      _loadNormalManualAd();
    }
  }

  void _loadNormalManualAd() {
    _nativeAd = NativeAd(
      request: const AdRequest(),
      factoryId: widget.isSmallAd ? "row_native_ad" : "medium_native_ad",
      adUnitId: widget.adId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          AppLogger.log('✅ NativeAdView: Manual ad loaded.');
          if (mounted) {
            context.read<NativeAdBloc>().add(
              ShowNativeAdEvent(isShowNative: true),
            );
          }
        },
        onAdFailedToLoad: (ad, error) {
          AppLogger.log('❌ NativeAdView: Manual ad failed: ${error.message}');
          ad.dispose();
        },
      ),
    );
    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    /// If ad should not show
    if (!_shouldShowAd) {
      return const SizedBox();
    }

    return BlocBuilder<NativeAdBloc, NativeAdState>(
      builder: (context, state) {
        if (!state.isShowNative || _nativeAd == null) {
          return SizedBox(
            height: widget.isSmallAd
                ? 140
                : Platform.isIOS
                ? 340
                : 380,
            child: Center(
              child: widget.isSmallAd
                  ? const NativeAdShimmer()
                  : const NativeMediumAdShimmer(),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SBH5(),

            /// Sponsored + Remove Ads Row
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Platform.isIOS ? 10.w : 16.w,
              ),
              child: Row(
                children: [
                  if (!widget.isSplash)
                    GestureDetector(
                      onTap: () {
                        // context.push(AppRoutesString.subscriptionView);
                      },
                      child: CommonTextWidget(
                        text: AppStrings.txtRemoveAds.getString(context),
                        isUnderline: true,
                        underlineColor: AppColors.greyColor,
                        textStyle: size12TextStyle(
                          textColor: AppColors.greyColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                  const Spacer(),

                  const Icon(
                    Icons.info,
                    size: 18,
                    color: AppColors.greyColor,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: CommonTextWidget(
                        text: AppStrings.txtSponsored.getString(context),
                        textStyle: size12TextStyle(
                          textColor: AppColors.greyColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: widget.isSmallAd
                  ? 140
                  : Platform.isIOS
                  ? 360
                  : 380,
              width: double.infinity,
              child: AdWidget(ad: _nativeAd!),
            ),
          ],
        );
      },
    );
  }
}
