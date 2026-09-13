import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/controls.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'Male';
  String _goal = 'Maintain';

  @override
  void initState() {
    super.initState();
    _loadCurrentValues();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _loadCurrentValues() {
    final session = ref.read(appSessionProvider).valueOrNull;
    if (session == null) return;
    final profile = session.profile;
    
    if (profile.heightCm != null) {
      _heightController.text = profile.heightCm.toString();
    }
    if (profile.weightKg != null) {
      _weightController.text = profile.weightKg.toString();
    }
    if (profile.age != null) {
      _ageController.text = profile.age.toString();
    }
    if (profile.gender != null) {
      _gender = profile.gender!;
    }
    if (profile.fitnessGoal != null) {
      _goal = profile.fitnessGoal!;
    }
  }

  Future<void> _saveGoals() async {
    if (!_formKey.currentState!.validate()) return;

    final current = ref.read(appSessionProvider).valueOrNull;
    if (current == null) return;

    final profile = current.profile.copyWith(
      heightCm: int.parse(_heightController.text),
      weightKg: double.parse(_weightController.text),
      age: int.parse(_ageController.text),
      gender: _gender,
      fitnessGoal: _goal,
    );

    await ref.read(appSessionProvider.notifier).updateProfile(profile);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goals saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  int _calculateBMR() {
    final height = int.tryParse(_heightController.text) ?? 170;
    final weight = double.tryParse(_weightController.text) ?? 70;
    final age = int.tryParse(_ageController.text) ?? 30;
    
    double bmr;
    if (_gender.toLowerCase() == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
    
    return bmr.round();
  }

  int _calculateTDEE() {
    final bmr = _calculateBMR();
    final activityMultiplier = 1.2;
    return (bmr * activityMultiplier).round();
  }

  int _calculateTargetCalories() {
    final tdee = _calculateTDEE();
    switch (_goal.toLowerCase()) {
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
    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: AppBar(
        title: const Text('Goals & Metrics'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Body Metrics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lime,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.text),
                        decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                          hintText: '175',
                          suffixText: 'cm',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your height';
                          }
                          final height = int.tryParse(value);
                          if (height == null || height < 100 || height > 250) {
                            return 'Please enter a valid height (100-250 cm)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.text),
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          hintText: '70',
                          suffixText: 'kg',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your weight';
                          }
                          final weight = double.tryParse(value);
                          if (weight == null || weight < 30 || weight > 200) {
                            return 'Please enter a valid weight (30-200 kg)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.text),
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          hintText: '30',
                          suffixText: 'years',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your age';
                          }
                          final age = int.tryParse(value);
                          if (age == null || age < 16 || age > 100) {
                            return 'Please enter a valid age (16-100)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Gender',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _GenderOption(
                            label: 'Male',
                            selected: _gender == 'Male',
                            onTap: () => setState(() => _gender = 'Male'),
                          ),
                          const SizedBox(width: 12),
                          _GenderOption(
                            label: 'Female',
                            selected: _gender == 'Female',
                            onTap: () => setState(() => _gender = 'Female'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fitness Goal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.electric,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _GoalOption(
                        label: 'Lose Weight',
                        description: 'Calorie deficit for fat loss',
                        selected: _goal == 'Lose',
                        onTap: () => setState(() => _goal = 'Lose'),
                      ),
                      const SizedBox(height: 8),
                      _GoalOption(
                        label: 'Maintain',
                        description: 'Keep current weight',
                        selected: _goal == 'Maintain',
                        onTap: () => setState(() => _goal = 'Maintain'),
                      ),
                      const SizedBox(height: 8),
                      _GoalOption(
                        label: 'Gain Muscle',
                        description: 'Calorie surplus for muscle building',
                        selected: _goal == 'Gain',
                        onTap: () => setState(() => _goal = 'Gain'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GlassCard(
                  accent: AppColors.lime,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calculated Targets',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lime,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _MetricRow(
                        label: 'BMR (Basal Metabolic Rate)',
                        value: '${_calculateBMR()} kcal',
                        accent: AppColors.electric,
                      ),
                      const SizedBox(height: 12),
                      _MetricRow(
                        label: 'TDEE (Total Daily Energy)',
                        value: '${_calculateTDEE()} kcal',
                        accent: AppColors.electricSoft,
                      ),
                      const SizedBox(height: 12),
                      _MetricRow(
                        label: 'Daily Calorie Target',
                        value: '${_calculateTargetCalories()} kcal',
                        accent: AppColors.lime,
                        isHighlight: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                NeonButton(
                  label: 'Save Goals',
                  onPressed: _saveGoals,
                  icon: Icons.save,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.electric : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.electric : AppColors.stroke,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.black : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  const _GoalOption({
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.lime.withValues(alpha: 0.15) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.lime : AppColors.stroke,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? AppColors.lime : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.lime : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    required this.accent,
    this.isHighlight = false,
  });

  final String label;
  final String value;
  final Color accent;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isHighlight ? AppColors.lime : AppColors.textMuted,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: accent,
          ),
        ),
      ],
    );
  }
}