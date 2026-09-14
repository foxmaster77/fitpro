import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/subscription.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/controls.dart';

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
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            const Text(
              'Telehealth & Rehab',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Guided mobility you can run offline. Clinical export stays encrypted.',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 18),
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
                        title: Text(
                          routine.title,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          '${routine.area} · ${routine.minutes} min',
                        ),
                        trailing: Icon(
                          open ? Icons.expand_less : Icons.expand_more,
                          color: AppColors.lime,
                        ),
                        onTap: () => setState(() {
                          _activeId = open ? null : routine.id;
                        }),
                      ),
                      if (open) ...[
                        const SizedBox(height: 4),
                        ...routine.cues.map(
                          (cue) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '▸  ',
                                  style: TextStyle(color: AppColors.electric),
                                ),
                                Expanded(child: Text(cue)),
                              ],
                            ),
                          ),
                        ),
                        NeonButton(
                          label: 'Start guided flow',
                          lime: true,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.lime,
                                content: Text(
                                  'Start ${routine.title} — ${routine.minutes} minutes',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
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
            const SizedBox(height: 8),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Send data to physical therapist',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Creates an encrypted bundle of your logs. No plaintext health data is copied to the clipboard.',
                    style: TextStyle(color: AppColors.textMuted, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  if (!pro)
                    GhostButton(
                      label: 'AI Pro required — view plans',
                      onPressed: () => context.push(
                        '/paywall',
                        extra: computePaywallReason(data.readiness, data.plan),
                      ),
                    )
                  else
                    NeonButton(
                      label: _exporting ? 'Encrypting…' : 'Secure export',
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
                                content: Text(
                                  'Encrypted payload copied. Share only with your clinician.',
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
          ],
        );
      },
    );
  }
}
