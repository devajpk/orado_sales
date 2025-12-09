// lib/presentation/screens/home/orders/service/order_details_service.dart
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:oradosales/presentation/orders/model/agent_delivery_status_model.dart';
import 'package:http/http.dart' as http;
import '../model/order_details_model.dart';

class OrderDetailsService {
  Future<OrderDetailsModel?> fetchOrderDetails({
    required String orderId,
    required String token,
  }) async {
    final url = Uri.parse(
      'https://orado-backend.onrender.com/agent/assigned-orders/$orderId',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      log(
        'Order Details API Response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == "success") {
          return OrderDetailsModel.fromJson(data);
        } else {
          log('API returned non-success status: ${data['message']}');
        }
      } else {
        log('Failed with status code: ${response.statusCode}');
        throw Exception('Failed to load order details: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching order details: $e');
      throw Exception('Failed to load order details: $e');
    }
    return null;
  }

  // Add this method to your OrderDetailsService class
  Future<UpdateStatusResponse?> updateDeliveryStatus({
  required String orderId,
  required String status,
  required String token,
}) async {
  final url = Uri.parse(
    'https://orado-backend.onrender.com/agent/agent-delivery-status/$orderId',
  );

  debugPrint("🟦 updateDeliveryStatus() called");
  debugPrint("➡️ URL: $url");
  debugPrint("➡️ Status to update: $status");
  debugPrint("➡️ Order ID: $orderId");
  debugPrint("➡️ Token: $token");

  try {
    debugPrint("📤 Sending PUT request...");
    debugPrint("📌 Headers: ${{
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    }}");
    debugPrint("📌 Body: ${json.encode({'status': status})}");

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({'status': status}),
    );

    debugPrint("📥 Response received");
    debugPrint("🔹 Status Code: ${response.statusCode}");
    debugPrint("🔹 Response Body: ${response.body}");

    log('API Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      debugPrint("✅ API Success - Parsing JSON");

      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        debugPrint("📌 Parsed JSON: $data");

        final parsed = UpdateStatusResponse.fromJson(data);
        debugPrint("✅ JSON converted to model: $parsed");

        return parsed;

      } catch (e, st) {
        debugPrint("❌ JSON parsing error: $e");
        debugPrint("📍 Stack Trace: $st");
        throw Exception('Failed to parse response: $e');
      }

    } else {
      debugPrint("❌ API Error - Code: ${response.statusCode}");
      debugPrint("❗ Body: ${response.body}");
      throw Exception('API Error: ${response.statusCode}');
    }

  } catch (e, st) {
    debugPrint("❌ Network error: $e");
    debugPrint("📍 Stack Trace: $st");
    log('Network error: $e');
    rethrow;
  }
}


  //   Future<bool> updateOrderStatus({
  //     required String orderId,
  //     required String status,
  //     required String token,
  //   }) async {
  //     final url = Uri.parse(
  //       'https://orado-backend.onrender.com/agent/agent-delivery-status/$orderId',
  //     );

  //     try {
  //       final response = await http.put(
  //         url,
  //         headers: {
  //           'Authorization': 'Bearer $token',
  //           'Accept': 'application/json',
  //           'Content-Type': 'application/json',
  //         },
  //         body: json.encode({'status': status}),
  //       );

  //       if (response.statusCode == 200) {
  //         final data = json.decode(response.body);
  //         return data['status'] == "success";
  //       }
  //       return false;
  //     } catch (e) {
  //       log('Error updating order status: $e');
  //       return false;
  //     }
  //   }
}
