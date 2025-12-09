class AgentCODModel {
  final int currentCashHeld;
  final int codLimit;
  final int codUsagePercent;
  final bool limitExceeded;

  AgentCODModel({
    required this.currentCashHeld,
    required this.codLimit,
    required this.codUsagePercent,
    required this.limitExceeded,
  });

  factory AgentCODModel.fromJson(Map<String, dynamic> json) {
    return AgentCODModel(
      currentCashHeld: json['currentCashHeld'] ?? 0,
      codLimit: json['codLimit'] ?? 0,
      codUsagePercent: int.tryParse(json['codUsagePercent'].toString()) ?? 0,
      limitExceeded: json['limitExceeded'] ?? false,
    );
  }
}
