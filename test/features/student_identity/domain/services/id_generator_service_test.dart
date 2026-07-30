import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/student_identity/domain/services/id_generator_service.dart';

void main() {
  final generator = IdGeneratorService();

  test('generateUniqueSystemId produces distinct SP-STUDENT- prefixed ids', () {
    final a = generator.generateUniqueSystemId();
    final b = generator.generateUniqueSystemId();

    expect(a, startsWith('SP-STUDENT-'));
    expect(a, isNot(equals(b)));
  });

  test('generateSchoolStudentId formats prefix-year-paddedSequence', () {
    final id = generator.generateSchoolStudentId(
      schoolPrefix: 'MH',
      year: 2026,
      sequenceNumber: 7,
    );

    expect(id, 'MH-2026-000007');
  });
}
