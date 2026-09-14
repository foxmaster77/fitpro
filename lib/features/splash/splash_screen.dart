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
            const _CssLoader()
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

class _CssLoader extends StatefulWidget {
  const _CssLoader();

  @override
  State<_CssLoader> createState() => _CssLoaderState();
}

class _CssLoaderState extends State<_CssLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = MediaQuery.of(context).disableAnimations;
    return SizedBox(
      width: 35,
      height: 80,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          painter: _CssLoaderPainter(
            progress: disabled ? 0 : _controller.value,
          ),
        ),
      ),
    );
  }
}

class _CssLoaderPainter extends CustomPainter {
  const _CssLoaderPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const bodyColor = Color(0xFFE4E0D7);
    const borderColor = Color(0xFFBBB6AA);
    const fillColor = Color(0xFF612329);
    const barColor = Color(0xFFEB6B3E);

    final body = Paint()..color = bodyColor;
    canvas.drawRect(Offset.zero & size, body);

    final fillHeight = size.height * (1 - progress * 0.95);
    final fill = Paint()..color = fillColor;
    canvas.drawRect(
      Rect.fromLTWH(5, size.height - fillHeight, size.width - 10, fillHeight),
      fill,
    );

    final border = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(const Offset(0, 0.5), Offset(size.width, 0.5), border);
    border.strokeWidth = 4;
    canvas.drawLine(
      Offset(0, size.height - 2),
      Offset(size.width, size.height - 2),
      border,
    );

    final bar = Paint()
      ..color = barColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;
    canvas.save();
    canvas.translate(size.width / 2, size.height - 8);
    canvas.rotate(8 * 3.1415926535 / 180);
    canvas.drawLine(const Offset(0, 0), const Offset(0, -90), bar);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CssLoaderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
