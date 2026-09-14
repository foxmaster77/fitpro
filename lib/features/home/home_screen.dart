import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/controls.dart';
import '../../widgets/readiness_ring.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    return session.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (data) {
        final generating = ref.watch(generatingWorkoutProvider);
        final readiness = data.readiness;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              sliver: SliverList.list(
                children: [
                  Text(
                    _greeting(data.profile.displayName),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Daily Readiness Score',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),
                  GlassCard(
                    child: Column(
                      children: [
                        ReadinessRing(
                          score: readiness.dailyReadiness,
                          label: readiness.label,
                        ).animate().scale(
                          duration: 500.ms,
                          curve: Curves.easeOutBack,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sleep ${readiness.sleepScore}  ·  Fatigue ${readiness.muscleFatigue}',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Dial today’s inputs',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _SliderCard(
                    title: 'Sleep Score',
                    value: readiness.sleepScore.toDouble(),
                    accent: AppColors.electric,
                    onChanged: (v) => ref
                        .read(appSessionProvider.notifier)
                        .updateReadiness(sleep: v.round()),
                  ),
                  const SizedBox(height: 10),
                  _SliderCard(
                    title: 'Muscle Fatigue',
                    value: readiness.muscleFatigue.toDouble(),
                    accent: AppColors.lime,
                    onChanged: (v) => ref
                        .read(appSessionProvider.notifier)
                        .updateReadiness(fatigue: v.round()),
                  ),
                  const SizedBox(height: 18),
                  NeonButton(
                    label: generating ? 'Coaching…' : 'Generate custom workout',
                    icon: Icons.auto_awesome,
                    loading: generating,
                    onPressed: generating
                        ? null
                        : () async {
                            ref.read(generatingWorkoutProvider.notifier).state =
                                true;
                            try {
                              await ref
                                  .read(appSessionProvider.notifier)
                                  .generateWorkout();
                              final plan = ref
                                  .read(appSessionProvider)
                                  .valueOrNull
                                  ?.plan;
                              if (context.mounted &&
                                  !data.subscription.isAiPro &&
                                  (readiness.dailyReadiness < 45 ||
                                      (plan?.injuryFlags.isNotEmpty ??
                                          false))) {
                                final reason =
                                    plan?.injuryFlags.isNotEmpty == true
                                    ? plan!.injuryFlags.first
                                    : 'Your readiness is ${readiness.dailyReadiness}. AI Pro can adapt today\'s session for recovery.';
                                context.push('/paywall', extra: reason);
                              }
                            } finally {
                              ref
                                      .read(generatingWorkoutProvider.notifier)
                                      .state =
                                  false;
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                  if (data.plan != null)
                    GlassCard(
                      accent: AppColors.lime,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI COACH PLAN',
                            style: TextStyle(
                              color: AppColors.lime,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data.plan!.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.plan!.rationale,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...data.plan!.blocks.map(
                            (b) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.play_circle_fill,
                                color: AppColors.electric,
                              ),
                              title: Text(
                                b.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(b.detail),
                              trailing: Text('${b.minutes}m'),
                            ),
                          ),
                          if (data.subscription.isAiPro) ...[
                            const Divider(height: 24),
                            const Text(
                              'Predictive injury analysis',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            ...data.plan!.injuryFlags.map(
                              (f) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.shield_moon,
                                      color: AppColors.warning,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(f)),
                                  ],
                                ),
                              ),
                            ),
                          ] else
                            TextButton(
                              onPressed: () => context.push('/paywall'),
                              child: Text(
                                data.plan!.injuryFlags.isNotEmpty
                                    ? 'Review this injury precaution with AI Pro'
                                    : 'Unlock injury forecasts with AI Pro',
                              ),
                            ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.08),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _greeting(String name) {
    final hour = DateTime.now().hour;
    final part = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';
    return '$part, $name';
  }
}

class _SliderCard extends StatelessWidget {
  const _SliderCard({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.accent,
  });

  final String title;
  final double value;
  final ValueChanged<double> onChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      accent: accent,
      child: Column(
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                '${value.round()}',
                style: TextStyle(color: accent, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 100,
            activeColor: accent,
            inactiveColor: AppColors.surfaceMuted,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
