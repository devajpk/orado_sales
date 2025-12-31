// agent_order_response_controller.dart
import 'package:oradosales/presentation/orders/model/order_response_model.dart';
import 'package:oradosales/presentation/orders/service/order_response_service.dart';
import 'package:flutter/material.dart';

class AgentOrderResponseController extends ChangeNotifier {
  final AgentOrderResponseService _service = AgentOrderResponseService();

  bool isLoading = false;
  String? error;
  OrderResponseModel? response;

  int? loadingIndex; // 0 = Accept, 1 = Reject

  Future<void> respond(String orderId, String action) async {
    // Prevent multiple taps
    if (isLoading) return;

    loadingIndex = action == "accept" ? 0 : 1;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      response = await _service.respondToOrder(
        orderId: orderId,
        action: action,
      );
      
      // Success - response is set
      isLoading = false;
      loadingIndex = null;
      notifyListeners();
      
    } catch (e) {
      // Error handling
      error = e.toString();
      isLoading = false;
      loadingIndex = null;
      notifyListeners();
    }
  }
    void reset() {
    isLoading = false;
    error = null;
    response = null;
    loadingIndex = null;
    notifyListeners();
  }
}

