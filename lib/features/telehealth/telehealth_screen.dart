import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/controls.dart';
import '../../widgets/fitpro_header.dart';

class TelehealthScreen extends ConsumerStatefulWidget {
  const TelehealthScreen({super.key});

  @override
  ConsumerState<TelehealthScreen> createState() => _TelehealthScreenState();
}

class _TelehealthScreenState extends ConsumerState<TelehealthScreen> {
  String? _activeId;
  var _exporting = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    return session.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (data) {
        final pro = data.subscription.isAiPro;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FitproHeader(subtitle: 'REHAB'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sub-header Badges
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
                                    Icons.shield_outlined,
                                    color: AppColors.lime,
                                    size: 14,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'PHYSICAL REHAB & MOBILITY',
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
                                    Icons.wifi_off_outlined,
                                    color: AppColors.electricSoft,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'OFFLINE-READY',
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
                        const SizedBox(height: 8),

                        const Text(
                          'Telehealth & Kinematics',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Guided mobility & joint decompression flows. Clinical exports remain hardware-encrypted.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Guided Mobility Routines List
                        ...guidedRoutines.map((routine) {
                          final open = _activeId == routine.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassCard(
                              accent: open ? AppColors.lime : AppColors.electric,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: (open ? AppColors.lime : AppColors.electric)
                                            .withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: (open ? AppColors.lime : AppColors.electric)
                                              .withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          routine.icon,
                                          color: open ? AppColors.lime : AppColors.electricSoft,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      routine.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${routine.area} · ${routine.minutes} min flow',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceElevated,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.stroke),
                                      ),
                                      child: Icon(
                                        open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                        color: open ? AppColors.lime : AppColors.textMuted,
                                        size: 20,
                                      ),
                                    ),
                                    onTap: () => setState(() {
                                      _activeId = open ? null : routine.id;
                                    }),
                                  ),
                                  if (open) ...[
                                    const SizedBox(height: 8),
                                    const Divider(color: AppColors.stroke, height: 1),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'CLINICAL CUES & MOVEMENT PATHWAYS',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textMuted,
                                        letterSpacing: 0.9,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...routine.cues.map(
                                      (cue) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '▸  ',
                                              style: TextStyle(
                                                color: AppColors.lime,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                cue,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: AppColors.text,
                                                  height: 1.3,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    NeonButton(
                                      label: 'Start Guided Flow (${routine.minutes} min)',
                                      icon: Icons.play_arrow_rounded,
                                      lime: true,
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: AppColors.lime,
                                            content: Text(
                                              'Flow Started: ${routine.title} (${routine.minutes} min)',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),

                        // Encrypted Clinician Bundle Export Card
                        GlassCard(
                          accent: AppColors.electric,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.medical_services_outlined,
                                    color: AppColors.electricSoft,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Encrypted Clinician Export',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.text,
                                        ),
                                      ),
                                      Text(
                                        'TELEHEALTH DATA PACK',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textMuted,
                                          letterSpacing: 0.9,
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
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'E2E AES-256',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.electricSoft,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Generates an encrypted payload of your local workout, cardio telemetry, and joint fatigue logs. Raw health metrics never leave your device unencrypted.',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 14),
                              if (!pro)
                                GhostButton(
                                  label: 'AI Pro Required — View Plans',
                                  onPressed: () => context.push(
                                    '/paywall',
                                    extra: computePaywallReason(data.readiness, data.plan),
                                  ),
                                )
                              else
                                NeonButton(
                                  label: _exporting ? 'Encrypting Payload…' : 'Secure Clinician Export',
                                  icon: Icons.lock,
                                  loading: _exporting,
                                  onPressed: () async {
                                    setState(() => _exporting = true);
                                    try {
                                      final blob = await ref
                                          .read(appSessionProvider.notifier)
                                          .clinicianExport();
                                      await Clipboard.setData(
                                        ClipboardData(
                                          text:
                                              'FITPRO-E2E-EXPORT\n${blob.substring(0, blob.length.clamp(0, 120))}…',
                                        ),
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            backgroundColor: AppColors.lime,
                                            content: Text(
                                              'Encrypted payload copied to clipboard. Share only with your clinician.',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted) setState(() => _exporting = false);
                                    }
                                  },
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

class GuidedRoutineItem {
  const GuidedRoutineItem({
    required this.id,
    required this.title,
    required this.area,
    required this.minutes,
    required this.icon,
    required this.cues,
  });

  final String id;
  final String title;
  final String area;
  final int minutes;
  final IconData icon;
  final List<String> cues;
}

final guidedRoutines = [
  const GuidedRoutineItem(
    id: 'quad-hip-flow',
    title: 'Quad & Knee Decompression',
    area: 'Lower Body & Patella',
    minutes: 8,
    icon: Icons.accessibility_new,
    cues: [
      '30s Wall Sit with Quad isometric squeeze',
      '45s Couch Stretch per side focusing on hip extension',
      '60s Tibialis Raise to balance patellar tendon load',
    ],
  ),
  const GuidedRoutineItem(
    id: 'lumbar-spine-flow',
    title: 'Lumbar Spine & Glute Activation',
    area: 'Posterior Chain',
    minutes: 10,
    icon: Icons.airline_seat_recline_extra,
    cues: [
      '60s Cat-Cow thoracic spine mobilization',
      '45s Single-leg Glute Bridge with 2s hold at peak',
      '90s Child Pose with side reach decompression',
    ],
  ),
  const GuidedRoutineItem(
    id: 'thoracic-shoulder-flow',
    title: 'Thoracic Mobility & Overhead Reach',
    area: 'Upper Body & Shoulders',
    minutes: 7,
    icon: Icons.fitness_center,
    cues: [
      '45s Open-book thoracic rotators per side',
      '60s Scapular Wall Slides with chin tucked',
      '45s Banded Face Pulls for posterior deltoid alignment',
    ],
  ),
];
