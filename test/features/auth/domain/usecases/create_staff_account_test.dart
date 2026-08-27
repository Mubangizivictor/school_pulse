import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';
import 'package:school_pulse/features/auth/domain/usecases/create_staff_account.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late CreateStaffAccount usecase;

  setUp(() {
    repository = MockAuthRepository();
    usecase = CreateStaffAccount(repository);
  });

  test(
    'passes department/designation/campus/employmentType/dateJoined through to the repository',
    () async {
      final dateJoined = DateTime(2026, 1, 15);
      when(
        () => repository.createStaffAccount(
          name: any(named: 'name'),
          email: any(named: 'email'),
          schoolId: any(named: 'schoolId'),
          roles: any(named: 'roles'),
          password: any(named: 'password'),
          assignedClass: any(named: 'assignedClass'),
          subjects: any(named: 'subjects'),
          academicYearId: any(named: 'academicYearId'),
          departmentId: any(named: 'departmentId'),
          designationId: any(named: 'designationId'),
          campusId: any(named: 'campusId'),
          employmentType: any(named: 'employmentType'),
          dateJoined: any(named: 'dateJoined'),
          idempotencyKey: any(named: 'idempotencyKey'),
          forcePasswordChange: any(named: 'forcePasswordChange'),
          sendLoginDetailsViaEmail: any(named: 'sendLoginDetailsViaEmail'),
          staffData: any(named: 'staffData'),
          roleConfigs: any(named: 'roleConfigs'),
        ),
      ).thenAnswer((_) async => const Right('temp-pass'));

      final result = await usecase(
        CreateStaffAccountParams(
          name: 'Jane Doe',
          email: 'jane@example.com',
          schoolId: 'school-1',
          roles: const [UserRole.subjectTeacher],
          password: '',
          departmentId: 'dept-1',
          designationId: 'desig-1',
          campusId: 'campus-1',
          employmentType: 'Permanent',
          dateJoined: dateJoined,
          idempotencyKey: null,
          forcePasswordChange: false,
          sendLoginDetailsViaEmail: false,
          staffData: null,
          roleConfigs: null,
        ),
      );

      expect(result, const Right('temp-pass'));
      verify(
        () => repository.createStaffAccount(
          name: 'Jane Doe',
          email: 'jane@example.com',
          schoolId: 'school-1',
          roles: const [UserRole.subjectTeacher],
          password: '',
          assignedClass: null,
          subjects: null,
          academicYearId: null,
          departmentId: 'dept-1',
          designationId: 'desig-1',
          campusId: 'campus-1',
          employmentType: 'Permanent',
          dateJoined: dateJoined,
          idempotencyKey: null,
          forcePasswordChange: false,
          sendLoginDetailsViaEmail: false,
          staffData: null,
          roleConfigs: null,
        ),
      ).called(1);
    },
  );
}
