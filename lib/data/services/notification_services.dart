import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vn_template/core/constant/app_string.dart';

/// Notification Channel
const AndroidNotificationChannel _highImportanceChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'Used for important notifications.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

bool _isLocalNotificationsInitialized = false;

/// Handle taps on notifications when app is terminated (background handler for taps)
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  final payload = notificationResponse.payload;
  if (payload != null && payload.isNotEmpty) {
    // TODO: handle navigation or other logic when user taps a notification and app was
    // in background/terminated. Keep this lightweight because it runs from a background isolate.
    // For now we just print the payload so it's visible in logs.
    print('Notification tapped (background): $payload');
  }
}

/// Initialize local notifications
Future<void> _setupFlutterNotifications() async {
  if (_isLocalNotificationsInitialized) return;

  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(
      // Request permission on iOS at initialization (we also explicitly request permissions
      // via FirebaseMessaging and the plugin later). These flags control the permissions the
      // plugin will request when asked.
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    ),
  );

  // Initialize plugin and set up tap handlers for when the user taps a notification.
  await _localNotifications.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        // TODO: handle navigation or app logic when notification is tapped (foreground)
        print('Notification tapped: $payload');
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  await _localNotifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_highImportanceChannel);

  // Request iOS-specific permission for the local notifications plugin (Darwin)
  await _localNotifications
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);

  // For iOS the system can show notifications while the app is in foreground.
  // If both the system foreground presentation and our local notification
  // are enabled we will see duplicate notifications on iOS. To avoid this,
  // disable the system foreground presentation on iOS and use the
  // local notifications plugin to show the banner/sound/badge instead.
  if (Platform.isIOS) {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );
  } else {
    // On Android (or other platforms) allow notifications to be shown by
    // the system when app is in foreground. We still show a local
    // notification in onMessage handler which is common on Android too,
    // but leaving this true is the default behavior.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  _isLocalNotificationsInitialized = true;
}

/// Show notification (ONLY used in foreground)
Future<void> _showFlutterNotification(RemoteMessage message) async {
  final notification = message.notification;

  final title = notification?.title ?? message.data['title']?.toString() ?? '';
  final body = notification?.body ?? message.data['body']?.toString() ?? '';

  if (title.isEmpty && body.isEmpty) return;

  final int id = message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch;

  await _localNotifications.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        _highImportanceChannel.id,
        _highImportanceChannel.name,
        channelDescription: _highImportanceChannel.description,
        icon: '@mipmap/ic_launcher',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    ),
    payload: message.data.isEmpty ? null : jsonEncode(message.data),
  );
}

Future onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
  if (payload != null && payload.isNotEmpty) {
    print('iOS (old) local notification received: $payload');
  }
}

/// 🔥 BACKGROUND HANDLER (DO NOTHING)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    final messaging = FirebaseMessaging.instance;

    /// 1. Request permission
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    /// 2. Init local notification
    await _setupFlutterNotifications();

    /// 3. Subscribe to topic
    await messaging.subscribeToTopic(AppStrings.txtNotificationChannel);

    /// 4. Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    /// 5. Foreground notification (ONLY HERE)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showFlutterNotification(message);
    });

    /// 6. When user taps notification (background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // TODO: Handle navigation here if needed
    });

    /// 7. When app is terminated and opened via notification
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      // TODO: Handle navigation here if needed
    }
    _isInitialized = true;
  }
}
