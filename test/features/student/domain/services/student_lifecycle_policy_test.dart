import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/services/student_lifecycle_policy.dart';

void main() {
  const policy = StudentLifecyclePolicy();

  group('StudentLifecyclePolicy', () {
    test('supports the admission-to-active journey', () {
      expect(
        policy.canTransition(
          StudentStatus.applicant,
          StudentStatus.pendingAdmission,
        ),
        isTrue,
      );
      expect(
        policy.canTransition(
          StudentStatus.pendingAdmission,
          StudentStatus.admitted,
        ),
        isTrue,
      );
      expect(
        policy.canTransition(StudentStatus.admitted, StudentStatus.active),
        isTrue,
      );
    });

    test('does not reactivate terminal student records', () {
      expect(
        policy.canTransition(StudentStatus.graduated, StudentStatus.active),
        isFalse,
      );
      expect(
        policy.canTransition(StudentStatus.alumni, StudentStatus.active),
        isFalse,
      );
      expect(
        policy.canTransition(StudentStatus.withdrawn, StudentStatus.active),
        isFalse,
      );
    });
  });
}
