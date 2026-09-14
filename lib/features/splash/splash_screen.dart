import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_session.dart';
import '../../theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _animationTimer;
  Timer? _capTimer;
  bool _animationDone = false;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _animationTimer = Timer(const Duration(milliseconds: 900), () {
      _animationDone = true;
      _finishWhenReady();
    });
    _capTimer = Timer(const Duration(milliseconds: 1500), () {
      _finishWhenReady(force: true);
    });
    ref.listenManual(appSessionProvider, (previous, next) {
      _finishWhenReady();
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _capTimer?.cancel();
    super.dispose();
  }

  void _finishWhenReady({bool force = false}) {
    if (_navigating || (!force && !_animationDone)) return;
    final session = ref.read(appSessionProvider);
    if (!force && (session.isLoading || session.hasError)) return;
    _navigating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (session.hasError || session.isLoading) {
        context.go('/boot');
      } else if (session.value!.profile.onboardingComplete) {
        context.go('/coach');
      } else {
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations && !_animationDone) {
      _animationDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _finishWhenReady());
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: 116,
                  height: 116,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.electric, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.electric.withValues(alpha: 0.35),
                        blurRadius: 32,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: AppColors.lime,
                    size: 54,
                  ),
                )
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.72, 0.72), duration: 500.ms)
                .then()
                .shimmer(duration: 400.ms, color: AppColors.lime),
            const SizedBox(height: 22),
            const Text(
              'FITPRO',
              style: TextStyle(
                color: AppColors.lime,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ).animate().fadeIn(delay: 180.ms, duration: 350.ms),
          ],
        ),
      ),
    );
  }
}
