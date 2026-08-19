import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_template/common_widgets/common_image.dart';
import 'package:vn_template/common_widgets/common_lottie_asset.dart';
import 'package:vn_template/core/constant/app_image_string.dart';
import 'package:vn_template/core/constant/app_lotties_string.dart';
import 'package:go_router/go_router.dart';
import 'package:vn_template/data/helper/ad_helper.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';
import 'package:vn_template/routes/app_route_string.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/view/native_ad_view.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../bloc/splash_bloc.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    context.read<SplashBloc>().add(SplashInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state.status == SplashStatus.loaded) {
          final remoteConfig = FirebaseRemoteConfig.instance;
          final bool isMaintenance = remoteConfig.getBool("isMaintenance");

          /// Maintenance Mode
          if (isMaintenance) {
            AdHelper.showAppOpenAd(
              onComplete: () {
                context.go(AppRoutesString.maintenanceView);
              },
            );
            return;
          }

          AdHelper.showInterstitialAd(
            adId: AppAdIdString.splashInterstitial,
            onAdClosed: () {
              final prefs = AppPreferences();
              final hasOnboarding =
                  prefs.getBool(AppPreferences.onboarding) ?? false;
              final hasLanguage =
                  prefs.getBool(AppPreferences.isLanguageSelected) ?? false;
              final hasInterest =
                  prefs.getBool(AppPreferences.isInterestDone) ?? false;

              if (!hasOnboarding) {
                context.go(AppRoutesString.onboardingView);
              } else if (!hasLanguage) {
                context.go(AppRoutesString.selectAppLanguageView);
              } else if (!hasInterest) {
                context.go(AppRoutesString.yourInterestView);
              } else {
                AdHelper.showAppOpenAd(
                  onComplete: () {
                    context.go(AppRoutesString.dashboardView);
                  },
                );
              }
            },
            reloadAfterClose: false,
          );
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 0.7),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) =>
                            Transform.scale(scale: scale, child: child),
                        child: const CommonImage(
                          assetName: AppImagesString.imgAppLogo,
                        ),
                      ),
                      CommonLottieAsset(
                        assetName: AppLottiesString.lottieOnboardingLoading,
                        width: MediaQuery.sizeOf(context).width,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            BlocProvider(
              create: (context) => NativeAdBloc(),
              child: NativeAdView(
                isSplash: true,
                adId: AppAdIdString.splashNativeAd,
                isSmallAd: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
