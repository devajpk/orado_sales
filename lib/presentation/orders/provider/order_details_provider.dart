// lib/presentation/screens/home/orders/controller/order_detail_controller.dart
import 'dart:developer';
import 'package:oradosales/presentation/orders/service/order_details_sevice.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/order_details_model.dart';

class OrderDetailController extends ChangeNotifier {
  final OrderDetailsService _service = OrderDetailsService();

  bool isLoading = false;
  OrderDetailsModel? orderDetails;
  // Order? order;
  String? errorMessage;
  String? successMessage;
  Order? get order => orderDetails?.order;
  Future<void> loadOrderDetails(String orderId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final OrderDetailsModel? fetchedDetails = await _service
          .fetchOrderDetails(orderId: orderId, token: token);

      if (fetchedDetails != null) {
        orderDetails = fetchedDetails;
      } else {
        throw Exception('Failed to load order details');
      }
    } catch (e) {
      errorMessage = e.toString();
      log('Error loading order details: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> updateOrderStatus(String status) async {
  debugPrint("🟦 updateOrderStatus() called with status: $status");

  if (order == null) {
    debugPrint("❌ Order is NULL. Exiting...");
    return false;
  }

  isLoading = true;
  notifyListeners();
  debugPrint("🔄 Loading started");

  try {
    debugPrint("📌 Fetching user token...");
    final token = await _getUserToken();
    debugPrint("✅ Token fetched: $token");

    debugPrint("📤 Sending API request to update status...");
    debugPrint("➡️ Payload: orderId=${order!.id}, status=$status");

    final response = await _service.updateDeliveryStatus(
      orderId: order!.id,
      status: status,
      token: token,
    );

    debugPrint("📥 API Response received: $response");

    if (response != null && response.message != null) {
      debugPrint("✅ Success message: ${response.message}");

      successMessage = response.message!;

      debugPrint("🔄 Reloading order details...");
      await loadOrderDetails(order!.id);
      debugPrint("✅ Order details loaded");

      return true;
    }

    debugPrint("⚠️ API returned null or empty message");
    return false;

  } catch (e, st) {
    errorMessage = e.toString();

    debugPrint("❌ Exception occurred: $e");
    debugPrint("📍 Stack Trace: $st");

    log('Status update error: $e');
    return false;

  } finally {
    isLoading = false;
    notifyListeners();
    debugPrint("🟩 Loading finished & listeners notified");
  }
}


  // Future<bool> updateOrderStatus(String status) async {
  //   if (order == null) return false;

  //   isLoading = true;
  //   notifyListeners();

  //   try {
  //     final token = await _getUserToken(); // Extract token logic
  //     final response = await _service.updateDeliveryStatus(
  //       orderId: order!.id,
  //       status: status,
  //       token: token,
  //     );

  //     if (response != null && response.message != null) {
  //       successMessage = response.message!;
  //       await loadOrderDetails(order!.id);
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     errorMessage = e.toString();
  //     log('Status update error: $e');
  //     return false;
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<String> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');
    if (token == null) throw Exception('Authentication token not found');
    return token;
  }

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }
}
