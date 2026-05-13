import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:unflappable/core/Routes/app_routes.dart';
import 'package:unflappable/core/storage/local_storage.dart';
import 'package:unflappable/firebase_options.dart';
import 'package:unflappable/service/notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationManager._initializeLocalNotifications();
  await NotificationManager._showNotification(message);
}

abstract final class NotificationManager {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'unflappable_notifications',
        'App Notifications',
        description: 'Notifications from Unflappable',
        importance: Importance.high,
      );

  static bool _isInitialized = false;
  static bool _isRegistering = false;
  static String? _currentRegisteredToken;
  static GoRouter? _router;

  static Future<void> init() async {
    if (_isInitialized) return;

    await _initializeLocalNotifications();
    await _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (!kIsWeb && Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
    _messaging.onTokenRefresh.listen(_handleTokenRefresh);

    final startupFcmToken = await _getFcmTokenSafely();
    if (startupFcmToken != null && startupFcmToken.isNotEmpty) {
      debugPrint('FCM token: $startupFcmToken');
    } else {
      debugPrint('FCM token: unavailable at startup');
    }
    await _registerDeviceTokenIfNeeded(prefetchedToken: startupFcmToken);
    _isInitialized = true;
  }

  static void configureRouter(GoRouter router) {
    _router = router;
    _handleInitialMessage();
  }

  static Future<void> requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      provisional: false,
      criticalAlert: false,
      carPlay: false,
    );
    debugPrint('FCM permission: ${settings.authorizationStatus}');
  }

  static Future<void> _handleInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      _handleMessageTap(message);
    }
  }

  static Future<void> registerDeviceToken() async {
    await _registerDeviceTokenIfNeeded(force: true, prefetchedToken: null);
  }

  static Future<void> deleteDeviceToken() async {
    final storedToken = LocalStorage.getData(LocalStorage.fcmToken);
    if (storedToken == null || storedToken.isEmpty) {
      _currentRegisteredToken = null;
      return;
    }

    try {
      await NotificationService.deleteDevice(fcmToken: storedToken);
      debugPrint('Notification device removed from backend');
    } catch (e, stackTrace) {
      debugPrint('Failed to delete notification device: $e');
      debugPrint('$stackTrace');
    } finally {
      await LocalStorage.removeData(LocalStorage.fcmToken);
      _currentRegisteredToken = null;
    }
  }

  static Future<void> _registerDeviceTokenIfNeeded({
    bool force = false,
    String? prefetchedToken,
  }) async {
    if (_isRegistering) return;
    final accessToken = LocalStorage.getData(LocalStorage.accessToken);
    if (accessToken == null || accessToken.trim().isEmpty) {
      return;
    }

    final fcmToken = prefetchedToken ?? await _getFcmTokenSafely();
    if (fcmToken == null || fcmToken.isEmpty) return;

    final cachedToken = LocalStorage.getData(LocalStorage.fcmToken);
    if (!force &&
        (_currentRegisteredToken == fcmToken || cachedToken == fcmToken)) {
      debugPrint('FCM token already registered. Skipping duplicate call.');
      _currentRegisteredToken = fcmToken;
      return;
    }

    _isRegistering = true;
    try {
      await NotificationService.registerDevice(
        fcmToken: fcmToken,
        platform: _currentPlatform,
      );
      await LocalStorage.saveData(LocalStorage.fcmToken, fcmToken);
      _currentRegisteredToken = fcmToken;
      debugPrint('FCM token registered successfully');
    } catch (e, stackTrace) {
      debugPrint('Failed to register FCM token: $e');
      debugPrint('$stackTrace');
    } finally {
      _isRegistering = false;
    }
  }

  static Future<String?> _getFcmTokenSafely() async {
    if (kIsWeb) return _messaging.getToken();

    // On iOS, `getToken()` throws until APNs token is available.
    if (Platform.isIOS) {
      const maxAttempts = 6;
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          final apns = await _messaging.getAPNSToken();
          if (apns == null || apns.isEmpty) {
            await Future.delayed(Duration(milliseconds: 350 * attempt));
            continue;
          }
        } catch (e) {
          // Not ready yet — keep waiting.
          await Future.delayed(Duration(milliseconds: 350 * attempt));
          continue;
        }

        try {
          return await _messaging.getToken();
        } catch (e) {
          final msg = e.toString();
          if (msg.contains('apns-token-not-set')) {
            await Future.delayed(Duration(milliseconds: 350 * attempt));
            continue;
          }
          debugPrint('FCM getToken() failed: $e');
          return null;
        }
      }

      debugPrint(
        'APNs token not available yet; skipping FCM token registration.',
      );
      return null;
    }

    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('FCM getToken() failed: $e');
      return null;
    }
  }

  static Future<void> _handleTokenRefresh(String token) async {
    if (token.isEmpty) return;
    await LocalStorage.saveData(LocalStorage.fcmToken, token);
    _currentRegisteredToken = null;
    await _registerDeviceTokenIfNeeded(force: true);
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    if (message.notification == null) return;
    _showNotification(message);
  }

  static void _handleMessageTap(RemoteMessage message) {
    if (_router == null) return;

    final rawScreen = message.data['screen']?.toString().trim().toLowerCase();
    final notificationId =
        message.data['notificationId'] ??
        message.data['notification_id'] ??
        message.data['id'];

    if (rawScreen == 'notifications' || rawScreen == 'notification') {
      _router!.go(AppRoutes.notifications);
      return;
    }

    if (notificationId != null && notificationId.toString().isNotEmpty) {
      _router!.go(AppRoutes.notifications);
      return;
    }

    _router!.go(AppRoutes.notifications);
  }

  static String get _currentPlatform {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'android';
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload == null) return;
        final data = jsonDecode(details.payload!);
        final message = RemoteMessage(data: Map<String, dynamic>.from(data));
        _handleMessageTap(message);
      },
    );

    if (!kIsWeb) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_androidChannel);
    }
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final payload = jsonEncode(message.data);
    await _localNotifications.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: payload,
    );
  }
}
