import 'dart:async';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/utils/localization_service.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';
import 'package:vn_template/data/models/dino_game_models/player_data.dart';
import 'package:vn_template/data/models/dino_game_models/settings.dart';
import 'package:vn_template/routes/app_routes.dart';
import 'package:hive/hive.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';
import 'package:vn_template/data/helper/ad_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vn_template/data/services/notification_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await MobileAds.instance.initialize();
  await AppPreferences().initialize();
  await initHive();
  await Firebase.initializeApp();

  // Set up Firebase Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialize Firebase Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  /// Firebase Remote Config
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 3),
      minimumFetchInterval: Duration.zero,
    ),
  );
  await remoteConfig.fetchAndActivate();
  AppAdIdString.initLiveAds();

  await NotificationService.init();
  AdHelper.precacheAppOpenAd();

  bool onboarding =
      AppPreferences().getBool(AppPreferences.onboarding) ?? false;
  bool isLanguageSelected =
      AppPreferences().getBool(AppPreferences.isLanguageSelected) ?? false;
  bool isInterestDone =
      AppPreferences().getBool(AppPreferences.isInterestDone) ?? false;
  bool isSubscribed =
      AppPreferences().getBool(AppPreferences.subscriptionPlan) ?? false;

  if (!isSubscribed) {
    if (!onboarding || !isLanguageSelected || !isInterestDone) {
      AdHelper.precacheInterstitialAd(adId: AppAdIdString.splashInterstitial);
    }
  }

  /// Localization
  await LocalizationService().init();
  
  final config = ClarityConfig(
    projectId: "y478zhy2sm",
    logLevel: LogLevel.None,
  );
  
  runApp(ClarityWidget(app: const MyApp(), clarityConfig: config));
}

/// for dino game
Future<void> initHive() async {
  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  Hive.registerAdapter<PlayerData>(PlayerDataAdapter());
  Hive.registerAdapter<Settings>(SettingsAdapter());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocalizationService _localizationService = LocalizationService();

  @override
  void initState() {
    _localizationService.localization.onTranslatedLanguage =
        _onTranslatedLanguage;
    super.initState();
  }

  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(370, 710),
      minTextAdapt: true,
      splitScreenMode: true,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          // --- ANDROID SETTINGS ---
          statusBarColor: AppColors.blackColor,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.blackColor,
          systemNavigationBarIconBrightness: Brightness.light,

          // --- iOS SETTINGS ---
          statusBarBrightness: Brightness.dark,
        ),
        child: MaterialApp.router(
          title: "VN Template QR",
          debugShowCheckedModeBanner: false,
          routerConfig: AppRoutes.routes,
          locale: _localizationService.localization.currentLocale,
          supportedLocales: _localizationService.localization.supportedLocales,
          localizationsDelegates:
              _localizationService.localization.localizationsDelegates,
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.primaryColor,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.light,
            ),
          ),
          builder: (context, child) {
            return SafeArea(bottom: false, child: child ?? const SizedBox());
          },
        ),
      ),
    );
  }
}
