import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logEvent(
    String eventName, {
    Map<String, Object>? params,
  }) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: params ?? <String, Object>{},
    );
  }
}
