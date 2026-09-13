import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/controls.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    return session.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (data) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            Text(
              data.profile.displayName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              data.subscription.isAiPro ? 'AI Pro member' : 'Core (free) member',
              style: const TextStyle(color: AppColors.lime, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            GlassCard(
              accent: AppColors.lime,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.lime,
                              AppColors.limeDeep,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lime.withValues(alpha: 0.4),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'LVL ${data.profile.userLevel}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Experience Points',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${data.profile.userXp} XP',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.lime,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: (data.profile.userXp % 100) / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.lime, AppColors.limeDeep],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${100 - (data.profile.userXp % 100)} XP to next level',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  _row('Vault', 'AES-256 + SQLite on device'),
                  _row('Data selling', 'Never'),
                  _row('Cloud', 'Opt-in ciphertext only'),
                  _row('Lifts logged', '${data.lifts.length}'),
                  _row('Runs logged', '${data.runs.length}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            NeonButton(
              label: 'Set Goals & Metrics',
              icon: Icons.track_changes,
              onPressed: () => context.push('/goals'),
            ),
            const SizedBox(height: 12),
            NeonButton(
              label: 'Build Workout Routine',
              icon: Icons.fitness_center,
              onPressed: () => context.push('/routine-builder'),
            ),
            const SizedBox(height: 12),
            NeonButton(
              label: data.subscription.isAiPro ? 'Manage AI Pro' : 'See AI Pro',
              onPressed: () => context.push('/paywall'),
            ),
            const SizedBox(height: 12),
            const Text(
              'FITPRO never requires a subscription to keep your history. Retention comes from usefulness, not lock-in.',
              style: TextStyle(color: AppColors.textMuted, height: 1.4),
            ),
          ],
        );
      },
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(k, style: const TextStyle(color: AppColors.textMuted)),
          const Spacer(),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
