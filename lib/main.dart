import 'package:oradosales/presentation/earnings/provider/earnings_controller.dart';
import 'package:oradosales/presentation/incentive/controller/incentive_controller.dart';
import 'package:oradosales/presentation/leave/controller/leave_controller.dart';
import 'package:oradosales/presentation/letters/controller/letter_controller.dart';
import 'package:oradosales/presentation/mileston/controller/milestone_controller.dart';
import 'package:oradosales/presentation/notification_fcm/controller/notification_get_controlller.dart';
import 'package:oradosales/presentation/notification_fcm/service/fcm_service.dart';
import 'package:oradosales/presentation/auth/provider/login_reg_provider.dart';
import 'package:oradosales/presentation/auth/provider/upload_selfi_controller.dart';
import 'package:oradosales/presentation/auth/provider/user_provider.dart';
import 'package:oradosales/presentation/home/home/provider/home_provider.dart';
import 'package:oradosales/presentation/orders/provider/order_details_provider.dart';
import 'package:oradosales/presentation/orders/provider/order_provider.dart';
import 'package:oradosales/presentation/orders/provider/order_response_controller.dart';
import 'package:oradosales/presentation/home/home/provider/available_provider.dart';
import 'package:oradosales/presentation/home/home/provider/drawer_controller.dart';
import 'package:oradosales/presentation/socket_io/socket_controller.dart';
import 'package:oradosales/presentation/splash_Screen/splash_screen.dart';
import 'package:oradosales/presentation/user/controller/user_controller.dart';
import 'package:oradosales/services/api_services.dart';
import 'package:oradosales/services/app_life_cycle_handler.dart';
import 'package:oradosales/services/navigation_service.dart';
import 'package:oradosales/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:developer';


void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase with error handling
    try {
      await Firebase.initializeApp();
      log('Firebase initialized successfully');
    } catch (e) {
      log('Error initializing Firebase: $e');
      // Continue without Firebase if it fails
    }

    // Set up error handling
    FlutterError.onError = (errorDetails) {
      log('Flutter error: ${errorDetails.exception}');
      try {
        FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      } catch (e) {
        log('Error reporting to Crashlytics: $e');
      }
    };

    // Initialize shared preferences
    SharedPreferences sharedPreferences;
    try {
      sharedPreferences = await SharedPreferences.getInstance();
      log('SharedPreferences initialized');
    } catch (e) {
      log('Error initializing SharedPreferences: $e');
      sharedPreferences = await SharedPreferences.getInstance();
    }

    // Set up API token if available
    var token = sharedPreferences.getString("token");
    if (token != null) {
      APIServices.headers.addAll({'Authorization': 'Bearer $token'});
      log('API token loaded');
    } else {
      log('No API token found');
    }

    // Initialize socket controller with error handling
    final socketController = SocketController.instance;
    try {
      await socketController.initializeApp();
      log('Socket controller initialized');
    } catch (e) {
      log('Error initializing socket controller: $e');
      // Continue without socket if it fails
    }

    // Initialize agent controller
    final agentAvailableController = AgentAvailableController(socketController);

  // Initialize FCM with error handling
  final fcmHandler = FCMHandler();
  try {
    await fcmHandler.initialize();
    log('FCM initialized successfully');
  } catch (e) {
    log('Error initializing FCM: $e');
    // Continue without FCM if it fails
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(create: (_) => AuthController()),
        ChangeNotifierProvider<EarningsController>(create: (_) => EarningsController()),
        ChangeNotifierProvider<AgentHomeProvider>(create: (_) => AgentHomeProvider()),
        ChangeNotifierProvider<AgentProvider>(create: (_) => AgentProvider()),
        ChangeNotifierProvider<DrawerProvider>(create: (_) => DrawerProvider()),
        ChangeNotifierProvider<AgentAvailableController>.value(value: agentAvailableController),
        // Use singleton instance here too
        ChangeNotifierProvider<SocketController>.value(value: socketController),
        ChangeNotifierProvider<OrderController>(create: (_) => OrderController()),
        ChangeNotifierProvider<MilestoneController>(create: (_) => MilestoneController()),
        ChangeNotifierProvider<OrderDetailController>(create: (_) => OrderDetailController()),
        ChangeNotifierProvider<NotificationController>(create: (_) => NotificationController()),
        ChangeNotifierProvider<AgentOrderResponseController>(create: (_) => AgentOrderResponseController()),
        ChangeNotifierProvider<SelfieUploadController>(create: (_) => SelfieUploadController()),
        ChangeNotifierProvider<LetterController>(create: (_) => LetterController()),
        ChangeNotifierProvider<LeaveController>(create: (_) => LeaveController()),
        ChangeNotifierProvider(create: (_) => AgentProfileController()),
        ChangeNotifierProvider(create: (_) => IncentiveController()),

      ],
      child: const MyApp(),
    ),
  );

  // Initialize NotificationService after UI renders
  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      NotificationService.initialize(NavigationService.navigatorKey.currentContext!);
      log('NotificationService initialized');
    } catch (e) {
      log('NotificationService initialization error: $e');
      // Continue without notification service if it fails
    }
  });
  } catch (e) {
    // Global error handler for main initialization
    print('Critical error during app initialization: $e');
    // Still try to run the app with minimal functionality
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text('Error initializing app')))));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use singleton instance consistently
    final socketController = SocketController.instance;

    return MaterialApp(
      title: 'ORADO Delivery',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      home: AppLifecycleWrapper(
          socketController: socketController,
          child: SplashScreen()
      ),
      theme: ThemeData(useMaterial3: true),
    );}}