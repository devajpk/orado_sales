class IncentiveSummaryModel {
  final String period;
  final double totalEarned;
  final int completedDeliveries;
  final IncentivePlan? highestEligibleIncentive;
  final List<IncentivePlan> incentivePlans;

  IncentiveSummaryModel({
    required this.period,
    required this.totalEarned,
    required this.completedDeliveries,
    required this.highestEligibleIncentive,
    required this.incentivePlans,
  });

  factory IncentiveSummaryModel.fromJson(Map<String, dynamic> json) {
    return IncentiveSummaryModel(
      period: json['period'] ?? '',
      totalEarned: (json['totalEarned'] ?? 0).toDouble(),
      completedDeliveries: json['completedDeliveries'] ?? 0,
      highestEligibleIncentive: json['highestEligibleIncentive'] != null
          ? IncentivePlan.fromJson(json['highestEligibleIncentive'])
          : null,
      incentivePlans: json['incentivePlans'] != null
          ? List<IncentivePlan>.from(
          json['incentivePlans'].map((x) => IncentivePlan.fromJson(x)))
          : [],
    );
  }
}

class IncentivePlan {
  final String id;
  final String name;
  final String description;
  final String period;
  final String conditionType;
  final double minValue;
  final double incentive;
  final double currentValue;
  final double percent;
  final String status;
  final bool highlighted;

  IncentivePlan({
    required this.id,
    required this.name,
    required this.description,
    required this.period,
    required this.conditionType,
    required this.minValue,
    required this.incentive,
    required this.currentValue,
    required this.percent,
    required this.status,
    required this.highlighted,
  });

  factory IncentivePlan.fromJson(Map<String, dynamic> json) {
    return IncentivePlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      period: json['period'] ?? '',
      conditionType: json['conditionType'] ?? '',
      minValue: (json['minValue'] ?? 0).toDouble(),
      incentive: (json['incentive'] ?? 0).toDouble(),
      currentValue: (json['currentValue'] ?? 0).toDouble(),
      percent: (json['percent'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      highlighted: json['highlighted'] != null && json['highlighted'] == true,
    );
  }
}

