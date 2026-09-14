import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../core/pose_angle_math.dart';
import '../models/form_check_result.dart';

class FormFeedback {
  const FormFeedback({required this.message, required this.correct});

  final String message;
  final bool correct;
}

class FormCheckTracker {
  FormCheckTracker({this.exercise = FormExerciseType.squat});

  FormExerciseType exercise;
  int reps = 0;
  bool _movementSeen = false;
  double _lowestKneeAngle = 180;
  final _repFaults = <String>{};
  final faultCounts = <String, int>{};
  Set<String> activeFaults = {};
  Set<PoseLandmarkType> faultedLandmarks = {};
  DateTime? _lastFeedbackAt;

  FormFeedback? process(Pose pose) {
    final faults = <String>{};
    final faulted = <PoseLandmarkType>{};
    if (exercise == FormExerciseType.squat) {
      _processSquat(pose, faults, faulted);
    } else {
      _processPlank(pose, faults, faulted);
      for (final fault in faults) {
        faultCounts[fault] = (faultCounts[fault] ?? 0) + 1;
      }
    }
    activeFaults = faults;
    faultedLandmarks = faulted;

    if (faults.isNotEmpty && _feedbackIsDue) {
      final feedback = FormFeedback(message: faults.first, correct: false);
      _lastFeedbackAt = DateTime.now();
      return feedback;
    }
    return null;
  }

  void _processSquat(
    Pose pose,
    Set<String> faults,
    Set<PoseLandmarkType> faulted,
  ) {
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final knee = pose.landmarks[PoseLandmarkType.leftKnee];
    final ankle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    if (hip == null || knee == null || ankle == null) return;

    final angle = kneeAngle(hip, knee, ankle);
    if (angle < 150) {
      _movementSeen = true;
      _lowestKneeAngle = angle < _lowestKneeAngle ? angle : _lowestKneeAngle;
    }
    if (knee.x > ankle.x + 40) {
      faults.add('Knees caving in');
      faulted.addAll({PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle});
    }
    if (shoulder != null && torsoAngleFromVertical(shoulder, hip) > 35) {
      faults.add('Leaning too far forward');
      faulted.addAll({PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip});
    }
    _repFaults.addAll(faults);
    final completesRep = _movementSeen && angle > 155;
    if (completesRep) {
      if (_lowestKneeAngle > 100) faults.add('Not deep enough');
      reps++;
      final completedFaults = {..._repFaults, ...faults};
      for (final fault in completedFaults) {
        faultCounts[fault] = (faultCounts[fault] ?? 0) + 1;
      }
      if (completedFaults.isEmpty) {
        _lastFeedbackAt = DateTime.now();
        _pendingCorrectRep = reps;
      }
      _movementSeen = false;
      _lowestKneeAngle = 180;
      _repFaults.clear();
    }
  }

  void _processPlank(
    Pose pose,
    Set<String> faults,
    Set<PoseLandmarkType> faulted,
  ) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final ankle = pose.landmarks[PoseLandmarkType.leftAnkle];
    if (shoulder == null || hip == null || ankle == null) return;

    final deviation = plankHipLineDeviation(shoulder, hip, ankle);
    if (deviation > 35) {
      faults.add('Hips sagging');
      faulted.add(PoseLandmarkType.leftHip);
    } else if (deviation < -35) {
      faults.add('Hips too high');
      faulted.add(PoseLandmarkType.leftHip);
    }
  }

  int? _pendingCorrectRep;

  bool get _feedbackIsDue =>
      _lastFeedbackAt == null ||
      DateTime.now().difference(_lastFeedbackAt!) >
          const Duration(milliseconds: 900);

  FormFeedback? takePendingCorrectFeedback() {
    final rep = _pendingCorrectRep;
    if (rep == null) return null;
    _pendingCorrectRep = null;
    return FormFeedback(message: 'Rep $rep - Good form', correct: true);
  }

  FormCheckResult result(DateTime startedAt) {
    return FormCheckResult(
      exercise: exercise,
      faults: faultCounts.entries
          .expand((entry) => List.filled(entry.value, entry.key))
          .toList(),
      repCount: reps,
      sessionDuration: DateTime.now().difference(startedAt),
    );
  }
}
