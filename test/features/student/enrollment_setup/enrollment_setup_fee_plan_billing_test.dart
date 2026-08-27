// Focused Phase 1 coverage for the fee-plan/billing integration: the
// enrolment wizard's Finance step no longer writes free-text totalBilled -
// it records a `findMatchingFeePlan` result (or "billing pending" on no
// match) and, on successful activation, issues a bill via the immutable
// fee-plan backend using a stable idempotency key.
//
// Deliberately a separate file rather than an addition to
// enrollment_setup_wizard_bloc_test.dart: that file currently fails to
// compile for unrelated, pre-existing reasons (references to a
// `parentLinkSkippedFlag` state field and a `ParentLinkRequested` event that
// don't exist on this branch) predating this change - see the task's
// verification notes.
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/finance/domain/repositories/fee_billing_repository.dart';
import 'package:school_pulse/features/relationships/domain/entities/relationship_enums.dart';
import 'package:school_pulse/features/relationships/domain/usecases/create_relationship.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/repositories/enrollment_setup_repository.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/student/domain/services/admission_service.dart';
import 'package:school_pulse/features/student/domain/services/parent_linking_service.dart';
import 'package:school_pulse/features/student/presentation/enrollment_setup/bloc/enrollment_setup_wizard_bloc.dart';
import 'package:school_pulse/features/student/presentation/enrollment_setup/bloc/enrollment_setup_wizard_event.dart';
import 'package:school_pulse/features/student/presentation/enrollment_setup/bloc/enrollment_setup_wizard_state.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/nfc_credential_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';

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

class MockFeeBillingRepository extends Mock implements FeeBillingRepository {}

void main() {
  late MockStudentRepository studentRepository;
  late MockAdmissionService admissionService;
  late MockEnrollmentSetupRepository enrollmentSetupRepository;
  late MockParentLinkingService parentLinkingService;
  late MockCreateRelationship createRelationship;
  late MockStudentIdentityRepository identityRepository;
  late MockNfcCredentialRepository nfcCredentialRepository;
  late MockPermissionEvaluator permissionEvaluator;
  late MockFeeBillingRepository feeBillingRepository;
  late EnrollmentSetupWizardBloc bloc;

  final operatorUser = const UserEntity(
    id: 'staff-1',
    name: 'Staff One',
    email: 'staff@school.com',
    roles: [UserRole.schoolAdmin],
    schoolId: 'school-1',
  );

  const seedState = EnrollmentSetupWizardState(
    studentId: 'student-1',
    schoolId: 'school-1',
    schoolCode: 'SCH',
    uniqueSystemId: 'usid-1',
    studentCode: 'SCH0001',
    admissionNumber: 'ADM-0001',
    academicYearId: 'year-1',
    classId: 'class-1',
    guardians: [
      GuardianDraft(
        name: 'Jane Doe',
        phoneNumber: '+256700000000',
        type: RelationshipType.parent,
        relationshipLabel: 'Mother',
      ),
    ],
    guardiansLinked: true,
  );

  setUpAll(() {
    registerFallbackValue(
      const UserEntity(
        id: 'fallback',
        name: 'Fallback',
        email: 'fallback@school.com',
        roles: [UserRole.schoolAdmin],
        schoolId: 'school-1',
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
    feeBillingRepository = MockFeeBillingRepository();

    bloc = EnrollmentSetupWizardBloc(
      studentRepository: studentRepository,
      admissionService: admissionService,
      enrollmentSetupRepository: enrollmentSetupRepository,
      parentLinkingService: parentLinkingService,
      createRelationship: createRelationship,
      identityRepository: identityRepository,
      nfcCredentialRepository: nfcCredentialRepository,
      permissionEvaluator: permissionEvaluator,
      feeBillingRepository: feeBillingRepository,
    );

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
      ),
    ).thenAnswer((_) async => const Right('student-1'));
  });

  tearDown(() => bloc.close());

  group('FeePlanMatchUpdated', () {
    blocTest<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
      'a null match sets billingPending true and clears any prior match',
      build: () => bloc,
      seed: () => seedState.copyWith(
        matchedFeePlanId: 'stale-plan',
        billingPending: false,
      ),
      act: (bloc) => bloc.add(const FeePlanMatchUpdated(billingPending: true)),
      expect: () => [
        predicate<EnrollmentSetupWizardState>(
          (s) => s.billingPending && s.matchedFeePlanId == null,
        ),
      ],
    );

    blocTest<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
      'a resolved match records the plan id/version/total and clears pending',
      build: () => bloc,
      seed: () => seedState,
      act: (bloc) => bloc.add(
        const FeePlanMatchUpdated(
          planId: 'plan-1',
          versionId: 'v1',
          planName: 'Term 1 Fees',
          totalUgx: 500000,
          lines: [
            FeePlanLineData(chargeId: 'tuition', name: 'Tuition', amountUgx: 500000),
          ],
          billingPending: false,
        ),
      ),
      expect: () => [
        predicate<EnrollmentSetupWizardState>(
          (s) =>
              !s.billingPending &&
              s.matchedFeePlanId == 'plan-1' &&
              s.matchedFeePlanVersionId == 'v1' &&
              s.matchedFeePlanTotalUgx == 500000 &&
              s.matchedFeePlanLines.length == 1,
        ),
      ],
    );
  });

  group('ActivationRequested - bill issuance', () {
    blocTest<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
      'issues a bill with a stable studentId_planId idempotency key when a '
      'fee plan matched',
      build: () => bloc,
      seed: () => seedState.copyWith(
        matchedFeePlanId: 'plan-1',
        billingPending: false,
      ),
      setUp: () {
        when(
          () => feeBillingRepository.issueStudentBill(
            schoolId: any(named: 'schoolId'),
            studentId: any(named: 'studentId'),
            planId: any(named: 'planId'),
            idempotencyKey: any(named: 'idempotencyKey'),
          ),
        ).thenAnswer((_) async => const Right('bill-1'));
      },
      act: (bloc) => bloc.add(ActivationRequested(operatorUser)),
      verify: (_) {
        verify(
          () => feeBillingRepository.issueStudentBill(
            schoolId: 'school-1',
            studentId: 'student-1',
            planId: 'plan-1',
            idempotencyKey: 'student-1_plan-1',
          ),
        ).called(1);
      },
    );

    blocTest<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
      'does not call issueStudentBill when billing is still pending '
      '(no matched plan) - activation must not be blocked by this',
      build: () => bloc,
      seed: () => seedState.copyWith(billingPending: true),
      act: (bloc) => bloc.add(ActivationRequested(operatorUser)),
      verify: (_) {
        verifyNever(
          () => feeBillingRepository.issueStudentBill(
            schoolId: any(named: 'schoolId'),
            studentId: any(named: 'studentId'),
            planId: any(named: 'planId'),
            idempotencyKey: any(named: 'idempotencyKey'),
          ),
        );
      },
      expect: () => [
        predicate<EnrollmentSetupWizardState>((s) => s.isActivating),
        predicate<EnrollmentSetupWizardState>((s) => s.activated),
      ],
    );

    blocTest<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
      'a failed issueStudentBill still leaves the student activated, with '
      'an info message rather than blocking/rolling back activation',
      build: () => bloc,
      seed: () => seedState.copyWith(
        matchedFeePlanId: 'plan-1',
        billingPending: false,
      ),
      setUp: () {
        when(
          () => feeBillingRepository.issueStudentBill(
            schoolId: any(named: 'schoolId'),
            studentId: any(named: 'studentId'),
            planId: any(named: 'planId'),
            idempotencyKey: any(named: 'idempotencyKey'),
          ),
        ).thenAnswer((_) async => const Left(ServerFailure('boom')));
      },
      act: (bloc) => bloc.add(ActivationRequested(operatorUser)),
      expect: () => [
        predicate<EnrollmentSetupWizardState>((s) => s.isActivating),
        predicate<EnrollmentSetupWizardState>(
          (s) => s.activated && s.infoMessage != null,
        ),
      ],
    );
  });
}
