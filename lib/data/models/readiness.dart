class ReadinessSnapshot {
  const ReadinessSnapshot({
    required this.sleepScore,
    required this.muscleFatigue,
    required this.updatedAt,
  });

  final int sleepScore;
  final int muscleFatigue;
  final DateTime updatedAt;

  int get dailyReadiness {
    final recovered = 100 - muscleFatigue;
    return ((sleepScore * 0.55) + (recovered * 0.45)).round().clamp(0, 100);
  }

  String get label {
    if (dailyReadiness >= 80) return 'Peak';
    if (dailyReadiness >= 60) return 'Ready';
    if (dailyReadiness >= 40) return 'Caution';
    return 'Recover';
  }

  Map<String, dynamic> toJson() => {
        'sleepScore': sleepScore,
        'muscleFatigue': muscleFatigue,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ReadinessSnapshot.fromJson(Map<String, dynamic> json) =>
      ReadinessSnapshot(
        sleepScore: json['sleepScore'] as int? ?? 72,
        muscleFatigue: json['muscleFatigue'] as int? ?? 38,
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );

  factory ReadinessSnapshot.seed() => ReadinessSnapshot(
        sleepScore: 74,
        muscleFatigue: 36,
        updatedAt: DateTime.now(),
      );

  ReadinessSnapshot copyWith({int? sleepScore, int? muscleFatigue}) {
    return ReadinessSnapshot(
      sleepScore: sleepScore ?? this.sleepScore,
      muscleFatigue: muscleFatigue ?? this.muscleFatigue,
      updatedAt: DateTime.now(),
    );
  }
}
