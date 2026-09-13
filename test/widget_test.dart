import 'package:flutter_test/flutter_test.dart';

import 'package:fitpro/data/models/readiness.dart';

void main() {
  test('daily readiness blends sleep and inverse fatigue', () {
    final snap = ReadinessSnapshot(
      sleepScore: 80,
      muscleFatigue: 20,
      updatedAt: DateTime(2026, 9, 14),
    );
    expect(snap.dailyReadiness, 80);
    expect(snap.label, 'Peak');
  });
}
