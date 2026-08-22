import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/relationships/domain/usecases/create_relationship.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/entities/scholarship_award.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/repositories/enrollment_setup_repository.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/student/domain/services/admission_service.dart';
import 'package:school_pulse/features/student/domain/services/parent_linking_service.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/nfc_credential_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
import 'package:school_pulse/features/student/presentation/enrollment_setup/bloc/enrollment_setup_wizard_bloc.dart';
import 'package:school_pulse/features/student/presentation/enrollment_setup/bloc/enrollment_setup_wizard_event.dart';
import 'package:school_pulse/features/student/presentation/enrollment_setup/bloc/enrollment_setup_wizard_state.dart';

class MockStudentRepository extends Mock implements StudentRepository {}

class MockAdmissionService extends Mock implements AdmissionService {}

class MockEnrollmentSetupRepository extends Mock
    implements EnrollmentSetupRepository {}

class MockParentLinkingService extends Mock implements ParentLinkingService {}

class MockCreateRelationship extends Mock implements CreateRelationship {}

class MockStudentIdentityRepository extends Mock
    implements StudentIdentityRepository {}

class MockNfcCredentialRepository extends Mock
    implements NfcCredentialRepository {}

class MockPermissionEvaluator extends Mock implements PermissionEvaluator {}

class FakeCreateRelationshipParams extends Fake
    implements CreateRelationshipParams {}

void main() {
  late MockStudentRepository studentRepository;
  late MockAdmissionService admissionService;
  late MockEnrollmentSetupRepository enrollmentSetupRepository;
  late MockParentLinkingService parentLinkingService;
  late MockCreateRelationship createRelationship;
  late MockStudentIdentityRepository identityRepository;
  late MockNfcCredentialRepository nfcCredentialRepository;
  late MockPermissionEvaluator permissionEvaluator;
  late EnrollmentSetupWizardBloc bloc;

  final operatorUser = const UserEntity(
    id: 'staff-1',
    name: 'Staff One',
    email: 'staff@school.com',
    roles: [UserRole.schoolAdmin],
    schoolId: 'school-1',
  );

  setUpAll(() {
    registerFallbackValue(FakeCreateRelationshipParams());
    registerFallbackValue(StudentStatus.enrollmentInProgress);
    registerFallbackValue(
      const UserEntity(
        id: 'fallback',
        name: 'Fallback',
        email: 'fallback@school.com',
        roles: [UserRole.schoolAdmin],
        schoolId: 'school-1',
      ),
    );
    registerFallbackValue(
      ScholarshipAward(
        id: 'fallback',
        schoolId: 'school-1',
        studentId: 'student-1',
        type: ScholarshipAwardType.none,
        amountOrPercentage: 0,
        isPercentage: true,
        effectiveStart: DateTime(2026),
        approvedBy: 'staff-1',
        reason: '',
        createdAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    studentRepository = MockStudentRepository();
    admissionService = MockAdmissionService();
    enrollmentSetupRepository = MockEnrollmentSetupRepository();
    parentLinkingService = MockParentLinkingService();
    createRelationship = MockCreateRelationship();
    identityRepository = MockStudentIdentityRepository();
    nfcCredentialRepository = MockNfcCredentialRepository();
    permissionEvaluator = MockPermissionEvaluator();

    bloc = EnrollmentSetupWizardBloc(
      studentRepository: studentRepository,
      admissionService: admissionService,
      enrollmentSetupRepository: enrollmentSetupRepository,
      parentLinkingService: parentLinkingService,
      createRelationship: createRelationship,
      identityRepository: identityRepository,
      nfcCredentialRepository: nfcCredentialRepository,
      permissionEvaluator: permissionEvaluator,
    );

    when(
      () => studentRepository.updateStudentStatus(any(), any()),
    ).thenAnswer((_) async => const Right(null));
  });

  tearDown(() => bloc.close());

  group('ActivationRequested - idempotent double-tap', () {
    setUp(() {
      when(
        () => permissionEvaluator.can(Permission.enrollmentActivate, any()),
      ).thenAnswer((_) async => const Right(true));
      when(
        () => admissionService.enrollStudent(
          any(),
          schoolId: any(named: 'schoolId'),
          uniqueSystemId: any(named: 'uniqueSystemId'),
          studentCode: any(named: 'studentCode'),
          academicYear: any(named: 'academicYear'),
          term: any(named: 'term'),
          feeStructureId: any(named: 'feeStructureId'),
          totalBilled: any(named: 'totalBilled'),
        ),
      ).thenAnswer((_) async => const Right('student-1'));
    });

    blocTest<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
      'a second ActivationRequested while already activated is a no-op '
      '(enrollStudent is called exactly once)',
      build: () => bloc,
      seed: () => const EnrollmentSetupWizardState(
        studentId: 'student-1',
        schoolId: 'school-1',
        schoolCode: 'SCH',
        uniqueSystemId: 'usid-1',
        studentCode: 'SCH0001',
        admissionNumber: 'ADM-0001',
        academicYearId: 'year-1',
        classId: 'class-1',
        parentLinkSkippedFlag: true,
      ),
      act: (bloc) async {
        bloc.add(ActivationRequested(operatorUser));
        await Future<void>.delayed(const Duration(milliseconds: 5));
        bloc.add(ActivationRequested(operatorUser));
      },
      wait: const Duration(milliseconds: 50),
      verify: (_) {
        verify(
          () => admissionService.enrollStudent(
            any(),
            schoolId: any(named: 'schoolId'),
            uniqueSystemId: any(named: 'uniqueSystemId'),
            studentCode: any(named: 'studentCode'),
            academicYear: any(named: 'academicYear'),
            term: any(named: 'term'),
            feeStructureId: any(named: 'feeStructureId'),
            totalBilled: any(named: 'totalBilled'),
          ),
        ).called(1);
      },
    );

    blocTest<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
      'activating twice from a fresh bloc rejects the second dispatch '
      'once `activated` is already true',
      build: () => bloc,
      seed: () => const EnrollmentSetupWizardState(
        studentId: 'student-1',
        schoolId: 'school-1',
        schoolCode: 'SCH',
        uniqueSystemId: 'usid-1',
        studentCode: 'SCH0001',
        admissionNumber: 'ADM-0001',
        academicYearId: 'year-1',
        classId: 'class-1',
        parentLinkSkippedFlag: true,
        activated: true,
      ),
      act: (bloc) => bloc.add(ActivationRequested(operatorUser)),
      expect: () => <EnrollmentSetupWizardState>[],
      verify: (_) {
        verifyNever(
          () => admissionService.enrollStudent(
            any(),
            schoolId: any(named: 'schoolId'),
            uniqueSystemId: any(named: 'uniqueSystemId'),
            studentCode: any(named: 'studentCode'),
            academicYear: any(named: 'academicYear'),
            term: any(named: 'term'),
            feeStructureId: any(named: 'feeStructureId'),
            totalBilled: any(named: 'totalBilled'),
          ),
        );
      },
    );
  });

  group('ScholarshipAwardRequested - permission enforcement', () {
    blocTest<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
      'rejects a scholarship award attempt when the operator lacks '
      'Permission.enrollmentBursaryAssign, and never writes it',
      build: () {
        when(
          () => permissionEvaluator.can(
            Permission.enrollmentBursaryAssign,
            any(),
          ),
        ).thenAnswer((_) async => const Right(false));
        return bloc;
      },
      seed: () => const EnrollmentSetupWizardState(
        studentId: 'student-1',
        schoolId: 'school-1',
      ),
      act: (bloc) => bloc.add(
        ScholarshipAwardRequested(
          operatorUser: operatorUser,
          type: ScholarshipAwardType.partial,
          amountOrPercentage: 50,
          isPercentage: true,
          effectiveStart: DateTime(2026),
          reason: 'Sibling discount',
        ),
      ),
      expect: () => [
        isA<EnrollmentSetupWizardState>().having(
          (s) => s.error,
          'error',
          isNotNull,
        ),
      ],
      verify: (_) {
        verifyNever(
          () => enrollmentSetupRepository.createScholarshipAward(any()),
        );
      },
    );

    blocTest<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
      'allows the award when the operator holds the permission',
      build: () {
        when(
          () => permissionEvaluator.can(
            Permission.enrollmentBursaryAssign,
            any(),
          ),
        ).thenAnswer((_) async => const Right(true));
        when(
          () => enrollmentSetupRepository.createScholarshipAward(any()),
        ).thenAnswer(
          (invocation) async =>
              Right(invocation.positionalArguments.first as ScholarshipAward),
        );
        return bloc;
      },
      seed: () => const EnrollmentSetupWizardState(
        studentId: 'student-1',
        schoolId: 'school-1',
      ),
      act: (bloc) => bloc.add(
        ScholarshipAwardRequested(
          operatorUser: operatorUser,
          type: ScholarshipAwardType.partial,
          amountOrPercentage: 50,
          isPercentage: true,
          effectiveStart: DateTime(2026),
          reason: 'Sibling discount',
        ),
      ),
      expect: () => [
        isA<EnrollmentSetupWizardState>().having(
          (s) => s.isLoading,
          'isLoading',
          true,
        ),
        isA<EnrollmentSetupWizardState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.hasScholarshipAward, 'hasScholarshipAward', true),
      ],
    );
  });
}
