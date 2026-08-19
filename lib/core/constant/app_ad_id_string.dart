import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class AppAdIdString {
  /// Test Ad IDs (Default values)
  static String appOpen = 'ca-app-pub-3940256099942544/9257395921';

  static String startCreatingRewardedAd = 'ca-app-pub-3940256099942544/5224354917';
  static String dinoGameRestart = 'ca-app-pub-3940256099942544/5224354917';

  static String favouriteNativeAd = 'ca-app-pub-3940256099942544/2247696110';
  static String favouriteBottomNativeAd = 'ca-app-pub-3940256099942544/2247696110';
  static String templateDetailNativeAd = 'ca-app-pub-3940256099942544/2247696110';
  static String templateDetailBottomNativeAd = 'ca-app-pub-3940256099942544/2247696110';
  static String settingNativeAd = 'ca-app-pub-3940256099942544/2247696110';
  static String rateUsNativeAd = 'ca-app-pub-3940256099942544/2247696110';
  static String splashNativeAd = 'ca-app-pub-3940256099942544/2247696110';
  static String maintenanceNativeAd = 'ca-app-pub-3940256099942544/2247696110';
  static String discoverNativeAd = 'ca-app-pub-3940256099942544/2247696110';
  static String discoverBottomSheetNativeAd = 'ca-app-pub-3940256099942544/2247696110';
  static String noDataFoundNativeAd = 'ca-app-pub-3940256099942544/2247696110';
  static String exitAppNativeAd = 'ca-app-pub-3940256099942544/2247696110';
  static String onBoarding1NativeAd = 'ca-app-pub-3940256099942544/2247696110';
  static String onBoarding2NativeAd = 'ca-app-pub-3940256099942544/2247696110';
  static String homeBottomNativeAd = 'ca-app-pub-3940256099942544/2247696110';
  static String selectLanguageNativeAd = 'ca-app-pub-3940256099942544/2247696110';
  static String chooseYourInterestNativeAd = 'ca-app-pub-3940256099942544/2247696110';

  static String splashInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static String onboardingInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static String homeReelsInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static String loadMoreInterstitialAd = 'ca-app-pub-3940256099942544/1033173712';
  static String backButtonInterstitialAd = 'ca-app-pub-3940256099942544/1033173712';
  static String categoryOnTapInterstitialAd = 'ca-app-pub-3940256099942544/1033173712';
  static String onboardingDoneInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static String selectLanguageInterstitial = 'ca-app-pub-3940256099942544/1033173712';

  static String discoverBannerAd = 'ca-app-pub-3940256099942544/6300978111';
  static String templateDetailBanner = 'ca-app-pub-3940256099942544/6300978111';
  static String favouriteBannerAd = 'ca-app-pub-3940256099942544/6300978111';
  static String settingBannerAd = 'ca-app-pub-3940256099942544/6300978111';
  static String feedbackBannerAd = 'ca-app-pub-3940256099942544/6300978111';
  static String qrBannerAd = 'ca-app-pub-3940256099942544/6300978111';
  static String otherAppBannerAd = 'ca-app-pub-3940256099942544/6300978111';
  static String selectLanguageBanner = 'ca-app-pub-3940256099942544/6300978111';
  static String chooseInterestBanner = 'ca-app-pub-3940256099942544/6300978111';

  static void initLiveAds() {
    // In debug mode, we typically want to keep using test ad IDs to avoid getting banned.
    if (kDebugMode) {
      debugPrint("Debug mode: Using test ad IDs.");
      return;
    }

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      String liveAdIdsStr = remoteConfig.getString('liveAdIds');

      if (liveAdIdsStr.isNotEmpty) {
        Map<String, dynamic> liveAds = jsonDecode(liveAdIdsStr);

        appOpen = liveAds['appOpen']?.toString() ?? appOpen;
        
        startCreatingRewardedAd = liveAds['startCreatingRewardedAd']?.toString() ?? startCreatingRewardedAd;
        dinoGameRestart = liveAds['dinoGameRestart']?.toString() ?? dinoGameRestart;
        
        favouriteNativeAd = liveAds['favouriteNativeAd']?.toString() ?? favouriteNativeAd;
        favouriteBottomNativeAd = liveAds['favouriteBottomNativeAd']?.toString() ?? favouriteBottomNativeAd;
        templateDetailNativeAd = liveAds['templateDetailNativeAd']?.toString() ?? templateDetailNativeAd;
        templateDetailBottomNativeAd = liveAds['templateDetailBottomNativeAd']?.toString() ?? templateDetailBottomNativeAd;
        settingNativeAd = liveAds['settingNativeAd']?.toString() ?? settingNativeAd;
        rateUsNativeAd = liveAds['rateUsNativeAd']?.toString() ?? rateUsNativeAd;
        splashNativeAd = liveAds['splashNativeAd']?.toString() ?? splashNativeAd;
        maintenanceNativeAd = liveAds['maintenanceNativeAd']?.toString() ?? maintenanceNativeAd;
        discoverNativeAd = liveAds['discoverNativeAd']?.toString() ?? discoverNativeAd;
        discoverBottomSheetNativeAd = liveAds['discoverBottomSheetNativeAd']?.toString() ?? discoverBottomSheetNativeAd;
        noDataFoundNativeAd = liveAds['noDataFoundNativeAd']?.toString() ?? noDataFoundNativeAd;
        exitAppNativeAd = liveAds['exitAppNativeAd']?.toString() ?? exitAppNativeAd;
        onBoarding1NativeAd = liveAds['onBoarding1NativeAd']?.toString() ?? onBoarding1NativeAd;
        onBoarding2NativeAd = liveAds['onBoarding2NativeAd']?.toString() ?? onBoarding2NativeAd;
        homeBottomNativeAd = liveAds['homeBottomNativeAd']?.toString() ?? homeBottomNativeAd;
        selectLanguageNativeAd = liveAds['selectLanguageNativeAd']?.toString() ?? selectLanguageNativeAd;
        chooseYourInterestNativeAd = liveAds['chooseYourInterestNativeAd']?.toString() ?? chooseYourInterestNativeAd;

        splashInterstitial = liveAds['splashInterstitial']?.toString() ?? splashInterstitial;
        onboardingInterstitial = liveAds['onboardingInterstitial']?.toString() ?? onboardingInterstitial;
        homeReelsInterstitial = liveAds['homeReelsInterstitial']?.toString() ?? homeReelsInterstitial;
        loadMoreInterstitialAd = liveAds['loadMoreInterstitialAd']?.toString() ?? loadMoreInterstitialAd;
        backButtonInterstitialAd = liveAds['backButtonInterstitialAd']?.toString() ?? backButtonInterstitialAd;
        categoryOnTapInterstitialAd = liveAds['categoryOnTapInterstitialAd']?.toString() ?? categoryOnTapInterstitialAd;
        onboardingDoneInterstitial = liveAds['onboardingDoneInterstitial']?.toString() ?? onboardingDoneInterstitial;
        selectLanguageInterstitial = liveAds['selectLanguageInterstitial']?.toString() ?? selectLanguageInterstitial;

        discoverBannerAd = liveAds['discoverBannerAd']?.toString() ?? discoverBannerAd;
        templateDetailBanner = liveAds['templateDetailBanner']?.toString() ?? templateDetailBanner;
        favouriteBannerAd = liveAds['favouriteBannerAd']?.toString() ?? favouriteBannerAd;
        settingBannerAd = liveAds['settingBannerAd']?.toString() ?? settingBannerAd;
        feedbackBannerAd = liveAds['feedbackBannerAd']?.toString() ?? feedbackBannerAd;
        qrBannerAd = liveAds['qrBannerAd']?.toString() ?? qrBannerAd;
        otherAppBannerAd = liveAds['otherAppBannerAd']?.toString() ?? otherAppBannerAd;
        selectLanguageBanner = liveAds['selectLanguageBanner']?.toString() ?? selectLanguageBanner;
        chooseInterestBanner = liveAds['chooseInterestBanner']?.toString() ?? chooseInterestBanner;
        
        debugPrint("Successfully loaded live ad IDs from Remote Config");
      }
    } catch (e) {
      debugPrint("Error parsing liveAdIds from Remote Config: $e");
    }
  }
}
