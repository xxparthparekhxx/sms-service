import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_messenger/flutter_background_messenger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sms_service/firebase_options.dart';
import 'package:sms_service/services/api_service.dart';

@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final messenger = FlutterBackgroundMessenger();
  await messenger.sendSMS(
    message: message.data['message'],
    phoneNumber: message.data['recipient'],
  );
}

class MessagingService {
  late final FirebaseMessaging _messaging;
  final ApiCaller apiCaller;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final messenger = FlutterBackgroundMessenger();

  MessagingService(this.apiCaller);

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    _messaging = FirebaseMessaging.instance;
    // Configure notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _notifications.initialize(initSettings);

    // Request permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true, // Add this
      announcement: true, // Add this
    );

    // Get initial token
    String? token = await _messaging.getToken();
    if (token != null) {
      await _updateDeviceToken(token);
    }

    // Listen to token refreshes
    _messaging.onTokenRefresh.listen((String newToken) {
      _updateDeviceToken(newToken);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleMessage);

    // Handle messages when app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessage(message);
      }
    });

    // Handle messages when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessage(message);
    });
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    // Show local notification
    // await _showNotification(message);
    print(message.data);

    // Send SMS if required data is present
    if (message.data.containsKey('recipient') &&
        message.data.containsKey('message')) {
      await messenger.sendSMS(
        message: message.data['message'],
        phoneNumber: message.data['recipient'],
      );
    }
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'sms_service_channel',
      'SMS Service Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? 'You have a new message',
      details,
    );
  }

  Future<void> _updateDeviceToken(String token) async {
    try {
      // First get user's devices
      final response = await apiCaller.get('/api/devices/');
      final devices = jsonDecode(response.body);
      print(token);

      if (devices.isNotEmpty) {
        // Update existing device
        final deviceId = devices[0]['id'];
        await apiCaller.patch('/api/devices/$deviceId/', body: {
          'fcm_token': token,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
          'name': Platform.isAndroid ? 'Android Device' : 'iOS Device'
        });
      } else {
        // Create new device
        await apiCaller.post('/api/devices/', body: {
          'fcm_token': token,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
          'name': Platform.isAndroid ? 'Android Device' : 'iOS Device'
        });
      }
    } catch (e) {
      print('Failed to update device token: $e');
    }
  }
}
