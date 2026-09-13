import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';

class LevelUpOverlay extends StatelessWidget {
  const LevelUpOverlay({
    super.key,
    required this.newLevel,
    required this.onDismiss,
  });

  final int newLevel;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppColors.lime.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.lime.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppColors.electric.withValues(alpha: 0.2),
                blurRadius: 60,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.lime.withValues(alpha: 0.8),
                      AppColors.electric.withValues(alpha: 0.4),
                      AppColors.lime.withValues(alpha: 0.1),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lime.withValues(alpha: 0.6),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'LVL $newLevel',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ).animate().scale(
                duration: 600.ms,
                curve: Curves.elasticOut,
              ).then().shimmer(
                duration: 1200.ms,
                color: AppColors.lime,
              ),
              const SizedBox(height: 24),
              const Text(
                'LEVEL UP!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.lime,
                  letterSpacing: 3,
                ),
              ).animate().fadeIn(
                duration: 400.ms,
                delay: 200.ms,
              ).slideY(
                begin: 0.3,
                duration: 400.ms,
                delay: 200.ms,
              ),
              const SizedBox(height: 12),
              Text(
                'You\'ve unlocked new potential',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ).animate().fadeIn(
                duration: 400.ms,
                delay: 400.ms,
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: onDismiss,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.lime,
                        AppColors.limeDeep,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lime.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'AWESOME!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ).animate().fadeIn(
                  duration: 400.ms,
                  delay: 600.ms,
                ).scale(
                  begin: const Offset(0.9, 0.9),
                  duration: 400.ms,
                  delay: 600.ms,
                  curve: Curves.elasticOut,
                ),
              ),
            ],
          ),
        ).animate().scale(
          duration: 500.ms,
          curve: Curves.easeOutBack,
        ),
      ),
    );
  }
}