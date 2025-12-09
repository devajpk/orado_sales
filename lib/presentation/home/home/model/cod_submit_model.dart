class CODSubmitResponse {
  final String message;
  final CODTracking codTracking;
  final CODHistoryItem lastSubmission;

  CODSubmitResponse({
    required this.message,
    required this.codTracking,
    required this.lastSubmission,
  });

  factory CODSubmitResponse.fromJson(Map<String, dynamic> json) {
    return CODSubmitResponse(
      message: json['message'],
      codTracking: CODTracking.fromJson(json['codTracking']),
      lastSubmission: CODHistoryItem.fromJson(json['lastSubmission']),
    );
  }
}

class CODTracking {
  final double currentCODHolding;
  final double dailyCollected;
  final DateTime lastUpdated;

  CODTracking({
    required this.currentCODHolding,
    required this.dailyCollected,
    required this.lastUpdated,
  });

  factory CODTracking.fromJson(Map<String, dynamic> json) {
    return CODTracking(
      currentCODHolding: (json['currentCODHolding'] as num).toDouble(),
      dailyCollected: (json['dailyCollected'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

class CODHistoryItem {
  final double droppedAmount;
  final String dropMethod;
  final String dropNotes;
  final CODLocation dropLocation;
  final DateTime droppedAt;

  CODHistoryItem({
    required this.droppedAmount,
    required this.dropMethod,
    required this.dropNotes,
    required this.dropLocation,
    required this.droppedAt,
  });

  factory CODHistoryItem.fromJson(Map<String, dynamic> json) {
    return CODHistoryItem(
      droppedAmount: (json['droppedAmount'] as num).toDouble(),
      dropMethod: json['dropMethod'],
      dropNotes: json['dropNotes'],
      dropLocation: CODLocation.fromJson(json['dropLocation']),
      droppedAt: DateTime.parse(json['droppedAt']),
    );
  }
}

class CODLocation {
  final String type;
  final List<double> coordinates;

  CODLocation({required this.type, required this.coordinates});

  factory CODLocation.fromJson(Map<String, dynamic> json) {
    return CODLocation(
      type: json['type'],
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}
