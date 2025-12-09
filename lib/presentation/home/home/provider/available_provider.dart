import 'dart:developer';

import 'package:oradosales/presentation/socket_io/socket_controller.dart';
import 'package:oradosales/services/agetn_available_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgentAvailableController extends ChangeNotifier {
  bool isAvailable = false;
  final AgentAvailabilityService _service = AgentAvailabilityService();
  final SocketController _socketController;
  bool isLoading = false;
  String? _agentId;
  String? get agentId => _agentId;

  // Notification service
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static const int _notificationId = 1;
  static const String _channelId = 'agent_availability_channel';

  AgentAvailableController(this._socketController) {

    _initializeNotifications();
    _loadInitialState();
  }

  // Initialize notification service
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);

    // Request notification permission for Android 13+
    // await _notificationsPlugin
    //     .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    //     ?.requestNotificationsPermission();

    log('🔔 Notifications initialized');
  }

  // Update notification based on availability status
  Future<void> _updateNotification() async {
    try {
      if (isAvailable) {
        await _showAvailableNotification();
      } else {
        await _showOfflineNotification();
      }
      log('🔔 Notification updated: ${isAvailable ? "Available" : "Offline"}');
    } catch (e) {
      log('❌ Notification update failed: $e');
    }
  }

  // Show "Available" notification
  Future<void> _showAvailableNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'agent_availability_channel',
      'Agent Availability',
      channelDescription: 'Shows agent availability status',
      importance: Importance.high,        // High for lock screen visibility
      priority: Priority.high,           // High priority
      ongoing: true,                     // Persistent notification
      autoCancel: false,                 // Don't auto-cancel
      showWhen: true,                    // Show timestamp
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF4CAF50),          // Green
      colorized: true,
      visibility: NotificationVisibility.public,  // Show on lock screen
      fullScreenIntent: false,           // Don't show as full screen
      category: AndroidNotificationCategory.service,  // Service category
      playSound: true,                  // No sound for ongoing notification
      enableVibration: false,            // No vibration
      ticker: 'Agent Available',         // Lock screen ticker text
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      _notificationId,
      '🟢 You\'re Available',
      'Ready to receive orders • Tap for active orders',
      notificationDetails,
    );
  }

  // Show "Offline" notification
  Future<void> _showOfflineNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'agent_availability_channel',
      'Agent Availability',
      channelDescription: 'Shows agent availability status',
      importance: Importance.high,        // High for lock screen visibility
      priority: Priority.high,           // High priority
      ongoing: true,                     // Persistent notification
      autoCancel: false,                 // Don't auto-cancel
      showWhen: true,                    // Show timestamp
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFF44336),          // Red
      colorized: true,
      visibility: NotificationVisibility.public,  // Show on lock screen
      fullScreenIntent: false,           // Don't show as full screen
      category: AndroidNotificationCategory.service,  // Service category
      playSound: true,                  // No sound for ongoing notification
      enableVibration: false,            // No vibration
      ticker: 'Agent Offline',           // Lock screen ticker text
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      _notificationId,
      '🔴 You\'re Offline',
      'Not accepting orders • Tap for active orders',
      notificationDetails,
    );
  }

  Future<void> _loadInitialState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _agentId = prefs.getString('agentId');
      isAvailable = prefs.getBool('agent_available') ?? false;
      log('🔑 Loaded agentId: $_agentId');
      log('🔄 Loaded availability state: $isAvailable');

      // Update notification based on loaded state
      await _updateNotification();

      // Connect socket if available
      if (isAvailable && _agentId != null) {
        await _socketController.connectSocket();
      }

      notifyListeners();
    } catch (e, stackTrace) {
      log('❌ Failed to load initial state', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> persistAvailability(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('agent_available', value);
  }

  Future<void> toggleAvailability(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    _agentId = prefs.getString('agentId');
    log("-------------${_agentId}");

    if (_agentId == null) {

      log('⚠️ agentId is null. Aborting toggle.');
      _showSnackBar(context, 'Agent ID not found. Please login again.');
      return;
    }

    isLoading = true;
    notifyListeners();

    final newState = !isAvailable;
    log('🔁 Changing availability to: ${newState ? 'AVAILABLE' : 'UNAVAILABLE'}');

    try {
      // Check current location permission status
      LocationPermission permission = await Geolocator.checkPermission();
      log('📱 Current permission status: $permission');

      // Handle different permission states
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        log('📱 Permission after request: $permission');
      }

      // Handle permanent denial or denied status
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        log('❌ Location permission denied');
        await _showLocationPermissionDialog(permission, context);
        return;
      }

      // Permission granted, proceed with location fetch
      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      log('📍 Current Position - Lat: ${pos.latitude}, Lng: ${pos.longitude}, Accuracy: ${pos.accuracy}');
      final apiSuccess = await _service.updateAvailability(
        agentId: _agentId!,
        status: newState ? "AVAILABLE" : "UNAVAILABLE",
        lat: pos.latitude,
        lng: pos.longitude,
        accuracy: pos.accuracy,

      );

      if (!apiSuccess) {
        log('❌ API updateAvailability failed');
        _showSnackBar(context, 'Failed to update availability on server');
        return;
      }
      // Delegate full flow to SocketController
      await _socketController.updateAgentAvailability(newState);
      isAvailable = newState;
      await persistAvailability(isAvailable);

      // Update notification immediately
      await _updateNotification();

      log('✅ Updated availability to $isAvailable');

      _showSnackBar(
          context,
          isAvailable ? 'You are now available for orders' : 'You are now offline'
      );

    } catch (e, stackTrace) {
      log('❌ Error during toggleAvailability', error: e, stackTrace: stackTrace);

      // Handle specific location errors
      if (e is LocationServiceDisabledException) {
        await _showLocationServiceDialog(context);
      } else {
        await _showGenericErrorDialog(e.toString(), context);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Show snackbar instead of toast
  void _showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
          backgroundColor: isAvailable ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  // Helper method to show location permission dialog
  Future<void> _showLocationPermissionDialog(LocationPermission permission, BuildContext context) async {
    String message;
    String actionText;
    bool canOpenSettings = false;

    if (permission == LocationPermission.deniedForever) {
      message = 'Location access is permanently denied. Please enable it from app settings to continue.';
      actionText = 'Open Settings';
      canOpenSettings = true;
    } else {
      message = 'Location permission is required to update your availability status.';
      actionText = 'OK';
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('Location Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              if (canOpenSettings) {
                await Geolocator.openAppSettings();
              }
            },
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  // Helper method to show location service dialog
  Future<void> _showLocationServiceDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('Location Service Disabled'),
        content: Text('Please enable location services from device settings to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await Geolocator.openLocationSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Helper method to show generic error dialog
  Future<void> _showGenericErrorDialog(String error, BuildContext context) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Error'),
        content: Text('Failed to update availability: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Simple version without dialogs
  Future<void> toggleAvailabilitySimple(BuildContext context) async {
    if (_agentId == null) {
      log('⚠️ agentId is null. Aborting toggle.');
      return;
    }

    isLoading = true;
    notifyListeners();

    final newState = !isAvailable;
    log('🔁 Changing availability to: ${newState ? 'AVAILABLE' : 'UNAVAILABLE'}');

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        log('❌ Location permission not granted. Availability not updated.');

        _showSnackBar(context,
            permission == LocationPermission.deniedForever
                ? 'Please enable location permission from settings'
                : 'Location permission required to update availability'
        );
        return;
      }

      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      log('📍 Current Position - Lat: ${pos.latitude}, Lng: ${pos.longitude}');

      await _socketController.updateAgentAvailability(newState);
      isAvailable = newState;
      await persistAvailability(isAvailable);

      // Update notification
      await _updateNotification();

      log('✅ Updated availability to $isAvailable');

    } catch (e, stackTrace) {
      log('❌ Error during toggleAvailability', error: e, stackTrace: stackTrace);
      _showSnackBar(context, 'Failed to update availability');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Clear notification when disposing
  @override
  void dispose() {
    _notificationsPlugin.cancel(_notificationId);
    super.dispose();
  }
}