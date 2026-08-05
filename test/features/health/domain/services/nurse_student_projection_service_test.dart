import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';
import 'package:school_pulse/features/health/domain/entities/student_health_profile.dart';
import 'package:school_pulse/features/health/domain/repositories/health_repository.dart';
import 'package:school_pulse/features/health/domain/services/nurse_student_projection_service.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';

class MockPermissionEvaluator extends Mock implements PermissionEvaluator {}

class MockStudentRepository extends Mock implements StudentRepository {}

class MockHealthRepository extends Mock implements HealthRepository {}

void main() {
  late NurseStudentProjectionService service;
  late MockPermissionEvaluator permissionEvaluator;
  late MockStudentRepository studentRepository;
  late MockHealthRepository healthRepository;

  const schoolId = 'school-1';
  const studentId = 'student-1';
  const operatorUser = UserEntity(
    id: 'nurse-1',
    name: 'Nurse Joy',
    email: 'nurse@example.com',
    schoolId: schoolId,
    roles: [UserRole.nurse],
  );

  final student = Student(
    id: studentId,
    schoolId: schoolId,
    name: 'Jane Doe',
    studentCode: 'MH-2026-000001',
    admissionNumber: 'SP-2026-0001',
    dateOfBirth: DateTime(2015, 1, 1),
    gender: Gender.female,
    classId: 'class-1',
    academicYearId: 'ay-2026',
    status: StudentStatus.active,
    level: EducationLevel.primary,
    medicalInfo: const MedicalInfo(
      allergies: ['Peanuts'],
      chronicConditions: ['Asthma'],
    ),
    emergencyContacts: const [
      EmergencyContact(
        name: 'John Doe',
        relationship: 'Father',
        phoneNumber: '0700000000',
      ),
    ],
  );

  final healthProfile = StudentHealthProfile(
    studentId: studentId,
    schoolId: schoolId,
    bloodGroup: 'O+',
    allergies: const ['Peanuts', 'Dust'],
    currentMedications: const ['Inhaler'],
    emergencyContactName: 'John Doe',
    emergencyContactPhone: '0700000000',
  );

  setUp(() {
    permissionEvaluator = MockPermissionEvaluator();
    studentRepository = MockStudentRepository();
    healthRepository = MockHealthRepository();
    service = NurseStudentProjectionService(
      permissionEvaluator: permissionEvaluator,
      studentRepository: studentRepository,
      healthRepository: healthRepository,
    );

    when(
      () => studentRepository.getStudentById(studentId),
    ).thenAnswer((_) async => Right(student));
    when(
      () => healthRepository.getClinicVisits(
        schoolId: schoolId,
        studentId: studentId,
      ),
    ).thenAnswer((_) async => const Right(<ClinicVisit>[]));
  });

  test(
    'denies without exposing any student data when basic read is not granted',
    () async {
      when(
        () => permissionEvaluator.can(
          Permission.healthStudentBasicRead,
          operatorUser,
        ),
      ).thenAnswer((_) async => const Right(false));

      final result = await service.getStudentView(
        studentId: studentId,
        schoolId: schoolId,
        operatorUser: operatorUser,
      );

      expect(result.isLeft(), true);
      expect(
        result.fold((f) => f, (r) => null),
        isA<PermissionDeniedFailure>(),
      );
      verifyNever(() => studentRepository.getStudentById(any()));
    },
  );

  test('returns identity-only view when only basic read is granted', () async {
    when(
      () => permissionEvaluator.can(
        Permission.healthStudentBasicRead,
        operatorUser,
      ),
    ).thenAnswer((_) async => const Right(true));
    when(
      () => permissionEvaluator.can(
        Permission.healthStudentClinicalRead,
        operatorUser,
      ),
    ).thenAnswer((_) async => const Right(false));

    final result = await service.getStudentView(
      studentId: studentId,
      schoolId: schoolId,
      operatorUser: operatorUser,
    );

    final view = result.getOrElse(() => throw StateError('expected Right'));
    expect(view.name, 'Jane Doe');
    expect(view.classId, 'class-1');
    expect(view.hasClinicalAccess, false);
    expect(view.allergies, null);
    verifyNever(() => healthRepository.getStudentHealthProfile(any(), any()));
  });

  test(
    'returns full clinical view (from StudentHealthProfile) when both permissions are granted',
    () async {
      when(
        () => permissionEvaluator.can(
          Permission.healthStudentBasicRead,
          operatorUser,
        ),
      ).thenAnswer((_) async => const Right(true));
      when(
        () => permissionEvaluator.can(
          Permission.healthStudentClinicalRead,
          operatorUser,
        ),
      ).thenAnswer((_) async => const Right(true));
      when(
        () => healthRepository.getStudentHealthProfile(studentId, schoolId),
      ).thenAnswer((_) async => Right(healthProfile));

      final result = await service.getStudentView(
        studentId: studentId,
        schoolId: schoolId,
        operatorUser: operatorUser,
      );

      final view = result.getOrElse(() => throw StateError('expected Right'));
      expect(view.hasClinicalAccess, true);
      expect(view.allergies, const ['Peanuts', 'Dust']);
      expect(view.currentMedications, const ['Inhaler']);
      expect(view.emergencyContactPhone, '0700000000');
    },
  );
}
