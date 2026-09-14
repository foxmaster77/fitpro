enum FormExerciseType { squat, plank }

enum InjuryFlagSource { aiPredicted, formCheckObserved }

class FormCheckFlag {
  const FormCheckFlag({required this.text, required this.source});

  final String text;
  final InjuryFlagSource source;

  Map<String, dynamic> toJson() => {'text': text, 'source': source.name};

  factory FormCheckFlag.fromJson(Map<String, dynamic> json) => FormCheckFlag(
    text: json['text'] as String,
    source: InjuryFlagSource.values.firstWhere(
      (value) => value.name == json['source'],
      orElse: () => InjuryFlagSource.formCheckObserved,
    ),
  );
}

class FormCheckResult {
  const FormCheckResult({
    required this.exercise,
    required this.faults,
    required this.repCount,
    required this.sessionDuration,
  });

  final FormExerciseType exercise;
  final List<String> faults;
  final int repCount;
  final Duration sessionDuration;

  Map<String, dynamic> toJson() => {
    'exercise': exercise.name,
    'faults': faults,
    'repCount': repCount,
    'sessionDurationSeconds': sessionDuration.inSeconds,
  };
}
