import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../theme/app_colors.dart';

class NeonButton extends StatelessWidget {
  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.lime = false,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool lime;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final bg = lime ? AppColors.lime : AppColors.electric;
    final fg = Colors.black;
    final child = ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(AppConstants.minTouchTarget, 56),
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: bg.withValues(alpha: 0.4),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.black),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 22),
                  const SizedBox(width: 8),
                ],
                Text(label),
              ],
            ),
    );
    if (!expand) return child;
    return SizedBox(width: double.infinity, child: child);
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.stroke, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        child: Text(label),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.accent,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (accent ?? AppColors.electric).withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: (accent ?? AppColors.electric).withValues(alpha: 0.08),
            blurRadius: 28,
          ),
        ],
      ),
      child: child,
    );
  }
}
