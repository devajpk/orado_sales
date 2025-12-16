import 'dart:developer';
import 'package:oradosales/presentation/profile_review_screen/profile_review_screen.dart';
import 'package:oradosales/presentation/auth/model/login_model.dart';
import 'package:oradosales/presentation/auth/service/selfi_status_service.dart';
import 'package:oradosales/presentation/auth/view/login.dart';
import 'package:oradosales/presentation/auth/view/selfi_screen.dart';
import 'package:oradosales/presentation/home/main_screen.dart';
import 'package:oradosales/services/device_info_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oradosales/presentation/auth/service/login_reg_service.dart';
import 'package:oradosales/presentation/notification_fcm/service/fcm_service.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class AuthController extends ChangeNotifier {
  final AgentService _agentService = AgentService();
  BuildContext? _context;

  String _message = '';
  String? _token;
  String? _agentId;
  bool _isLoading = false;
  LoginAgent? _agent;
  LoginAgent? get currentAgent => _agent;
  String get message => _message;
  String? get token => _token;
  String? get agentId => _agentId;
  bool get isLoading => _isLoading;

  void setContext(BuildContext context) {
    _context = context;
  }

  AuthController() {
    log('AuthController initialized. Loading stored data...');
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('userToken');
    _agentId = prefs.getString('agentId');
    log(
      'Stored data loaded: Token=${_token != null ? "exists" : "null"}, Agent ID=${_agentId ?? "null"}',
    );
    notifyListeners();
  }

  Future<void> _saveLoginData(String token, String agentId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userToken', token);
    await prefs.setString('agentId', agentId);
    _token = token;
    _agentId = agentId;
    log('Login data saved.');
    notifyListeners();
  }

  Future<void> clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _token = null;
    _agentId = null;
    _message = 'Stored data cleared!';
    log('All SharedPreferences cleared.');
    notifyListeners();
  }

  Future<void> logout() async {
    log('Logout triggered. Preparing to call logout API...');

    try {
      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString('fcmToken') ?? '';
      final token = prefs.getString('userToken') ?? '';

      if (fcmToken.isEmpty || token.isEmpty) {
        log('FCM token or auth token missing, skipping API logout');
      } else {
        await _agentService.logoutAgent(fcmToken: fcmToken, token: token);
        log('Logout successful on server.');
      }
    } catch (e) {
      log('Logout failed, but proceeding with local cleanup.');
    }

    // Local cleanup
    await clearStoredData();
    _message = 'You have been logged out.';

    if (_context != null && _context!.mounted) {
      Navigator.of(_context!).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> login(
    BuildContext context,
    String identifier,
    String password,
  ) async {
    _isLoading = true;
    _message = '';
    notifyListeners();

    try {
      final response = await _agentService.login(identifier, password);
      await _saveLoginData(response.token, response.agent.id);
      _message = response.message;

      // ✅ Navigate first to ensure user sees progress
      if (context.mounted) {
        // Check selfie status
        try {
        final selfieStatus = await SelfieStatusService().fetchSelfieStatus();
        if (selfieStatus?.selfieRequired == true) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const UploadSelfieScreen()),
          );
            // Continue with background tasks after navigation
            _performPostLoginTasks(response.agent.id);
            return;
          }
        } catch (e) {
          log('Error checking selfie status: $e');
          // Continue with navigation even if selfie check fails
        }

        // Navigate to main screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }

      // ✅ Perform background tasks after navigation
      _performPostLoginTasks(response.agent.id);
    } catch (e) {
      _message = e.toString().replaceFirst('Exception: ', '');
      _token = null;
      _agentId = null;
      log('Login failed: $_message');
      await clearStoredData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Perform post-login tasks in background (non-blocking)
  Future<void> _performPostLoginTasks(String agentId) async {
    // Send device info to backend
    try {
      await DeviceInfoService().sendDeviceInfo(agentId);
      log('Device info sent successfully');
    } catch (e) {
      log('Error sending device info: $e');
    }

    // Resend FCM token to server after login (now that agentId is available)
    try {
      await FCMHandler.instance.resendTokenToServer();
      log('FCM token resent to server after login');
    } catch (e) {
      log('Error resending FCM token after login: $e');
      // Don't fail login if FCM token resend fails
    }
  }
}
