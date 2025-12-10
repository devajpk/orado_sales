import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:battery_plus/battery_plus.dart';
import 'package:oradosales/presentation/socket_io/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../services/navigation_service.dart';
import '../../widgets/countdownTimerWidget.dart';
import '../orders/model/new_order_model.dart';
import '../orders/model/order_response_model.dart';
import '../orders/service/order_response_service.dart';
import '../orders/view/order_details_screen.dart';
import 'package:http/http.dart'as http;

@pragma('vm:entry-point')
class SocketController extends ChangeNotifier {
  static SocketController? _instance;
  static SocketController get instance => _instance ??= SocketController._internal();

  SocketController._internal();

  final SocketService _socketService = SocketService();
  Timer? _singleLocationTimer;
  bool _isConnected = false;
  bool _isAvailable = false;
  String? _currentAgentId;
  bool _isInBackground = false;
  bool _isLocationServiceInitialized = false;

  bool get isConnected => _isConnected;
  bool get isAvailable => _isAvailable;
  Map<String, dynamic>? latestOrderEvent;


  Future<void> initializeApp() async {
    if (_isLocationServiceInitialized) return;

    try {
      _isLocationServiceInitialized = true;
      await _loadAvailabilityStatus();
      // await setupBackgroundService();
      log('Socket controller initialization completed successfully');
    } catch (e) {
      log('Error initializing socket controller: $e');
      // Don't rethrow - allow app to continue even if socket init fails
    }
  }

  Future<void> _loadAvailabilityStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAvailable = prefs.getBool('agent_available') ?? false;
      notifyListeners();
      log('Loaded availability status: $_isAvailable');
    } catch (e) {
      log('Error loading availability status: $e');
      _isAvailable = false;
      notifyListeners();
    }
  }

  Future<void> setupBackgroundService() async {
    try {
      final service = FlutterBackgroundService();

      await service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: onBackgroundStart,
          autoStart: true, // Changed to true
          isForegroundMode: true,
          notificationChannelId: 'location_service',
          initialNotificationTitle: 'Orado Delivery',
          initialNotificationContent: 'Tracking location in background',
          foregroundServiceNotificationId: 888,
        ),
        iosConfiguration: IosConfiguration(
          autoStart: true, // Changed to true
          onForeground: onBackgroundStart,
        ),
      );

      log('Background service configured successfully');
    } catch (e) {
      log('Background service setup error: $e');
    }
  }

  @pragma('vm:entry-point')
  static void onBackgroundStart(ServiceInstance service) async {
    try {
      log('🚀 Background service started');

      // Ensure Flutter bindings are initialized
      WidgetsFlutterBinding.ensureInitialized();
      DartPluginRegistrant.ensureInitialized();

      if (service is AndroidServiceInstance) {
        service.setAsForegroundService();
        // service.setForegroundNotificationInfo(
        //
        //   title: "Orado Delivery",
        //   content: "Tracking your location in background",
        //
        //
        //
        // );
        log('📱 Foreground service notification set');
      }

      // Listen to stop event
      service.on('stopService').listen((event) {
        log('🛑 Stopping background service');
        service.stopSelf();
      });

      // Add initial delay to ensure everything is initialized
      await Future.delayed(Duration(seconds: 2));

      // Create periodic timer for background location updates
      Timer.periodic(Duration(seconds: 10), (timer) async {
        try {
          log('⏰ Background timer tick');

          final prefs = await SharedPreferences.getInstance();
          final agentId = prefs.getString('agentId');
          final isAvailable = prefs.getBool('agent_available') ?? false;

          log('🔍 AgentId: $agentId, Available: $isAvailable');

          if (agentId != null && isAvailable) {
            try {
              // Check location permission
              bool permissionGranted = await _checkLocationPermission();
              if (!permissionGranted) {
                log('❌ Location permission denied');
                return;
              }

              log('📍 Getting current position...');

              // Get current position with proper error handling
              final position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
                timeLimit: Duration(seconds: 15), // Increased timeout
              ).timeout(
                Duration(seconds: 20),
                onTimeout: () {
                  throw TimeoutException('Location request timeout', Duration(seconds: 20));
                },
              );

              log('✅ Position obtained: ${position.latitude}, ${position.longitude}');

              // Get device info
              final deviceInfo = await _getDeviceInfo();

              // Prepare API request
              final apiUrl = 'https://orado-backend.onrender.com/agent/$agentId/update-location';


              final requestBody = {
                "lat": position.latitude,
                "lng": position.longitude,
                "deviceInfo": deviceInfo
              };

              log('🌐 Sending location to API...');
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('userToken');
              // Make HTTP request with proper error handling
              final response = await http.post(
                Uri.parse(apiUrl),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: jsonEncode(requestBody),
              ).timeout(Duration(seconds: 15));

              log('📡 API Response: ${response.statusCode}');
              log('📄 Response body: ${response.body}');

              // Update notification with current status
              // if (service is AndroidServiceInstance) {
              //   service.setForegroundNotificationInfo(
              //     title: "Orado Delivery - Active",
              //     content: "Last update: ${DateTime.now().toString().substring(11, 19)}",
              //   );
              // }

              // Store last background call timestamp
              await prefs.setString('lastBackgroundCall', DateTime.now().toIso8601String());

            } catch (e) {
              log('❌ Background location/API error: $e');

              // Update notification with error status
              // if (service is AndroidServiceInstance) {
              //   service.setForegroundNotificationInfo(
              //     title: "Orado Delivery - Error",
              //     content: "Location update failed: ${DateTime.now().toString().substring(11, 19)}",
              //   );
              // }
            }
          } else {
            log('⚠️ Agent not available or ID missing');

            // Update notification for unavailable status
            // if (service is AndroidServiceInstance) {
            //   service.setForegroundNotificationInfo(
            //     title: "Orado Delivery - Inactive",
            //     content: "Agent not available",
            //   );
            // }
          }
        } catch (e) {
          log('💥 Background timer error: $e');
        }
      });

      log('✅ Background service timer started');

    } catch (e) {
      log('💥 Background service start error: $e');
    }
  }

  // Helper function to get device info
  @pragma('vm:entry-point')
  static Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      final battery = Battery();
      int batteryLevel = await battery.batteryLevel.timeout(Duration(seconds: 5));

      return {
        "batteryLevel": batteryLevel,
        "model": "Android Device", // You can get actual model if needed
        "os": "Android",
        "osVersion": Platform.operatingSystemVersion,
        "appVersion": "1.0.0",
        "isRooted": false,
        "locationEnabled": true,
        "networkType": "Mobile", // You can detect actual network type if needed
        "timezone": DateTime.now().timeZoneName
      };
    } catch (e) {
      log('⚠️ Device info error: $e');
      return {
        "batteryLevel": 50, // Default value
        "model": "Android Device",
        "os": "Android",
        "osVersion": "Unknown",
        "appVersion": "1.0.0",
        "isRooted": false,
        "locationEnabled": true,
        "networkType": "Mobile",
        "timezone": "Asia/Kolkata"
      };
    }
  }

  // Helper function to check location permission
  @pragma('vm:entry-point')
  static Future<bool> _checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        log('❌ Location permission denied forever');
        return false;
      }

      // For Android, request background location if only foreground is granted
      if (Platform.isAndroid && permission == LocationPermission.whileInUse) {
        // Note: Background location permission needs to be requested from UI
        log('⚠️ Only foreground location permission granted');

      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log('❌ Location service is disabled');
        return false;
      }

      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      log('❌ Permission check error: $e');
      return false;
    }
  }



  Future<void> connectSocket({bool isAppResume = false}) async {
    if (_isConnected && !isAppResume) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('agentId');

      if (userId == null || userId.isEmpty) {
        log('Agent ID not found');
        return;
      }

      _currentAgentId = userId;

      if (isAppResume && _socketService.instance != null) {
        _socketService.disconnect();
        await Future.delayed(Duration(milliseconds: 500));
      }

      await _socketService.connect(
        userId: userId,
        userType: 'agent',
        onConnect: () {
          _isConnected = true;
          notifyListeners();
          log('Socket connected successfully');
          if (_isAvailable) {
            _startSingleLocationTimer();
          }
        },
        onNewOrder: (data) {
          log('new order assigned: $data');
  
          final orderDetails = OrderPayload.fromJson(data);
          log("===========${orderDetails}");
          _showOrderBottomSheet(orderDetails);
        },
        onDisconnect: () {
          _isConnected = false;
          _stopLocationTimer();
          notifyListeners();
          log('Socket disconnected');
          if (!_isConnected) {
            Timer(Duration(seconds: 5), () => connectSocket(isAppResume: true));
          }
        },
        onError: (error) {
          _isConnected = false;
          _stopLocationTimer();
          notifyListeners();
          log('Socket error: $error');
        },
        onOrderAssigned: (data) async {
          log('Order assigned: $data');
          notifyListeners();
        },
      );
    } catch (e) {
      _isConnected = false;
      _stopLocationTimer();
      notifyListeners();
      log('Socket connection error: $e');
    }
  }

  Future<void> handleAppPause() async {
    log('📱 App paused - starting background service');
    _isInBackground = true;
    _stopLocationTimer();

    if (_isAvailable) {
      await _startBackgroundService();
    }
  }

  Future<void> handleAppResume() async {
    log('📱 App resumed - stopping background service');
    _isInBackground = false;

    await _stopBackgroundService();

    if (!_isConnected) {
      await connectSocket(isAppResume: true);
    } else if (_isAvailable) {
      _startSingleLocationTimer();
    }
  }

  Future<void> _startBackgroundService() async {
    try {
      final service = FlutterBackgroundService();
      bool isRunning = await service.isRunning();

      if (!isRunning) {
        await service.startService();
        log('✅ Background service started');
      } else {
        log('⚠️ Background service already running');
      }
    } catch (e) {
      log('❌ Background service start error: $e');
    }
  }

  Future<void> _stopBackgroundService() async {
    try {
      final service = FlutterBackgroundService();
      bool isRunning = await service.isRunning();

      if (isRunning) {
        service.invoke("stopService");
        log('🛑 Background service stopped');
      }
    } catch (e) {
      log('❌ Background service stop error: $e');
    }
  }
  Map<String, dynamic> getDummyOrderPayload() {
    return {
      "orderDetails": {
        "id": "68d37800ba4d902b1a8500bb",
        "totalPrice": 272,
        "deliveryAddress": {
          "street": "Nana Varachha Flyover, 395006, Nana Varachha, Surat, Surat, Gujarat, India",
          "area": "Mota varachhaa",
          "city": "Surat",
          "state": "Gujarat",
          "country": "India"
        },
        "deliveryLocation": {
          "lat": 21.222056042754232,
          "long": 72.89053706587003
        },
        "createdAt": "2025-09-24T04:48:00.101Z",
        "paymentMethod": "cash",
        "orderItems": [
          {"name": "Fried Rice", "qty": 0, "price": 140}
        ],
        "estimatedEarning": 0,
        "distanceKm": 2.03,
        "customer": {
          "name": "testernew",
          "phone": "7546258465",
          "email": "testernew@gmail.com"
        },
        "restaurant": {
          "name": "Urban Tandoor",
          "address": {
            "street": "Canal Corridor, Punagam, 395006, Varachha, Surat, Surat, Gujarat, India",
            "city": "Surat",
            "state": "Gujarat"
          },
          "location": {
            "lat": 21.206541909001132,
            "long": 72.88020384721256
          }
        }
      },
      "allocationMethod": "manual_assignment",
      "requestExpirySec": 30,
      "showAcceptReject": false
    };
  }

  // Single location timer for both foreground and background
  void _startSingleLocationTimer() {
    _stopLocationTimer(); // Always stop existing timer first

    if (!_isAvailable) return;

    _singleLocationTimer = Timer.periodic(Duration(seconds: 8), (timer) async {
      if (!_isConnected || !_isAvailable) {
        timer.cancel();
        return;
      }

      try {
        await _safeLocationUpdate();
      } catch (e) {
        log('Location update error: $e');
        // Don't cancel timer, just log error
      }
    });

    log('Single location timer started');
  }

  Future<void> _safeLocationUpdate() async {
    if (_currentAgentId == null) return;

    try {
      // Check basic requirements
      bool hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        log('No location permission');
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log('Location service disabled');
        return;
      }

      if (_socketService.instance?.connected != true) {
        log('Socket not connected');
        return;
      }

      // Get location with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 8),
      ).timeout(Duration(seconds: 10));

      // Emit location
      _socketService.emitAgentLocation(
        agentId: _currentAgentId!,
        lat: position.latitude,
        lng: position.longitude,
        deviceInfo: await _getBasicDeviceInfo(_currentAgentId!),
      );

      _socketService.instance?.emit('agentStatusUpdate', {
        'agentId': _currentAgentId,
        'availabilityStatus': 'available',
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      });

      log('Location updated: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      log('Safe location update error: $e');
    }
  }

  void _stopLocationTimer() {
    _singleLocationTimer?.cancel();
    _singleLocationTimer = null;
  }

  bool isLoading=false;

  final AgentOrderResponseService _service = AgentOrderResponseService();
  OrderResponseModel? response;
  Future<void> respond(String orderId, String action) async {
    isLoading = true;
    // error = null;
    notifyListeners();

    try {
      response = await _service.respondToOrder(
        orderId: orderId,
        action: action,
      );
    } catch (e) {
      log("Order Acc${e}");
      // error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  final AudioPlayer player = AudioPlayer();
  Future<void> _showOrderBottomSheet(OrderPayload order) async {
    if (NavigationService.navigatorKey.currentContext == null) return;

    // Play notification sound

    try {
      await player.setAsset("asstes/sounds/positive-notification-digital-strum-fast-gamemaster-audio-1-1-00-03.mp3"); // Correct path

      await player.play(); // Start playback
    } catch (e) {
      print("Audio play error: $e");
    }

    showModalBottomSheet(
      context: NavigationService.navigatorKey.currentContext!,
      isScrollControlled: true,
      enableDrag: false,
      showDragHandle: false,

      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.6,
          minChildSize: 0.5,

          expand: false,
          builder: (context, scrollController) {


            return Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(top: 8, bottom: 16),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Header
                          Text(
                            'New Order Assigned!',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          SizedBox(height: 8),

                          // Status chip
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Color(0xFF4CAF50), borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              'ORDER • PICKUP • DROP',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.5),
                            ),
                          ),
                          SizedBox(height: 12),

                          // Earnings section
                          Text(
                            'PICKUP EARNINGS',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2),

                          Text(
                            '₹${order.orderDetails.estimatedEarning}',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                          ),

                          Text('${order.orderDetails.distanceKm} kms', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          SizedBox(height: 16),
                          // Pickup Details section
                          Text(
                            'PICKUP DETAILS',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 12),

                          // Restaurant items
                          Container(
                            child: Column(
                              children: [
                                // First restaurant
                                ...List.generate(
                                  order.orderDetails.orderItems.length,
                                      (index) => Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(color: Colors.grey[800], shape: BoxShape.circle),
                                        child: Icon(Icons.restaurant, color: Colors.white, size: 18),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '${order.orderDetails.orderItems[index].name}- ₹${order.orderDetails.orderItems[index].price}',
                                          style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          // Locations section
                          Column(
                            children: [
                              // Pickup location
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(color: Color(0xFF2196F3), shape: BoxShape.circle),
                                    child: Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 18),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${order.orderDetails.restaurant.address.street}',
                                          style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 12),

                              // Drop location
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                                    child: Icon(Icons.home, color: Colors.white, size: 18),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${order.orderDetails.deliveryAddress.street}',
                                          style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 24),
                          Center(child: SizedBox(height: 50, child: CountdownTimerWidget(initialSeconds: order.requestExpirySec))),

                          SizedBox(height: 20),

                          // Conditional buttons based on showAcceptReject flag
                          if (order.showAcceptReject == true) ...[
                            // Accept/Reject buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      respond(order.orderDetails.id,"reject");
                                      // Handle reject action
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[100],
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Reject',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      respond(order.orderDetails.id,"accept");

                                      // Handle accept action
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF4CAF50),
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Accept',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            // View Order Details Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {


                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                          OrderDetailsBottomSheet(orderId: order.orderDetails.id,onStartPressed: () {
                                            
                                          }, ),
                                    ),
                                  );                                  // Navigator.pop(context);
                                  // Navigate to order details page if needed
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFF9800),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'View Order Details',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                ),
                              ),
                            ),
                          ],

                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Future<void> updateAgentAvailability(bool isAvailable) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final agentId = prefs.getString('agentId');

      if (agentId == null) {
        log('Agent ID not found');
        return;
      }

      _isAvailable = isAvailable;
      await prefs.setBool('agent_available', isAvailable);

      if (isAvailable) {
        _startSingleLocationTimer();
        if (_isInBackground) {
          _startBackgroundService();
        }
      } else {
        _stopLocationTimer();
        await _stopBackgroundService();
      }

      notifyListeners();
      log('Availability updated: ${isAvailable ? "AVAILABLE" : "UNAVAILABLE"}');

    } catch (e) {
      log('Availability update error: $e');
    }
  }


  void disconnectSocket() {
    _stopLocationTimer();
    _stopBackgroundService();
    _socketService.disconnect();
    _isConnected = false;
    notifyListeners();
  }

  // Simplified device info
  Future<Map<String, dynamic>> _getBasicDeviceInfo(String agentId) async {
    try {
      final battery = Battery();
      int batteryLevel = await battery.batteryLevel;

      return {
        "agent": agentId,
        "batteryLevel": batteryLevel,
        "timestamp": DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {"agent": agentId};
    }
  }

  @override
  void dispose() {
    _stopLocationTimer();
    _stopBackgroundService();
    _socketService.disconnect();
    super.dispose();
  }

  io.Socket? get socket => _socketService.instance;
}