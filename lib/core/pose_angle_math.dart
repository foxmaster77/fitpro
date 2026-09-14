import 'dart:math' as math;

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

double jointAngle(PoseLandmark first, PoseLandmark vertex, PoseLandmark third) {
  final firstVector = _Point(first.x - vertex.x, first.y - vertex.y);
  final thirdVector = _Point(third.x - vertex.x, third.y - vertex.y);
  final denominator = firstVector.length * thirdVector.length;
  if (denominator == 0) return 0;

  final cosine =
      (firstVector.x * thirdVector.x + firstVector.y * thirdVector.y) /
      denominator;
  return _degrees(math.acos(cosine.clamp(-1.0, 1.0)));
}

double kneeAngle(PoseLandmark hip, PoseLandmark knee, PoseLandmark ankle) {
  return jointAngle(hip, knee, ankle);
}

double torsoAngleFromVertical(PoseLandmark shoulder, PoseLandmark hip) {
  final dx = shoulder.x - hip.x;
  final dy = shoulder.y - hip.y;
  if (dx == 0 && dy == 0) return 0;
  return _degrees(math.atan2(dx.abs(), dy.abs()));
}

double plankAlignmentAngle(
  PoseLandmark shoulder,
  PoseLandmark hip,
  PoseLandmark ankle,
) {
  return jointAngle(shoulder, hip, ankle);
}

/// Positive values mean the hip is below the shoulder-to-ankle line in image
/// coordinates; negative values mean it is above the line.
double plankHipLineDeviation(
  PoseLandmark shoulder,
  PoseLandmark hip,
  PoseLandmark ankle,
) {
  final horizontalSpan = ankle.x - shoulder.x;
  if (horizontalSpan == 0) return hip.y - shoulder.y;
  final expectedY =
      shoulder.y +
      ((hip.x - shoulder.x) / horizontalSpan) * (ankle.y - shoulder.y);
  return hip.y - expectedY;
}

double _degrees(double radians) => radians * 180 / math.pi;

class _Point {
  const _Point(this.x, this.y);

  final double x;
  final double y;

  double get length => math.sqrt(x * x + y * y);
}
