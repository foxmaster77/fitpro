import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/controls.dart';
import '../../widgets/fitpro_header.dart';
import '../../widgets/log_success_burst.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  // Lift state
  String _selectedExercise = 'Back squat';
  int _sets = 4;
  int _reps = 6;
  double _weight = 80;

  // Run state
  double _runDistance = 5.0;
  String _presetDistance = '5K';
  final int _runMinutes = 28;

  // Fuel state
  int _fuelCalories = 650;
  String _selectedMeal = 'Lunch + snacks';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
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
        final activeTab = _tabs.index;

        return Column(
          children: [
            FitproHeader(
              subtitle: activeTab == 1 ? 'COACH' : 'LOG',
            ),
            LogSuccessBurst(tick: tick),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                children: [
                  // Top Badges depend on active tab
                  if (activeTab == 0) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.lime.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.swap_horizontal_circle_outlined,
                                color: AppColors.lime,
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'BIOMETRIC SINGULARITY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.lime,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else if (activeTab == 1) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.stroke),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                color: AppColors.textMuted,
                                size: 8,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'CARDIO & KINEMATICS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                  letterSpacing: 0.9,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.edit_outlined,
                                color: AppColors.textMuted,
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.stroke),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: AppColors.lime,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'ENCLAVE SECURE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.lime,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lime.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.lime.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                color: AppColors.lime,
                                size: 8,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'NUTRITION & MACROS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.lime,
                                  letterSpacing: 0.9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.stroke),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sync,
                                color: AppColors.electricSoft,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'METABOLIC VAULT • LIVE SYNC',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.electricSoft,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),

                  // Title & Subtitle
                  Text(
                    activeTab == 1 ? 'Unified Tracking' : 'Unified Health Tracking',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Lifts, runs, and calories — one vault, zero app-hopping.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Lift Carousel Cards (Shown on Lift Tab - Image 5)
                  if (activeTab == 0) ...[
                    SizedBox(
                      height: 84,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _EngineCard(
                            title: 'LIFT ENGINE',
                            active: true,
                            accent: AppColors.lime,
                          ),
                          const SizedBox(width: 10),
                          _EngineCard(
                            title: 'RUN ROUTE',
                            active: false,
                            accent: AppColors.electric,
                          ),
                          const SizedBox(width: 10),
                          _EngineCard(
                            title: 'FUEL BURN',
                            active: false,
                            accent: AppColors.warning,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Tab Switcher Pills: Lift | Run | Fuel
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _tabs.index = 0),
                            borderRadius: BorderRadius.circular(26),
                            child: Container(
                              decoration: BoxDecoration(
                                color: activeTab == 0
                                    ? AppColors.lime
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.fitness_center,
                                      size: 18,
                                      color: activeTab == 0
                                          ? Colors.black
                                          : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Lift',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: activeTab == 0
                                            ? Colors.black
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _tabs.index = 1),
                            borderRadius: BorderRadius.circular(26),
                            child: Container(
                              decoration: BoxDecoration(
                                color: activeTab == 1
                                    ? AppColors.electric
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: activeTab == 1
                                    ? [
                                        BoxShadow(
                                          color: AppColors.electric.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.directions_run,
                                      size: 18,
                                      color: activeTab == 1
                                          ? Colors.white
                                          : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'RUN •',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: activeTab == 1
                                            ? Colors.white
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _tabs.index = 2),
                            borderRadius: BorderRadius.circular(26),
                            child: Container(
                              decoration: BoxDecoration(
                                color: activeTab == 2
                                    ? AppColors.lime
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.restaurant,
                                      size: 18,
                                      color: activeTab == 2
                                          ? Colors.black
                                          : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Fuel',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: activeTab == 2
                                            ? Colors.black
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // TAB CONTENT
                  if (activeTab == 0) ...[
                    // LIFT TAB (Image 5)
                    _buildLiftTabContent(data),
                  ] else if (activeTab == 1) ...[
                    // RUN TAB (Image 2)
                    _buildRunTabContent(data),
                  ] else ...[
                    // FUEL TAB (Image 1)
                    _buildFuelTabContent(data),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------
  // LIFT TAB CONTENT (Image 5)
  // ----------------------------------------------------
  Widget _buildLiftTabContent(AppSession data) {
    return Column(
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.lime,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Record Active Set',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        'HYPERTROPHY BLOCK A',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: const Text(
                      'SET 4 OF 5',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lime,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Exercise Dropdown / Selector
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: AppColors.lime,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EXERCISE SELECTED',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted,
                              letterSpacing: 0.9,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedExercise,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropdownButton<String>(
                      value: _selectedExercise,
                      underline: const SizedBox.shrink(),
                      dropdownColor: AppColors.surfaceElevated,
                      icon: const Row(
                        children: [
                          Text(
                            'SWITCH ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                        ],
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Back squat',
                          child: Text('Back squat'),
                        ),
                        DropdownMenuItem(
                          value: 'Front squat',
                          child: Text('Front squat'),
                        ),
                        DropdownMenuItem(
                          value: 'Deadlift',
                          child: Text('Deadlift'),
                        ),
                        DropdownMenuItem(
                          value: 'Bench press',
                          child: Text('Bench press'),
                        ),
                        DropdownMenuItem(
                          value: 'Barbell Row',
                          child: Text('Barbell Row'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedExercise = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3 Steppers: SETS | REPS | LOAD
              Row(
                children: [
                  Expanded(
                    child: _NumberStepperCard(
                      label: 'SETS',
                      value: '$_sets',
                      subtext: 'Target: 4',
                      onDecrement: () => setState(() {
                        if (_sets > 1) _sets--;
                      }),
                      onIncrement: () => setState(() => _sets++),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _NumberStepperCard(
                      label: 'REPS',
                      value: '$_reps',
                      subtext: 'RPE 8.5',
                      onDecrement: () => setState(() {
                        if (_reps > 1) _reps--;
                      }),
                      onIncrement: () => setState(() => _reps++),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _NumberStepperCard(
                      label: 'LOAD (KG)',
                      value: '${_weight.toInt()}',
                      subtext: '+5kg vs Last',
                      subtextColor: AppColors.lime,
                      onDecrement: () => setState(() {
                        if (_weight >= 2.5) _weight -= 2.5;
                      }),
                      onIncrement: () => setState(() => _weight += 2.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Button: Log set
              NeonButton(
                label: 'Log set',
                icon: Icons.check,
                lime: true,
                onPressed: () async {
                  await ref
                      .read(appSessionProvider.notifier)
                      .logLift(
                        exercise: _selectedExercise,
                        sets: _sets,
                        reps: _reps,
                        weightKg: _weight,
                      );
                  await _celebrate();
                  if (mounted) {
                    context.push('/workout-complete');
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Daily Balance Vault (Calorie & Cardio Telemetry)
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.show_chart,
                    color: AppColors.electric,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Balance Vault',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        'CALORIE & CARDIO TELEMETRY',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.electric.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'LIVE SYNC',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.electricSoft,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Ring display inside Balance Vault
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 86,
                          height: 86,
                          child: CircularProgressIndicator(
                            value: 0.1,
                            strokeWidth: 8,
                            backgroundColor: AppColors.surfaceMuted,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.lime,
                            ),
                          ),
                        ),
                        const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '0',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.text,
                              ),
                            ),
                            Text(
                              'KCAL IN',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'BUDGET STATUS ',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textMuted,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Spacer(),
                            Text(
                              'Target 2,000',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.electricSoft,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '2,000',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.text,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'kcal left',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          '0 kcal consumed today.\nDynamic ceiling adjusts wit...',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              color: AppColors.electricSoft,
                              size: 8,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'READY FOR FUEL ENTRY',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.electricSoft,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: AppColors.stroke, height: 1),
              const SizedBox(height: 12),

              const Text(
                'TELEMETRY RECORDED TODAY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 0.9,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.stroke),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.directions_run,
                            color: AppColors.electric,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '5.0 km Morning...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '28:14 • 5\'38"/km',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.stroke),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            color: AppColors.lime,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '3 Sets Recorded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.lime,
                                  ),
                                ),
                                Text(
                                  'Back Squat • 240kg Σ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Auto-sync notice box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.stroke),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.lime,
                size: 16,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Vault auto-syncs with your Apple Watch & Whoop 4.0',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Icon(
                Icons.check_circle_outline,
                color: AppColors.textMuted,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // RUN TAB CONTENT (Image 2)
  // ----------------------------------------------------
  Widget _buildRunTabContent(AppSession data) {
    return Column(
      children: [
        // Satellite Kinematics Card
        GlassCard(
          accent: AppColors.electric,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.radar_outlined,
                    color: AppColors.electricSoft,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SATELLITE KINEMATICS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.9,
                        ),
                      ),
                      Text(
                        'Presidio Coastal Loop',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          color: AppColors.lime,
                          size: 6,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '4 SAT • STRONG',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Elevation wave graphic container
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: CustomPaint(
                  painter: _GpsElevationWavePainter(),
                ),
              ),
              const SizedBox(height: 14),

              // Sub-mode pills: OUTDOOR GPS | TREADMILL | INTERVALS
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.electric,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.electric.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cell_tower,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'OUTDOOR GPS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.stroke),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              color: AppColors.textMuted,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'TREADMILL',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.stroke),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: AppColors.textMuted,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'INTERVALS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Log Run Telemetry Card
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.tune,
                    color: AppColors.lime,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log Run Telemetry',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        'MANUAL ENTRY • AUTO-SYNC ENABLED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt,
                          color: AppColors.electricSoft,
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'GARMIN • STRAVA',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Primary Displacement Stepper Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PRIMARY DISPLACEMENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                            letterSpacing: 0.9,
                          ),
                        ),
                        Text(
                          'METRIC (KM)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _RoundStepBtn(
                          icon: Icons.remove,
                          onTap: () => setState(() {
                            if (_runDistance >= 0.5) _runDistance -= 0.5;
                          }),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _runDistance.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'km',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.lime,
                              ),
                            ),
                          ],
                        ),
                        _RoundStepBtn(
                          icon: Icons.add,
                          onTap: () => setState(() => _runDistance += 0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Distance Presets: 3K | 5K | 10K | HALF
                    Row(
                      children: [
                        _PresetBtn(
                          label: '3K',
                          selected: _presetDistance == '3K',
                          onTap: () => setState(() {
                            _presetDistance = '3K';
                            _runDistance = 3.0;
                          }),
                        ),
                        const SizedBox(width: 8),
                        _PresetBtn(
                          label: '5K',
                          selected: _presetDistance == '5K',
                          onTap: () => setState(() {
                            _presetDistance = '5K';
                            _runDistance = 5.0;
                          }),
                        ),
                        const SizedBox(width: 8),
                        _PresetBtn(
                          label: '10K',
                          selected: _presetDistance == '10K',
                          onTap: () => setState(() {
                            _presetDistance = '10K';
                            _runDistance = 10.0;
                          }),
                        ),
                        const SizedBox(width: 8),
                        _PresetBtn(
                          label: 'HALF',
                          selected: _presetDistance == 'HALF',
                          onTap: () => setState(() {
                            _presetDistance = 'HALF';
                            _runDistance = 21.1;
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2x2 Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.8,
                children: const [
                  _RunStatCard(
                    title: 'ELAPSED TIME',
                    value: '28',
                    unit: 'm ',
                    subValue: '14',
                    subUnit: 's',
                    badge: 'STOPWATCH SYNCED',
                  ),
                  _RunStatCard(
                    title: 'AVG PACE',
                    value: "5'38\"",
                    unit: ' /km',
                    badge: 'AEROBIC TEMPO',
                    badgeColor: AppColors.lime,
                  ),
                  _RunStatCard(
                    icon: Icons.favorite_outline,
                    iconColor: AppColors.danger,
                    title: 'AVG HEART RATE',
                    value: '154',
                    unit: ' BPM ',
                    subText: '(Z4)',
                    subTextColor: AppColors.danger,
                  ),
                  _RunStatCard(
                    icon: Icons.terrain_outlined,
                    iconColor: AppColors.electricSoft,
                    title: 'ELEVATION GAIN',
                    value: '+62',
                    unit: ' M',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Button: LOG RUN (+380 KCAL VAULT CREDIT) ->
              NeonButton(
                label: 'LOG RUN (+380 KCAL VAULT CREDIT) ➔',
                icon: Icons.directions_run,
                lime: true,
                onPressed: () async {
                  await ref
                      .read(appSessionProvider.notifier)
                      .logRun(
                        distanceKm: _runDistance,
                        minutes: _runMinutes,
                      );
                  await _celebrate();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Biometric Impact Card
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: AppColors.electricSoft,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biometric Impact',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        'PHYSIOLOGICAL KINEMATICS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: const Text(
                      'TE: 3.8 IMPACT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lime,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Aerobic Training Stimulus',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const Text(
                    'Highly Improving',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.lime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 8,
                  width: double.infinity,
                  color: AppColors.surfaceMuted,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.75,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.electric, AppColors.lime],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Synced status box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.bolt,
                      color: AppColors.lime,
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '380 kcal Synced to Fuel Vault',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            'New daily budget: 2,840 kcal remaining',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle_outline,
                      color: AppColors.lime,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.stroke),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AVG CADENCE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted,
                            ),
                          ),
                          SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '168',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.text,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'spm',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.electricSoft,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Optimal ground contact',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.electricSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.stroke),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PEAK SPLIT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted,
                            ),
                          ),
                          SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                "5'18\"",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.lime,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'KM 4',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.lime,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '-20s negative split',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.lime,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Section: RECENT CARDIO TELEMETRY
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.history,
                  color: AppColors.textMuted,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'RECENT CARDIO TELEMETRY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                    letterSpacing: 0.9,
                  ),
                ),
              ],
            ),
            Text(
              'VIEW ALL (34)',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.lime.withValues(alpha: 0.9),
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        _CardioTelemetryItem(
          icon: Icons.directions_run,
          title: 'Morning Tempo Run',
          tag: 'TODAY',
          tagColor: AppColors.lime,
          details: "5.00 km • 28:14 • 5'38\"/km • 380 kcal",
          device: 'Apple Watch',
        ),
        const SizedBox(height: 8),
        _CardioTelemetryItem(
          icon: Icons.terrain,
          title: 'Recovery Trail Jog',
          tag: 'YESTERDAY',
          tagColor: AppColors.textMuted,
          details: "4.20 km • 26:10 • 6'13\"/km • 310 kcal",
          device: 'Garmin Epix',
        ),
        const SizedBox(height: 16),

        // Security / Enclave Notice Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.stroke),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.shield_outlined,
                color: AppColors.electricSoft,
                size: 18,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ZERO-KNOWLEDGE GPS ENCLAVE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        letterSpacing: 0.9,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Route coordinates and biometric tracks are hardware-encrypted locally on your device (AES-256). FITPRO never sells or transmits kinematic geometry to third-party ad brokers.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // FUEL TAB CONTENT (Image 1)
  // ----------------------------------------------------
  Widget _buildFuelTabContent(AppSession data) {
    return Column(
      children: [
        // Daily Fuel Target Card (ACTIVE BUDGET)
        GlassCard(
          accent: AppColors.lime,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACTIVE BUDGET',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.9,
                        ),
                      ),
                      Text(
                        'Daily Fuel Target',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.lime.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt,
                          color: AppColors.lime,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'DYNAMIC SURPLUS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.lime,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Large Circular Ring Display
              Center(
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 210,
                        height: 210,
                        child: CustomPaint(
                          painter: _FuelRingPainter(
                            progress: 1450 / 2000,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '1,450',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: AppColors.text,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'KCAL CONSUMED',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.lime,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.stroke),
                            ),
                            child: const Text(
                              '550 kcal left',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.electricSoft,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sub-row: Morning 5K + Heavy Squats +320 kcal
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: AppColors.lime,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Morning 5K + Heavy Squats',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    Text(
                      '+320 kcal',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.lime,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Macros breakdown (3 progress bars side by side)
              Row(
                children: [
                  Expanded(
                    child: _MacroBarCard(
                      label: 'PROTEIN',
                      percent: '78%',
                      value: '140',
                      target: '/180g',
                      progress: 0.78,
                      barColor: const Color(0xFF9B8CFF),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MacroBarCard(
                      label: 'CARBS',
                      percent: '75%',
                      value: '165',
                      target: '/220g',
                      progress: 0.75,
                      barColor: AppColors.lime,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MacroBarCard(
                      label: 'FATS',
                      percent: '74%',
                      value: '48',
                      target: '/65g',
                      progress: 0.74,
                      barColor: const Color(0xFFB0A8F8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Log Meal Card
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.lime,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Log Meal or Calories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.electricSoft,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'AI Snap',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.electricSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Meal type selection pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _MealTypePill(
                      label: 'Breakfast',
                      selected: _selectedMeal == 'Breakfast',
                      onTap: () => setState(() => _selectedMeal = 'Breakfast'),
                    ),
                    const SizedBox(width: 8),
                    _MealTypePill(
                      label: 'Lunch + snacks',
                      selected: _selectedMeal == 'Lunch + snacks',
                      onTap: () =>
                          setState(() => _selectedMeal = 'Lunch + snacks'),
                    ),
                    const SizedBox(width: 8),
                    _MealTypePill(
                      label: 'Dinner',
                      selected: _selectedMeal == 'Dinner',
                      onTap: () => setState(() => _selectedMeal = 'Dinner'),
                    ),
                    const SizedBox(width: 8),
                    _MealTypePill(
                      label: 'Post-Workout',
                      selected: _selectedMeal == 'Post-Workout',
                      onTap: () =>
                          setState(() => _selectedMeal = 'Post-Workout'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Calorie Intake Stepper Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CALORIE INTAKE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 0.9,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$_fuelCalories',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'kcal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.lime,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _RoundStepBtn(
                              icon: Icons.remove,
                              onTap: () => setState(() {
                                if (_fuelCalories >= 50) _fuelCalories -= 50;
                              }),
                            ),
                            const SizedBox(width: 10),
                            _RoundStepBtn(
                              icon: Icons.add,
                              onTap: () => setState(() => _fuelCalories += 50),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    NeonButton(
                      label: 'Log fuel',
                      icon: Icons.local_fire_department,
                      lime: true,
                      onPressed: () async {
                        await ref
                            .read(appSessionProvider.notifier)
                            .logCalories(
                              calories: _fuelCalories,
                              note: _selectedMeal,
                            );
                        await _celebrate();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EngineCard extends StatelessWidget {
  const _EngineCard({
    required this.title,
    required this.active,
    required this.accent,
  });

  final String title;
  final bool active;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? accent : AppColors.stroke,
          width: active ? 1.5 : 1,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Container(
                height: 4,
                width: 100,
                decoration: BoxDecoration(
                  color: active ? accent : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: active ? accent : AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberStepperCard extends StatelessWidget {
  const _NumberStepperCard({
    required this.label,
    required this.value,
    required this.subtext,
    this.subtextColor = AppColors.textMuted,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final String value;
  final String subtext;
  final Color subtextColor;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: onDecrement,
                child: const Icon(
                  Icons.remove,
                  color: AppColors.textMuted,
                  size: 16,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              InkWell(
                onTap: onIncrement,
                child: const Icon(
                  Icons.add,
                  color: AppColors.textMuted,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: subtextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundStepBtn extends StatelessWidget {
  const _RoundStepBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.stroke),
        ),
        child: Icon(icon, color: AppColors.text, size: 20),
      ),
    );
  }
}

class _PresetBtn extends StatelessWidget {
  const _PresetBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 32,
          decoration: BoxDecoration(
            color: selected ? AppColors.electric : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.electric : AppColors.stroke,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RunStatCard extends StatelessWidget {
  const _RunStatCard({
    this.icon,
    this.iconColor,
    required this.title,
    required this.value,
    this.unit = '',
    this.subValue = '',
    this.subUnit = '',
    this.subText = '',
    this.subTextColor = AppColors.textMuted,
    this.badge,
    this.badgeColor = AppColors.electricSoft,
  });

  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String value;
  final String unit;
  final String subValue;
  final String subUnit;
  final String subText;
  final Color subTextColor;
  final String? badge;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: iconColor, size: 14),
                const SizedBox(width: 4),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: unit,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                if (subValue.isNotEmpty)
                  TextSpan(
                    text: subValue,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                if (subUnit.isNotEmpty)
                  TextSpan(
                    text: subUnit,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                if (subText.isNotEmpty)
                  TextSpan(
                    text: ' $subText',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: subTextColor,
                    ),
                  ),
              ],
            ),
          ),
          if (badge != null)
            Text(
              badge!,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: badgeColor,
                letterSpacing: 0.6,
              ),
            ),
        ],
      ),
    );
  }
}

class _CardioTelemetryItem extends StatelessWidget {
  const _CardioTelemetryItem({
    required this.icon,
    required this.title,
    required this.tag,
    required this.tagColor,
    required this.details,
    required this.device,
  });

  final IconData icon;
  final String title;
  final String tag;
  final Color tagColor;
  final String details;
  final String device;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.stroke),
            ),
            child: Icon(icon, color: AppColors.lime, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tag,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: tagColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            device,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroBarCard extends StatelessWidget {
  const _MacroBarCard({
    required this.label,
    required this.percent,
    required this.value,
    required this.target,
    required this.progress,
    required this.barColor,
  });

  final String label;
  final String percent;
  final String value;
  final String target;
  final double progress;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                percent,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                TextSpan(
                  text: target,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: AppColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealTypePill extends StatelessWidget {
  const _MealTypePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.lime : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.lime : AppColors.stroke,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.black : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _GpsElevationWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.stroke.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    // Draw grid background dots/lines
    for (double i = 20; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double j = 20; j < size.height; j += 25) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
    }

    final path = Path();
    path.moveTo(10, size.height * 0.7);
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.1,
      size.width * 0.7,
      size.height * 0.9,
      size.width - 20,
      size.height * 0.25,
    );

    final lineShader = const LinearGradient(
      colors: [AppColors.electric, AppColors.lime],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..shader = lineShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..shader = lineShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);

    // End point callout dot
    final endPoint = Offset(size.width - 20, size.height * 0.25);
    canvas.drawCircle(
      endPoint,
      5,
      Paint()..color = AppColors.lime,
    );
    canvas.drawCircle(
      endPoint,
      8,
      Paint()
        ..color = AppColors.lime.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Callout box for KM 4 SPLIT
    final textPainter = TextPainter(
      text: const TextSpan(
        text: "KM 4 SPLIT: 5'18\"",
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final bgRect = Rect.fromLTWH(
      endPoint.dx - 90,
      endPoint.dy - 22,
      textPainter.width + 12,
      18,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(6)),
      Paint()..color = Colors.black.withValues(alpha: 0.7),
    );
    textPainter.paint(canvas, Offset(bgRect.left + 6, bgRect.top + 3));

    // Bottom elevation callout pill
    final elevText = TextPainter(
      text: const TextSpan(
        text: "↑ +62m ELEV",
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: AppColors.lime,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    elevText.layout();
    final elevRect = Rect.fromLTWH(15, size.height * 0.7 + 6, elevText.width + 10, 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(elevRect, const Radius.circular(6)),
      Paint()..color = AppColors.surfaceElevated,
    );
    elevText.paint(canvas, Offset(elevRect.left + 5, elevRect.top + 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FuelRingPainter extends CustomPainter {
  _FuelRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 12;

    final trackPaint = Paint()
      ..color = AppColors.surfaceMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final glowPaint = Paint()
      ..color = AppColors.lime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final arcPaint = Paint()
      ..color = AppColors.lime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, sweep, false, glowPaint);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(_FuelRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
