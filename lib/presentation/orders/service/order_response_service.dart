// agent_order_response_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oradosales/presentation/orders/model/order_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AgentOrderResponseService {                                             
  final String baseUrl = "https://orado-backend.onrender.com";

  Future<OrderResponseModel> respondToOrder({
  required String orderId,
  required String action,
  String? reason,
}) async {
  debugPrint("🟦 respondToOrder() called");
  debugPrint("➡️ Order ID: $orderId");
  debugPrint("➡️ Action: $action");
  if (reason != null) debugPrint("➡️ Reason: $reason");

  // Read token
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('userToken') ?? '';

  debugPrint("🔐 Token: $token");

  final url = Uri.parse("$baseUrl/agent/agent-order-response/$orderId");
  debugPrint("🌐 URL: $url");

  final payload = {
    "action": action,
    if (reason != null) "reason": reason,
  };
  debugPrint("📌 Request Payload: $payload");

  final headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };
  debugPrint("📌 Request Headers: $headers");

  try {
    debugPrint("📤 Sending PUT request...");

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    debugPrint("📥 Response received");
    debugPrint("🔹 Status Code: ${response.statusCode}");
    debugPrint("🔹 Response Body Raw: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        debugPrint("📌 Parsed JSON: $jsonData");

        final parsed = OrderResponseModel.fromJson(jsonData);
        debugPrint("✅ Parsed model: $parsed");

        return parsed;
      } catch (e, st) {
        debugPrint("❌ JSON Parsing Error: $e");
        debugPrint("📍 Stack Trace: $st");
        throw Exception("JSON Parse Failure: $e");
      }
    } else {
      debugPrint("❌ API Error");
      debugPrint("🔹 Code: ${response.statusCode}");
      debugPrint("🔹 Body: ${response.body}");
      throw Exception("Failed to respond: ${response.body}");
    }

  } catch (e, st) {
    debugPrint("❌ Network/Unknown error: $e");
    debugPrint("📍 Stack Trace: $st");
    throw Exception("Respond API Failed: $e");
  }
}

}
