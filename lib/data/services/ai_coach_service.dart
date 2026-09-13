import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/ai_workout.dart';
import '../models/readiness.dart';
import '../models/user_profile.dart';

class AiCoachService {
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'YOUR_GEMINI_API_KEY',
  );

  GenerativeModel? _model;

  Future<AiWorkoutPlan> generate({
    required ReadinessSnapshot readiness,
    UserProfile? profile,
  }) async {
    final bmr = calculateBmr(profile);
    final tdee = calculateTdee(bmr);
    final userLevel = profile?.userLevel ?? 1;
    final userXp = profile?.userXp ?? 0;

    try {
      _model ??= GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.4,
        ),
        systemInstruction: Content.system(
          'You are FITPRO\'s on-device coach. Reply with a single JSON object only. '
          'No markdown, no commentary, no code fences.',
        ),
      );

      final prompt = _buildPrompt(
        readiness: readiness,
        profile: profile,
        bmr: bmr,
        tdee: tdee,
        userLevel: userLevel,
        userXp: userXp,
      );

      final response = await _model!.generateContent([Content.text(prompt)]);
      final raw = response.text;
      if (raw == null || raw.trim().isEmpty) {
        return _generateFallbackPlan(readiness, profile);
      }
      return _parseWorkoutPlan(raw, readiness, profile);
    } catch (_) {
      return _generateFallbackPlan(readiness, profile);
    }
  }

  String _buildPrompt({
    required ReadinessSnapshot readiness,
    required UserProfile? profile,
    required int bmr,
    required int tdee,
    required int userLevel,
    required int userXp,
  }) {
    return '''
You are an expert fitness coach AI. Generate a personalized workout routine for this athlete.

User context (must influence volume, intensity, and exercise selection):
- userLevel: $userLevel
- userXp: $userXp
- BMR: $bmr kcal/day
- TDEE: $tdee kcal/day
- Sleep Score: ${readiness.sleepScore}/100
- Muscle Fatigue: ${readiness.muscleFatigue}/100
- Daily Readiness: ${readiness.dailyReadiness}/100
${profile != null ? '- Fitness Goal: ${profile.fitnessGoal ?? "Maintain"}' : ''}
${profile != null ? '- Display name: ${profile.displayName}' : ''}

Return ONLY valid JSON with this exact schema:
{
  "title": "Workout Title",
  "rationale": "Brief explanation of why this routine fits userLevel, userXp, BMR, and readiness",
  "focus": "strength|cardio|mobility|mixed",
  "injuryFlags": ["injury prevention tip 1", "injury prevention tip 2"],
  "blocks": [
    {
      "title": "Exercise Name",
      "detail": "Specific instructions (sets, reps, intensity)",
      "minutes": 10
    }
  ]
}

Rules:
- If readiness < 45 or sleep < 50: Focus on recovery/mobility
- If fatigue > 62: Reduce intensity, focus on technique
- If readiness > 70 and fatigue < 40: Can include higher intensity work
- Scale load to userLevel and userXp (lower level = more coaching cues, fewer max-effort sets)
- Respect energy availability implied by BMR/TDEE
- Total workout time should be 30-45 minutes
- Include 3-4 exercise blocks
- Focus on compound movements when appropriate
''';
  }

  String _extractJsonFromResponse(String response) {
    var text = response.trim();
    if (text.startsWith('```')) {
      final firstNl = text.indexOf('\n');
      if (firstNl != -1) {
        text = text.substring(firstNl + 1);
      }
      if (text.endsWith('```')) {
        text = text.substring(0, text.length - 3).trim();
      }
    }
    final jsonStart = text.indexOf('{');
    final jsonEnd = text.lastIndexOf('}');
    if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
      return text.substring(jsonStart, jsonEnd + 1);
    }
    return text;
  }

  AiWorkoutPlan _parseWorkoutPlan(
    String jsonResponse,
    ReadinessSnapshot readiness,
    UserProfile? profile,
  ) {
    try {
      final json = jsonDecode(_extractJsonFromResponse(jsonResponse))
          as Map<String, dynamic>;
      final blocks = (json['blocks'] as List<dynamic>?)
              ?.map(
                (block) => AiWorkoutBlock(
                  title: block['title'] as String? ?? 'Exercise',
                  detail: block['detail'] as String? ?? '',
                  minutes: (block['minutes'] as num?)?.toInt() ?? 10,
                ),
              )
              .toList() ??
          const <AiWorkoutBlock>[];
      if (blocks.isEmpty) {
        return _generateFallbackPlan(readiness, profile);
      }
      return AiWorkoutPlan(
        title: json['title'] as String? ?? 'Custom Routine',
        rationale: json['rationale'] as String? ?? 'AI-generated routine',
        focus: _parseFocus(json['focus'] as String?),
        injuryFlags: (json['injuryFlags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        blocks: blocks,
      );
    } catch (_) {
      return _generateFallbackPlan(readiness, profile);
    }
  }

  AiWorkoutFocus _parseFocus(String? focus) {
    switch (focus?.toLowerCase()) {
      case 'strength':
        return AiWorkoutFocus.strength;
      case 'cardio':
        return AiWorkoutFocus.mixed;
      case 'mobility':
        return AiWorkoutFocus.mobility;
      default:
        return AiWorkoutFocus.mixed;
    }
  }

  static int calculateBmr(UserProfile? profile) {
    if (profile == null ||
        profile.heightCm == null ||
        profile.weightKg == null ||
        profile.age == null ||
        profile.gender == null) {
      return 1800;
    }

    final weight = profile.weightKg!;
    final height = profile.heightCm!;
    final age = profile.age!;
    final gender = profile.gender!;

    final double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    return bmr.round();
  }

  static int calculateTdee(int bmr) {
    return (bmr * 1.2).round();
  }

  AiWorkoutPlan _generateFallbackPlan(
    ReadinessSnapshot readiness,
    UserProfile? profile,
  ) {
    final sleep = readiness.sleepScore;
    final fatigue = readiness.muscleFatigue;
    final score = readiness.dailyReadiness;

    if (score < 45 || sleep < 50) {
      return AiWorkoutPlan(
        title: 'Recovery Circuit',
        rationale:
            'Sleep $sleep and fatigue $fatigue point to incomplete recovery. Volume is cut; tissue quality is the session.',
        focus: AiWorkoutFocus.mobility,
        injuryFlags: [
          if (fatigue > 70) 'High residual fatigue — skip loaded spinal flexion',
          if (sleep < 50) 'Sleep debt — avoid max-effort intervals',
        ],
        blocks: const [
          AiWorkoutBlock(
            title: 'Nasal-breath walk',
            detail: 'Zone 1, 12 min, nasal only',
            minutes: 12,
          ),
          AiWorkoutBlock(
            title: '90/90 + couch stretch',
            detail: '2 x 60s / side, no forcing range',
            minutes: 8,
          ),
          AiWorkoutBlock(
            title: 'Isometric core',
            detail: 'Dead bug 3 x 8, dead-stop between reps',
            minutes: 8,
          ),
        ],
      );
    }

    if (fatigue > 62) {
      return AiWorkoutPlan(
        title: 'Lower-Stress Strength',
        rationale:
            'Muscle fatigue is elevated ($fatigue). We keep intensity moderate and bias unilateral work.',
        focus: AiWorkoutFocus.strength,
        injuryFlags: [
          'Watch knee valgus on lunges',
          'Cap RPE at 7 — no grinders',
        ],
        blocks: const [
          AiWorkoutBlock(
            title: 'Goblet squat',
            detail: '4 x 8 @ RPE 6',
            minutes: 12,
          ),
          AiWorkoutBlock(
            title: 'Single-leg RDL',
            detail: '3 x 8 / side, slow eccentric',
            minutes: 10,
          ),
          AiWorkoutBlock(
            title: 'Incline push-up',
            detail: '3 x 10, 2s down',
            minutes: 8,
          ),
        ],
      );
    }

    if (sleep >= 78 && fatigue < 40) {
      return AiWorkoutPlan(
        title: 'Peak Power Session',
        rationale:
            'Sleep $sleep and low fatigue ($fatigue) support neural work. Short, high-quality sets.',
        focus: AiWorkoutFocus.strength,
        injuryFlags: const [
          'Warm up jumps progressively',
          'Stop the set if landing mechanics degrade',
        ],
        blocks: const [
          AiWorkoutBlock(
            title: 'Pogo + box landings',
            detail: '4 x 5 quality contacts',
            minutes: 8,
          ),
          AiWorkoutBlock(
            title: 'Trap-bar deadlift',
            detail: '5 x 3 @ RPE 8',
            minutes: 16,
          ),
          AiWorkoutBlock(
            title: 'Chin-up',
            detail: '4 x 5, full hang',
            minutes: 10,
          ),
        ],
      );
    }

    return AiWorkoutPlan(
      title: 'Balanced Builder',
      rationale:
          'Readiness $score is in the workable zone. Mixed stimulus without stacking fatigue.',
      focus: AiWorkoutFocus.mixed,
      injuryFlags: const [
        'Keep rest honest between compounds',
      ],
      blocks: const [
        AiWorkoutBlock(
          title: 'Front squat',
          detail: '4 x 6 @ RPE 7',
          minutes: 14,
        ),
        AiWorkoutBlock(
          title: 'One-arm row',
          detail: '3 x 10 / side',
          minutes: 9,
        ),
        AiWorkoutBlock(
          title: 'Easy jog finisher',
          detail: '10 min conversational pace',
          minutes: 10,
        ),
      ],
    );
  }
}
