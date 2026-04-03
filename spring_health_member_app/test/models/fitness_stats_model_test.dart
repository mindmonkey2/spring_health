import 'package:flutter_test/flutter_test.dart';
import 'package:spring_health_member/models/fitness_stats_model.dart';

void main() {
  group('WorkoutType.fromString', () {
    final testCases = {
      'upper': WorkoutType.upperBody,
      'power': WorkoutType.upperBody,
      'UPPER BODY': WorkoutType.upperBody,
      'Power lifting': WorkoutType.upperBody,
      'cardio': WorkoutType.cardio,
      'run': WorkoutType.cardio,
      'Cardio Blast': WorkoutType.cardio,
      'Running': WorkoutType.cardio,
      'yoga': WorkoutType.yoga,
      'Yoga Flow': WorkoutType.yoga,
      'leg': WorkoutType.legDay,
      'Leg day': WorkoutType.legDay,
      'full': WorkoutType.fullBody,
      'Full Body': WorkoutType.fullBody,
      'hiit': WorkoutType.hiit,
      'HIIT Session': WorkoutType.hiit,
      'unknown': WorkoutType.other,
      '': WorkoutType.other,
      'Walking': WorkoutType.other,
    };

    testCases.forEach((input, expected) {
      test('returns $expected for input "$input"', () {
        expect(WorkoutType.fromString(input), expected);
      });
    });
  });
}
