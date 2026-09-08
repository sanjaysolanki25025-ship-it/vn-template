import 'dart:async';
import 'package:vn_template/core/utils/app_logger.dart';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';
import 'package:vn_template/data/helper/db_helper.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';

class AdCacheConfig {
  final int cacheSize;
  final String factoryId;
  final String adName;

  AdCacheConfig({required this.cacheSize, required this.factoryId, required this.adName});
}

class AdStats {
  int loaded = 0;
  int served = 0;
  int failed = 0;

  int get pending => loaded - served;

  Map<String, dynamic> toJson() {
    return {'loaded': loaded, 'served': served, 'failed': failed, 'pending': pending};
  }
}

class NativeAdManager {
  static final NativeAdManager _instance = NativeAdManager._internal();

  factory NativeAdManager() => _instance;

  NativeAdManager._internal();
  final Map<String, int> _retryCount = {};
  final Map<String, Timer> _retryTimers = {};

  static final Map<String, AdCacheConfig> _configs = {
    AppAdIdString.rateUsNativeAd: AdCacheConfig(
      adName: 'Rate Us Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),
    AppAdIdString.splashNativeAd: AdCacheConfig(
      adName: 'Splash Native Ad',
      cacheSize: 1,
      factoryId: 'row_native_ad',
    ),
    AppAdIdString.onBoarding1NativeAd: AdCacheConfig(
      adName: 'OnBoarding Native Ad 1',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),
    AppAdIdString.onBoarding2NativeAd: AdCacheConfig(
      adName: 'OnBoarding Native Ad 2',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),
    AppAdIdString.selectLanguageNativeAd: AdCacheConfig(
      adName: 'Select Language Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),
    AppAdIdString.chooseYourInterestNativeAd: AdCacheConfig(
      adName: 'Choose Your Interest Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),
    AppAdIdString.homeBottomNativeAd: AdCacheConfig(
      adName: 'Home Bottom Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),
    AppAdIdString.discoverNativeAd: AdCacheConfig(
      adName: 'Discover Native Ad',
      cacheSize: 2,
      factoryId: 'medium_native_ad',
    ),
    AppAdIdString.noDataFoundNativeAd: AdCacheConfig(
      adName: 'No Data Found Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),
    AppAdIdString.favouriteNativeAd: AdCacheConfig(
      adName: 'Favourite Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),
    AppAdIdString.templateDetailNativeAd: AdCacheConfig(
      adName: 'Template Detail Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),

    AppAdIdString.templateDetailBottomNativeAd: AdCacheConfig(
      adName: 'Template Detail Bottom Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),
    AppAdIdString.maintenanceNativeAd: AdCacheConfig(
      adName: 'Maintenance Native Ad',
      cacheSize: 1,
      factoryId: 'row_native_ad',
    ),

    AppAdIdString.exitAppNativeAd: AdCacheConfig(
      adName: 'Exit App Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),
  };

  final Map<String, List<NativeAd>> _cachedAds = {};
  final Map<String, bool> _isLoading = {};
  final Map<String, AdStats> _adStats = {};
  final Map<String, bool> _preCacheSuccessful = {};

  AdStats _getStats(String adId) {
    return _adStats.putIfAbsent(adId, () => AdStats());
  }

  // -------------------------------------------------------
  // INIT
  // -------------------------------------------------------
  void init() async {
    final onboarding = AppPreferences().getBool(AppPreferences.onboarding) ?? false;
    final isLanguageSelected = AppPreferences().getBool(AppPreferences.isLanguageSelected) ?? false;
    final isInterestDone = AppPreferences().getBool(AppPreferences.isInterestDone) ?? false;
    final isMaintenance = FirebaseRemoteConfig.instance.getBool("isMaintenance");
    final favourites = await DbHelper().getFavourites();
    final isFavouriteEmpty = favourites.isEmpty;

    for (final entry in _configs.entries) {
      final adId = entry.key;

      if (onboarding &&
          (adId == AppAdIdString.onBoarding1NativeAd   ||
              adId == AppAdIdString.onBoarding2NativeAd)) {
        AppLogger.log('SKIP INITIAL PRE-CACHE | ${entry.value.adName} | $adId | Onboarding already completed.');
        continue;
      }

      if (isLanguageSelected && adId == AppAdIdString.selectLanguageNativeAd) {
        AppLogger.log('SKIP INITIAL PRE-CACHE | ${entry.value.adName} | $adId | Language already selected.');
        continue;
      }

      if (isInterestDone && adId == AppAdIdString.chooseYourInterestNativeAd) {
        AppLogger.log('SKIP INITIAL PRE-CACHE | ${entry.value.adName} | $adId | Choose Category already done.');
        continue;
      }

      if (adId == AppAdIdString.maintenanceNativeAd && !isMaintenance) {
        AppLogger.log('SKIP INITIAL PRE-CACHE | ${entry.value.adName} | $adId | Not in maintenance mode.');
        continue;
      }

      if (isFavouriteEmpty && adId == AppAdIdString.favouriteNativeAd) {
        AppLogger.log('SKIP INITIAL PRE-CACHE | ${entry.value.adName} | $adId | Favourite DB is empty.');
        continue;
      }

      if (!isFavouriteEmpty && adId == AppAdIdString.noDataFoundNativeAd) {
        AppLogger.log('SKIP INITIAL PRE-CACHE | ${entry.value.adName} | $adId | Favourite DB is not empty.');
        continue;
      }

      if (adId == AppAdIdString.noDataFoundNativeAd) {
        AppLogger.log('SKIP INITIAL PRE-CACHE | ${entry.value.adName} | $adId | Direct load on tap instead.');
        continue;
      }

      if (adId == AppAdIdString.exitAppNativeAd) {
        AppLogger.log('SKIP INITIAL PRE-CACHE | ${entry.value.adName} | $adId | Triggered by user back press instead.');
        continue;
      }

      if (adId == AppAdIdString.homeBottomNativeAd) {
        AppLogger.log('SKIP INITIAL PRE-CACHE | ${entry.value.adName} | $adId | Pre-cached on demand.');
        continue;
      }

      if (adId == AppAdIdString.templateDetailBottomNativeAd) {
        AppLogger.log('SKIP INITIAL PRE-CACHE | ${entry.value.adName} | $adId | Pre-cached on demand.');
        continue;
      }

      if (adId == AppAdIdString.templateDetailNativeAd) {
        AppLogger.log('SKIP INITIAL PRE-CACHE | ${entry.value.adName} | $adId | Pre-cached on demand.');
        continue;
      }

      if (adId == AppAdIdString.rateUsNativeAd) {
        AppLogger.log('SKIP INITIAL PRE-CACHE | ${entry.value.adName} | $adId | Pre-cached on demand.');
        continue;
      }

      final cache = _cachedAds[adId] ?? [];
      final loading = _isLoading[adId] ?? false;

      if (cache.isEmpty && !loading) {
        _loadBatchForAd(adId);
      }
    }
  }

  // -------------------------------------------------------
  // LOAD ADS
  // -------------------------------------------------------
  void _loadBatchForAd(String adId) async {
    final config = _configs[adId];
    if (config == null) return;

    if (_isLoading[adId] == true) return;

    final onboarding = AppPreferences().getBool(AppPreferences.onboarding) ?? false;
    if (onboarding &&
        (adId == AppAdIdString.onBoarding1NativeAd ||
            adId == AppAdIdString.onBoarding2NativeAd ||
            adId == AppAdIdString.maintenanceNativeAd)) {
      AppLogger.log('SKIP PRE-CACHE | ${config.adName} | $adId | Onboarding already completed.');
      return;
    }

    final isLanguageSelected = AppPreferences().getBool(AppPreferences.isLanguageSelected) ?? false;
    if (isLanguageSelected && adId == AppAdIdString.selectLanguageNativeAd) {
      AppLogger.log('SKIP PRE-CACHE | ${config.adName} | $adId | Language already selected.');
      return;
    }

    final isInterestDone = AppPreferences().getBool(AppPreferences.isInterestDone) ?? false;
    if (isInterestDone && adId == AppAdIdString.chooseYourInterestNativeAd) {
      AppLogger.log('SKIP PRE-CACHE | ${config.adName} | $adId | Choose Category already done.');
      return;
    }

    final favourites = await DbHelper().getFavourites();
    final isFavouriteEmpty = favourites.isEmpty;

    if (isFavouriteEmpty && adId == AppAdIdString.favouriteNativeAd) {
      AppLogger.log('SKIP PRE-CACHE | ${config.adName} | $adId | Favourite DB is empty.');
      return;
    }

    if (!isFavouriteEmpty && adId == AppAdIdString.noDataFoundNativeAd) {
      AppLogger.log('SKIP PRE-CACHE | ${config.adName} | $adId | Favourite DB is not empty.');
      return;
    }

    // If this ad has been successfully pre-cached once, don't try to pre-cache again (except for full screen reels ads, home bottom ads, and discover ads)
    if (
        adId != AppAdIdString.homeBottomNativeAd &&
        adId != AppAdIdString.discoverNativeAd &&
        adId != AppAdIdString.favouriteNativeAd &&
        adId != AppAdIdString.templateDetailNativeAd &&
        adId != AppAdIdString.rateUsNativeAd &&
        // adId != AppAdIdString.settingNativeAd &&
        // adId != AppAdIdString.settingDialogNativeAd &&
        // adId != AppAdIdString.howToUseNativeAd &&
        adId != AppAdIdString.templateDetailBottomNativeAd &&
        adId != AppAdIdString.exitAppNativeAd &&
        adId != AppAdIdString.noDataFoundNativeAd &&
        // adId != AppAdIdString.slotDialogNativeAd &&
        _preCacheSuccessful[adId] == true) {
      AppLogger.log('SKIP PRE-CACHE | ${config.adName} | $adId | Already successfully pre-cached once.');
      return;
    }

    _isLoading[adId] = true;

    final cache = _cachedAds.putIfAbsent(adId, () => []);
    final currentCacheSize = cache.length;
    final needToLoad = config.cacheSize - currentCacheSize;

    if (needToLoad <= 0) {
      _isLoading[adId] = false;
      return;
    }

    final futures = <Future<void>>[];

    for (int i = 0; i < needToLoad; i++) {
      final completer = Completer<void>();

      // 📥 PRE CACHE START LOG
      AppLogger.log('PRE CACHE START | ${config.adName} | $adId | Ad ${i + 1}/$needToLoad');

      NativeAd(
        adUnitId: adId,
        factoryId: config.factoryId,
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            cache.add(ad as NativeAd);
            _retryCount[adId] = 0;
            _retryTimers[adId]?.cancel();
            _getStats(adId).loaded++;
            _preCacheSuccessful[adId] = true;

            // ✅ PRE CACHE SUCCESS LOG
            AppLogger.log(
              'PRE CACHE SUCCESS | ${config.adName} | $adId | Total Pre Cache: ${cache.length}/${config.cacheSize}',
            );

            completer.complete();
          },
          onAdFailedToLoad: (ad, error) {
            _getStats(adId).failed++;

            // ❌ PRE CACHE FAILED LOG
            AppLogger.log('PRE CACHE FAILED | ${config.adName} | $adId | Error: ${error.message}');

            ad.dispose();
            completer.complete();

            // Retry pre-caching after FailureModel (except for splash native ad)
            if (adId != AppAdIdString.splashNativeAd) {
              _scheduleRetry(adId);
            }
          },
        ),
      ).load();

      futures.add(completer.future);
    }

    await Future.wait(futures);
    _isLoading[adId] = false;
  }

  // -------------------------------------------------------
  // PRE-CACHE AD ON DEMAND
  // -------------------------------------------------------
  void preCacheAd(String adId) {
    _loadBatchForAd(adId);
  }

  // -------------------------------------------------------
  // GET AD (row_native_ad)
  // -------------------------------------------------------
  NativeAd? getAd(String adId) {
    final onboarding = AppPreferences().getBool(AppPreferences.onboarding) ?? false;
    if (onboarding &&
        (adId == AppAdIdString.onBoarding1NativeAd ||
            adId == AppAdIdString.onBoarding2NativeAd)) {
      AppLogger.log('SKIP GET AD | $adId | Onboarding already completed.');
      return null;
    }

    final isLanguageSelected = AppPreferences().getBool(AppPreferences.isLanguageSelected) ?? false;
    if (isLanguageSelected && adId == AppAdIdString.selectLanguageNativeAd) {
      AppLogger.log('SKIP GET AD | $adId | Language already selected.');
      return null;
    }

    final isInterestDone = AppPreferences().getBool(AppPreferences.isInterestDone) ?? false;
    if (isInterestDone && adId == AppAdIdString.chooseYourInterestNativeAd) {
      AppLogger.log('SKIP GET AD | $adId | Choose Category already done.');
      return null;
    }

    final config = _configs[adId];
    if (config != null && config.factoryId != 'row_native_ad') return null;
    return _serveAd(adId);
  }

  // -------------------------------------------------------
  // GET MEDIUM AD (medium_native_ad)
  // -------------------------------------------------------
  NativeAd? getMediumAd(String adId) {
    final config = _configs[adId];
    if (config != null && config.factoryId != 'medium_native_ad') return null;
    return _serveAd(adId);
  }

  // -------------------------------------------------------
  // SERVE AD
  // -------------------------------------------------------
  NativeAd? _serveAd(String adId) {
    final config = _configs[adId];
    if (config == null) return null;

    final onboarding = AppPreferences().getBool(AppPreferences.onboarding) ?? false;
    if (onboarding &&
        (adId == AppAdIdString.onBoarding1NativeAd ||
            adId == AppAdIdString.onBoarding2NativeAd)) {
      AppLogger.log('SKIP SERVE AD | ${config.adName} | $adId | Onboarding already completed.');
      return null;
    }

    final isLanguageSelected = AppPreferences().getBool(AppPreferences.isLanguageSelected) ?? false;
    if (isLanguageSelected && adId == AppAdIdString.selectLanguageNativeAd) {
      AppLogger.log('SKIP SERVE AD | ${config.adName} | $adId | Language already selected.');
      return null;
    }

    final isInterestDone = AppPreferences().getBool(AppPreferences.isInterestDone) ?? false;
    if (isInterestDone && adId == AppAdIdString.chooseYourInterestNativeAd) {
      AppLogger.log('SKIP SERVE AD | ${config.adName} | $adId | Choose Category already done.');
      return null;
    }

    final cache = _cachedAds[adId] ?? [];

    if (cache.isEmpty) {
      AppLogger.log('NO CACHE | ${config.adName} | $adId | No Cached Ads Available');

      if (!(_isLoading[adId] ?? false)) {
        _loadBatchForAd(adId);
      }

      return null;
    }

    final ad = cache.removeAt(0);
    final stats = _getStats(adId);
    stats.served++;

    // 📤 SHOW AD LOG
    AppLogger.log(
      'SHOW AD | ${config.adName} | $adId | Total Pre Cache: ${cache.length}/${config.cacheSize} | Showed Ad: ${stats.served}',
    );

    if (cache.isEmpty) {
      if (adId != AppAdIdString.exitAppNativeAd) {
        _loadBatchForAd(adId);
      } else {
        AppLogger.log('SKIP RE-PRE-CACHE | ${config.adName} | $adId | Triggered on demand only.');
      }
    }

    return ad;
  }

  // -------------------------------------------------------
  // STATS
  // -------------------------------------------------------
  Map<String, dynamic> getAdStats(String adId) {
    final stats = _getStats(adId);
    return {
      'adId': adId,
      'loaded': stats.loaded,
      'served': stats.served,
      'failed': stats.failed,
      'pending': stats.pending,
      'cached': _cachedAds[adId]?.length ?? 0,
      'isLoading': _isLoading[adId] ?? false,
    };
  }

  void printAllStats() {
    for (final adId in _configs.keys) {
      final config = _configs[adId];
      final stats = getAdStats(adId);
      AppLogger.log(
        'STATS | ${config?.adName} | $adId | Loaded: ${stats['loaded']} | Served: ${stats['served']} | Failed: ${stats['failed']} | Cached: ${stats['cached']}',
      );
    }
  }

  void _scheduleRetry(String adId) {
    final config = _configs[adId];
    if (config == null) return;

    _retryTimers[adId]?.cancel();

    final retry = (_retryCount[adId] ?? 0) + 1;
    _retryCount[adId] = retry;

    final delaySeconds =
    (30 * retry).clamp(30, 300);

    AppLogger.log(
      'RETRY PRE-CACHE | ${config.adName} | '
          '$adId | Retry #$retry after ${delaySeconds}s',
    );

    _retryTimers[adId] = Timer(
      Duration(seconds: delaySeconds),
          () {
        final currentCache = _cachedAds[adId] ?? [];

        bool shouldRetry = false;

        if (
        adId == AppAdIdString.homeBottomNativeAd ||
            adId == AppAdIdString.discoverNativeAd ||
            adId == AppAdIdString.favouriteNativeAd ||
            adId == AppAdIdString.templateDetailNativeAd ||
            adId == AppAdIdString.rateUsNativeAd ||
            // adId == AppAdIdString.settingNativeAd ||
            // adId == AppAdIdString.settingDialogNativeAd ||
            // adId == AppAdIdString.howToUseNativeAd ||
            adId == AppAdIdString.templateDetailBottomNativeAd ||
            adId == AppAdIdString.exitAppNativeAd ||
            adId == AppAdIdString.noDataFoundNativeAd /* ||
            adId == AppAdIdString.slotDialogNativeAd */) {
          shouldRetry =
              currentCache.length < config.cacheSize &&
                  !(_isLoading[adId] ?? false);
        } else if (adId == AppAdIdString.splashNativeAd) {
          shouldRetry = false; // Splash is already gone by the time retry fires
        } else {
          final onboarding = AppPreferences().getBool(AppPreferences.onboarding) ?? false;
          final isLanguageSelected = AppPreferences().getBool(AppPreferences.isLanguageSelected) ?? false;
          final isInterestDone = AppPreferences().getBool(AppPreferences.isInterestDone) ?? false;

          if (onboarding &&
              (adId == AppAdIdString.onBoarding1NativeAd ||
                  adId == AppAdIdString.onBoarding2NativeAd)) {
            shouldRetry = false;
          } else if (isLanguageSelected && adId == AppAdIdString.selectLanguageNativeAd) {
            shouldRetry = false;
          } else if (isInterestDone && adId == AppAdIdString.chooseYourInterestNativeAd) {
            shouldRetry = false;
          } else {
            shouldRetry =
                currentCache.isEmpty &&
                    !(_isLoading[adId] ?? false) &&
                    _preCacheSuccessful[adId] != true;
          }
        }

        if (shouldRetry) {
          _loadBatchForAd(adId);
        }
      },
    );
  }

  // -------------------------------------------------------
  // DISPOSE
  // -------------------------------------------------------
  void dispose() {
    for (final timer in _retryTimers.values) {
      timer.cancel();
    }

    _retryTimers.clear();

    for (final cache in _cachedAds.values) {
      for (final ad in cache) {
        ad.dispose();
      }
      cache.clear();
    }

    _cachedAds.clear();
    _isLoading.clear();
    _adStats.clear();
    _preCacheSuccessful.clear();
  }
}
