import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/entities/assessment_grading_entities.dart';
import 'package:school_pulse/features/structure/domain/services/grading_band_validator.dart';

GradeBand band(String grade, double from, double to) => GradeBand(
  id: grade,
  schoolId: 'school-a',
  gradingSystemId: 'system-a',
  grade: grade,
  minScore: from,
  maxScore: to,
);

void main() {
  test('accepts grade bands that cover the full inclusive range once', () {
    expect(
      GradingBandValidator.validate(
        maximumMark: 100,
        bands: [band('A', 80, 100), band('B', 50, 79), band('C', 0, 49)],
      ),
      isNull,
    );
  });

  test('rejects overlaps, gaps, invalid bounds and incomplete ranges', () {
    expect(
      GradingBandValidator.validate(
        maximumMark: 100,
        bands: [band('A', 80, 100), band('B', 70, 85), band('C', 0, 69)],
      ),
      contains('overlap'),
    );
    expect(
      GradingBandValidator.validate(
        maximumMark: 100,
        bands: [band('A', 80, 100), band('B', 0, 78)],
      ),
      contains('exactly once'),
    );
    expect(
      GradingBandValidator.validate(
        maximumMark: 100,
        bands: [band('A', 1, 100)],
      ),
      contains('complete range'),
    );
    expect(
      GradingBandValidator.validate(
        maximumMark: 100,
        bands: [band('A', 60, 50)],
      ),
      contains('minimum'),
    );
  });
}
