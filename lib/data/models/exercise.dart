class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.muscleGroups,
    required this.equipment,
    required this.difficulty,
    this.isPremium = false,
    this.mediaUrl,
    this.instructions,
  });

  final String id;
  final String name;
  final ExerciseCategory category;
  final List<String> muscleGroups;
  final String equipment;
  final ExerciseDifficulty difficulty;
  final bool isPremium;
  final String? mediaUrl;
  final String? instructions;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'muscleGroups': muscleGroups,
        'equipment': equipment,
        'difficulty': difficulty.name,
        'isPremium': isPremium,
        'mediaUrl': mediaUrl,
        'instructions': instructions,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as String,
        name: json['name'] as String,
        category: ExerciseCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => ExerciseCategory.strength,
        ),
        muscleGroups: (json['muscleGroups'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        equipment: json['equipment'] as String? ?? 'None',
        difficulty: ExerciseDifficulty.values.firstWhere(
          (e) => e.name == json['difficulty'],
          orElse: () => ExerciseDifficulty.intermediate,
        ),
        isPremium: json['isPremium'] as bool? ?? false,
        mediaUrl: json['mediaUrl'] as String?,
        instructions: json['instructions'] as String?,
      );

  Exercise copyWith({
    String? id,
    String? name,
    ExerciseCategory? category,
    List<String>? muscleGroups,
    String? equipment,
    ExerciseDifficulty? difficulty,
    bool? isPremium,
    String? mediaUrl,
    String? instructions,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      equipment: equipment ?? this.equipment,
      difficulty: difficulty ?? this.difficulty,
      isPremium: isPremium ?? this.isPremium,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      instructions: instructions ?? this.instructions,
    );
  }
}

enum ExerciseCategory {
  strength,
  cardio,
  flexibility,
  balance,
  functional,
}

enum ExerciseDifficulty {
  beginner,
  intermediate,
  advanced,
}

class Routine {
  const Routine({
    required this.id,
    required this.name,
    required this.description,
    required this.exerciseIds,
    required this.createdAt,
    this.isPremium = false,
  });

  final String id;
  final String name;
  final String description;
  final List<String> exerciseIds;
  final DateTime createdAt;
  final bool isPremium;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'exerciseIds': exerciseIds,
        'createdAt': createdAt.toIso8601String(),
        'isPremium': isPremium,
      };

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        exerciseIds: (json['exerciseIds'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        isPremium: json['isPremium'] as bool? ?? false,
      );

  Routine copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? exerciseIds,
    DateTime? createdAt,
    bool? isPremium,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exerciseIds: exerciseIds ?? this.exerciseIds,
      createdAt: createdAt ?? this.createdAt,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}