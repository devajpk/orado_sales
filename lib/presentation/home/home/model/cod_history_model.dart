class AgentCODHistoryModel {
  final String agentId;
  final double currentCODHolding;
  final double codLimit;
  final double usagePercent;
  final List<CODHistory> history;

  AgentCODHistoryModel({
    required this.agentId,
    required this.currentCODHolding,
    required this.codLimit,
    required this.usagePercent,
    required this.history,
  });

  factory AgentCODHistoryModel.fromJson(Map<String, dynamic> json) {
    return AgentCODHistoryModel(
      agentId: json['agentId'] as String,
      currentCODHolding: (json['currentCODHolding'] as num).toDouble(),
      codLimit: (json['codLimit'] as num).toDouble(),
      usagePercent: (json['usagePercent'] as num).toDouble(),
      history: (json['history'] as List<dynamic>)
          .map((e) => CODHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agentId': agentId,
      'currentCODHolding': currentCODHolding,
      'codLimit': codLimit,
      'usagePercent': usagePercent,
      'history': history.map((e) => e.toJson()).toList(),
    };
  }
}

class CODHistory {
  final double amount;
  final String method;
  final String notes;
  final String status;
  final DateTime droppedAt;

  CODHistory({
    required this.amount,
    required this.method,
    required this.notes,
    required this.status,
    required this.droppedAt,
  });

  factory CODHistory.fromJson(Map<String, dynamic> json) {
    return CODHistory(
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String,
      notes: json['notes'] as String,
      status: json['status'] as String,
      droppedAt: DateTime.parse(json['droppedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'method': method,
      'notes': notes,
      'status': status,
      'droppedAt': droppedAt.toIso8601String(),
    };
  }
}
