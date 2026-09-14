import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../data/models/exercise.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/controls.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider).valueOrNull;
    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final library = ref.watch(exerciseLibraryServiceProvider);
    final hasAiPro = ref
        .watch(aiProEntitlementProvider)
        .maybeWhen(
          data: (active) => active,
          orElse: () => session.subscription.isAiPro,
        );

    final exercise = session.exercises.firstWhere(
      (e) => e.id == exerciseId,
      orElse: () => Exercise(
        id: '',
        name: 'Unknown',
        category: ExerciseCategory.strength,
        muscleGroups: [],
        equipment: 'None',
        difficulty: ExerciseDifficulty.beginner,
      ),
    );

    final isPremium = exercise.isPremium;
    final isProUser = hasAiPro;
    final isLocked = library.isPaywalled(
      exercise,
      hasAiProEntitlement: hasAiPro,
    );

    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: AppBar(
        title: Text(exercise.name),
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              exercise.category,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getCategoryColor(exercise.category),
                            ),
                          ),
                          child: Text(
                            exercise.category.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _getCategoryColor(exercise.category),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(
                              exercise.difficulty,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getDifficultyColor(exercise.difficulty),
                            ),
                          ),
                          child: Text(
                            exercise.difficulty.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _getDifficultyColor(exercise.difficulty),
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (isPremium)
                          Icon(
                            Icons.workspace_premium,
                            color: isProUser
                                ? AppColors.lime
                                : AppColors.danger,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Equipment: ${exercise.equipment}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (isLocked)
                GlassCard(
                  accent: AppColors.danger,
                  child: Column(
                    children: [
                      const Icon(Icons.lock, size: 48, color: AppColors.danger),
                      const SizedBox(height: 16),
                      const Text(
                        'AI Pro Feature',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Visual form guides are available for AI Pro subscribers',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      NeonButton(
                        label: 'Upgrade to AI Pro',
                        icon: Icons.workspace_premium,
                        onPressed: () => context.push(
                          '/paywall',
                          extra: computePaywallReason(
                            session.readiness,
                            session.plan,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    GlassCard(
                      accent: AppColors.electric,
                      child: Column(
                        children: [
                          const Text(
                            'Visual Form Guide',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.electric,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (exercise.mediaUrl != null &&
                              exercise.mediaUrl!.endsWith('.json'))
                            SizedBox(
                              height: 250,
                              child: Lottie.network(
                                exercise.mediaUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 48,
                                          color: AppColors.danger,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Animation not available',
                                          style: TextStyle(
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            Container(
                              height: 250,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.video_library,
                                      size: 48,
                                      color: AppColors.textMuted,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Video guide coming soon',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Target Muscle Groups',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lime,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: exercise.muscleGroups.map((muscle) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lime.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.lime.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            muscle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lime,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (exercise.instructions != null &&
                  exercise.instructions!.isNotEmpty)
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Instructions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.electric,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        exercise.instructions!,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.strength:
        return AppColors.electric;
      case ExerciseCategory.cardio:
        return AppColors.lime;
      case ExerciseCategory.flexibility:
        return AppColors.success;
      case ExerciseCategory.balance:
        return AppColors.warning;
      case ExerciseCategory.functional:
        return AppColors.danger;
    }
  }

  Color _getDifficultyColor(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return AppColors.success;
      case ExerciseDifficulty.intermediate:
        return AppColors.warning;
      case ExerciseDifficulty.advanced:
        return AppColors.danger;
    }
  }
}
