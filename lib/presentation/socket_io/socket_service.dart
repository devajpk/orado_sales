import 'dart:convert';
import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;

  io.Socket? get instance => _socket;

  Future<void> connect({
    required String userId,
    required String userType,
    Function(Map<String, dynamic> data)? onNewOrder, // New callback for order:new
    Function(dynamic data)? onOrderAssigned,
    Function()? onConnect,
    Function()? onDisconnect,
    Function(dynamic error)? onError,
  }) async {
    try {
      final url = 'https://orado-backend.onrender.com';

      _socket = io.io(
        url,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
        // NEW: Enhanced reconnection settings
            .setReconnectionDelay(1000)    // Wait 1 second before reconnecting
            .setReconnectionAttempts(5)    // Try 5 times
            .setTimeout(20000)             // 20 second timeout
            .build(),
      );

      _socket!.onAny((event, data) {
        log('Received event: $event with data: $data');
      });
      // Your existing onConnect handler - enhanced
      _socket!.onConnect((_) {
        log('✅ Connected to socket server');

        _socket!.emit('join-room', {'userId': userId, 'userType': userType});
        log('📢 Emitted join-room for userId: $userId, userType: $userType');
        onConnect?.call();
      });


      _socket!.on('order:new', (data) {
        Map<String, dynamic> orderData;

        if (data is String) {
          orderData = jsonDecode(data);
        } else if (data is Map) {
          orderData = Map<String, dynamic>.from(data);
        } else {
          log('⚠️ Unknown data type: ${data.runtimeType}');
          return;
        }

        log('📦 New order received: $orderData');
        onNewOrder?.call(orderData);
      });
      // _socket!.on('order:new', (data) {
      //   log('📦 New order received: $data');
      //   onNewOrder?.call(data);
      // });
      // Your existing onDisconnect handler - enhanced with reason
      _socket!.onDisconnect((reason) {
        log('❌ Disconnected from socket server. Reason: $reason');
        onDisconnect?.call();

      });

      // Your existing onError handler (unchanged)
      _socket!.onError((error) {
        log('⚠️ Socket error: $error');
        onError?.call(error);
      });

      // NEW: Additional reconnection event handlers
      _socket!.onReconnect((data) {
        log('🔄 Socket reconnected successfully');
        // Re-join room after reconnection
        _socket!.emit('join-room', {'userId': userId, 'userType': userType});
      });

      _socket!.onReconnectError((data) {
        log('❌ Socket reconnection error: $data');
      });

      _socket!.onReconnectAttempt((data) {
        log('🔄 Socket reconnection attempt: $data');
      });

      // Your existing order assignment listener (unchanged)
      _socket!.on('orderAssigned', (data) {
        log('📦 New order assigned: $data');
        onOrderAssigned?.call(data);
      });

      _socket!.connect();
    } catch (e) {
      throw Exception('Socket connection error: $e');
    }
  }

  // Your existing emitAgentLocation - enhanced with timestamp
  void emitAgentLocation({
    required String agentId,
    required double lat,
    required double lng,
    required Map<String, dynamic> deviceInfo,
  }) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('agent:location', {
        'agentId': agentId,
        'lat': lat,
        'lng': lng,
        'timestamp': DateTime.now().toIso8601String(), // NEW: Add timestamp
        'deviceInfo': deviceInfo,
      });
      log(
        '📍 Emitted agent:location => agentId: $agentId, lat: $lat, lng: $lng',
      );
    } else {
      log('⚠️ Socket not connected. Cannot emit agent location.');
    }
  }

  // NEW: Check if socket is connected
  bool get isConnected => _socket?.connected ?? false;

  // NEW: Manually trigger reconnect
  Future<void> reconnect() async {
    if (_socket != null) {
      _socket!.connect();
    }
  }

  // NEW: Emit agent available (for availability toggle)
  void emitAgentAvailable({
    required String agentId,
    required double lat,
    required double lng,
  }) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('agentAvailable', {
        'agentId': agentId,
        'location': {
          'type': 'Point',
          'coordinates': [lng, lat],
        },
        'timestamp': DateTime.now().toIso8601String(),
      });
      log('✅ Emitted agentAvailable => agentId: $agentId');
    } else {
      log('⚠️ Socket not connected. Cannot emit agent available.');
    }
  }

  // NEW: Emit agent unavailable
  void emitAgentUnavailable({required String agentId}) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('agentUnavailable', {
        'agentId': agentId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      log('❌ Emitted agentUnavailable => agentId: $agentId');
    } else {
      log('⚠️ Socket not connected. Cannot emit agent unavailable.');
    }
  }

  // Your existing disconnect (unchanged)
  void disconnect() {

    _socket?.disconnect();
    _socket = null;
    log('🔌 Socket disconnected manually.');
  }
}