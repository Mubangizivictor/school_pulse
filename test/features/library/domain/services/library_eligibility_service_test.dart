import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/library/domain/repositories/library_repository.dart';
import 'package:school_pulse/features/library/domain/services/library_eligibility_service.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';

class MockPermissionEvaluator extends Mock implements PermissionEvaluator {}

class MockStudentRepository extends Mock implements StudentRepository {}

class MockLibraryRepository extends Mock implements LibraryRepository {}

void main() {
  late LibraryEligibilityService service;
  late MockPermissionEvaluator permissionEvaluator;
  late MockStudentRepository studentRepository;
  late MockLibraryRepository libraryRepository;

  const schoolId = 'school-1';
  const studentId = 'student-1';
  const operatorUser = UserEntity(
    id: 'librarian-1',
    name: 'Lib Rarian',
    email: 'librarian@example.com',
    schoolId: schoolId,
    roles: [UserRole.librarian],
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
  );

  setUp(() {
    permissionEvaluator = MockPermissionEvaluator();
    studentRepository = MockStudentRepository();
    libraryRepository = MockLibraryRepository();
    service = LibraryEligibilityService(
      permissionEvaluator: permissionEvaluator,
      studentRepository: studentRepository,
      libraryRepository: libraryRepository,
    );

    when(() => studentRepository.getStudentById(studentId)).thenAnswer((_) async => Right(student));
  });

  test('denies when the operator lacks libraryMemberVerify', () async {
    when(() => permissionEvaluator.can(Permission.libraryMemberVerify, operatorUser))
        .thenAnswer((_) async => const Right(false));

    final result = await service.getEligibility(studentId: studentId, schoolId: schoolId, operatorUser: operatorUser);

    expect(result.fold((f) => f, (r) => null), isA<PermissionDeniedFailure>());
    verifyNever(() => libraryRepository.getBorrowerAnalytics(any(), any()));
  });

  test('is eligible when there are no overdue items', () async {
    when(() => permissionEvaluator.can(Permission.libraryMemberVerify, operatorUser))
        .thenAnswer((_) async => const Right(true));
    when(() => libraryRepository.getBorrowerAnalytics(schoolId, studentId))
        .thenAnswer((_) async => {'totalBorrowed': 5, 'currentlyBorrowed': 2, 'overdueCount': 0});

    final result = await service.getEligibility(studentId: studentId, schoolId: schoolId, operatorUser: operatorUser);

    final view = result.getOrElse(() => throw StateError('expected Right'));
    expect(view.eligible, true);
    expect(view.currentlyBorrowed, 2);
  });

  test('is not eligible when there are overdue items', () async {
    when(() => permissionEvaluator.can(Permission.libraryMemberVerify, operatorUser))
        .thenAnswer((_) async => const Right(true));
    when(() => libraryRepository.getBorrowerAnalytics(schoolId, studentId))
        .thenAnswer((_) async => {'totalBorrowed': 5, 'currentlyBorrowed': 3, 'overdueCount': 1});

    final result = await service.getEligibility(studentId: studentId, schoolId: schoolId, operatorUser: operatorUser);

    final view = result.getOrElse(() => throw StateError('expected Right'));
    expect(view.eligible, false);
    expect(view.overdueCount, 1);
  });
}
