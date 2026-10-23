import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Handling background message: ${message.messageId}");
    print("Title: ${message.notification?.title}, Body: ${message.notification?.body}");
  }

  // Handle data-only messages in background/killed state
  if (message.notification == null && message.data.isNotEmpty) {
    final service = NotificationService();
    await service._setupLocalNotifications();
    await service._showNotification(message);
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const String channelId = 'scupporo_notification_channel_v2';
  static const String channelName = 'Scupporo High Importance Notifications';
  static const String channelDescription = 'This channel is used for important notifications with sound and banner.';

  Future<void> initialize() async {
    try {
      // 1. Initialize Firebase if not already initialized
      if (Firebase.apps.isEmpty) {
        try {
          await Firebase.initializeApp().timeout(const Duration(seconds: 5));
        } catch (e) {
          if (kDebugMode) print('Firebase initializeApp error/timeout: $e');
        }
      }

      // 2. Request Notification Permission (iOS & Android 13+)
      try {
        NotificationSettings settings = await _messaging.requestPermission(
          alert: true,
          announcement: true,
          badge: true,
          carPlay: false,
          criticalAlert: true,
          provisional: false,
          sound: true,
        ).timeout(const Duration(seconds: 5));

        if (kDebugMode) {
          print('User notification permission status: ${settings.authorizationStatus}');
        }
      } catch (e) {
        if (kDebugMode) print('Notification permission request error/timeout: $e');
      }

      // 3. Set foreground presentation options for iOS
      try {
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      } catch (e) {
        if (kDebugMode) print('Set foreground notification options error: $e');
      }

      // 4. Register Background Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 5. Setup Local Notifications (For Foreground Push Display & Sound)
      await _setupLocalNotifications();

      // 6. Listen to Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Received foreground message: ${message.messageId}');
          print('Title: ${message.notification?.title}');
          print('Body: ${message.notification?.body}');
        }
        _showNotification(message);
      });

      // 7. Handle Notification Click when app is in Background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Notification clicked (onMessageOpenedApp): ${message.data}');
        }
        _handleNotificationClick(message.data);
      });

      // 8. Handle Notification Click when app was Terminated
      try {
        RemoteMessage? initialMessage = await _messaging.getInitialMessage().timeout(
          const Duration(seconds: 3),
        );
        if (initialMessage != null) {
          if (kDebugMode) {
            print('Notification clicked (getInitialMessage): ${initialMessage.data}');
          }
          _handleNotificationClick(initialMessage.data);
        }
      } catch (e) {
        if (kDebugMode) print('getInitialMessage error: $e');
      }

      // 9. Get & Print FCM Token
      getToken();

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        if (kDebugMode) {
          print('FCM Token Refreshed: $newToken');
        }
      });
    } catch (e, stack) {
      if (kDebugMode) {
        print('Error initializing NotificationService: $e\n$stack');
      }
    }
  }

  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) {
          print('Local Notification clicked: ${response.payload}');
        }
      },
    );

    // Explicitly request permissions on iOS and Android
    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.requestNotificationsPermission();

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.notification,
      );

      await androidPlugin?.createNotificationChannel(channel);
    }
  }

  Future<void> _showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    Map<String, dynamic> data = message.data;

    String? title = notification?.title ?? data['title'];
    String? body = notification?.body ?? data['body'];

    if (title == null && body == null) return;

    AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.notification,
      icon: '@mipmap/launcher_icon',
    );

    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    int notificationId = notification?.hashCode ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await _localNotifications.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: message.data.toString(),
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.notification,
      icon: '@mipmap/launcher_icon',
    );

    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await _localNotifications.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  void _handleNotificationClick(Map<String, dynamic> data) {
    // Navigate or perform specific action based on notification data payload
  }

  Future<String?> getToken() async {
    try {
      String? token = await _messaging.getToken().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      if (kDebugMode) {
        print('================ FCM TOKEN ================');
        print(token);
        print('===========================================');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching FCM Token: $e');
      }
      return null;
    }
  }
}
