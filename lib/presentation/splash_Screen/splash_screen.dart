// lib/presentation/screens/splash_screen.dart
import 'dart:async';
import 'dart:developer';

import 'package:oradosales/presentation/auth/provider/user_provider.dart';
import 'package:oradosales/presentation/auth/service/selfi_status_service.dart';
import 'package:oradosales/presentation/auth/view/selfi_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oradosales/presentation/home/main_screen.dart';
import 'package:oradosales/presentation/auth/view/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    
    // Set a timeout to ensure we don't get stuck on splash screen
    // _timeoutTimer = Timer(const Duration(seconds: 3), () {
    //   if (mounted) {
    //     log("Splash screen timeout reached, forcing navigation to login");
    //     Navigator.of(context).pushReplacement(
    //       MaterialPageRoute(builder: (_) => const LoginScreen())
    //     );
    //   }
    // });
  }
  
  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    try {
      log("Starting auth status check");
      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString('fcmToken') ?? '';
      log("FCM token: ${fcmToken.isEmpty ? 'not found' : 'exists'}");

      final authController = context.read<AuthController>();
      await Future.delayed(Duration.zero);

      log("Auth token: ${authController.token != null ? 'exists' : 'null'}");
      
      if (authController.token != null) {
        try {
          final selfieStatus = await SelfieStatusService().fetchSelfieStatus();
          log("Selfie status: ${selfieStatus?.selfieRequired}");

          if (mounted) {
            if (selfieStatus?.selfieRequired == true) {
              log("Navigating to selfie screen");
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const UploadSelfieScreen()));
            } else {
              log("Navigating to main screen");
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
            }
          }
        } catch (e) {
          log("Error checking selfie status: $e");
          // If selfie check fails, default to main screen
          if (mounted) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
          }
        }
      } else {
        log("No auth token, navigating to login");
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
        }
      }
    } catch (e) {
      log("Error in auth check: $e");
      // Fallback to login screen if anything fails
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.asset('asstes/oradoLogo.png', width: double.infinity, height: double.infinity)));
  }
}
