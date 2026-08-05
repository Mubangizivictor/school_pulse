import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/transport/domain/entities/transport_info.dart';
import 'package:school_pulse/features/transport/domain/repositories/transport_repository.dart';
import 'package:school_pulse/features/transport/domain/services/transport_student_projection_service.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';

class MockPermissionEvaluator extends Mock implements PermissionEvaluator {}

class MockStudentRepository extends Mock implements StudentRepository {}

class MockTransportRepository extends Mock implements TransportRepository {}

void main() {
  late TransportStudentProjectionService service;
  late MockPermissionEvaluator permissionEvaluator;
  late MockStudentRepository studentRepository;
  late MockTransportRepository transportRepository;

  const studentId = 'student-1';
  const operatorUser = UserEntity(
    id: 'transport-1',
    name: 'Coordinator Cole',
    email: 'transport@example.com',
    schoolId: 'school-1',
    roles: [UserRole.transportCoordinator],
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
  );

  const transportInfo = TransportInfo(
    studentId: studentId,
    routeName: 'Route A',
    stopName: 'Main Gate',
    status: 'Assigned',
  );

  setUp(() {
    permissionEvaluator = MockPermissionEvaluator();
    studentRepository = MockStudentRepository();
    transportRepository = MockTransportRepository();
    service = TransportStudentProjectionService(
      permissionEvaluator: permissionEvaluator,
      studentRepository: studentRepository,
      transportRepository: transportRepository,
    );

    when(
      () => studentRepository.getStudentById(studentId),
    ).thenAnswer((_) async => Right(student));
  });

  test('denies when the operator lacks transportBoardingVerify', () async {
    when(
      () => permissionEvaluator.can(
        Permission.transportBoardingVerify,
        operatorUser,
      ),
    ).thenAnswer((_) async => const Right(false));

    final result = await service.getStudentView(
      studentId: studentId,
      operatorUser: operatorUser,
    );

    expect(result.fold((f) => f, (r) => null), isA<PermissionDeniedFailure>());
    verifyNever(() => transportRepository.getTransportInfo(any()));
  });

  test('returns route/stop/status when allowed', () async {
    when(
      () => permissionEvaluator.can(
        Permission.transportBoardingVerify,
        operatorUser,
      ),
    ).thenAnswer((_) async => const Right(true));
    when(
      () => transportRepository.getTransportInfo(studentId),
    ).thenAnswer((_) async => const Right(transportInfo));

    final result = await service.getStudentView(
      studentId: studentId,
      operatorUser: operatorUser,
    );

    final view = result.getOrElse(() => throw StateError('expected Right'));
    expect(view.name, 'Jane Doe');
    expect(view.routeName, 'Route A');
    expect(view.stopName, 'Main Gate');
  });
}
