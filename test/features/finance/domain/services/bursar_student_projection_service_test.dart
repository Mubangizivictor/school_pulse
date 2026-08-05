import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/finance/domain/entities/student_financial_account.dart';
import 'package:school_pulse/features/finance/domain/repositories/finance_repository.dart';
import 'package:school_pulse/features/finance/domain/services/bursar_student_projection_service.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';

class MockPermissionEvaluator extends Mock implements PermissionEvaluator {}

class MockStudentRepository extends Mock implements StudentRepository {}

class MockFinanceRepository extends Mock implements FinanceRepository {}

void main() {
  late BursarStudentProjectionService service;
  late MockPermissionEvaluator permissionEvaluator;
  late MockStudentRepository studentRepository;
  late MockFinanceRepository financeRepository;

  const schoolId = 'school-1';
  const studentId = 'student-1';
  const operatorUser = UserEntity(
    id: 'bursar-1',
    name: 'Bursar Bob',
    email: 'bursar@example.com',
    schoolId: schoolId,
    roles: [UserRole.bursar],
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

  const account = StudentFinancialAccount(
    studentId: studentId,
    schoolId: schoolId,
    academicYear: '2026',
    term: 'Term 1',
    feeStructureId: 'fee-1',
    totalBilled: 500,
    totalPaid: 300,
    paymentHistory: [],
  );

  setUp(() {
    permissionEvaluator = MockPermissionEvaluator();
    studentRepository = MockStudentRepository();
    financeRepository = MockFinanceRepository();
    service = BursarStudentProjectionService(
      permissionEvaluator: permissionEvaluator,
      studentRepository: studentRepository,
      financeRepository: financeRepository,
    );

    when(
      () => studentRepository.getStudentById(studentId),
    ).thenAnswer((_) async => Right(student));
    when(
      () => financeRepository.getStudentFinancialAccount(studentId, schoolId),
    ).thenAnswer((_) async => const Right(account));
  });

  test(
    'denies without exposing any financial data when the operator lacks financeStudentBalanceRead',
    () async {
      when(
        () => permissionEvaluator.can(
          Permission.financeStudentBalanceRead,
          operatorUser,
        ),
      ).thenAnswer((_) async => const Right(false));

      final result = await service.getStudentView(
        studentId: studentId,
        schoolId: schoolId,
        operatorUser: operatorUser,
      );

      expect(
        result.fold((f) => f, (r) => null),
        isA<PermissionDeniedFailure>(),
      );
      verifyNever(
        () => financeRepository.getStudentFinancialAccount(any(), any()),
      );
    },
  );

  test(
    'returns balance/isFullyPaid computed from the financial account when allowed',
    () async {
      when(
        () => permissionEvaluator.can(
          Permission.financeStudentBalanceRead,
          operatorUser,
        ),
      ).thenAnswer((_) async => const Right(true));

      final result = await service.getStudentView(
        studentId: studentId,
        schoolId: schoolId,
        operatorUser: operatorUser,
      );

      final view = result.getOrElse(() => throw StateError('expected Right'));
      expect(view.name, 'Jane Doe');
      expect(view.totalBilled, 500);
      expect(view.totalPaid, 300);
      expect(view.balance, 200);
      expect(view.isFullyPaid, false);
    },
  );
}
