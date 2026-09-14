import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/health_logs.dart';
import '../../data/models/user_profile.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/controls.dart';
import '../../widgets/log_success_burst.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  final _exercise = TextEditingController(text: 'Back squat');
  final _sets = TextEditingController(text: '4');
  final _reps = TextEditingController(text: '6');
  final _weight = TextEditingController(text: '80');
  final _distance = TextEditingController(text: '5.0');
  final _minutes = TextEditingController(text: '28');
  final _calories = TextEditingController(text: '2100');
  final _note = TextEditingController(text: 'Lunch + snacks');

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _exercise.dispose();
    _sets.dispose();
    _reps.dispose();
    _weight.dispose();
    _distance.dispose();
    _minutes.dispose();
    _calories.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _celebrate() async {
    ref.read(logSuccessTickProvider.notifier).state++;
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    final tick = ref.watch(logSuccessTickProvider);

    return session.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (data) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Unified Health Tracking',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Lifts, runs, and calories — one vault, zero app-hopping.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  LogSuccessBurst(tick: tick),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: TabBar(
                      controller: _tabs,
                      indicator: BoxDecoration(
                        color: AppColors.electric.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: AppColors.lime,
                      unselectedLabelColor: AppColors.textMuted,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(height: 48, text: 'Lift'),
                        Tab(height: 48, text: 'Run'),
                        Tab(height: 48, text: 'Fuel'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _LiftTab(
                    exercise: _exercise,
                    sets: _sets,
                    reps: _reps,
                    weight: _weight,
                    logs: data.lifts,
                    onLog: () async {
                      await ref
                          .read(appSessionProvider.notifier)
                          .logLift(
                            exercise: _exercise.text,
                            sets: int.tryParse(_sets.text) ?? 3,
                            reps: int.tryParse(_reps.text) ?? 8,
                            weightKg: double.tryParse(_weight.text) ?? 0,
                          );
                      await _celebrate();
                    },
                  ),
                  _RunTab(
                    distance: _distance,
                    minutes: _minutes,
                    logs: data.runs,
                    onLog: () async {
                      await ref
                          .read(appSessionProvider.notifier)
                          .logRun(
                            distanceKm: double.tryParse(_distance.text) ?? 0,
                            minutes: int.tryParse(_minutes.text) ?? 0,
                          );
                      await _celebrate();
                    },
                  ),
                  _CalorieTab(
                    calories: _calories,
                    note: _note,
                    logs: data.calories,
                    profile: data.profile,
                    onLog: () async {
                      await ref
                          .read(appSessionProvider.notifier)
                          .logCalories(
                            calories: int.tryParse(_calories.text) ?? 0,
                            note: _note.text,
                          );
                      await _celebrate();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LiftTab extends StatelessWidget {
  const _LiftTab({
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.logs,
    required this.onLog,
  });

  final TextEditingController exercise;
  final TextEditingController sets;
  final TextEditingController reps;
  final TextEditingController weight;
  final List<LiftSet> logs;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        GlassCard(
          child: Column(
            children: [
              TextField(
                controller: exercise,
                decoration: const InputDecoration(hintText: 'Exercise'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: sets,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Sets'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: reps,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Reps'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: weight,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'kg'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              NeonButton(
                label: 'Log set',
                icon: Icons.check,
                lime: true,
                onPressed: onLog,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (logs.isEmpty)
          const _HistoryEmpty(
            message: 'No lifts logged yet — your first set will show up here.',
          )
        else
          ...logs.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.fitness_center, color: AppColors.electric),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${e.exercise}  ${e.sets}×${e.reps} @ ${e.weightKg}kg',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      _relativeTimestamp(e.completedAt),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 280.ms).slideX(begin: 0.04),
            );
          }),
      ],
    );
  }
}

class _RunTab extends StatelessWidget {
  const _RunTab({
    required this.distance,
    required this.minutes,
    required this.logs,
    required this.onLog,
  });

  final TextEditingController distance;
  final TextEditingController minutes;
  final List<RunLog> logs;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        GlassCard(
          accent: AppColors.lime,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: distance,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Distance km',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: minutes,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Time min'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              NeonButton(
                label: 'Log run',
                icon: Icons.directions_run,
                onPressed: onLog,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (logs.isEmpty)
          const _HistoryEmpty(
            message: 'No runs logged yet — your first route will show up here.',
          )
        else
          ...logs.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_run, color: AppColors.lime),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${e.distanceKm} km · ${e.minutes} min',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      _relativeTimestamp(e.completedAt),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _CalorieTab extends StatelessWidget {
  const _CalorieTab({
    required this.calories,
    required this.note,
    required this.logs,
    required this.profile,
    required this.onLog,
  });

  final TextEditingController calories;
  final TextEditingController note;
  final List<CalorieLog> logs;
  final UserProfile profile;
  final VoidCallback onLog;

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

  int _calculateTargetCalories(UserProfile profile) {
    final tdee = _calculateTdee(profile);
    final goal = profile.fitnessGoal?.toLowerCase() ?? 'maintain';

    switch (goal) {
      case 'lose':
        return (tdee * 0.85).round();
      case 'gain':
        return (tdee * 1.15).round();
      default:
        return tdee;
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = logs
        .where((e) {
          final d = e.loggedAt;
          final n = DateTime.now();
          return d.year == n.year && d.month == n.month && d.day == n.day;
        })
        .fold<int>(0, (sum, e) => sum + e.calories);

    final targetCalories = _calculateTargetCalories(profile);
    final progress = (today / targetCalories).clamp(0.0, 1.0);
    final remaining = targetCalories - today;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        GlassCard(
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 180,
                      width: 180,
                      child: CustomPaint(
                        painter: _CalorieProgressPainter(
                          progress: progress,
                          backgroundColor: AppColors.surfaceMuted,
                          progressColor: progress >= 1.0
                              ? AppColors.lime
                              : AppColors.electric,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$today',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: AppColors.text,
                          ),
                        ),
                        const Text(
                          'kcal consumed',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          remaining > 0
                              ? '$remaining remaining'
                              : '${remaining.abs()} over',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: remaining > 0
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Target: $targetCalories kcal',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: calories,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Calories'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: note,
                decoration: const InputDecoration(hintText: 'Meal note'),
              ),
              const SizedBox(height: 14),
              NeonButton(
                label: 'Log fuel',
                icon: Icons.local_fire_department,
                lime: true,
                onPressed: onLog,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (logs.isEmpty)
          const _HistoryEmpty(
            message: 'No fuel logged yet — your first meal will show up here.',
          )
        else
          ...logs.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${e.calories} kcal  ${e.note}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      _relativeTimestamp(e.loggedAt),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Text(message, style: const TextStyle(color: AppColors.textMuted)),
    );
  }
}

String _relativeTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  final date = timestamp.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final entryDay = DateTime(date.year, date.month, date.day);
  final daysAgo = today.difference(entryDay).inDays;
  final time = DateFormat.jm().format(date);
  if (daysAgo == 0) return 'Today, $time';
  if (daysAgo == 1) return 'Yesterday';
  return DateFormat('MMM d, y').format(date);
}

class _CalorieProgressPainter extends CustomPainter {
  _CalorieProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final strokeWidth = 12.0;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center, radius, backgroundPaint);

    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      if (progress >= 1.0) {
        final glowPaint = Paint()
          ..color = progressColor.withValues(alpha: 0.3)
          ..strokeWidth = strokeWidth + 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          sweepAngle,
          false,
          glowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CalorieProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}
