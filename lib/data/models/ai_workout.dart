enum AiWorkoutFocus { strength, mixed, mobility }

class AiWorkoutBlock {
  const AiWorkoutBlock({
    required this.title,
    required this.detail,
    required this.minutes,
  });

  final String title;
  final String detail;
  final int minutes;

  Map<String, dynamic> toJson() => {
        'title': title,
        'detail': detail,
        'minutes': minutes,
      };

  factory AiWorkoutBlock.fromJson(Map<String, dynamic> json) => AiWorkoutBlock(
        title: json['title'] as String,
        detail: json['detail'] as String,
        minutes: json['minutes'] as int,
      );
}

class AiWorkoutPlan {
  const AiWorkoutPlan({
    required this.title,
    required this.rationale,
    required this.focus,
    required this.blocks,
    required this.injuryFlags,
  });

  final String title;
  final String rationale;
  final AiWorkoutFocus focus;
  final List<AiWorkoutBlock> blocks;
  final List<String> injuryFlags;

  int get totalMinutes =>
      blocks.fold(0, (sum, block) => sum + block.minutes);

  Map<String, dynamic> toJson() => {
        'title': title,
        'rationale': rationale,
        'focus': focus.name,
        'blocks': blocks.map((b) => b.toJson()).toList(),
        'injuryFlags': injuryFlags,
      };

  factory AiWorkoutPlan.fromJson(Map<String, dynamic> json) => AiWorkoutPlan(
        title: json['title'] as String,
        rationale: json['rationale'] as String,
        focus: AiWorkoutFocus.values.firstWhere(
          (v) => v.name == json['focus'],
          orElse: () => AiWorkoutFocus.mixed,
        ),
        blocks: (json['blocks'] as List<dynamic>)
            .map((e) => AiWorkoutBlock.fromJson(e as Map<String, dynamic>))
            .toList(),
        injuryFlags: (json['injuryFlags'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
}
