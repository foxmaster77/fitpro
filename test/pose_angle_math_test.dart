import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'package:fitpro/core/pose_angle_math.dart';

PoseLandmark landmark(double x, double y) =>
    PoseLandmark(type: PoseLandmarkType.nose, x: x, y: y, z: 0, likelihood: 1);

void main() {
  test('knee angle returns a right angle', () {
    expect(
      kneeAngle(landmark(0, 0), landmark(0, 1), landmark(1, 1)),
      closeTo(90, 0.001),
    );
  });

  test('plank alignment returns a straight angle', () {
    expect(
      plankAlignmentAngle(landmark(0, 0), landmark(1, 0), landmark(2, 0)),
      closeTo(180, 0.001),
    );
  });

  test('torso angle is zero when upright', () {
    expect(
      torsoAngleFromVertical(landmark(0, 0), landmark(0, 2)),
      closeTo(0, 0.001),
    );
  });

  test('plank deviation is positive when hips sag below the line', () {
    expect(
      plankHipLineDeviation(landmark(0, 0), landmark(1, 2), landmark(2, 0)),
      closeTo(2, 0.001),
    );
  });
}
