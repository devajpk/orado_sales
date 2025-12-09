// incentive_controller.dart
import 'package:oradosales/presentation/incentive/model/incentive_model.dart';
import 'package:flutter/material.dart';
import '../service/incentive_service.dart';

class IncentiveController extends ChangeNotifier {
  final IncentiveService _service = IncentiveService();

  IncentiveSummaryModel? incentiveData;
  List<IncentivePlan> incentivePlans = [];
  bool isLoading = false;

  Future<void> loadIncentive(String type) async {
    isLoading = true;
    notifyListeners();

    final result = await _service.fetchIncentiveSummary(type.toLowerCase());
    incentiveData = result;
    incentivePlans.addAll(result?.incentivePlans??[]);

    isLoading = false;
    notifyListeners();
  }
}
