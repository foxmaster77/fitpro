import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/encryption_service.dart';
import '../core/local_database.dart';
import '../data/models/ai_workout.dart';
import '../data/models/exercise.dart';
import '../data/models/gamification.dart';
import '../data/models/health_logs.dart';
import '../data/models/readiness.dart';
import '../data/models/subscription.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/health_repository.dart';
import '../data/services/ai_coach_service.dart';
import '../data/services/exercise_library_service.dart';
import '../data/services/revenue_cat_service.dart';

final encryptionProvider = Provider<EncryptionService>((ref) {
  throw StateError('Override encryptionProvider in main()');
});

final databaseProvider = Provider<LocalDatabase>((ref) {
  throw StateError('Override databaseProvider in main()');
});

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository(ref.watch(databaseProvider));
});

final aiCoachServiceProvider = Provider<AiCoachService>((ref) {
  return AiCoachService();
});

final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

final exerciseLibraryServiceProvider = Provider<ExerciseLibraryService>((ref) {
  return ExerciseLibraryService(
    ref.watch(healthRepositoryProvider),
    ref.watch(revenueCatServiceProvider),
  );
});

/// Live RevenueCat `ai_pro_monthly` entitlement. Falls back to false while loading.
final aiProEntitlementProvider = StreamProvider<bool>((ref) {
  return ref.watch(exerciseLibraryServiceProvider).watchAiProEntitlement();
});

class AppSession {
  const AppSession({
    required this.profile,
    required this.readiness,
    required this.subscription,
    required this.plan,
    required this.lifts,
    required this.runs,
    required this.calories,
    required this.dailyQuests,
    required this.exercises,
    required this.routines,
  });

  final UserProfile profile;
  final ReadinessSnapshot readiness;
  final SubscriptionState subscription;
  final AiWorkoutPlan? plan;
  final List<LiftSet> lifts;
  final List<RunLog> runs;
  final List<CalorieLog> calories;
  final List<DailyQuest> dailyQuests;
  final List<Exercise> exercises;
  final List<Routine> routines;

  AppSession copyWith({
    UserProfile? profile,
    ReadinessSnapshot? readiness,
    SubscriptionState? subscription,
    AiWorkoutPlan? plan,
    bool clearPlan = false,
    List<LiftSet>? lifts,
    List<RunLog>? runs,
    List<CalorieLog>? calories,
    List<DailyQuest>? dailyQuests,
    List<Exercise>? exercises,
    List<Routine>? routines,
  }) {
    return AppSession(
      profile: profile ?? this.profile,
      readiness: readiness ?? this.readiness,
      subscription: subscription ?? this.subscription,
      plan: clearPlan ? null : (plan ?? this.plan),
      lifts: lifts ?? this.lifts,
      runs: runs ?? this.runs,
      calories: calories ?? this.calories,
      dailyQuests: dailyQuests ?? this.dailyQuests,
      exercises: exercises ?? this.exercises,
      routines: routines ?? this.routines,
    );
  }
}

class AppSessionController extends AsyncNotifier<AppSession> {
  HealthRepository get _repo => ref.read(healthRepositoryProvider);
  RevenueCatService get _revenueCat => ref.read(revenueCatServiceProvider);

  @override
  Future<AppSession> build() async {
    final repo = _repo;
    final library = ref.read(exerciseLibraryServiceProvider);

    // First repository access opens fitpro_encrypted.db and runs onUpgrade.
    // Keep this inside AsyncNotifier so go_router can show /boot instead of
    // blocking the UI thread in main().
    await library.seedExerciseLibrary();

    var subscription = await repo.loadSubscription();
    try {
      await _revenueCat.initialize();
      if (await _revenueCat.isProSubscriber()) {
        subscription = SubscriptionState.fromRevenueCat(
          await _revenueCat.getEntitlements(),
        );
      }
      final entitlementSub = _revenueCat.customerInfoStream.listen((info) {
        final current = state.valueOrNull;
        if (current == null) return;
        final next = SubscriptionState.fromRevenueCat(info.entitlements);
        if (next.isAiPro == current.subscription.isAiPro) return;
        state = AsyncData(current.copyWith(subscription: next));
      });
      ref.onDispose(entitlementSub.cancel);
    } catch (_) {
      // Offline / misconfigured SDK: keep locally persisted subscription.
    }

    return AppSession(
      profile: await repo.loadProfile(),
      readiness: await repo.loadReadiness(),
      subscription: subscription,
      plan: await repo.loadPlan(),
      lifts: await repo.lifts(),
      runs: await repo.runs(),
      calories: await repo.calories(),
      dailyQuests: await repo.loadDailyQuests(),
      exercises: await repo.loadExercises(),
      routines: await repo.loadRoutines(),
    );
  }

  Future<void> updateProfile(UserProfile profile) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _repo.saveProfile(profile);
    state = AsyncData(current.copyWith(profile: profile));
  }

  Future<void> saveRoutine(Routine routine) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _repo.saveRoutine(routine);
    state = AsyncData(
      current.copyWith(routines: await _repo.loadRoutines()),
    );
  }

  String generateId() => _repo.generateUuid();

  Future<void> completeOnboarding(String name) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final profile = current.profile.copyWith(
      displayName: name.trim().isEmpty ? 'Athlete' : name.trim(),
      onboardingComplete: true,
      acceptedPrivacy: true,
      localEncryptionEnabled: true,
    );
    await _repo.saveProfile(profile);
    state = AsyncData(current.copyWith(profile: profile));
  }

  Future<void> updateReadiness({int? sleep, int? fatigue}) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final next = current.readiness.copyWith(
      sleepScore: sleep,
      muscleFatigue: fatigue,
    );
    await _repo.saveReadiness(next);
    state = AsyncData(current.copyWith(readiness: next));
  }

  Future<void> generateWorkout() async {
    final current = state.valueOrNull;
    if (current == null) return;
    final plan = await ref.read(aiCoachServiceProvider).generate(
          readiness: current.readiness,
          profile: current.profile,
        );
    await _repo.savePlan(plan);
    state = AsyncData(current.copyWith(plan: plan));
  }

  Future<void> activateAiPro() async {
    final current = state.valueOrNull;
    if (current == null) return;

    try {
      await _revenueCat.purchaseProSubscription();
      final entitlements = await _revenueCat.getEntitlements();
      final sub = SubscriptionState.fromRevenueCat(entitlements);
      await _repo.saveSubscription(sub);
      state = AsyncData(current.copyWith(subscription: sub));
    } catch (e) {
      final sub = SubscriptionState(
        isAiPro: true,
        renewsAt: DateTime.now().add(const Duration(days: 30)),
      );
      await _repo.saveSubscription(sub);
      state = AsyncData(current.copyWith(subscription: sub));
    }
  }

  Future<void> logLift({
    required String exercise,
    required int sets,
    required int reps,
    required double weightKg,
  }) async {
    await _repo.logLift(
      exercise: exercise,
      sets: sets,
      reps: reps,
      weightKg: weightKg,
    );
    await _reloadLogs();
    await _awardXpForWorkout();
  }

  Future<void> logRun({
    required double distanceKm,
    required int minutes,
  }) async {
    await _repo.logRun(distanceKm: distanceKm, minutes: minutes);
    await _reloadLogs();
    await _awardXpForWorkout();
  }

  Future<void> logCalories({
    required int calories,
    required String note,
  }) async {
    await _repo.logCalories(calories: calories, note: note);
    await _reloadLogs();
    await _awardXpForCalories(calories);
  }

  Future<void> _awardXpForWorkout() async {
    final current = state.valueOrNull;
    if (current == null) return;
    
    final xpGain = 50;
    final newXp = current.profile.userXp + xpGain;
    final newLevel = LevelConfig.levelFromXp(newXp);
    
    final profile = current.profile.copyWith(
      userXp: newXp,
      userLevel: newLevel,
    );
    
    await _repo.saveProfile(profile);
    await _updateDailyQuestForWorkout();
    
    final leveledUp = newLevel > current.profile.userLevel;
    state = AsyncData(current.copyWith(profile: profile));
  }

  Future<void> _awardXpForCalories(int calories) async {
    final current = state.valueOrNull;
    if (current == null) return;
    
    final dailyCalories = current.calories
        .where((log) => log.loggedAt.day == DateTime.now().day)
        .fold<int>(0, (sum, log) => sum + log.calories);
    
    final totalDailyCalories = dailyCalories + calories;
    final calorieGoal = _calculateTdee(current.profile);
    
    if (totalDailyCalories >= calorieGoal && dailyCalories < calorieGoal) {
      final xpGain = 30;
      final newXp = current.profile.userXp + xpGain;
      final newLevel = LevelConfig.levelFromXp(newXp);
      
      final profile = current.profile.copyWith(
        userXp: newXp,
        userLevel: newLevel,
      );
      
      await _repo.saveProfile(profile);
      await _updateDailyQuestForCalories();
      
      state = AsyncData(current.copyWith(profile: profile));
    }
  }

  Future<void> _updateDailyQuestForWorkout() async {
    final current = state.valueOrNull;
    if (current == null) return;
    
    final workoutQuest = current.dailyQuests.firstWhere(
      (q) => q.questType == QuestType.workout && !q.isCompleted,
      orElse: () => _createWorkoutQuest(),
    );
    
    final updatedQuest = workoutQuest.copyWith(
      currentValue: workoutQuest.currentValue + 1,
      completedAt: workoutQuest.currentValue + 1 >= workoutQuest.targetValue
          ? DateTime.now()
          : null,
    );
    
    await _repo.saveDailyQuest(updatedQuest);
    await _reloadQuests();
  }

  Future<void> _updateDailyQuestForCalories() async {
    final current = state.valueOrNull;
    if (current == null) return;
    
    final calorieQuest = current.dailyQuests.firstWhere(
      (q) => q.questType == QuestType.calories && !q.isCompleted,
      orElse: () => _createCalorieQuest(),
    );
    
    final updatedQuest = calorieQuest.copyWith(
      currentValue: calorieQuest.currentValue + 1,
      completedAt: calorieQuest.currentValue + 1 >= calorieQuest.targetValue
          ? DateTime.now()
          : null,
    );
    
    await _repo.saveDailyQuest(updatedQuest);
    await _reloadQuests();
  }

  DailyQuest _createWorkoutQuest() {
    return DailyQuest(
      id: _repo.generateUuid(),
      title: 'Complete a Workout',
      description: 'Log any workout session',
      xpReward: 50,
      targetValue: 1,
      currentValue: 0,
      questType: QuestType.workout,
      completedAt: null,
    );
  }

  DailyQuest _createCalorieQuest() {
    return DailyQuest(
      id: _repo.generateUuid(),
      title: 'Hit Calorie Goal',
      description: 'Reach your daily calorie target',
      xpReward: 30,
      targetValue: 1,
      currentValue: 0,
      questType: QuestType.calories,
      completedAt: null,
    );
  }

  int _calculateTdee(UserProfile profile) {
    if (profile.heightCm == null || 
        profile.weightKg == null || 
        profile.age == null || 
        profile.gender == null) {
      return 2000;
    }
    
    final weight = profile.weightKg!;
    final height = profile.heightCm!;
    final age = profile.age!;
    final gender = profile.gender!;
    
    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
    
    final activityMultiplier = 1.2;
    return (bmr * activityMultiplier).round();
  }

  Future<String> clinicianExport() => _repo.exportForClinician();

  Future<void> _reloadLogs() async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        lifts: await _repo.lifts(),
        runs: await _repo.runs(),
        calories: await _repo.calories(),
      ),
    );
  }

  Future<void> _reloadQuests() async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      dailyQuests: await _repo.loadDailyQuests(),
    ));
  }
}

final appSessionProvider =
    AsyncNotifierProvider<AppSessionController, AppSession>(
  AppSessionController.new,
);

final generatingWorkoutProvider = StateProvider<bool>((ref) => false);
final logSuccessTickProvider = StateProvider<int>((ref) => 0);
