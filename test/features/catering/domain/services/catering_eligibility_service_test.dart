import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/catering/domain/repositories/catering_repository.dart';
import 'package:school_pulse/features/catering/domain/services/catering_eligibility_service.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';

class MockPermissionEvaluator extends Mock implements PermissionEvaluator {}

class MockStudentRepository extends Mock implements StudentRepository {}

class MockCateringRepository extends Mock implements CateringRepository {}

void main() {
  late CateringEligibilityService service;
  late MockPermissionEvaluator permissionEvaluator;
  late MockStudentRepository studentRepository;
  late MockCateringRepository cateringRepository;

  const studentId = 'student-1';
  const operatorUser = UserEntity(
    id: 'catering-1',
    name: 'Cook Casey',
    email: 'catering@example.com',
    schoolId: 'school-1',
    roles: [UserRole.cateringManager],
  );

  final student = Student(
    id: studentId,
    schoolId: 'school-1',
    name: 'Jane Doe',
    studentCode: 'MH-2026-000001',
    admissionNumber: 'SP-2026-0001',
    dateOfBirth: DateTime(2015, 1, 1),
    gender: Gender.female,
    classId: 'class-1',
    academicYearId: 'ay-2026',
    status: StudentStatus.active,
    level: EducationLevel.primary,
    medicalInfo: const MedicalInfo(allergies: ['Peanuts']),
  );

  setUp(() {
    permissionEvaluator = MockPermissionEvaluator();
    studentRepository = MockStudentRepository();
    cateringRepository = MockCateringRepository();
    service = CateringEligibilityService(
      permissionEvaluator: permissionEvaluator,
      studentRepository: studentRepository,
      cateringRepository: cateringRepository,
    );

    when(
      () => studentRepository.getStudentById(studentId),
    ).thenAnswer((_) async => Right(student));
    when(
      () => permissionEvaluator.can(Permission.mealsVerify, operatorUser),
    ).thenAnswer((_) async => const Right(true));
  });

  test('denies when the operator lacks mealsVerify', () async {
    when(
      () => permissionEvaluator.can(Permission.mealsVerify, operatorUser),
    ).thenAnswer((_) async => const Right(false));

    final result = await service.getEligibility(
      studentId: studentId,
      operatorUser: operatorUser,
    );

    expect(result.fold((f) => f, (r) => null), isA<PermissionDeniedFailure>());
    verifyNever(() => cateringRepository.verifyStudentMealEligibility(any()));
  });

  test(
    'is eligible and shows dietary restrictions when cleared, with no balance field anywhere in the view',
    () async {
      when(
        () => cateringRepository.verifyStudentMealEligibility(studentId),
      ).thenAnswer(
        (_) async => const Right({
          'studentName': 'Jane Doe',
          'eligibilityStatus': 'Cleared',
          'percentagePaid': 100.0,
        }),
      );

      final result = await service.getEligibility(
        studentId: studentId,
        operatorUser: operatorUser,
      );

      final view = result.getOrElse(() => throw StateError('expected Right'));
      expect(view.eligible, true);
      expect(view.dietaryRestrictions, const ['Peanuts']);
      // CateringEligibilityView has no balance/percentagePaid field at all -
      // this asserts the view's own field set, not just that one field is
      // absent, so a future field addition would have to be a deliberate change.
      expect(view.props.length, 7);
    },
  );

  test(
    'shows the generic denial message without the underlying eligibilityStatus/percentage when not cleared',
    () async {
      when(
        () => cateringRepository.verifyStudentMealEligibility(studentId),
      ).thenAnswer(
        (_) async => const Right({
          'studentName': 'Jane Doe',
          'eligibilityStatus': 'Not Cleared',
          'percentagePaid': 30.0,
        }),
      );

      final result = await service.getEligibility(
        studentId: studentId,
        operatorUser: operatorUser,
      );

      final view = result.getOrElse(() => throw StateError('expected Right'));
      expect(view.eligible, false);
      expect(view.message, 'Meal not authorized. Please contact the bursar.');
    },
  );
}
