// incentive_controller.dart
import 'package:oradosales/presentation/incentive/model/incentive_model.dart';
import 'package:flutter/material.dart';
import '../model/milestone_model.dart';
import '../service/milestone_service.dart';

class MilestoneController  extends ChangeNotifier {
  final MilestoneService _service = MilestoneService();

  MileStoreRewardsModel? mileStoreRewardsData;
  List<Milestone> mileStoneList  = [];
  bool isLoading = false;

  Future<void> loadMileStone() async {
    isLoading = true;
    notifyListeners();

    final result = await _service.fetchMilestonesStore();
    mileStoreRewardsData = result;
    mileStoneList.addAll(result?.milestoneList??[]);

    isLoading = false;
    notifyListeners();
  }
}
