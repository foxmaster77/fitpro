import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../data/models/form_check_result.dart';
import '../../data/services/form_check_tracker.dart';
import '../../data/services/pose_detection_service.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../widgets/controls.dart';

class FormCheckScreen extends ConsumerStatefulWidget {
  const FormCheckScreen({super.key});

  @override
  ConsumerState<FormCheckScreen> createState() => _FormCheckScreenState();
}

class _FormCheckScreenState extends ConsumerState<FormCheckScreen>
    with WidgetsBindingObserver {
  CameraController? _camera;
  CameraDescription? _description;
  PoseDetectionService? _poseService;
  StreamSubscription<Pose>? _poseSubscription;
  Pose? _pose;
  String? _error;
  bool _initializing = true;
  final _tracker = FormCheckTracker();
  DateTime? _sessionStartedAt;
  FormCheckResult? _result;
  String? _feedback;
  bool _feedbackCorrect = false;
  bool _accessDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    final session = ref.read(appSessionProvider).valueOrNull;
    if (session == null || !session.subscription.isAiPro) {
      _accessDenied = true;
      _initializing = false;
      return;
    }
    if (kIsWeb) {
      setState(() {
        _error = 'Form Check is available on iOS and Android devices.';
        _initializing = false;
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: defaultTargetPlatform == TargetPlatform.android
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      final service = PoseDetectionService();
      _description = camera;
      _camera = controller;
      _poseService = service;
      _poseSubscription = service.poses.listen((pose) {
        if (!mounted) return;
        final feedback =
            _tracker.process(pose) ?? _tracker.takePendingCorrectFeedback();
        setState(() {
          _pose = pose;
          if (feedback != null) {
            _feedback = feedback.message;
            _feedbackCorrect = feedback.correct;
          }
        });
        if (feedback != null) HapticFeedback.mediumImpact();
      });
      await controller.startImageStream((image) {
        service.processCameraImage(
          image: image,
          camera: camera,
          deviceOrientation: controller.value.deviceOrientation,
        );
      });
      if (mounted) {
        setState(() {
          _initializing = false;
          _sessionStartedAt = DateTime.now();
        });
      }
    } on CameraException catch (error) {
      await _disposeCameraResources();
      if (mounted) {
        setState(() {
          _error = _cameraErrorMessage(error.code);
          _initializing = false;
        });
      }
    } catch (_) {
      await _disposeCameraResources();
      if (mounted) {
        setState(() {
          _error =
              'Camera could not start. Check camera permissions and try again.';
          _initializing = false;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _camera;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _camera = null;
    } else if (state == AppLifecycleState.resumed && _description != null) {
      _restartCamera(_description!);
    }
  }

  Future<void> _restartCamera(CameraDescription description) async {
    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: defaultTargetPlatform == TargetPlatform.android
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    await controller.initialize();
    _camera = controller;
    final service = _poseService;
    if (service == null) return;
    await controller.startImageStream((image) {
      service.processCameraImage(
        image: image,
        camera: description,
        deviceOrientation: controller.value.deviceOrientation,
      );
    });
    if (mounted) setState(() {});
  }

  String _cameraErrorMessage(String code) {
    switch (code) {
      case 'CameraAccessDenied':
      case 'CameraAccessDeniedWithoutPrompt':
      case 'CameraAccessRestricted':
        return 'Camera access is needed for on-device form analysis. Enable it in Settings.';
      default:
        return 'Camera could not start. Check camera permissions and try again.';
    }
  }

  Future<void> _disposeCameraResources() async {
    await _poseSubscription?.cancel();
    _poseSubscription = null;
    await _camera?.dispose();
    _camera = null;
    await _poseService?.dispose();
    _poseService = null;
  }

  Future<void> _finishSession() async {
    final startedAt = _sessionStartedAt ?? DateTime.now();
    final result = _tracker.result(startedAt);
    try {
      if (_camera?.value.isStreamingImages ?? false) {
        await _camera?.stopImageStream();
      }
    } catch (_) {}
    await _disposeCameraResources();
    if (mounted) {
      await ref.read(appSessionProvider.notifier).recordFormCheck(result);
      setState(() => _result = result);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_disposeCameraResources());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _camera;
    return Scaffold(
      appBar: AppBar(title: const Text('Form Check')),
      body: _accessDenied
          ? _ProGate(
              onPressed: () => context.push(
                '/paywall',
                extra:
                    'Form Check uses live camera analysis to catch form issues before they become injuries.',
              ),
            )
          : _result != null
          ? _Summary(result: _result!)
          : _error != null
          ? _ErrorState(message: _error!)
          : _initializing || controller == null
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final size = controller.value.previewSize;
                final imageSize = size == null
                    ? const Size(1, 1)
                    : Size(size.height, size.width);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(controller),
                    CustomPaint(
                      painter: PoseSkeletonPainter(
                        pose: _pose,
                        imageSize: imageSize,
                        mirror:
                            _description?.lensDirection ==
                            CameraLensDirection.front,
                        faultedLandmarks: _tracker.faultedLandmarks,
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: FormExerciseType.values
                            .map(
                              (exercise) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(exercise.name.toUpperCase()),
                                  selected: _tracker.exercise == exercise,
                                  selectedColor: AppColors.lime,
                                  onSelected: (_) => setState(() {
                                    _tracker.exercise = exercise;
                                    _tracker.activeFaults = {};
                                    _tracker.faultedLandmarks = {};
                                  }),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Positioned(
                      top: 70,
                      left: 20,
                      child: Text(
                        _tracker.exercise == FormExerciseType.squat
                            ? '${_tracker.reps} reps'
                            : 'Plank form',
                        style: const TextStyle(
                          color: AppColors.lime,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          shadows: [
                            Shadow(blurRadius: 12, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                    if (_feedback != null)
                      Positioned(
                        top: 108,
                        left: 20,
                        right: 20,
                        child: Text(
                          _feedback!,
                          style: TextStyle(
                            color: _feedbackCorrect
                                ? AppColors.lime
                                : AppColors.warning,
                            fontWeight: FontWeight.w800,
                            shadows: const [
                              Shadow(blurRadius: 12, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 24,
                      child: GlassCard(
                        accent: AppColors.electric,
                        child: const Text(
                          'Stand where your full body is visible. Pose analysis stays on this device.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 112,
                      child: IconButton.filled(
                        onPressed: _finishSession,
                        icon: const Icon(Icons.stop),
                        tooltip: 'End session',
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          accent: AppColors.warning,
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class _ProGate extends StatelessWidget {
  const _ProGate({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          accent: AppColors.lime,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.accessibility_new,
                color: AppColors.lime,
                size: 42,
              ),
              const SizedBox(height: 12),
              const Text(
                'Form Check is an AI Pro feature.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Live camera analysis stays on-device and checks squat or plank form in real time.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 18),
              NeonButton(
                label: 'Unlock AI Pro',
                lime: true,
                onPressed: onPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.result});

  final FormCheckResult result;

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final fault in result.faults) {
      counts[fault] = (counts[fault] ?? 0) + 1;
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          '${result.exercise.name.toUpperCase()} COMPLETE',
          style: const TextStyle(
            color: AppColors.lime,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${result.repCount} reps',
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Session ${result.sessionDuration.inSeconds}s',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),
        GlassCard(
          accent: AppColors.warning,
          child: counts.isEmpty
              ? const Text('No repeated form faults observed.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Form faults observed',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    ...counts.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber,
                              color: AppColors.warning,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(entry.key)),
                            Text('${entry.value}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class PoseSkeletonPainter extends CustomPainter {
  PoseSkeletonPainter({
    required this.pose,
    required this.imageSize,
    required this.mirror,
    this.faultedLandmarks = const {},
  });

  final Pose? pose;
  final Size imageSize;
  final bool mirror;
  final Set<PoseLandmarkType> faultedLandmarks;

  static const connections = [
    [PoseLandmarkType.nose, PoseLandmarkType.leftEye],
    [PoseLandmarkType.nose, PoseLandmarkType.rightEye],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
    [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final currentPose = pose;
    if (currentPose == null || imageSize.isEmpty) return;

    final scale =
        (size.width / imageSize.width) > (size.height / imageSize.height)
        ? size.width / imageSize.width
        : size.height / imageSize.height;
    final drawnSize = Size(imageSize.width * scale, imageSize.height * scale);
    final offset = Offset(
      (size.width - drawnSize.width) / 2,
      (size.height - drawnSize.height) / 2,
    );

    Offset point(PoseLandmark landmark) {
      final x = mirror ? imageSize.width - landmark.x : landmark.x;
      return Offset(x * scale + offset.dx, landmark.y * scale + offset.dy);
    }

    final linePaint = Paint()
      ..color = AppColors.electric
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final dotPaint = Paint()..color = AppColors.lime;

    for (final connection in connections) {
      final start = currentPose.landmarks[connection[0]];
      final end = currentPose.landmarks[connection[1]];
      if (start != null && end != null) {
        linePaint.color =
            faultedLandmarks.contains(connection[0]) ||
                faultedLandmarks.contains(connection[1])
            ? AppColors.danger
            : AppColors.electric;
        canvas.drawLine(point(start), point(end), linePaint);
      }
    }
    for (final landmark in currentPose.landmarks.values) {
      dotPaint.color = faultedLandmarks.contains(landmark.type)
          ? AppColors.danger
          : AppColors.lime;
      canvas.drawCircle(point(landmark), 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PoseSkeletonPainter oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.mirror != mirror ||
        oldDelegate.faultedLandmarks != faultedLandmarks;
  }
}
