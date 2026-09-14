import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/controls.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _page = PageController();
  final _name = TextEditingController();
  final _otherInjury = TextEditingController();
  final _injuries = <String>{};
  var _index = 0;
  var _accepted = false;

  @override
  void dispose() {
    _page.dispose();
    _name.dispose();
    _otherInjury.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_index < 3) {
      await _page.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    if (!_accepted) return;
    final injuries = {..._injuries};
    final other = _otherInjury.text.trim();
    if (other.isNotEmpty) injuries.add(other);
    await ref
        .read(appSessionProvider.notifier)
        .completeOnboarding(_name.text, injuryHistory: injuries.toList());
    if (mounted) context.go('/coach');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  const Text(
                    'FITPRO',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: AppColors.lime,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_index + 1} / 4',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: (_index + 1) / 4,
                  color: AppColors.electric,
                  backgroundColor: AppColors.surfaceMuted,
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _page,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _WelcomePane(),
                  _PrivacyPane(
                    accepted: _accepted,
                    onChanged: (v) => setState(() => _accepted = v),
                  ),
                  _InjuryPane(
                    selected: _injuries,
                    otherController: _otherInjury,
                    onToggle: (injury) => setState(() {
                      if (!_injuries.add(injury)) _injuries.remove(injury);
                    }),
                  ),
                  _NamePane(controller: _name),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: NeonButton(
                label: _index == 3 ? 'Enter the vault' : 'Continue',
                onPressed: _index == 3 && !_accepted ? null : _next,
                lime: _index == 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InjuryPane extends StatelessWidget {
  const _InjuryPane({
    required this.selected,
    required this.otherController,
    required this.onToggle,
  });

  final Set<String> selected;
  final TextEditingController otherController;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    const areas = [
      'Shoulder',
      'Elbow',
      'Wrist',
      'Back',
      'Hip',
      'Knee',
      'Ankle',
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      children: [
        const Text(
          'Anything your coach should protect?',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        const Text(
          'Select current or recurring injuries. FITPRO will use this to avoid risky loading and explain adaptations. Leave blank if none.',
          style: TextStyle(color: AppColors.textMuted, height: 1.4),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: areas
              .map(
                (area) => FilterChip(
                  label: Text(area),
                  selected: selected.contains(area),
                  onSelected: (_) => onToggle(area),
                  selectedColor: AppColors.lime,
                  checkmarkColor: Colors.black,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: otherController,
          decoration: const InputDecoration(
            labelText: 'Other injury or movement to avoid',
            hintText: 'e.g. plantar fasciitis',
          ),
        ),
      ],
    );
  }
}

class _WelcomePane extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Training that stays with you — without selling you out.',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ).animate().fadeIn().slideY(begin: 0.12, duration: 500.ms),
          const SizedBox(height: 16),
          const Text(
            'FITPRO is built for retention without subscription fatigue: core logging is free forever. AI Pro is optional.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 16,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),
          const _Pill(icon: Icons.offline_bolt, text: 'Works fully offline'),
          const SizedBox(height: 12),
          const _Pill(
            icon: Icons.psychology_alt,
            text: 'Daily readiness, not guilt',
          ),
          const SizedBox(height: 12),
          const _Pill(
            icon: Icons.merge_type,
            text: 'Lifts, runs, calories in one log',
          ),
        ],
      ),
    );
  }
}

class _PrivacyPane extends StatelessWidget {
  const _PrivacyPane({required this.accepted, required this.onChanged});

  final bool accepted;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      children: [
        const Text(
          'Privacy-first, on purpose.',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 18),
        const GlassCard(
          accent: AppColors.lime,
          child: _PrivacyRow(
            title: 'Zero Data Selling',
            body:
                'We do not sell, rent, or broker health data. There is no ad graph, no hidden SDK marketplace, no “partners” clause.',
          ),
        ),
        const SizedBox(height: 12),
        const GlassCard(
          child: _PrivacyRow(
            title: 'End-to-End Encryption',
            body:
                'Workout, sleep, and nutrition payloads are AES-256 encrypted on device. The key lives in Android Keystore / iOS Keychain — not in the database file.',
          ),
        ),
        const SizedBox(height: 12),
        const GlassCard(
          child: _PrivacyRow(
            title: 'Local-first vault',
            body:
                'SQLite is the source of truth. Cloud sync (Supabase or Firebase) is opt-in and stores ciphertext only.',
          ),
        ),
        const SizedBox(height: 20),
        CheckboxListTile(
          value: accepted,
          onChanged: (v) => onChanged(v ?? false),
          activeColor: AppColors.lime,
          checkColor: Colors.black,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            'I understand FITPRO keeps my health data on this device unless I explicitly export it.',
            style: TextStyle(fontSize: 14, height: 1.35),
          ),
        ),
      ],
    );
  }
}

class _NamePane extends StatelessWidget {
  const _NamePane({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What should your coach call you?',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'First name'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your name is stored encrypted next to your logs. You can change it later.',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _PrivacyRow extends StatelessWidget {
  const _PrivacyRow({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(color: AppColors.textMuted, height: 1.4),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.electric),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
