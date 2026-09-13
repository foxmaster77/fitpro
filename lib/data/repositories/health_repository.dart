import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../core/local_database.dart';
import '../models/ai_workout.dart';
import '../models/exercise.dart';
import '../models/gamification.dart';
import '../models/health_logs.dart';
import '../models/readiness.dart';
import '../models/subscription.dart';
import '../models/user_profile.dart';

class HealthRepository {
  HealthRepository(this._db);

  final LocalDatabase _db;
  final _uuid = const Uuid();

  Future<UserProfile> loadProfile() async {
    final raw = await _db.getKv('profile');
    if (raw == null) return UserProfile.guest();
    return UserProfile.fromJson(raw);
  }

  Future<void> saveProfile(UserProfile profile) =>
      _db.putKv('profile', profile.toJson());

  Future<ReadinessSnapshot> loadReadiness() async {
    final raw = await _db.getKv('readiness');
    if (raw == null) return ReadinessSnapshot.seed();
    return ReadinessSnapshot.fromJson(raw);
  }

  Future<void> saveReadiness(ReadinessSnapshot snapshot) =>
      _db.putKv('readiness', snapshot.toJson());

  Future<SubscriptionState> loadSubscription() async {
    final raw = await _db.getKv('subscription');
    if (raw == null) return SubscriptionState.free;
    return SubscriptionState.fromJson(raw);
  }

  Future<void> saveSubscription(SubscriptionState state) =>
      _db.putKv('subscription', state.toJson());

  Future<void> savePlan(AiWorkoutPlan plan) =>
      _db.putKv('latest_plan', plan.toJson());

  Future<AiWorkoutPlan?> loadPlan() async {
    final raw = await _db.getKv('latest_plan');
    if (raw == null) return null;
    return AiWorkoutPlan.fromJson(raw);
  }

  Future<void> logLift({
    required String exercise,
    required int sets,
    required int reps,
    required double weightKg,
  }) async {
    final now = DateTime.now();
    final entry = LiftSet(
      id: _uuid.v4(),
      exercise: exercise,
      sets: sets,
      reps: reps,
      weightKg: weightKg,
      completedAt: now,
    );
    await _db.insertEvent(
      id: entry.id,
      kind: 'lift',
      createdAt: now,
      payload: entry.toJson(),
    );
  }

  Future<void> logRun({
    required double distanceKm,
    required int minutes,
  }) async {
    final now = DateTime.now();
    final entry = RunLog(
      id: _uuid.v4(),
      distanceKm: distanceKm,
      minutes: minutes,
      completedAt: now,
    );
    await _db.insertEvent(
      id: entry.id,
      kind: 'run',
      createdAt: now,
      payload: entry.toJson(),
    );
  }

  Future<void> logCalories({
    required int calories,
    required String note,
  }) async {
    final now = DateTime.now();
    final entry = CalorieLog(
      id: _uuid.v4(),
      calories: calories,
      note: note,
      loggedAt: now,
    );
    await _db.insertEvent(
      id: entry.id,
      kind: 'calorie',
      createdAt: now,
      payload: entry.toJson(),
    );
  }

  Future<List<LiftSet>> lifts() async {
    final rows = await _db.eventsByKind('lift');
    return rows.map(LiftSet.fromJson).toList();
  }

  Future<List<RunLog>> runs() async {
    final rows = await _db.eventsByKind('run');
    return rows.map(RunLog.fromJson).toList();
  }

  Future<List<CalorieLog>> calories() async {
    final rows = await _db.eventsByKind('calorie');
    return rows.map(CalorieLog.fromJson).toList();
  }

  Future<List<DailyQuest>> loadDailyQuests() async {
    final db = await _db.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final rows = await db.query(
      'daily_quests',
      where: 'created_at >= ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch],
      orderBy: 'created_at DESC',
    );
    
    return rows.map((row) {
      final payload = _db.decryptJson(row['ciphertext'] as String);
      return DailyQuest.fromJson({
        ...payload,
        'id': row['id'],
        'completedAt': row['completed_at'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(row['completed_at'] as int).toIso8601String()
            : null,
      });
    }).toList();
  }

  Future<void> saveDailyQuest(DailyQuest quest) async {
    final db = await _db.database;
    final now = DateTime.now();
    
    await db.insert(
      'daily_quests',
      {
        'id': quest.id,
        'title': quest.title,
        'description': quest.description,
        'xp_reward': quest.xpReward,
        'target_value': quest.targetValue,
        'current_value': quest.currentValue,
        'quest_type': quest.questType.name,
        'completed_at': quest.completedAt?.millisecondsSinceEpoch,
        'created_at': now.millisecondsSinceEpoch,
        'ciphertext': _db.encryptJson(quest.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Exercise>> loadExercises() async {
    final db = await _db.database;
    final rows = await db.query('exercises', orderBy: 'name ASC');
    
    return rows.map((row) {
      final payload = _db.decryptJson(row['ciphertext'] as String);
      return Exercise.fromJson({
        ...payload,
        'id': row['id'],
      });
    }).toList();
  }

  Future<void> saveExercise(Exercise exercise) async {
    final db = await _db.database;
    
    await db.insert(
      'exercises',
      {
        'id': exercise.id,
        'name': exercise.name,
        'category': exercise.category.name,
        'muscle_groups': exercise.muscleGroups.join(','),
        'equipment': exercise.equipment,
        'difficulty': exercise.difficulty.name,
        'is_premium': exercise.isPremium ? 1 : 0,
        'media_url': exercise.mediaUrl,
        'instructions': exercise.instructions,
        'ciphertext': _db.encryptJson(exercise.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Routine>> loadRoutines() async {
    final db = await _db.database;
    final rows = await db.query('routines', orderBy: 'created_at DESC');
    
    return rows.map((row) {
      final payload = _db.decryptJson(row['ciphertext'] as String);
      return Routine.fromJson({
        ...payload,
        'id': row['id'],
        'createdAt': DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int).toIso8601String(),
      });
    }).toList();
  }

  Future<void> saveRoutine(Routine routine) async {
    final db = await _db.database;
    
    await db.insert(
      'routines',
      {
        'id': routine.id,
        'name': routine.name,
        'description': routine.description,
        'is_premium': routine.isPremium ? 1 : 0,
        'created_at': routine.createdAt.millisecondsSinceEpoch,
        'ciphertext': _db.encryptJson(routine.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    for (var i = 0; i < routine.exerciseIds.length; i++) {
      final exerciseId = routine.exerciseIds[i];
      await db.insert(
        'routine_exercises',
        {
          'routine_id': routine.id,
          'exercise_id': exerciseId,
          'order_index': i,
          'ciphertext': _db.encryptJson({
            'routineId': routine.id,
            'exerciseId': exerciseId,
            'orderIndex': i,
          }),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Exercise>> loadExercisesForRoutine(String routineId) async {
    final db = await _db.database;
    final rows = await db.query(
      'routine_exercises',
      where: 'routine_id = ?',
      whereArgs: [routineId],
      orderBy: 'order_index ASC',
    );
    
    final exerciseIds = rows.map((row) => row['exercise_id'] as String).toList();
    final allExercises = await loadExercises();
    
    return allExercises.where((ex) => exerciseIds.contains(ex.id)).toList();
  }

  String generateUuid() => _uuid.v4();

  Future<String> exportForClinician() => _db.exportEncryptedBundle();
}
