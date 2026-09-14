import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/controls.dart';
import '../../widgets/fitpro_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    return session.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (data) {
        final profile = data.profile;
        final pro = data.subscription.isAiPro;
        final currentXp = profile.userXp % 100;
        final xpNeeded = 100 - currentXp;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FitproHeader(subtitle: 'YOU'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Profile Header Card
                        GlassCard(
                          accent: pro ? AppColors.lime : AppColors.electric,
                          child: Row(
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: pro ? AppColors.lime : AppColors.electric,
                                    width: 2,
                                  ),
                                  image: const DecorationImage(
                                    image: NetworkImage(
                                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.displayName,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: (pro ? AppColors.lime : AppColors.electric)
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            pro ? '⚡ AI PRO ATHLETE' : 'CORE ATHLETE',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: pro ? AppColors.lime : AppColors.electricSoft,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          '🔒 ENCRYPTED',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Gamification XP & Leveling Card
                        Hero(
                          tag: 'xp-level-card',
                          child: GlassCard(
                            accent: AppColors.lime,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [AppColors.lime, AppColors.limeDeep],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.lime.withValues(alpha: 0.4),
                                            blurRadius: 16,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'LVL ${profile.userLevel}',
                                          style: const TextStyle(
                                            fontSize: 15,
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
                                            'ATHLETE ATHLETIC LEVEL',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textMuted,
                                              letterSpacing: 0.9,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${profile.userXp} Total XP',
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.lime,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: currentXp / 100,
                                    minHeight: 8,
                                    backgroundColor: AppColors.surfaceMuted,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      AppColors.lime,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$currentXp / 100 XP',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    Text(
                                      '$xpNeeded XP to Level ${profile.userLevel + 1}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.lime,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Encrypted Health Vault Stats Grid
                        const Text(
                          'LOCAL HEALTH VAULT STATUS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),

                        GlassCard(
                          child: Column(
                            children: [
                              _VaultRow(
                                icon: Icons.security,
                                label: 'Biometric Encryption',
                                value: 'AES-256 + SQLite',
                                valueColor: AppColors.lime,
                              ),
                              const Divider(color: AppColors.stroke, height: 16),
                              _VaultRow(
                                icon: Icons.privacy_tip_outlined,
                                label: 'Data Monetization',
                                value: 'Zero / Never Sold',
                                valueColor: AppColors.success,
                              ),
                              const Divider(color: AppColors.stroke, height: 16),
                              _VaultRow(
                                icon: Icons.fitness_center,
                                label: 'Strength Sets Logged',
                                value: '${data.lifts.length}',
                              ),
                              const Divider(color: AppColors.stroke, height: 16),
                              _VaultRow(
                                icon: Icons.directions_run,
                                label: 'Cardio Telemetry Logged',
                                value: '${data.runs.length}',
                              ),
                              const Divider(color: AppColors.stroke, height: 16),
                              _VaultRow(
                                icon: Icons.restaurant,
                                label: 'Fuel Entries Synced',
                                value: '${data.calories.length}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons
                        const Text(
                          'ATHLETE CONTROLS & PLANS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),

                        NeonButton(
                          label: 'Set Goals & Metrics',
                          icon: Icons.track_changes,
                          onPressed: () => context.push('/goals'),
                        ),
                        const SizedBox(height: 12),

                        NeonButton(
                          label: 'Build Workout Routine',
                          icon: Icons.fitness_center,
                          lime: true,
                          onPressed: () => context.push('/routine-builder'),
                        ),
                        const SizedBox(height: 12),

                        InkWell(
                          onTap: () => context.push(
                            '/paywall',
                            extra: computePaywallReason(data.readiness, data.plan),
                          ),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: pro ? AppColors.lime : AppColors.electric,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star_outline,
                                  color: pro ? AppColors.lime : AppColors.electricSoft,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  pro ? 'Manage AI Pro Subscription' : 'Upgrade to AI Pro',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: pro ? AppColors.lime : AppColors.electricSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Privacy Commitment Notice
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.stroke),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: AppColors.textMuted,
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'FITPRO never requires a subscription to keep your history. Your biometric telemetry remains encrypted locally on your device.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
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

class _VaultRow extends StatelessWidget {
  const _VaultRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = AppColors.text,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 16),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
