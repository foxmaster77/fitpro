class DailyQuest {
  const DailyQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.targetValue,
    required this.currentValue,
    required this.questType,
    required this.completedAt,
  });

  final String id;
  final String title;
  final String description;
  final int xpReward;
  final int targetValue;
  final int currentValue;
  final QuestType questType;
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;
  double get progress => currentValue / targetValue;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'xpReward': xpReward,
        'targetValue': targetValue,
        'currentValue': currentValue,
        'questType': questType.name,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory DailyQuest.fromJson(Map<String, dynamic> json) => DailyQuest(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        xpReward: json['xpReward'] as int,
        targetValue: json['targetValue'] as int,
        currentValue: json['currentValue'] as int,
        questType: QuestType.values.firstWhere(
          (e) => e.name == json['questType'],
          orElse: () => QuestType.workout,
        ),
        completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
      );

  DailyQuest copyWith({
    String? id,
    String? title,
    String? description,
    int? xpReward,
    int? targetValue,
    int? currentValue,
    QuestType? questType,
    DateTime? completedAt,
  }) {
    return DailyQuest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      xpReward: xpReward ?? this.xpReward,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      questType: questType ?? this.questType,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

enum QuestType {
  workout,
  calories,
  run,
  streak,
}

class LevelConfig {
  static int xpForLevel(int level) {
    return (level * 100).toInt();
  }

  static int levelFromXp(int xp) {
    if (xp < 100) return 1;
    return (xp / 100).floor() + 1;
  }

  static int xpProgressInCurrentLevel(int xp) {
    final currentLevel = levelFromXp(xp);
    final xpForCurrentLevel = xpForLevel(currentLevel - 1);
    return xp - xpForCurrentLevel;
  }

  static int xpNeededForNextLevel(int xp) {
    final currentLevel = levelFromXp(xp);
    return xpForLevel(currentLevel) - xp;
  }
}