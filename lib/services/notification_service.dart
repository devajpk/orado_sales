import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:oradosales/presentation/orders/view/order_details_screen.dart';
import 'package:oradosales/services/navigation_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// ---------------------------------------------------------
  /// SAFE PAYLOAD PARSER (UNCHANGED)
  /// ---------------------------------------------------------
  static Map<String, dynamic> _safeParsePayload(String payload) {
    try {
      return jsonDecode(payload);
    } catch (_) {
      log("⚠ Invalid JSON payload detected, fixing manually...");

      final fixed = payload
          .replaceAll("{", "{\"")
          .replaceAll("}", "\"}")
          .replaceAll(": ", "\": \"")
          .replaceAll(", ", "\", \"");

      log("➡ Fixed Payload = $fixed");
      return jsonDecode(fixed);
    }
  }

  /// ---------------------------------------------------------
  /// INITIALIZE NOTIFICATIONS
  /// ---------------------------------------------------------
  static Future<void> initialize(BuildContext context) async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit =
        DarwinInitializationSettings(
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
      onDidReceiveNotificationResponse: (response) {
        try {
          final payload = response.payload;
          if (payload == null) return;

          final data = _safeParsePayload(payload);
          final orderId = data["orderId"];

          if (orderId == null || orderId.isEmpty) return;

          _navigateToOrder(orderId);
        } catch (e) {
          log("❌ Notification tap error: $e");
        }
      },
    );

    /// ---------------------------------------------------------
    /// ANDROID CHANNELS
    /// ---------------------------------------------------------
    const AndroidNotificationChannel orderChannel =
        AndroidNotificationChannel(
      'order_channel',
      'Order Notifications',
      description: 'Notifications for new orders and updates',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('order_assignment'),
    );

    final androidPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(orderChannel);

    /// ---------------------------------------------------------
    /// FOREGROUND MESSAGE
    /// ---------------------------------------------------------
    FirebaseMessaging.onMessage.listen(_handleFCMMessage);

    /// ---------------------------------------------------------
    /// BACKGROUND TAP
    /// ---------------------------------------------------------
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final orderId = message.data["orderId"];
      if (orderId != null && orderId.isNotEmpty) {
        _navigateToOrder(orderId);
      }
    });

    /// ---------------------------------------------------------
    /// TERMINATED TAP
    /// ---------------------------------------------------------
    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      final orderId = initialMessage.data["orderId"];
      if (orderId != null && orderId.isNotEmpty) {
        _navigateToOrder(orderId);
      }
    }
  }

  /// ---------------------------------------------------------
  /// SHOW LOCAL NOTIFICATION (UNCHANGED PAYLOAD)
  /// ---------------------------------------------------------
  static Future<void> showNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'order_channel',
        'Order Notifications',
        channelDescription: 'Notifications for order updates',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('order_assignment'),
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
        visibility: NotificationVisibility.public,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'order_assignment.caf',
      );

      await _flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
        payload: payload, // ❌ NOT CHANGED
      );
    } catch (e) {
      log('❌ Error showing notification: $e');
    }
  }

  /// ---------------------------------------------------------
  /// HANDLE FCM MESSAGE
  /// ---------------------------------------------------------
  static void _handleFCMMessage(RemoteMessage message) {
    if (message.data['type'] == 'order_assignment') {
      log("📩 Incoming ORDER_ASSIGNMENT");

      final title =
          message.notification?.title ?? 'New Order Assignment';
      final body = message.notification?.body ?? '';

      /// ❌ PAYLOAD NOT TOUCHED
      final payload = jsonEncode({
        "orderId": message.data['orderId'] ?? "",
        "address": message.data['address'] ?? "",
        "type": message.data['type'] ?? "",
      });

      showNotification(
        title: title,
        body: body,
        payload: payload,
      );
    }
  }

  /// ---------------------------------------------------------
  /// SAFE NAVIGATION (🔥 FIX)
  /// ---------------------------------------------------------
  static void _navigateToOrder(String orderId) {
    Future.delayed(const Duration(milliseconds: 400), () {
      final navigatorState =
          NavigationService.navigatorKey.currentState;

      if (navigatorState == null) {
        log("❌ Navigator not ready");
        return;
      }

      navigatorState.push(
        MaterialPageRoute(
          builder: (_) =>
              OrderDetailsBottomSheet(orderId: orderId),
        ),
      );

      log("✅ Navigated to order: $orderId");
    });
  }
}
