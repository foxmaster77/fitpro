enum LiftSessionKind { weightlifting }

class LiftSet {
  const LiftSet({
    required this.id,
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.weightKg,
    required this.completedAt,
  });

  final String id;
  final String exercise;
  final int sets;
  final int reps;
  final double weightKg;
  final DateTime completedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'exercise': exercise,
        'sets': sets,
        'reps': reps,
        'weightKg': weightKg,
        'completedAt': completedAt.toIso8601String(),
      };

  factory LiftSet.fromJson(Map<String, dynamic> json) => LiftSet(
        id: json['id'] as String,
        exercise: json['exercise'] as String,
        sets: json['sets'] as int,
        reps: json['reps'] as int,
        weightKg: (json['weightKg'] as num).toDouble(),
        completedAt: DateTime.parse(json['completedAt'] as String),
      );
}

class RunLog {
  const RunLog({
    required this.id,
    required this.distanceKm,
    required this.minutes,
    required this.completedAt,
  });

  final String id;
  final double distanceKm;
  final int minutes;
  final DateTime completedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'distanceKm': distanceKm,
        'minutes': minutes,
        'completedAt': completedAt.toIso8601String(),
      };

  factory RunLog.fromJson(Map<String, dynamic> json) => RunLog(
        id: json['id'] as String,
        distanceKm: (json['distanceKm'] as num).toDouble(),
        minutes: json['minutes'] as int,
        completedAt: DateTime.parse(json['completedAt'] as String),
      );
}

class CalorieLog {
  const CalorieLog({
    required this.id,
    required this.calories,
    required this.note,
    required this.loggedAt,
  });

  final String id;
  final int calories;
  final String note;
  final DateTime loggedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'calories': calories,
        'note': note,
        'loggedAt': loggedAt.toIso8601String(),
      };

  factory CalorieLog.fromJson(Map<String, dynamic> json) => CalorieLog(
        id: json['id'] as String,
        calories: json['calories'] as int,
        note: json['note'] as String? ?? '',
        loggedAt: DateTime.parse(json['loggedAt'] as String),
      );
}
