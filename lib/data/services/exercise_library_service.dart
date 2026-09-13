import '../../core/constants.dart';
import '../../data/models/exercise.dart';
import '../repositories/health_repository.dart';
import 'revenue_cat_service.dart';

class ExerciseLibraryService {
  ExerciseLibraryService(this._repository, [this._revenueCat]);

  final HealthRepository _repository;
  final RevenueCatService? _revenueCat;

  static const String premiumEntitlementId = AppConstants.premiumSku;

  /// Live `ai_pro_monthly` entitlement from `purchases_flutter`.
  Stream<bool> watchAiProEntitlement() {
    final revenueCat = _revenueCat;
    if (revenueCat == null) {
      return Stream<bool>.value(false);
    }
    return revenueCat.watchAiProEntitlement();
  }

  Future<bool> hasAiProEntitlement() async {
    return _revenueCat?.isProSubscriber() ?? false;
  }

  /// Catalog `isPremium` items are locked unless `ai_pro_monthly` is active.
  bool isPaywalled(Exercise exercise, {required bool hasAiProEntitlement}) {
    return exercise.isPremium && !hasAiProEntitlement;
  }

  Future<void> seedExerciseLibrary() async {
    final existingExercises = await _repository.loadExercises();
    if (existingExercises.isNotEmpty) return;

    final exercises = _getDefaultExercises();
    for (final exercise in exercises) {
      await _repository.saveExercise(exercise);
    }
  }

  List<Exercise> _getDefaultExercises() {
    return [
      Exercise(
        id: 'ex_001',
        name: 'Barbell Squat',
        category: ExerciseCategory.strength,
        muscleGroups: ['Quadriceps', 'Glutes', 'Hamstrings', 'Core'],
        equipment: 'Barbell',
        difficulty: ExerciseDifficulty.intermediate,
        isPremium: false,
        instructions: 'Stand with feet shoulder-width apart, bar across shoulders. Lower hips until thighs are parallel to ground, then return to standing.',
      ),
      Exercise(
        id: 'ex_002',
        name: 'Deadlift',
        category: ExerciseCategory.strength,
        muscleGroups: ['Hamstrings', 'Glutes', 'Lower Back', 'Traps'],
        equipment: 'Barbell',
        difficulty: ExerciseDifficulty.advanced,
        isPremium: true,
        instructions: 'Stand with feet hip-width apart, grip bar. Drive through heels to lift, keeping back straight. Lower with control.',
      ),
      Exercise(
        id: 'ex_003',
        name: 'Bench Press',
        category: ExerciseCategory.strength,
        muscleGroups: ['Chest', 'Triceps', 'Shoulders'],
        equipment: 'Barbell',
        difficulty: ExerciseDifficulty.intermediate,
        isPremium: false,
        instructions: 'Lie on bench, grip bar slightly wider than shoulders. Lower to chest, then press up until arms are extended.',
      ),
      Exercise(
        id: 'ex_004',
        name: 'Pull-up',
        category: ExerciseCategory.strength,
        muscleGroups: ['Latissimus Dorsi', 'Biceps', 'Upper Back'],
        equipment: 'Pull-up Bar',
        difficulty: ExerciseDifficulty.intermediate,
        isPremium: false,
        instructions: 'Hang from bar with overhand grip. Pull chest to bar, then lower with control.',
      ),
      Exercise(
        id: 'ex_005',
        name: 'Overhead Press',
        category: ExerciseCategory.strength,
        muscleGroups: ['Shoulders', 'Triceps', 'Upper Chest'],
        equipment: 'Barbell',
        difficulty: ExerciseDifficulty.intermediate,
        isPremium: true,
        instructions: 'Stand with bar at shoulder height. Press overhead until arms are extended, then lower with control.',
      ),
      Exercise(
        id: 'ex_006',
        name: 'Push-up',
        category: ExerciseCategory.strength,
        muscleGroups: ['Chest', 'Triceps', 'Shoulders', 'Core'],
        equipment: 'Bodyweight',
        difficulty: ExerciseDifficulty.beginner,
        isPremium: false,
        instructions: 'Start in plank position. Lower chest to ground, then push back up. Keep body straight throughout.',
      ),
      Exercise(
        id: 'ex_007',
        name: 'Lunges',
        category: ExerciseCategory.strength,
        muscleGroups: ['Quadriceps', 'Glutes', 'Hamstrings'],
        equipment: 'Bodyweight',
        difficulty: ExerciseDifficulty.beginner,
        isPremium: false,
        instructions: 'Step forward with one leg, lower hips until both knees are at 90 degrees. Return to standing, alternate legs.',
      ),
      Exercise(
        id: 'ex_008',
        name: 'Plank',
        category: ExerciseCategory.strength,
        muscleGroups: ['Core', 'Shoulders', 'Lower Back'],
        equipment: 'Bodyweight',
        difficulty: ExerciseDifficulty.beginner,
        isPremium: false,
        instructions: 'Hold push-up position with body straight. Engage core, keep hips level. Hold for time.',
      ),
      Exercise(
        id: 'ex_009',
        name: 'Dumbbell Rows',
        category: ExerciseCategory.strength,
        muscleGroups: ['Latissimus Dorsi', 'Biceps', 'Upper Back'],
        equipment: 'Dumbbells',
        difficulty: ExerciseDifficulty.beginner,
        isPremium: false,
        instructions: 'Bend over with flat back, row dumbbell to hip. Lower with control, alternate sides.',
      ),
      Exercise(
        id: 'ex_010',
        name: 'Running',
        category: ExerciseCategory.cardio,
        muscleGroups: ['Legs', 'Core', 'Cardiovascular'],
        equipment: 'None',
        difficulty: ExerciseDifficulty.beginner,
        isPremium: false,
        instructions: 'Run at steady pace, maintain good posture. Land midfoot, keep cadence around 180 steps per minute.',
      ),
      Exercise(
        id: 'ex_011',
        name: 'Cycling',
        category: ExerciseCategory.cardio,
        muscleGroups: ['Legs', 'Cardiovascular'],
        equipment: 'Bike',
        difficulty: ExerciseDifficulty.beginner,
        isPremium: false,
        instructions: 'Cycle at moderate intensity, maintain steady cadence. Adjust resistance as needed.',
      ),
      Exercise(
        id: 'ex_012',
        name: 'Jump Rope',
        category: ExerciseCategory.cardio,
        muscleGroups: ['Calves', 'Cardiovascular', 'Coordination'],
        equipment: 'Jump Rope',
        difficulty: ExerciseDifficulty.intermediate,
        isPremium: true,
        instructions: 'Jump over rope with both feet, keeping rhythm. Stay light on balls of feet.',
      ),
      Exercise(
        id: 'ex_013',
        name: 'Yoga Flow',
        category: ExerciseCategory.flexibility,
        muscleGroups: ['Full Body', 'Flexibility', 'Balance'],
        equipment: 'Mat',
        difficulty: ExerciseDifficulty.beginner,
        isPremium: false,
        instructions: 'Flow through yoga poses, linking breath with movement. Hold each pose for several breaths.',
      ),
      Exercise(
        id: 'ex_014',
        name: 'Hip Flexor Stretch',
        category: ExerciseCategory.flexibility,
        muscleGroups: ['Hip Flexors', 'Quadriceps'],
        equipment: 'None',
        difficulty: ExerciseDifficulty.beginner,
        isPremium: false,
        instructions: 'Kneel on one knee, push hips forward. Keep chest up, feel stretch in hip flexor of kneeling leg.',
      ),
      Exercise(
        id: 'ex_015',
        name: 'Hamstring Stretch',
        category: ExerciseCategory.flexibility,
        muscleGroups: ['Hamstrings', 'Lower Back'],
        equipment: 'None',
        difficulty: ExerciseDifficulty.beginner,
        isPremium: false,
        instructions: 'Sit with one leg extended, reach toward toes. Keep back straight, feel gentle stretch in hamstrings.',
      ),
      Exercise(
        id: 'ex_016',
        name: 'Balance Board',
        category: ExerciseCategory.balance,
        muscleGroups: ['Core', 'Ankle Stabilizers', 'Proprioception'],
        equipment: 'Balance Board',
        difficulty: ExerciseDifficulty.intermediate,
        isPremium: true,
        instructions: 'Stand on balance board, maintain stability. Progress to single-leg variations for added challenge.',
      ),
      Exercise(
        id: 'ex_017',
        name: 'Single Leg Deadlift',
        category: ExerciseCategory.balance,
        muscleGroups: ['Hamstrings', 'Glutes', 'Balance'],
        equipment: 'Dumbbell',
        difficulty: ExerciseDifficulty.intermediate,
        isPremium: true,
        instructions: 'Stand on one leg, hinge at hips while extending other leg behind. Return to standing with control.',
      ),
      Exercise(
        id: 'ex_018',
        name: 'Kettlebell Swing',
        category: ExerciseCategory.functional,
        muscleGroups: ['Hamstrings', 'Glutes', 'Core', 'Cardiovascular'],
        equipment: 'Kettlebell',
        difficulty: ExerciseDifficulty.intermediate,
        isPremium: true,
        instructions: 'Hinge at hips, swing kettlebell between legs. Drive through hips to swing kettlebell to shoulder height.',
      ),
      Exercise(
        id: 'ex_019',
        name: 'Burpees',
        category: ExerciseCategory.functional,
        muscleGroups: ['Full Body', 'Cardiovascular'],
        equipment: 'Bodyweight',
        difficulty: ExerciseDifficulty.advanced,
        isPremium: true,
        instructions: 'Start standing, drop to push-up position, do push-up, jump feet to hands, then jump up with arms overhead.',
      ),
      Exercise(
        id: 'ex_020',
        name: 'Box Jumps',
        category: ExerciseCategory.functional,
        muscleGroups: ['Legs', 'Core', 'Explosive Power'],
        equipment: 'Plyo Box',
        difficulty: ExerciseDifficulty.advanced,
        isPremium: true,
        instructions: 'Stand in front of box, jump onto it landing softly. Step down and repeat. Focus on explosive power.',
      ),
    ];
  }
}