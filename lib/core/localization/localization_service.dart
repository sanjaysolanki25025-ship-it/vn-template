import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();

  factory LocalizationService() => _instance;

  LocalizationService._internal();

  final FlutterLocalization localization = FlutterLocalization.instance;

  List<String> supportedLocales = ['en', 'hi', 'es', 'pt', 'de', 'fr', 'ar', 'ko', 'tr', 'id'];
  Map<String, Map<String, dynamic>> loadedMaps = {};

  Future<void> init() async {
    for (var locale in supportedLocales) {
      try {
        final jsonString = await rootBundle.loadString('assets/languages/$locale.json');
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        loadedMaps[locale] = jsonMap;
      } catch (e) {
        // Fallback or empty map if missing
        loadedMaps[locale] = {};
      }
    }

    final savedLanguage = AppPreferences().getString(AppPreferences.selectedLanguage) ?? 'en';

    await localization.ensureInitialized();

    localization.init(
      mapLocales: supportedLocales.map((locale) {
        return MapLocale(locale, loadedMaps[locale]!);
      }).toList(),
      initLanguageCode: savedLanguage,
    );
  }

  void changeLanguage(String languageCode) {
    localization.translate(languageCode);
    AppPreferences().setString(AppPreferences.selectedLanguage, languageCode);
  }

  String get currentLocale => localization.currentLocale?.languageCode ?? 'en';
}
