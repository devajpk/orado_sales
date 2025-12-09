// incentive_service.dart
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/milestone_model.dart';

class MilestoneService  {
  final String baseUrl = 'https://orado-backend.onrender.com';

  Future<MileStoreRewardsModel?> fetchMilestonesStore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken') ?? '';
      final agentId = prefs.getString('agentId');

      final url = '$baseUrl/agent/$agentId/milestones';


      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      log('Response status For Milestones: ${response.statusCode}');
      log('Response body For Milestones:: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MileStoreRewardsModel.fromJson(data);
      } else {
        log('Failed to load incentive summary: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error fetching incentive summary: $e');
      return null;
    }
  }
}
