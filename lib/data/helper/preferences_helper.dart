import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  // Singleton instance
  static final AppPreferences _instance = AppPreferences._internal();

  // Factory constructor
  factory AppPreferences() {
    return _instance;
  }

  // Private constructor
  AppPreferences._internal();

  // SharedPreferences instance
  SharedPreferences? _preferences;

  // Keys for shared preferences
  static const String onboarding = "onboarding";
  static const String coin = "coin";
  static const String firstTimeOpen = "first_time_open";
  static const String onBackPress = "on_back_press";
  static const String slotMachineShowcase = "slot_machine_showcase";
  static const String swipeUp = "swipe_up";
  static const String subscriptionPlan = "subscription_plan";
  static const String planType = "plan_type";
  static const String openAppCount = "open_app_count";
  static const String loadMoreOnTap = "load_more_on_tap";
  static const String instagramFollow = "instagram_follow";
  static const String joinTelegram = "join_telegram";
  static const String allLanguage = "all_language";
  static const String notificationCoinRewarded = "notification_coin_rewarded";
  static const String categoryOnTap = "category_on_tap";
  static const String selectedLanguage = "selected_language";
  static const String isLanguageSelected = "is_language_selected";
  static const String isInterestDone = "is_interest_done";
  // Initialize SharedPreferences
  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Save a string value
  Future<void> setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  // // Get a string value
  String? getString(String key) {
    return _preferences?.getString(key);
  }

  // // Get a int value
  int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  // Save a boolean value
  Future<void> setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  // Save a int value
  Future<void> setInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  // Get a boolean value
  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  // Save a boolean value
  Future<void> setDouble(String key, double value) async {
    await _preferences?.setDouble(key, value);
  }

  // Get a boolean value
  double? getDouble(String key) {
    return _preferences?.getDouble(key);
  }

  // Save a list string
  Future<void> setListString(String key, List<String> value) async {
    await _preferences?.setStringList(key, value);
  }

  List<String>? getListString(String key) {
    return _preferences?.getStringList(key);
  }
}
