import 'package:flutter_localization/flutter_localization.dart';
import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';

enum InterstitialPlacement { onboarding, reels }

class _InterstitialAdState {
  InterstitialAd? ad;
  bool isLoaded = false;
  bool isLoading = false;
  bool isShowing = false;
}

class _AppOpenAdState {
  AppOpenAd? ad;
  bool isLoaded = false;
  bool isLoading = false;
  bool isShowing = false;
}

enum RewardedPlacement { startCreating, watchAndWin }

class _RewardedAdState {
  RewardedAd? ad;
  bool isLoaded = false;
  bool isLoading = false;
  bool isShowing = false;
}

class AdHelper {
  static InterstitialAd? _interstitialAd;
  static bool _isAdShowing = false;
  static bool _interstitialAdLoaded = false;
  static int _interstitialRetryCount = 0;
  static Timer? _interstitialRetryTimer;
  static RewardedAd? _rewardedAd;
  static bool cancelLoadMoreAd = false;
  static bool isLoadMoreAdLoadingOrShowing = false;
  static bool isBackButtonAdLoadingOrShowing = false;
  static bool isCategoryAdLoadingOrShowing = false;
  static bool get isInterstitialReady => _interstitialAdLoaded && _interstitialAd != null && !_isAdShowing;

  // =================== SINGLE SOURCE OF TRUTH ===================
  static bool get _isUserSubscribed {
    return AppPreferences().getBool(AppPreferences.subscriptionPlan) ?? false;
  }

  //*****************App Open Ad******************
  static AppOpenAd? _appOpenAd;
  static bool _isAppOpenAdLoading = false;

  static bool _isShowing = false;

  //LOAD APP OPEN AD
  static void precacheAppOpenAd() {

    if (_isUserSubscribed) {
      log('❌ User subscribed, skipping App Open Ad preload');
      return;
    }

    if (_appOpenAd != null || _isAppOpenAdLoading) {
      log('✅ App Open Ad Already Cached or Loading');
      return;
    }

    log('🚀 Loading App Open Ad');
    _isAppOpenAdLoading = true;

    AppOpenAd.load(
      adUnitId: AppAdIdString.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          log('✅ App Open Ad Loaded');
          _appOpenAd = ad;
          _isAppOpenAdLoading = false;
          _setFullScreenCallback();
        },
        onAdFailedToLoad: (error) {
          log('❌ Failed To Load App Open Ad : $error');
          _appOpenAd = null;
          _isAppOpenAdLoading = false;
        },
      ),
    );
  }

  // SHOW APP OPEN AD
  static Future<void> showAppOpenAd({required Function onComplete}) async {
    if (_isUserSubscribed) {
      log('❌ User subscribed, skipping App Open Ad');
      onComplete();
      return;
    }

    if (_isAppOpenAdLoading) {
      log('⏳ Waiting for App Open Ad to load...');
      int waitMs = 0;
      while (_isAppOpenAdLoading && waitMs < 5000) {
        await Future.delayed(const Duration(milliseconds: 200));
        waitMs += 200;
      }
    }

    /// if ad not loaded -> move next screen
    if (_appOpenAd == null) {
      log('⚠️ App Open Ad Not Available');
      onComplete();
      return;
    }

    /// prevent multiple show
    if (_isShowing) {
      onComplete();
      return;
    }

    _isShowing = true;

    _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        log('🗑️ App Open Ad Dismissed');
        _disposeAd();
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('❌ Failed To Show App Open Ad : $error');
        _disposeAd();
        onComplete();
      },
    );

    await _appOpenAd?.show();
  }

  // FULL SCREEN CALLBACK
  static void _setFullScreenCallback() {
    // Moved callback assignment to showAppOpenAd so we can trigger onComplete when ad closes
  }

  // DISPOSE
  static void _disposeAd() {
    _appOpenAd?.dispose();

    _appOpenAd = null;

    _isShowing = false;
  }

  //*****************Interstitial Ad With pre catch ******************
  static void precacheInterstitialAd({required String adId}) {
    log('🔄 Precache Interstitial Ad Started - AdId: $adId');

    if (_isUserSubscribed) {
      log('❌ User subscribed, skipping preload - AdId: $adId');
      return;
    }

    if (_interstitialAdLoaded || _isAdShowing) {
      log(
        '⚠️ Ad already loaded/showing - AdId: $adId | Loaded: $_interstitialAdLoaded | Showing: $_isAdShowing',
      );
      return;
    }

    InterstitialAd.load(
      adUnitId: adId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAdLoaded = true;
          _interstitialRetryCount = 0;
          _interstitialRetryTimer?.cancel();
          log('✅ Interstitial Ad Precached Successfully - AdId: $adId');
        },
        onAdFailedToLoad: (err) {
          resetInterstitialAd();

          log(
            '❌ Interstitial Load Failed '
                '| Code: ${err.code} '
                '| Error: ${err.message}',
          );

          // No Fill
          if (err.code == 3) {
            _scheduleInterstitialRetry(adId);
          }
        },
      ),
    );
  }
  static void _scheduleInterstitialRetry(String adId) {
    _interstitialRetryTimer?.cancel();

    _interstitialRetryCount++;

    final delaySeconds =
    (30 * _interstitialRetryCount).clamp(30, 300);

    log(
      '🔄 Retry #$_interstitialRetryCount '
          'after ${delaySeconds}s',
    );

    _interstitialRetryTimer = Timer(
      Duration(seconds: delaySeconds),
          () {
        if (!_interstitialAdLoaded && !_isAdShowing) {
          precacheInterstitialAd(adId: adId);
        }
      },
    );
  }

  static void showInterstitialAd({
    required String adId,
    VoidCallback? onAdClosed,
    bool reloadAfterClose = true,
  }) {
    log('🎯 Show Interstitial Requested - AdId: $adId');

    if (_isUserSubscribed) {
      log('❌ User subscribed, skipping ad - AdId: $adId');
      onAdClosed?.call();
      return;
    }

    if (_interstitialAd == null || !_interstitialAdLoaded) {
      log('⚠️ No Interstitial Ready - AdId: $adId');

      onAdClosed?.call();

      if (reloadAfterClose) {
        precacheInterstitialAd(adId: adId);
      }

      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isAdShowing = true;

        log('✅ Interstitial Showing - AdId: $adId');
      },

      onAdDismissedFullScreenContent: (ad) {
        log('✅ Interstitial Closed By User - AdId: $adId');

        _isAdShowing = false;

        ad.dispose();

        _interstitialAd = null;
        _interstitialAdLoaded = false;

        onAdClosed?.call();

        if (reloadAfterClose) {
          precacheInterstitialAd(adId: adId);
        }
      },

      onAdFailedToShowFullScreenContent: (ad, error) {
        log('❌ Interstitial Failed To Show - AdId: $adId | Error: ${error.message}');

        _isAdShowing = false;

        ad.dispose();

        _interstitialAd = null;
        _interstitialAdLoaded = false;

        onAdClosed?.call();

        if (reloadAfterClose) {
          precacheInterstitialAd(adId: adId);
        }
      },
    );

    _interstitialAd!.show();
  }

  static void resetInterstitialAd() {
    _isAdShowing = false;
    _interstitialAdLoaded = false;

    _interstitialAd?.dispose();
    _interstitialAd = null;

    log('♻️ Interstitial Reset');
  }

  //*****************Interstitial Ad Without pre catch ******************;
  static void instantShowInterstitialAdt({
    required String adUnitId,
    VoidCallback? onAdClosed,
    VoidCallback? onAdShowed,
    VoidCallback? onAdFailed,
  }) {
    if (_isUserSubscribed) return;

    cancelLoadMoreAd = false;
    isLoadMoreAdLoadingOrShowing = true;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (cancelLoadMoreAd) {
            ad.dispose();
            isLoadMoreAdLoadingOrShowing = false;
            return;
          }
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              onAdShowed?.call();
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              isLoadMoreAdLoadingOrShowing = false;
              onAdClosed?.call();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              isLoadMoreAdLoadingOrShowing = false;
              onAdFailed?.call();
            },
          );

          ad.show();
        },
        onAdFailedToLoad: (error) {
          isLoadMoreAdLoadingOrShowing = false;
          onAdFailed?.call();
        },
      ),
    );
  }

  //*****************Rewarded Ad******************
  static bool _isLoading = false;

  static bool get isRewardedAdLoaded => _rewardedAd != null;

  // PRELOAD REWARDED AD
  static void loadRewardedAd(String adUnitId) {
    if (_isLoading || _rewardedAd != null) return;

    _isLoading = true;

    log('Loading Rewarded Ad...');

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          log('Rewarded Ad Loaded');

          _rewardedAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          log('Rewarded Ad Failed: ${error.message}');

          _rewardedAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  // SHOW REWARDED AD
  static void showRewardedAd({
    required String adUnitId,
    required VoidCallback onRewardEarned,
    required VoidCallback onAdFailed,
    required VoidCallback onComplete,
  }) {
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onComplete();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              onAdFailed();
            },
          );

          ad.show(
            onUserEarnedReward: (ad, reward) {
              onRewardEarned();
            },
          );
        },
        onAdFailedToLoad: (error) {
          onAdFailed();
        },
      ),
    );
  }
  // DISPOSE
  static void disposeRewardedAd() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isLoading = false;
  }


  /// ========================== Interstitial ===================================
  // ========================== Onboarding & reel ===================================
  //
  // static final Map<String, _InterstitialAdState> _interstitialStates = {};
  //
  // static String _getInterstitialKey({
  //   required InterstitialPlacement placement,
  //   List<String> adUnitIds = const [],
  // }) {
  //   if (adUnitIds.isNotEmpty) {
  //     return adUnitIds.first;
  //   }
  //   return placement.name;
  // }
  //
  // static _InterstitialAdState _getInterstitialState(String key) {
  //   return _interstitialStates.putIfAbsent(key, () => _InterstitialAdState());
  // }
  //
  // // static bool get isInterstitialReady => isInterstitialReadyForId(AppAdIdString.backButtonInterstitialAd);
  //
  // static bool isInterstitialReadyForId(String adId) {
  //   final state = _interstitialStates[adId];
  //   if (state == null) return false;
  //   return state.isLoaded && state.ad != null && !state.isShowing;
  // }
  //
  // static bool get isReelsInterstitialReady {
  //   final key = AppAdIdString.homeReelsInterstitial;
  //   final state = _interstitialStates[key];
  //   if (state == null) return false;
  //   return state.isLoaded && state.ad != null && !state.isShowing;
  // }
  //
  // static void precacheInterstitial({
  //   required InterstitialPlacement placement,
  //   List<String> adUnitIds = const [],
  //   int attempt = 1,
  // }) {
  //   if (_isUserSubscribed) return;
  //
  //   final key = _getInterstitialKey(placement: placement, adUnitIds: adUnitIds);
  //   final state = _getInterstitialState(key);
  //
  //   if (state.isLoaded || state.isShowing) return;
  //
  //   log('Precache ${placement.name} Attempt: $attempt for key: $key');
  //
  //   if (attempt == 1) {
  //     if (state.isLoading) return;
  //     state.isLoading = true;
  //   }
  //
  //   if (adUnitIds.isEmpty) {
  //     state.isLoading = false;
  //     log('No ad IDs for ${placement.name}');
  //     return;
  //   }
  //
  //   if (attempt < 1 || attempt > adUnitIds.length) {
  //     state.isLoading = false;
  //     log('All waterfall tiers failed for ${placement.name}');
  //     return;
  //   }
  //
  //   final waterfallAdId = adUnitIds[attempt - 1];
  //
  //   log('Loading ${placement.name} tier $attempt with ID: $waterfallAdId');
  //
  //   InterstitialAd.load(
  //     adUnitId: waterfallAdId,
  //     request: const AdRequest(),
  //     adLoadCallback: InterstitialAdLoadCallback(
  //       onAdLoaded: (ad) {
  //         state.ad = ad;
  //         state.isLoaded = true;
  //         state.isLoading = false;
  //
  //         log('${placement.name} loaded on tier $attempt for key: $key');
  //       },
  //       onAdFailedToLoad: (err) {
  //         log('${placement.name} failed tier $attempt for key $key: ${err.message}');
  //
  //         if (attempt < adUnitIds.length) {
  //           precacheInterstitial(placement: placement, adUnitIds: adUnitIds, attempt: attempt + 1);
  //         } else {
  //           _resetInterstitialState(key);
  //         }
  //       },
  //     ),
  //   );
  // }
  //
  // static void waitForInterstitialThenShow({
  //   required InterstitialPlacement placement,
  //   List<String> adUnitIds = const [],
  //   required bool autoReprecache,
  //   VoidCallback? onAdClosed,
  //   int maxWaitMs = 5000,
  //   int intervalMs = 300,
  // }) {
  //   final key = _getInterstitialKey(placement: placement, adUnitIds: adUnitIds);
  //   final state = _getInterstitialState(key);
  //
  //   if (state.isLoaded && state.ad != null) {
  //     showInterstitial(
  //       placement: placement,
  //       adUnitIds: adUnitIds,
  //       autoReprecache: autoReprecache,
  //       onAdClosed: onAdClosed,
  //     );
  //     return;
  //   }
  //
  //   int elapsed = 0;
  //   Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
  //     elapsed += intervalMs;
  //
  //     if (state.isLoaded && state.ad != null) {
  //       timer.cancel();
  //       showInterstitial(
  //         placement: placement,
  //         adUnitIds: adUnitIds,
  //         autoReprecache: autoReprecache,
  //         onAdClosed: onAdClosed,
  //       );
  //     } else if (elapsed >= maxWaitMs || (!state.isLoading && !state.isLoaded)) {
  //       timer.cancel();
  //       log('Interstitial wait timeout for key: $key, proceeding without ad.');
  //       onAdClosed?.call();
  //     }
  //   });
  // }
  //
  // static void showInterstitial({
  //   required InterstitialPlacement placement,
  //   List<String> adUnitIds = const [],
  //   required bool autoReprecache,
  //   VoidCallback? onAdClosed,
  // }) {
  //   if (_isUserSubscribed) {
  //     onAdClosed?.call();
  //     return;
  //   }
  //
  //   final key = _getInterstitialKey(placement: placement, adUnitIds: adUnitIds);
  //   final state = _getInterstitialState(key);
  //
  //   if (state.ad == null || !state.isLoaded) {
  //     log('No interstitial ad ready for key: $key');
  //     onAdClosed?.call();
  //     if (autoReprecache) {
  //       precacheInterstitial(placement: placement, adUnitIds: adUnitIds);
  //     }
  //     return;
  //   }
  //
  //   state.ad!.fullScreenContentCallback = FullScreenContentCallback(
  //     onAdShowedFullScreenContent: (ad) {
  //       log('${placement.name} Interstitial ad showed for key: $key');
  //       state.isShowing = true;
  //     },
  //     onAdDismissedFullScreenContent: (ad) {
  //       log('User closed ${placement.name} ad for key: $key');
  //       state.isShowing = false;
  //       ad.dispose();
  //       state.ad = null;
  //       state.isLoaded = false;
  //       onAdClosed?.call();
  //       if (autoReprecache) {
  //         precacheInterstitial(placement: placement, adUnitIds: adUnitIds);
  //       }
  //     },
  //     onAdFailedToShowFullScreenContent: (ad, error) {
  //       log('${placement.name} ad failed to show for key $key: ${error.message}');
  //       state.isShowing = false;
  //       ad.dispose();
  //       state.ad = null;
  //       state.isLoaded = false;
  //       onAdClosed?.call();
  //       if (autoReprecache) {
  //         precacheInterstitial(placement: placement, adUnitIds: adUnitIds);
  //       }
  //     },
  //   );
  //
  //   state.ad!.show();
  // }
  //
  // static void resetInterstitial(InterstitialPlacement placement) {
  //   String key;
  //   if (placement == InterstitialPlacement.reels) {
  //     key = AppAdIdString.homeReelsInterstitial;
  //   } else if (placement == InterstitialPlacement.onboarding) {
  //     key = AppAdIdString.onboardingInterstitial;
  //   } else {
  //     key = placement.name;
  //   }
  //   _resetInterstitialState(key);
  // }
  //
  // static void _resetInterstitialState(String key) {
  //   final state = _interstitialStates[key];
  //   if (state != null) {
  //     state.isShowing = false;
  //     state.isLoaded = false;
  //     state.isLoading = false;
  //     state.ad?.dispose();
  //     state.ad = null;
  //   }
  // }

  // =================== Back Button Interstitial (Single Ad ID) ===================

  static final _InterstitialAdState _backButtonAdState = _InterstitialAdState();

  static bool get isBackButtonAdReady =>
      _backButtonAdState.isLoaded && _backButtonAdState.ad != null && !_backButtonAdState.isShowing;

  static void precacheBackButtonInterstitial() {
    if (_isUserSubscribed) return;
    if (_backButtonAdState.isLoaded || _backButtonAdState.isShowing) return;
    if (_backButtonAdState.isLoading) return;

    _backButtonAdState.isLoading = true;
    final adId = AppAdIdString.backButtonInterstitialAd;

    log('Loading BackButton Interstitial with ID: $adId');

    InterstitialAd.load(
      adUnitId: adId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _backButtonAdState.ad = ad;
          _backButtonAdState.isLoaded = true;
          _backButtonAdState.isLoading = false;
          log('BackButton Interstitial loaded');
        },
        onAdFailedToLoad: (err) {
          log('BackButton Interstitial failed: ${err.message}');
          _backButtonAdState.isLoading = false;
          _backButtonAdState.isLoaded = false;
          _backButtonAdState.ad = null;
        },
      ),
    );
  }

  static void showBackButtonInterstitial({required bool autoReprecache, VoidCallback? onAdClosed}) {
    if (_isUserSubscribed) {
      onAdClosed?.call();
      return;
    }

    if (!isBackButtonAdReady) {
      log('BackButton Interstitial not ready');
      onAdClosed?.call();
      if (autoReprecache) precacheBackButtonInterstitial();
      return;
    }

    _backButtonAdState.ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        log('BackButton Interstitial showed');
        _backButtonAdState.isShowing = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        log('BackButton Interstitial dismissed');
        _backButtonAdState.isShowing = false;
        ad.dispose();
        _backButtonAdState.ad = null;
        _backButtonAdState.isLoaded = false;
        onAdClosed?.call();
        if (autoReprecache) precacheBackButtonInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('BackButton Interstitial failed to show: ${error.message}');
        _backButtonAdState.isShowing = false;
        ad.dispose();
        _backButtonAdState.ad = null;
        _backButtonAdState.isLoaded = false;
        onAdClosed?.call();
        if (autoReprecache) precacheBackButtonInterstitial();
      },
    );

    _backButtonAdState.ad!.show();
  }

  // =================== Load More Interstitial (Single Ad ID) ===================

  static final _InterstitialAdState _loadMoreAdState = _InterstitialAdState();

  static bool get isLoadMoreAdReady =>
      _loadMoreAdState.isLoaded && _loadMoreAdState.ad != null && !_loadMoreAdState.isShowing;

  static void precacheLoadMoreInterstitial() {
    if (_isUserSubscribed) return;
    if (_loadMoreAdState.isLoaded || _loadMoreAdState.isShowing) return;
    if (_loadMoreAdState.isLoading) return;

    _loadMoreAdState.isLoading = true;
    final adId = AppAdIdString.loadMoreInterstitialAd;

    log('Loading LoadMore Interstitial with ID: $adId');

    InterstitialAd.load(
      adUnitId: adId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loadMoreAdState.ad = ad;
          _loadMoreAdState.isLoaded = true;
          _loadMoreAdState.isLoading = false;
          log('LoadMore Interstitial loaded');
        },
        onAdFailedToLoad: (err) {
          log('LoadMore Interstitial failed: ${err.message}');
          _loadMoreAdState.isLoading = false;
          _loadMoreAdState.isLoaded = false;
          _loadMoreAdState.ad = null;
        },
      ),
    );
  }

  static void showLoadMoreInterstitial({required bool autoReprecache, VoidCallback? onAdClosed}) {
    if (_isUserSubscribed) {
      onAdClosed?.call();
      return;
    }

    if (!isLoadMoreAdReady) {
      log('LoadMore Interstitial not ready');
      onAdClosed?.call();
      if (autoReprecache) precacheLoadMoreInterstitial();
      return;
    }

    _loadMoreAdState.ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        log('LoadMore Interstitial showed');
        _loadMoreAdState.isShowing = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        log('LoadMore Interstitial dismissed');
        _loadMoreAdState.isShowing = false;
        ad.dispose();
        _loadMoreAdState.ad = null;
        _loadMoreAdState.isLoaded = false;
        onAdClosed?.call();
        if (autoReprecache) precacheLoadMoreInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('LoadMore Interstitial failed to show: ${error.message}');
        _loadMoreAdState.isShowing = false;
        ad.dispose();
        _loadMoreAdState.ad = null;
        _loadMoreAdState.isLoaded = false;
        onAdClosed?.call();
        if (autoReprecache) precacheLoadMoreInterstitial();
      },
    );

    _loadMoreAdState.ad!.show();
  }

  /// ========================== Rewarded Ad ===================================
  // =================== Start Creating ===================
  //
  // static final Map<RewardedPlacement, _RewardedAdState> _rewardedStates = {
  //   RewardedPlacement.startCreating: _RewardedAdState(),
  //   RewardedPlacement.watchAndWin: _RewardedAdState(),
  // };
  //
  // static void precacheRewardedAd({
  //   required RewardedPlacement placement,
  //   List<String> adUnitIds = const [],
  //   int attempt = 1,
  // }) {
  //   if (_isUserSubscribed) return;
  //
  //   final state = _rewardedStates[placement]!;
  //
  //   if (state.isLoaded || state.isShowing) return;
  //
  //   if (attempt == 1) {
  //     if (state.isLoading) return;
  //     state.isLoading = true;
  //   }
  //
  //   if (adUnitIds.isEmpty) {
  //     state.isLoading = false;
  //     log('No ad IDs for rewarded ${placement.name}');
  //     return;
  //   }
  //
  //   if (attempt < 1 || attempt > adUnitIds.length) {
  //     state.isLoading = false;
  //     log('All rewarded waterfall tiers failed for ${placement.name}');
  //     return;
  //   }
  //
  //   final adId = adUnitIds[attempt - 1];
  //   log('Loading Rewarded ${placement.name} tier $attempt with ID: $adId');
  //
  //   RewardedAd.load(
  //     adUnitId: adId,
  //     request: const AdRequest(),
  //     rewardedAdLoadCallback: RewardedAdLoadCallback(
  //       onAdLoaded: (ad) {
  //         state.ad = ad;
  //         state.isLoaded = true;
  //         state.isLoading = false;
  //         log('Rewarded ${placement.name} loaded on tier $attempt');
  //       },
  //       onAdFailedToLoad: (err) {
  //         log('Rewarded ${placement.name} failed tier $attempt: ${err.message}');
  //         if (attempt < adUnitIds.length) {
  //           precacheRewardedAd(placement: placement, adUnitIds: adUnitIds, attempt: attempt + 1);
  //         } else {
  //           state.isLoading = false;
  //           state.isLoaded = false;
  //           state.ad = null;
  //           log('All rewarded tiers failed for ${placement.name}');
  //         }
  //       },
  //     ),
  //   );
  // }
  //
  // static String checkRewardedAdStatus(RewardedPlacement placement) {
  //   if (placement == RewardedPlacement.watchAndWin) {
  //     return isWatchAndWinAdReady ? AppStrings.txtAvailable.getString(context) : AppStrings.txtNoAdAvailable.getString(context);
  //   }
  //   final state = _rewardedStates[placement]!;
  //   if (state.isLoaded && state.ad != null && !state.isShowing) {
  //     return AppStrings.txtAvailable.getString(context);
  //   }
  //   return AppStrings.txtNoAdAvailable.getString(context);
  // }
  //
  // static void showRewardedAd({
  //   required RewardedPlacement placement,
  //   List<String> adUnitIds = const [],
  //   VoidCallback? onComplete,
  //   VoidCallback? onRewardEarned,
  // }) {
  //   if (_isUserSubscribed) {
  //     onRewardEarned?.call();
  //     onComplete?.call();
  //     return;
  //   }
  //
  //   final state = _rewardedStates[placement]!;
  //
  //   if (state.ad == null || !state.isLoaded) {
  //     log('Rewarded ${placement.name} not ready');
  //     onComplete?.call();
  //     precacheRewardedAd(placement: placement, adUnitIds: adUnitIds);
  //     return;
  //   }
  //
  //   state.ad!.fullScreenContentCallback = FullScreenContentCallback(
  //     onAdShowedFullScreenContent: (ad) {
  //       log('Rewarded ${placement.name} showed');
  //       state.isShowing = true;
  //     },
  //     onAdDismissedFullScreenContent: (ad) {
  //       log('Rewarded ${placement.name} dismissed');
  //       state.isShowing = false;
  //       ad.dispose();
  //       state.ad = null;
  //       state.isLoaded = false;
  //       onComplete?.call();
  //       precacheRewardedAd(placement: placement, adUnitIds: adUnitIds);
  //     },
  //     onAdFailedToShowFullScreenContent: (ad, error) {
  //       log('Rewarded ${placement.name} failed to show: ${error.message}');
  //       state.isShowing = false;
  //       ad.dispose();
  //       state.ad = null;
  //       state.isLoaded = false;
  //       onComplete?.call();
  //       precacheRewardedAd(placement: placement, adUnitIds: adUnitIds);
  //     },
  //   );
  //
  //   state.ad!.show(
  //     onUserEarnedReward: (_, reward) {
  //       log('Rewarded ${placement.name} reward earned');
  //       onRewardEarned?.call();
  //     },
  //   );
  // }
  //
  // static void resetRewardedAd(RewardedPlacement placement) {
  //   final state = _rewardedStates[placement]!;
  //   state.isShowing = false;
  //   state.isLoaded = false;
  //   state.isLoading = false;
  //   state.ad?.dispose();
  //   state.ad = null;
  // }

  // =================== Watch & Win Rewarded Ad (Single Ad ID) ===================

  static final _RewardedAdState _watchAndWinAdState = _RewardedAdState();

  static bool get isWatchAndWinAdReady =>
      _watchAndWinAdState.isLoaded && _watchAndWinAdState.ad != null && !_watchAndWinAdState.isShowing;

  // static String watchWinRewardedAdStatus(RewardedPlacement placement) {
  //   final state = _watchAndWinAdState[placement]!;
  //   if (state.isLoaded && state.ad != null && !state.isShowing) {
  //     return AppStrings.txtAvailable.getString(context);
  //   } else {
  //     return AppStrings.txtNoAdAvailable.getString(context);
  //   }
  // }

  // static String watchWinRewardedAdStatus(RewardedPlacement placement) {
  //   final state = _rewardedStates[placement]!;
  //   if (state.isLoaded && state.ad != null && !state.isShowing) {
  //     return AppStrings.txtAvailable.getString(context);
  //   }
  //   return AppStrings.txtNoAdAvailable.getString(context);
  // }

  //
  // static String watchWinRewardedAdStatus() {
  //   if (_watchAndWinAdState.isLoaded &&
  //       _watchAndWinAdState.ad != null &&
  //       !_watchAndWinAdState.isShowing) {
  //     return AppStrings.txtAvailable.getString(context);
  //   }
  //   return AppStrings.txtNoAdAvailable.getString(context);
  // }

  // static void precacheWatchAndWinRewarded() {
  //   if (_isUserSubscribed) return;
  //   if (_watchAndWinAdState.isLoaded || _watchAndWinAdState.isShowing) return;
  //   if (_watchAndWinAdState.isLoading) return;
  //
  //   _watchAndWinAdState.isLoading = true;
  //   final adId = AppAdIdString.watchAndWinRewardedAd;
  //
  //   log('Loading WatchAndWin Rewarded with ID: $adId');
  //
  //   RewardedAd.load(
  //     adUnitId: adId,
  //     request: const AdRequest(),
  //     rewardedAdLoadCallback: RewardedAdLoadCallback(
  //       onAdLoaded: (ad) {
  //         _watchAndWinAdState.ad = ad;
  //         _watchAndWinAdState.isLoaded = true;
  //         _watchAndWinAdState.isLoading = false;
  //         log('WatchAndWin Rewarded loaded');
  //       },
  //       onAdFailedToLoad: (err) {
  //         log('WatchAndWin Rewarded failed: ${err.message}');
  //         _watchAndWinAdState.isLoading = false;
  //         _watchAndWinAdState.isLoaded = false;
  //         _watchAndWinAdState.ad = null;
  //       },
  //     ),
  //   );
  // }

  // static void showWatchAndWinRewarded({
  //   required bool autoReprecache,
  //   required VoidCallback onComplete,
  //   required VoidCallback onRewardEarned,
  // }) {
  //   if (_isUserSubscribed) {
  //     onComplete();
  //     return;
  //   }
  //
  //   if (!isWatchAndWinAdReady) {
  //     log('WatchAndWin Rewarded not ready');
  //     onComplete();
  //     if (autoReprecache) precacheWatchAndWinRewarded();
  //     return;
  //   }
  //
  //   _watchAndWinAdState.ad!.fullScreenContentCallback = FullScreenContentCallback(
  //     onAdShowedFullScreenContent: (ad) {
  //       log('WatchAndWin Rewarded showed');
  //       _watchAndWinAdState.isShowing = true;
  //     },
  //     onAdDismissedFullScreenContent: (ad) {
  //       log('WatchAndWin Rewarded dismissed');
  //       _watchAndWinAdState.isShowing = false;
  //       ad.dispose();
  //       _watchAndWinAdState.ad = null;
  //       _watchAndWinAdState.isLoaded = false;
  //       onComplete();
  //       if (autoReprecache) precacheWatchAndWinRewarded();
  //     },
  //     onAdFailedToShowFullScreenContent: (ad, error) {
  //       log('WatchAndWin Rewarded failed to show: ${error.message}');
  //       _watchAndWinAdState.isShowing = false;
  //       ad.dispose();
  //       _watchAndWinAdState.ad = null;
  //       _watchAndWinAdState.isLoaded = false;
  //       onComplete();
  //       if (autoReprecache) precacheWatchAndWinRewarded();
  //     },
  //   );
  //
  //   _watchAndWinAdState.ad!.show(
  //     onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
  //       log('WatchAndWin reward earned: ${reward.amount} ${reward.type}');
  //       onRewardEarned();
  //     },
  //   );
  // }

  // //*****************Unified Rewarded Ad Flow******************
  // static void precacheRewardedAd({
  //   required RewardedPlacement placement,
  //   String? adId,
  //   List<String> adUnitIds = const [],
  //   int attempt = 1,
  // }) {
  //   if (_isUserSubscribed) return;
  //   final state = _rewardedStates[placement]!;
  //   if (state.isLoaded || state.isShowing) return;
  //
  //   if (placement == RewardedPlacement.watchAndWin) {
  //     if (state.isLoading) return;
  //     state.isLoading = true;
  //
  //     final id = adId ?? (adUnitIds.isNotEmpty ? adUnitIds.first : null);
  //     if (id == null || id.isEmpty) {
  //       state.isLoading = false;
  //       log('WatchAndWin rewarded adId is null');
  //       return;
  //     }
  //     log('Precache Rewarded Ad - Placement: watchAndWin, ID: $id');
  //
  //     RewardedAd.load(
  //       adUnitId: id,
  //       request: const AdRequest(),
  //       rewardedAdLoadCallback: RewardedAdLoadCallback(
  //         onAdLoaded: (RewardedAd ad) {
  //           state.ad = ad;
  //           state.isLoaded = true;
  //           state.isLoading = false;
  //           log('WatchAndWin Rewarded ad loaded');
  //         },
  //         onAdFailedToLoad: (LoadAdError err) {
  //           log('WatchAndWin Rewarded ad failed to load: ${err.message}');
  //           resetRewardedAd(RewardedPlacement.watchAndWin);
  //         },
  //       ),
  //     );
  //     return;
  //   }
  //
  //   log('Precache Rewarded Ad - Placement: ${placement.name}, Attempt: $attempt');
  //
  //   if (attempt == 1) {
  //     if (state.isLoading) {
  //       log('${placement.name} Rewarded Ad is already loading, skipping.');
  //       return;
  //     }
  //     state.isLoading = true;
  //   }
  //
  //   if (adUnitIds.isEmpty) {
  //     log('No Ad IDs provided for ${placement.name} rewarded ad.');
  //     state.isLoading = false;
  //     return;
  //   }
  //
  //   if (attempt < 1 || attempt > adUnitIds.length) {
  //     log('All ${placement.name} Rewarded Ad waterfall tiers failed.');
  //     state.isLoading = false;
  //     return;
  //   }
  //
  //   final currentAdId = adUnitIds[attempt - 1];
  //   log('Loading ${placement.name} Rewarded Ad tier $attempt with ID: $currentAdId');
  //
  //   RewardedAd.load(
  //     adUnitId: currentAdId,
  //     request: const AdRequest(),
  //     rewardedAdLoadCallback: RewardedAdLoadCallback(
  //       onAdLoaded: (RewardedAd ad) {
  //         state.ad = ad;
  //         state.isLoaded = true;
  //         state.isLoading = false;
  //         log('${placement.name} Rewarded ad loaded on tier $attempt');
  //       },
  //       onAdFailedToLoad: (LoadAdError err) {
  //         log('${placement.name} Rewarded ad failed tier $attempt: ${err.message}');
  //         if (attempt < adUnitIds.length) {
  //           precacheRewardedAd(placement: placement, adUnitIds: adUnitIds, attempt: attempt + 1);
  //         } else {
  //           resetRewardedAd(placement);
  //           log('Failed to load all tiers for ${placement.name} rewarded ad.');
  //         }
  //       },
  //     ),
  //   );
  // }
  //
  // static String checkRewardedAdStatus(RewardedPlacement placement) {
  //   final state = _rewardedStates[placement]!;
  //   if (state.isLoaded && state.ad != null && !state.isShowing) {
  //     return AppStrings.txtAvailable.getString(context);
  //   } else {
  //     return AppStrings.txtNoAdAvailable.getString(context);
  //   }
  // }
  //
  // static void resetRewardedAd(RewardedPlacement placement) {
  //   final state = _rewardedStates[placement]!;
  //   state.isShowing = false;
  //   state.isLoaded = false;
  //   state.isLoading = false;
  //   state.ad?.dispose();
  //   state.ad = null;
  // }
  //
  // static void showRewardedAd({
  //   required RewardedPlacement placement,
  //   List<String> adUnitIds = const [],
  //   String? adId,
  //   required VoidCallback onComplete,
  //   required VoidCallback onRewardEarned,
  // }) {
  //   if (Config.hideAds) {
  //     onComplete();
  //     return;
  //   }
  //
  //   final state = _rewardedStates[placement]!;
  //
  //   if (state.ad == null || !state.isLoaded) {
  //     log('No ${placement.name} rewarded ad ready. Loading instant ad...');
  //     _loadRewardedAdThenShow(
  //       placement: placement,
  //       adUnitIds: adUnitIds,
  //       adId: adId,
  //       attempt: 1,
  //       onComplete: onComplete,
  //       onRewardEarned: onRewardEarned,
  //     );
  //     return;
  //   }
  //
  //   final ad = state.ad!;
  //   ad.fullScreenContentCallback = FullScreenContentCallback(
  //     onAdShowedFullScreenContent: (ad) {
  //       log('${placement.name} Rewarded ad showed');
  //       state.isShowing = true;
  //     },
  //     onAdDismissedFullScreenContent: (ad) {
  //       log('Rewarded video dismissed (${placement.name}).');
  //       state.isShowing = false;
  //       ad.dispose();
  //       state.ad = null;
  //       state.isLoaded = false;
  //       onComplete();
  //       precacheRewardedAd(placement: placement, adUnitIds: adUnitIds, adId: adId);
  //     },
  //     onAdFailedToShowFullScreenContent: (ad, error) {
  //       log('Failed to show rewarded video (${placement.name}): ${error.message}');
  //       state.isShowing = false;
  //       ad.dispose();
  //       state.ad = null;
  //       state.isLoaded = false;
  //       onComplete();
  //       precacheRewardedAd(placement: placement, adUnitIds: adUnitIds, adId: adId);
  //     },
  //   );
  //
  //   ad.show(
  //     onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
  //       log('User earned reward: ${reward.amount}');
  //       onRewardEarned();
  //     },
  //   );
  // }
  //
  // static void _loadRewardedAdThenShow({
  //   required RewardedPlacement placement,
  //   List<String> adUnitIds = const [],
  //   String? adId,
  //   required int attempt,
  //   required VoidCallback onComplete,
  //   required VoidCallback onRewardEarned,
  // }) {
  //   if (placement == RewardedPlacement.watchAndWin) {
  //     final id = adId ?? (adUnitIds.isNotEmpty ? adUnitIds.first : null);
  //     if (id == null || id.isEmpty) {
  //       onComplete();
  //       return;
  //     }
  //     log('Loading watchAndWin rewarded ad with ID: $id');
  //
  //     RewardedAd.load(
  //       adUnitId: id,
  //       request: const AdRequest(),
  //       rewardedAdLoadCallback: RewardedAdLoadCallback(
  //         onAdLoaded: (RewardedAd ad) {
  //           log('WatchAndWin Rewarded Video loaded (instant).');
  //
  //           ad.fullScreenContentCallback = FullScreenContentCallback(
  //             onAdDismissedFullScreenContent: (ad) {
  //               log('Rewarded video dismissed (instant).');
  //               onComplete();
  //               ad.dispose();
  //               precacheRewardedAd(placement: placement, adUnitIds: adUnitIds, adId: adId);
  //             },
  //             onAdFailedToShowFullScreenContent: (ad, error) {
  //               log('Failed to show rewarded video (instant): ${error.message}');
  //               onComplete();
  //               ad.dispose();
  //               precacheRewardedAd(placement: placement, adUnitIds: adUnitIds, adId: adId);
  //             },
  //           );
  //
  //           ad.show(
  //             onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
  //               log('User earned reward: ${reward.amount}');
  //               onRewardEarned();
  //             },
  //           );
  //         },
  //         onAdFailedToLoad: (LoadAdError error) {
  //           log('Failed to load watchAndWin rewarded video: ${error.message}');
  //           onComplete();
  //         },
  //       ),
  //     );
  //     return;
  //   }
  //
  //   if (adUnitIds.isEmpty || attempt > adUnitIds.length) {
  //     log('All instant rewarded ad waterfall tiers failed.');
  //     onComplete();
  //     return;
  //   }
  //
  //   final currentAdId = adUnitIds[attempt - 1];
  //   log('Loading instant rewarded ad tier $attempt with ID: $currentAdId');
  //
  //   RewardedAd.load(
  //     adUnitId: currentAdId,
  //     request: const AdRequest(),
  //     rewardedAdLoadCallback: RewardedAdLoadCallback(
  //       onAdLoaded: (RewardedAd ad) {
  //         log('Rewarded Video loaded (instant tier $attempt).');
  //
  //         ad.fullScreenContentCallback = FullScreenContentCallback(
  //           onAdDismissedFullScreenContent: (ad) {
  //             log('Rewarded video dismissed (instant).');
  //             onComplete();
  //             ad.dispose();
  //             precacheRewardedAd(placement: placement, adUnitIds: adUnitIds, adId: adId);
  //           },
  //           onAdFailedToShowFullScreenContent: (ad, error) {
  //             log('Failed to show rewarded video (instant): ${error.message}');
  //             onComplete();
  //             ad.dispose();
  //             precacheRewardedAd(placement: placement, adUnitIds: adUnitIds, adId: adId);
  //           },
  //         );
  //
  //         ad.show(
  //           onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
  //             log('User earned reward: ${reward.amount}');
  //             onRewardEarned();
  //           },
  //         );
  //       },
  //       onAdFailedToLoad: (LoadAdError error) {
  //         log('Failed to load rewarded video tier $attempt: ${error.message}');
  //         if (attempt < adUnitIds.length) {
  //           _loadRewardedAdThenShow(
  //             placement: placement,
  //             adUnitIds: adUnitIds,
  //             attempt: attempt + 1,
  //             onComplete: onComplete,
  //             onRewardEarned: onRewardEarned,
  //           );
  //         } else {
  //           log('Finished all tiers for instant rewarded ad.');
  //           onComplete();
  //         }
  //       },
  //     ),
  //   );
  // }

  // =================== App Open Ad (Waterfall) ===================
  // static final List<String> _appOpenAdUnitIds = [
  //   AppAdIdString.appOpen1,
  //   AppAdIdString.appOpen2,
  //   AppAdIdString.appOpen3,
  // ];
  //
  // static AppOpenAd? _appOpenAd;
  // static bool _appOpenAdLoaded = false;
  // static bool _appOpenAdLoading = false;
  // static bool _appOpenAdShowing = false;
  //
  // static bool get isAppOpenAdReady => _appOpenAdLoaded && _appOpenAd != null && !_appOpenAdShowing;
  //
  // static void precacheAppOpenAd({int attempt = 1}) {
  //   if (_isUserSubscribed) return;
  //   if (_appOpenAdLoaded || _appOpenAdShowing) return;
  //
  //   if (attempt == 1) {
  //     if (_appOpenAdLoading) return;
  //     _appOpenAdLoading = true;
  //   }
  //
  //   if (attempt < 1 || attempt > _appOpenAdUnitIds.length) {
  //     _appOpenAdLoading = false;
  //     log('All AppOpen Ad waterfall tiers failed.');
  //     return;
  //   }
  //
  //   final adId = _appOpenAdUnitIds[attempt - 1];
  //   log('Loading AppOpen ad tier $attempt with ID: $adId');
  //
  //   AppOpenAd.load(
  //     adUnitId: adId,
  //     request: const AdRequest(),
  //     adLoadCallback: AppOpenAdLoadCallback(
  //       onAdLoaded: (ad) {
  //         _appOpenAd = ad;
  //         _appOpenAdLoaded = true;
  //         _appOpenAdLoading = false;
  //         log('AppOpen ad loaded on tier $attempt');
  //         // WidgetsBinding.instance.addPostFrameCallback((_) {
  //         //   final context = navigatorKey.currentContext;
  //         //   if (context != null && context.mounted) {
  //         //     CommonToast.showToast(
  //         //       context: context,
  //         //       message: 'Precache completed for AppOpen (tier $attempt)',
  //         //       isError: false,
  //         //     );
  //         //   }
  //         // });
  //       },
  //       onAdFailedToLoad: (err) {
  //         log('AppOpen ad failed tier $attempt: ${err.message}');
  //         if (attempt < _appOpenAdUnitIds.length) {
  //           precacheAppOpenAd(attempt: attempt + 1);
  //         } else {
  //           _appOpenAdLoading = false;
  //           _appOpenAdLoaded = false;
  //           _appOpenAd = null;
  //           log('All AppOpen tiers failed.');
  //         }
  //       },
  //     ),
  //   );
  // }
  //
  // static void waitForAppOpenAdThenShow({
  //   VoidCallback? onComplete,
  //   int maxWaitMs = 5000,
  //   int intervalMs = 300,
  // }) {
  //   // Already ready — show immediately
  //   if (isAppOpenAdReady) {
  //     showAppOpenAd(onComplete: onComplete);
  //     return;
  //   }
  //
  //   // Not ready yet — wait until loaded or timeout
  //   int elapsed = 0;
  //   Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
  //     elapsed += intervalMs;
  //
  //     if (isAppOpenAdReady) {
  //       timer.cancel();
  //       showAppOpenAd(onComplete: onComplete);
  //     } else if (elapsed >= maxWaitMs || (!_appOpenAdLoading && !_appOpenAdLoaded)) {
  //       timer.cancel();
  //       log('AppOpen ad wait timeout, proceeding without ad.');
  //       onComplete?.call();
  //     }
  //   });
  // }
  //
  // static void showAppOpenAd({VoidCallback? onComplete}) {
  //   if (_isUserSubscribed) {
  //     onComplete?.call();
  //     return;
  //   }
  //
  //   if (!isAppOpenAdReady) {
  //     log('AppOpen ad not ready, proceeding without ad.');
  //     onComplete?.call();
  //     // precacheAppOpenAd();
  //     return;
  //   }
  //
  //   _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
  //     onAdShowedFullScreenContent: (ad) {
  //       log('AppOpen ad showed');
  //       _appOpenAdShowing = true;
  //     },
  //     onAdDismissedFullScreenContent: (ad) {
  //       log('AppOpen ad dismissed');
  //       _appOpenAdShowing = false;
  //       ad.dispose();
  //       _appOpenAd = null;
  //       _appOpenAdLoaded = false;
  //       onComplete?.call();
  //       precacheAppOpenAd();
  //     },
  //     onAdFailedToShowFullScreenContent: (ad, error) {
  //       log('AppOpen ad failed to show: ${error.message}');
  //       _appOpenAdShowing = false;
  //       ad.dispose();
  //       _appOpenAd = null;
  //       _appOpenAdLoaded = false;
  //       onComplete?.call();
  //       precacheAppOpenAd();
  //     },
  //   );
  //
  //   _appOpenAd!.show();
  // }

  // static void disposeAds() {
  //   for (final state in _interstitialStates.values) {
  //     state.isShowing = false;
  //     state.isLoaded = false;
  //     state.isLoading = false;
  //     state.ad?.dispose();
  //   }
  //   _interstitialStates.clear();
  //
  //   // resetRewardedAd(RewardedPlacement.startCreating);
  //   // resetRewardedAd(RewardedPlacement.watchAndWin);
  // }
}
