import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/exercise.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/controls.dart';

class RoutineBuilderScreen extends ConsumerStatefulWidget {
  const RoutineBuilderScreen({super.key});

  @override
  ConsumerState<RoutineBuilderScreen> createState() => _RoutineBuilderScreenState();
}

class _RoutineBuilderScreenState extends ConsumerState<RoutineBuilderScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _selectedExerciseIds = [];
  String _searchQuery = '';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveRoutine() async {
    if (_nameController.text.trim().isEmpty || _selectedExerciseIds.isEmpty) {
      return;
    }

    final notifier = ref.read(appSessionProvider.notifier);
    final routine = Routine(
      id: notifier.generateId(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      exerciseIds: _selectedExerciseIds,
      createdAt: DateTime.now(),
    );

    await notifier.saveRoutine(routine);
    
    if (mounted) {
      context.pop();
    }
  }

  List<Exercise> _getFilteredExercises(List<Exercise> exercises) {
    if (_searchQuery.isEmpty) return exercises;
    final query = _searchQuery.toLowerCase();
    return exercises
        .where((ex) =>
            ex.name.toLowerCase().contains(query) ||
            ex.category.name.toLowerCase().contains(query) ||
            ex.muscleGroups.any((mg) => mg.toLowerCase().contains(query)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider).valueOrNull;
    if (session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final library = ref.watch(exerciseLibraryServiceProvider);
    final hasAiPro = ref.watch(aiProEntitlementProvider).maybeWhen(
          data: (active) => active,
          orElse: () => session.subscription.isAiPro,
        );
    final filteredExercises = _getFilteredExercises(session.exercises);

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: AppBar(
        title: const Text('Create Routine'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Routine Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lime,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: AppColors.text),
                      decoration: const InputDecoration(
                        hintText: 'Routine Name',
                        hintStyle: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      style: const TextStyle(color: AppColors.text),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Description (optional)',
                        hintStyle: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Exercises',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(
                    hintText: 'Search exercises...',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedExerciseIds.isNotEmpty)
                GlassCard(
                  accent: AppColors.lime,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Selected',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.lime,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_selectedExerciseIds.length} exercises',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lime,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedExerciseIds.map((id) {
                          final exercise = session.exercises.firstWhere((e) => e.id == id);
                          return _ExerciseChip(
                            exercise: exercise,
                            onRemove: () => setState(() {
                              _selectedExerciseIds.remove(id);
                            }),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              ...filteredExercises.map((exercise) {
                final isSelected = _selectedExerciseIds.contains(exercise.id);
                final isLocked = library.isPaywalled(
                  exercise,
                  hasAiProEntitlement: hasAiPro,
                );
                
                return _ExerciseTile(
                  exercise: exercise,
                  isSelected: isSelected,
                  isLocked: isLocked,
                  onTap: isLocked
                      ? null
                      : () {
                          setState(() {
                            if (isSelected) {
                              _selectedExerciseIds.remove(exercise.id);
                            } else {
                              _selectedExerciseIds.add(exercise.id);
                            }
                          });
                        },
                  onViewDetails: () => context.push('/exercise/${exercise.id}'),
                );
              }),
              const SizedBox(height: 24),
              NeonButton(
                label: 'Save Routine',
                onPressed: _selectedExerciseIds.isNotEmpty ? _saveRoutine : null,
                icon: Icons.save,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({
    required this.exercise,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
    required this.onViewDetails,
  });

  final Exercise exercise;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback? onTap;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.lime
              : isLocked
                  ? AppColors.danger
                  : AppColors.stroke,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.lime.withValues(alpha: 0.2)
                    : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isLocked ? Icons.lock : Icons.fitness_center,
                color: isSelected
                    ? AppColors.lime
                    : isLocked
                        ? AppColors.danger
                        : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isLocked ? AppColors.textMuted : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${exercise.category.name} • ${exercise.difficulty.name}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle, color: AppColors.lime, size: 24),
          if (isLocked)
            const Icon(Icons.lock, color: AppColors.danger, size: 24),
          if (!isLocked)
            IconButton(
              icon: const Icon(Icons.info_outline, color: AppColors.electric),
              onPressed: onViewDetails,
            ),
        ],
      ),
    );
  }
}

class _ExerciseChip extends StatelessWidget {
  const _ExerciseChip({
    required this.exercise,
    required this.onRemove,
  });

  final Exercise exercise;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lime.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lime.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            exercise.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.lime,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.lime,
            ),
          ),
        ],
      ),
    );
  }
}