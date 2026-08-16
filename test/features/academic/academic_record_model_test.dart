import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/academic/data/models/academic_record_model.dart';

void main() {
  group('AcademicRecordModel', () {
    test('round-trips a fully-graded record through Firestore map shape', () {
      final model = AcademicRecordModel(
        studentId: 'student-1',
        subject: 'Mathematics',
        score: 85,
        grade: 'A',
        gradeLabel: 'Excellent',
        gradeColorHex: '#4CAF50',
        isPassing: true,
        term: 'Term 1',
        year: '2026',
      );
      final map = model.toFirestore();
      final restored = AcademicRecordModel.fromFirestore(map);

      expect(restored.grade, 'A');
      expect(restored.gradeLabel, 'Excellent');
      expect(restored.gradeColorHex, '#4CAF50');
      expect(restored.isPassing, isTrue);
    });

    test('a record with no grading system configured deserializes with a '
        'null grade rather than a fabricated one', () {
      final map = {
        'studentId': 'student-1',
        'subject': 'Mathematics',
        'score': 72,
        'grade': null,
        'gradeLabel': null,
        'gradeColorHex': null,
        'isPassing': null,
        'term': 'Term 1',
        'year': '2026',
      };
      final restored = AcademicRecordModel.fromFirestore(map);

      expect(restored.grade, isNull);
      expect(restored.gradeColorHex, isNull);
      expect(restored.isPassing, isNull);
      expect(restored.score, 72);
    });

    test('a legacy record written before grade metadata existed '
        'deserializes safely with the new fields null', () {
      final legacyMap = {
        'studentId': 'student-1',
        'subject': 'Mathematics',
        'score': 90,
        'grade': 'D1',
        'term': 'Term 1',
        'year': '2026',
      };
      final restored = AcademicRecordModel.fromFirestore(legacyMap);

      expect(restored.grade, 'D1');
      expect(restored.gradeLabel, isNull);
      expect(restored.gradeColorHex, isNull);
      expect(restored.isPassing, isNull);
    });
  });
}
