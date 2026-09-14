import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetectionService {
  PoseDetectionService()
    : _detector = PoseDetector(
        options: PoseDetectorOptions(
          model: PoseDetectionModel.base,
          mode: PoseDetectionMode.stream,
        ),
      );

  final PoseDetector _detector;
  final _poses = StreamController<Pose>.broadcast();
  bool _processing = false;
  bool _closed = false;

  Stream<Pose> get poses => _poses.stream;

  Future<void> processCameraImage({
    required CameraImage image,
    required CameraDescription camera,
    required DeviceOrientation deviceOrientation,
  }) async {
    if (_closed || _processing || kIsWeb) return;

    final inputImage = _inputImageFromCameraImage(
      image,
      camera,
      deviceOrientation,
    );
    if (inputImage == null) return;

    _processing = true;
    try {
      final detected = await _detector.processImage(inputImage);
      if (!_closed && detected.isNotEmpty && !_poses.isClosed) {
        _poses.add(detected.first);
      }
    } catch (_) {
      // A dropped frame should not stop the camera stream.
    } finally {
      _processing = false;
    }
  }

  InputImage? _inputImageFromCameraImage(
    CameraImage image,
    CameraDescription camera,
    DeviceOrientation deviceOrientation,
  ) {
    final rotation = _rotationFor(camera, deviceOrientation);
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    final validFormat = defaultTargetPlatform == TargetPlatform.android
        ? format == InputImageFormat.nv21
        : defaultTargetPlatform == TargetPlatform.iOS
        ? format == InputImageFormat.bgra8888
        : false;
    if (!validFormat || image.planes.length != 1) return null;

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format!,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  InputImageRotation? _rotationFor(
    CameraDescription camera,
    DeviceOrientation deviceOrientation,
  ) {
    final sensorOrientation = camera.sensorOrientation;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return InputImageRotationValue.fromRawValue(sensorOrientation);
    }
    if (defaultTargetPlatform != TargetPlatform.android) return null;

    const orientations = {
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeLeft: 90,
      DeviceOrientation.portraitDown: 180,
      DeviceOrientation.landscapeRight: 270,
    };
    var compensation = orientations[deviceOrientation];
    if (compensation == null) return null;
    if (camera.lensDirection == CameraLensDirection.front) {
      compensation = (sensorOrientation + compensation) % 360;
    } else {
      compensation = (sensorOrientation - compensation + 360) % 360;
    }
    return InputImageRotationValue.fromRawValue(compensation);
  }

  Future<void> dispose() async {
    if (_closed) return;
    _closed = true;
    await _poses.close();
    await _detector.close();
  }
}
