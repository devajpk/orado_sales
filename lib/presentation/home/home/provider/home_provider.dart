import 'dart:developer';
import 'package:oradosales/presentation/home/home/model/cod_history_model.dart';
import 'package:oradosales/presentation/home/home/model/cod_model.dart';
import 'package:oradosales/presentation/home/home/model/home_model.dart';
import 'package:oradosales/presentation/home/home/service/home_service.dart';
import 'package:flutter/material.dart';
import 'package:oradosales/services/api_services.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../services/navigation_service.dart';
import '../../../orders/model/new_order_model.dart';
import '../model/cod_submit_model.dart'; // Create this model as previously shared

class AgentHomeProvider with ChangeNotifier {
  final AgentHomeService apiServices = AgentHomeService();

  bool isLoading = false;
  AgentHomeModel? homeData;
  AgentHomeProvider(){
    // Call async method properly - don't await in constructor
    Future.microtask(() => getDashboardData());
  }

  int cancelledOrders = 0;
  int totalOrders = 0;
  AgentCODModel? agentCODModel;
  AgentCODHistoryModel? agentCODHistoryModel;
  List<CODHistory> codHistoryList = [];

  List<Map<String, dynamic>> incentiveGraph = [
    {"period": "Daily", "value": 1200},
    {"period": "Weekly", "value": 2200},
    {"period": "Monthly", "value": 3850},
  ];

  Future<void> loadAgentHomeData() async {
    isLoading = true;
    notifyListeners();

    try {
      homeData = await apiServices.fetchAgentHomeData();
      getDashboardData();
      // If your API also returns cancelledOrders and totalOrders separately,
      // extract them here, otherwise use logic to compute them if needed.

      isLoading = false;
      notifyListeners();
    } catch (error) {
      log("Error loading agent home data: $error");
      isLoading = false;
      notifyListeners();
    }
  }
  void getDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final agentId = prefs.getString('agentId');
      final data = await apiServices.fetchCODData(agentId??"");
      agentCODModel=data;
      log("Current Cash: ${data.currentCashHeld}");
      log("COD Limit: ${data.codLimit}");
    } catch (e) {
      log("Error: $e");
    }
  }
bool istrue=false;
  void getCODHistoryData() async {
    try {
      istrue=true;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final agentId = prefs.getString('agentId');
      log("------${agentId}");
      final data = await apiServices.fetchCODHistory(agentId ?? "");

      agentCODHistoryModel = data;
      // Clear the list before adding to avoid duplicates
      codHistoryList.clear();
      codHistoryList.addAll(data.history ?? []);

      // Safe access
      if (data.history != null && data.history.isNotEmpty) {
      } else {
        log("COD History is empty");
      }
      istrue=false;
      notifyListeners();
    } catch (e) {
      log("Error: $e");
      istrue=false;
      notifyListeners();
    }
  }
bool isSubmit=false;
  Future<void> submitCOD(
      double droppedAmount,
      String dropMethod,
      String dropNotes,

      ) async {
    isSubmit = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final agentId = prefs.getString('agentId') ?? "";

      // API call
      final response = await apiServices.submitCOD(
        agentId: agentId,
        droppedAmount: droppedAmount,
        dropMethod: dropMethod,
        dropNotes: dropNotes,
      );

      Fluttertoast.showToast(msg: response);

    } catch (e) {
      Fluttertoast.showToast(msg: "Error submitting COD: $e");
      debugPrint("Error submitting COD: $e");
    } finally {
      isSubmit = false;
      notifyListeners();
    }
  }



}
