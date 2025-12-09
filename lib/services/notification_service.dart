import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Initialize notifications & FCM
  static Future<void> initialize(BuildContext context) async {
    // Android Initialization
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && context.mounted) {
          Navigator.of(context)
              .pushNamed('/order-details', arguments: payload);
        }
      },
    );

    // Create Android Notification Channels
    const AndroidNotificationChannel orderChannel = AndroidNotificationChannel(
      'order_channel',
      'Order Notifications',
      description: 'Notifications for new orders and updates',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('order_assignment'),
    );

    // Location service channel for background service
    const AndroidNotificationChannel locationChannel = AndroidNotificationChannel(
      'location_service',
      'Location Service',
      description: 'Background location tracking service',
      importance: Importance.low,
      playSound: false,
    );

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(orderChannel);
    await androidPlugin?.createNotificationChannel(locationChannel);

    // FCM listeners
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Foreground notification
      _handleFCMMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Clicked notification (background / terminated)
      final orderId = message.data['orderId'] ?? '';
      if (orderId.isNotEmpty && context.mounted) {
        Navigator.of(context).pushNamed('/order-details', arguments: orderId);
      }
    });

    // For terminated state (when app opened via notification)
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final orderId = initialMessage.data['orderId'] ?? '';
      if (orderId.isNotEmpty && context.mounted) {
        Navigator.of(context).pushNamed('/order-details', arguments: orderId);
      }
    }
  }

  /// Show notification locally
  static Future<void> showNotification({
    required String title,
    required String body,
    required String payload,

  }) async {
    try {
      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'order_channel',
        'Order Notifications',
        channelDescription: 'Notifications for new orders and updates',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,

        sound: RawResourceAndroidNotificationSound('order_assignment'),
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
        visibility: NotificationVisibility.public,
      );

      DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'order_assignment.caf',
      );

      NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      log('Error showing notification: $e');
    }
  }

  /// Handle FCM message and show local notification
  static void _handleFCMMessage(RemoteMessage message) {
    if (message.data['type'] == 'order_assignment') {
      log("${message.toMap().toString()}");
      String title = message.notification?.title ?? 'New Order Assignment';
      String body = message.notification?.body ?? '';
      String orderId = message.data['orderId'] ?? '';

      showNotification(title: title, body: body, payload: orderId);
    }
  }
}
