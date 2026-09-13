import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';

class LogSuccessBurst extends StatelessWidget {
  const LogSuccessBurst({super.key, required this.tick});

  final int tick;

  @override
  Widget build(BuildContext context) {
    if (tick == 0) return const SizedBox.shrink();
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.lime,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.black, size: 20),
              SizedBox(width: 8),
              Text(
                'Logged locally, encrypted',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        )
            .animate(key: ValueKey(tick))
            .fadeIn(duration: 180.ms)
            .slideY(begin: -0.4, end: 0, curve: Curves.easeOutBack)
            .then(delay: 1400.ms)
            .fadeOut(),
      ),
    );
  }
}
