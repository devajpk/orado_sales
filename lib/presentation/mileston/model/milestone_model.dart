class MileStoreRewardsModel {
  final CurrentLevel currentLevel;
  final List<Milestone> milestoneList;

  MileStoreRewardsModel({
    required this.currentLevel,
    required this.milestoneList,
  });

  factory MileStoreRewardsModel.fromJson(Map<String, dynamic> json) {
    return MileStoreRewardsModel(
      currentLevel: CurrentLevel.fromJson(json['currentLevel'] ?? {}),
      milestoneList: json['milestoneList'] != null
          ? List<Milestone>.from(
          json['milestoneList'].map((x) => Milestone.fromJson(x)))
          : [],
    );
  }
}

class CurrentLevel {
  final int level;
  final String title;
  final double overallProgress;

  CurrentLevel({
    required this.level,
    required this.title,
    required this.overallProgress,
  });

  factory CurrentLevel.fromJson(Map<String, dynamic> json) {
    return CurrentLevel(
      level: json['level'] ?? 0,
      title: json['title'] ?? '',
      overallProgress: (json['overallProgress'] ?? 0).toDouble(),
    );
  }
}

class Milestone {
  final int level;
  final String title;
  final String status;
  final Reward reward;
  final double overallProgress;
  final List<Condition> conditions;
  final bool claimable;
  final String? levelImageUrl;

  Milestone({
    required this.level,
    required this.title,
    required this.status,
    required this.reward,
    required this.overallProgress,
    required this.conditions,
    required this.claimable,
    this.levelImageUrl,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      level: json['level'] ?? 0,
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      reward: json['reward'] != null
          ? Reward.fromJson(json['reward'])
          : Reward(name: '', description: '', imageUrl: ''),
      overallProgress: (json['overallProgress'] ?? 0).toDouble(),
      conditions: json['conditions'] != null
          ? List<Condition>.from(
          json['conditions'].map((x) => Condition.fromJson(x)))
          : [],
      claimable: json['claimable'] ?? false,
      levelImageUrl: json['levelImageUrl'],
    );
  }
}

class Reward {
  final String name;
  final String description;
  final String imageUrl;

  Reward({
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class Condition {
  final String name;
  final double done;
  final double target;
  final double percent;

  Condition({
    required this.name,
    required this.done,
    required this.target,
    required this.percent,
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      name: json['name'] ?? '',
      done: (json['done'] ?? 0).toDouble(),
      target: (json['target'] ?? 0).toDouble(),
      percent: (json['percent'] ?? 0).toDouble(),
    );
  }
}
