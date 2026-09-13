import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/controls.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider).valueOrNull;
    final pro = session?.subscription.isAiPro ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Flexible plan'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const Text(
            'Keep logging free. Pay only if the coach should see around corners.',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.2),
          ),
          const SizedBox(height: 8),
          const Text(
            'Built against subscription fatigue: core tracking never locks.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          const _PlanCard(
            title: 'Core — Free',
            price: '\$0',
            highlight: false,
            perks: [
              'Weight, run, and calorie logging',
              'Daily readiness score',
              'On-device encrypted vault',
              'Guided mobility routines',
              'AI workout from sleep + fatigue',
            ],
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: 'AI Pro',
            price: '\$${AppConstants.premiumPrice.toStringAsFixed(2)}/mo',
            highlight: true,
            perks: const [
              'Predictive injury analysis',
              'Telehealth clinician export',
              'Priority coach adaptations',
              'Still zero data selling',
            ],
          ),
          const SizedBox(height: 20),
          if (pro)
            const GlassCard(
              accent: AppColors.lime,
              child: Text(
                'AI Pro is active on this device. Cancel anytime in store settings — logs stay free either way.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          else
            NeonButton(
              label: 'Start AI Pro — \$4.99/mo',
              lime: true,
              onPressed: () async {
                await ref.read(appSessionProvider.notifier).activateAiPro();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.lime,
                      content: Text(
                        'AI Pro unlocked (simulated purchase)',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                  context.pop();
                }
              },
            ),
          const SizedBox(height: 12),
          const Text(
            'Simulated IAP for this build. Wire StoreKit / Play Billing to AppConstants.premiumSku.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.perks,
    required this.highlight,
  });

  final String title;
  final String price;
  final List<String> perks;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      accent: highlight ? AppColors.lime : AppColors.electric,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(
                price,
                style: TextStyle(
                  color: highlight ? AppColors.lime : AppColors.electricSoft,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...perks.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: highlight ? AppColors.lime : AppColors.electric,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(p)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
