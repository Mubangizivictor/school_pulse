import 'package:dartz/dartz.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/relationships/domain/entities/parent_student_relationship.dart';
import 'package:school_pulse/features/relationships/domain/entities/relationship_enums.dart';
import 'package:school_pulse/features/relationships/domain/usecases/create_relationship.dart';
import 'package:school_pulse/features/student/data/enrollment_setup/repositories/enrollment_setup_repository_impl.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/entities/scholarship_award.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/student/domain/services/admission_service.dart';
import 'package:school_pulse/features/student/domain/services/parent_linking_service.dart';
import 'package:school_pulse/features/student/presentation/enrollment_setup/bloc/enrollment_setup_wizard_bloc.dart';
import 'package:school_pulse/features/student/presentation/enrollment_setup/bloc/enrollment_setup_wizard_event.dart';
import 'package:school_pulse/features/student_identity/domain/entities/student_identity.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/nfc_credential_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';

class MockStudentRepository extends Mock implements StudentRepository {}

class MockAdmissionService extends Mock implements AdmissionService {}

class MockParentLinkingService extends Mock implements ParentLinkingService {}

class MockCreateRelationship extends Mock implements CreateRelationship {}

class MockStudentIdentityRepository extends Mock
    implements StudentIdentityRepository {}

class MockNfcCredentialRepository extends Mock
    implements NfcCredentialRepository {}

class MockPermissionEvaluator extends Mock implements PermissionEvaluator {}

class FakeCreateRelationshipParams extends Fake
    implements CreateRelationshipParams {}

/// Bloc-sequence integration test (see Task 9 of the enrollment-followup
/// spec): drives the full 8-step Enrollment Setup Wizard end to end.
///
/// The 3 collections the wizard's OWN repository owns
/// (scholarship_awards/dormitory_assignments/student_club_memberships) are
/// backed by a real [FakeFirebaseFirestore] + the real
/// [EnrollmentSetupRepositoryImpl] - not mocked - so the "exactly one X
/// doc" assertions below are checking real Firestore-shaped writes, not a
/// mock call count. Everything the wizard borrows from other already-
/// tested features (AdmissionService.enrollStudent, ParentLinkingService,
/// StudentIdentityRepository, NfcCredentialRepository - each has its own
/// dedicated test suite) is mocked here, matching this repo's convention
/// of not re-deriving another feature's correctness inside this test.
void main() {
  late FakeFirebaseFirestore firestore;
  late EnrollmentSetupRepositoryImpl enrollmentSetupRepository;
  late MockStudentRepository studentRepository;
  late MockAdmissionService admissionService;
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
    registerFallbackValue(operatorUser);
  });

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    enrollmentSetupRepository = EnrollmentSetupRepositoryImpl(
      firestore: firestore,
    );
    studentRepository = MockStudentRepository();
    admissionService = MockAdmissionService();
    parentLinkingService = MockParentLinkingService();
    createRelationship = MockCreateRelationship();
    identityRepository = MockStudentIdentityRepository();
    nfcCredentialRepository = MockNfcCredentialRepository();
    permissionEvaluator = MockPermissionEvaluator();

    // Every enrollment* permission check passes - role-security is its own
    // dedicated test group in enrollment_setup_wizard_bloc_test.dart.
    when(
      () => permissionEvaluator.can(any(), any()),
    ).thenAnswer((_) async => const Right(true));

    when(
      () => studentRepository.updateStudentStatus(any(), any()),
    ).thenAnswer((_) async => const Right(null));

    when(
      () => parentLinkingService.linkStudentToParent(
        studentId: any(named: 'studentId'),
        studentName: any(named: 'studentName'),
        schoolId: any(named: 'schoolId'),
        phoneNumber: any(named: 'phoneNumber'),
        parentName: any(named: 'parentName'),
        createdBy: any(named: 'createdBy'),
      ),
    ).thenAnswer((_) async => const Right('PARACC01'));

    when(() => createRelationship(any())).thenAnswer(
      (_) async => Right(
        ParentStudentRelationship(
          id: 'rel-1',
          schoolId: 'school-1',
          studentId: 'student-1',
          type: RelationshipType.parent,
          isPrimaryGuardian: true,
          createdBy: 'staff-1',
          createdAt: DateTime(2026),
        ),
      ),
    );

    when(() => identityRepository.getStudentIdentity(any())).thenAnswer(
      (_) async => Right(
        StudentIdentity(
          studentId: 'student-1',
          schoolId: 'school-1',
          uniqueSystemId: 'usid-1',
          schoolStudentId: 'SCH0001',
          qrCodeData: 'qr-data',
          nfcStatus: 'unassigned',
        ),
      ),
    );

    when(
      () => nfcCredentialRepository.findAssignedCredential(
        identityId: any(named: 'identityId'),
        schoolId: any(named: 'schoolId'),
      ),
    ).thenAnswer((_) async => const Right(null));
    when(
      () => nfcCredentialRepository.assign(
        credentialValue: any(named: 'credentialValue'),
        identityId: any(named: 'identityId'),
        identityType: any(named: 'identityType'),
        schoolId: any(named: 'schoolId'),
        studentId: any(named: 'studentId'),
      ),
    ).thenAnswer((_) async => const Right(null));

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
  });

  tearDown(() => bloc.close());

  Future<void> driveFullWizard({required bool withBoarding}) async {
    bloc.add(
      WizardStarted(
        operatorUser: operatorUser,
        studentId: 'student-1',
        schoolId: 'school-1',
        schoolCode: 'SCH',
        uniqueSystemId: 'usid-1',
        studentCode: 'SCH0001',
        admissionNumber: 'ADM-0001',
        academicYearId: 'year-1',
        classId: 'class-1',
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 5));

    // Step 1: Admission
    bloc.add(
      const AdmissionDetailsUpdated(
        boardingType: StudentBoardingType.day,
        joiningStatus: 'New admission',
      ),
    );
    bloc.add(const WizardNextStep());

    // Step 2: Academic Placement
    bloc.add(
      const AcademicPlacementUpdated(
        classId: 'class-1',
        academicYearId: 'year-1',
      ),
    );
    bloc.add(const WizardNextStep());

    // Step 3: Finance + bursary
    bloc.add(
      const FinanceDetailsUpdated(
        feeStructureId: 'fee-1',
        term: 'Term 1',
        totalBilled: 500000,
      ),
    );
    bloc.add(
      ScholarshipAwardRequested(
        operatorUser: operatorUser,
        type: ScholarshipAwardType.partial,
        amountOrPercentage: 20,
        isPercentage: true,
        effectiveStart: DateTime(2026),
        reason: 'Sibling discount',
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 5));
    bloc.add(const WizardNextStep());

    // Step 4: Boarding/House
    if (withBoarding) {
      bloc.add(
        DormitoryAssignmentRequested(
          operatorUser: operatorUser,
          hostelId: 'hostel-1',
          roomId: 'room-1',
          bed: 'A1',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    bloc.add(const WizardNextStep());

    // Step 5: Clubs
    bloc.add(const ClubMembershipToggled('chess-club', true));
    bloc.add(const ClubMembershipsSaveRequested());
    await Future<void>.delayed(const Duration(milliseconds: 5));
    bloc.add(const WizardNextStep());

    // Step 6: Parent/Guardian
    bloc.add(
      ParentLinkRequested(
        operatorUser: operatorUser,
        phoneNumber: '+256700000000',
        parentName: 'Jane Parent',
        isPrimaryGuardian: true,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 5));
    bloc.add(const WizardNextStep());

    // Step 7: Student Identity
    bloc.add(IdentityPreviewRequested(operatorUser));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    bloc.add(const WizardNextStep());

    // Step 8: Review & Activate
    bloc.add(ActivationRequested(operatorUser));
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }

  test('full 8-step sequence (with boarding) ends activated with exactly one '
      'write to each collection the wizard owns', () async {
    await driveFullWizard(withBoarding: true);

    expect(bloc.state.activated, isTrue);
    expect(bloc.state.error, isNull);

    final awards = await firestore.collection('scholarship_awards').get();
    expect(awards.docs, hasLength(1));
    expect(awards.docs.first.data()['studentId'], 'student-1');

    final assignments = await firestore
        .collection('dormitory_assignments')
        .get();
    expect(assignments.docs, hasLength(1));
    expect(assignments.docs.first.data()['bed'], 'A1');

    final memberships = await firestore
        .collection('student_club_memberships')
        .get();
    expect(memberships.docs, hasLength(1));
    expect(memberships.docs.first.data()['clubId'], 'chess-club');

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
  });

  test('a day (non-boarding) student ends activated with zero dormitory '
      'assignments and exactly one scholarship + club membership', () async {
    await driveFullWizard(withBoarding: false);

    expect(bloc.state.activated, isTrue);

    final assignments = await firestore
        .collection('dormitory_assignments')
        .get();
    expect(assignments.docs, isEmpty);

    final awards = await firestore.collection('scholarship_awards').get();
    expect(awards.docs, hasLength(1));

    final memberships = await firestore
        .collection('student_club_memberships')
        .get();
    expect(memberships.docs, hasLength(1));
  });

  test('a simulated retry of ActivationRequested after activation never '
      'calls enrollStudent twice and never creates duplicate award/'
      'assignment/membership docs', () async {
    await driveFullWizard(withBoarding: true);
    expect(bloc.state.activated, isTrue);

    // Simulated retry: the operator's device double-taps or resubmits
    // after a slow response - the bloc's own idempotency guard
    // (isActivating || activated) must make this a no-op.
    bloc.add(ActivationRequested(operatorUser));
    await Future<void>.delayed(const Duration(milliseconds: 20));

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

    final awards = await firestore.collection('scholarship_awards').get();
    expect(awards.docs, hasLength(1));
    final assignments = await firestore
        .collection('dormitory_assignments')
        .get();
    expect(assignments.docs, hasLength(1));
    final memberships = await firestore
        .collection('student_club_memberships')
        .get();
    expect(memberships.docs, hasLength(1));
  });
}
