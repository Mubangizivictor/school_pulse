import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/relationships/domain/usecases/create_relationship.dart';
import 'package:school_pulse/features/student/data/enrollment_setup/datasources/enrollment_setup_draft.dart';
import 'package:school_pulse/features/student/data/enrollment_setup/datasources/enrollment_setup_draft_local_data_source.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/entities/dormitory_assignment.dart';
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

/// In-memory fake (not a mock) - draft persistence is a stateful round trip
/// (save then later get/delete), which is simpler to express faithfully as
/// a fake than to stub call-by-call with mocktail.
class FakeEnrollmentSetupDraftLocalDataSource
    implements EnrollmentSetupDraftLocalDataSource {
  final Map<String, EnrollmentSetupDraft> _store = {};
  int saveCount = 0;

  String _key(String schoolId, String studentId) => '$schoolId::$studentId';

  @override
  Future<EnrollmentSetupDraft?> getDraft({
    required String schoolId,
    required String studentId,
  }) async => _store[_key(schoolId, studentId)];

  @override
  Future<void> saveDraft({
    required String schoolId,
    required String studentId,
    String? applicationId,
    required int currentStep,
    required int completedStepsMask,
    required Map<String, dynamic> stateJson,
  }) async {
    saveCount++;
    _store[_key(schoolId, studentId)] = EnrollmentSetupDraft(
      currentStep: currentStep,
      completedStepsMask: completedStepsMask,
      stateJson: '{}',
    );
  }

  @override
  Future<void> deleteDraft({
    required String schoolId,
    required String studentId,
  }) async {
    _store.remove(_key(schoolId, studentId));
  }
}

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
      DormitoryAssignment(
        id: 'fallback',
        studentId: 'student-1',
        schoolId: 'school-1',
        hostelId: 'hostel-1',
        roomId: 'room-1',
        bed: 'A',
        assignedAt: DateTime(2026),
        assignedBy: 'staff-1',
      ),
    );
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

  group('role-security: non-privileged staff is denied, not silently '
      'ignored or thrown', () {
    final classTeacher = const UserEntity(
      id: 'teacher-1',
      name: 'Class Teacher',
      email: 'teacher@school.com',
      roles: [UserRole.classTeacher],
      schoolId: 'school-1',
    );

    blocTest<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
      'DormitoryAssignmentRequested is denied for an operator lacking '
      'Permission.enrollmentBoardingAssign - repository is never called',
      build: () {
        when(
          () => permissionEvaluator.can(
            Permission.enrollmentBoardingAssign,
            any(),
          ),
        ).thenAnswer((_) async => const Right(false));
        return bloc;
      },
      seed: () =>
          const EnrollmentSetupWizardState(studentId: 's1', schoolId: 'sc1'),
      act: (bloc) => bloc.add(
        DormitoryAssignmentRequested(
          operatorUser: classTeacher,
          hostelId: 'h1',
          roomId: 'r1',
          bed: 'A',
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
        verifyNever(() => enrollmentSetupRepository.assignDormitory(any()));
      },
    );

    blocTest<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
      'ParentLinkRequested is denied for an operator lacking '
      'Permission.enrollmentParentLink - linking service is never called',
      build: () {
        when(
          () => permissionEvaluator.can(Permission.enrollmentParentLink, any()),
        ).thenAnswer((_) async => const Right(false));
        return bloc;
      },
      seed: () =>
          const EnrollmentSetupWizardState(studentId: 's1', schoolId: 'sc1'),
      act: (bloc) => bloc.add(
        ParentLinkRequested(
          operatorUser: classTeacher,
          phoneNumber: '+256700000000',
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
          () => parentLinkingService.linkStudentToParent(
            studentId: any(named: 'studentId'),
            studentName: any(named: 'studentName'),
            schoolId: any(named: 'schoolId'),
            phoneNumber: any(named: 'phoneNumber'),
            parentName: any(named: 'parentName'),
            createdBy: any(named: 'createdBy'),
          ),
        );
      },
    );

    blocTest<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
      'ActivationRequested is denied for an operator lacking '
      'Permission.enrollmentActivate - enrollStudent is never called',
      build: () {
        when(
          () => permissionEvaluator.can(Permission.enrollmentActivate, any()),
        ).thenAnswer((_) async => const Right(false));
        return bloc;
      },
      seed: () => const EnrollmentSetupWizardState(
        studentId: 's1',
        schoolId: 'sc1',
        academicYearId: 'y1',
        classId: 'c1',
        studentCode: 'SCH0001',
        parentLinkSkippedFlag: true,
      ),
      act: (bloc) => bloc.add(ActivationRequested(classTeacher)),
      expect: () => [
        isA<EnrollmentSetupWizardState>().having(
          (s) => s.error,
          'error',
          isNotNull,
        ),
      ],
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

  group('NfcRegistrationRequested - duplicate assignment prevention', () {
    blocTest<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
      'when the student already has an assigned credential, assign() is '
      'never called again - findAssignedCredential short-circuits',
      build: () {
        when(
          () =>
              permissionEvaluator.can(Permission.enrollmentCardGenerate, any()),
        ).thenAnswer((_) async => const Right(true));
        when(
          () => nfcCredentialRepository.findAssignedCredential(
            identityId: any(named: 'identityId'),
            schoolId: any(named: 'schoolId'),
          ),
        ).thenAnswer((_) async => const Right('existing-card-uid'));
        return bloc;
      },
      seed: () =>
          const EnrollmentSetupWizardState(studentId: 's1', schoolId: 'sc1'),
      act: (bloc) => bloc.add(
        NfcRegistrationRequested(
          operatorUser: operatorUser,
          credentialValue: 'new-card-uid',
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
            .having((s) => s.nfcRegistered, 'nfcRegistered', true),
      ],
      verify: (_) {
        verifyNever(
          () => nfcCredentialRepository.assign(
            credentialValue: any(named: 'credentialValue'),
            identityId: any(named: 'identityId'),
            identityType: any(named: 'identityType'),
            schoolId: any(named: 'schoolId'),
            studentId: any(named: 'studentId'),
          ),
        );
      },
    );
  });

  group('ParentLinkRequested - already-linked parent is idempotent', () {
    blocTest<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
      'calling ParentLinkRequested twice for the same student+phone only '
      'creates one relationship - linkStudentToParent itself owns '
      'idempotency (verified in parent_linking_service_test.dart); this '
      'proves the bloc calls it exactly once per dispatch, never twice '
      'for one dispatch',
      build: () {
        when(
          () => permissionEvaluator.can(Permission.enrollmentParentLink, any()),
        ).thenAnswer((_) async => const Right(true));
        when(
          () => parentLinkingService.linkStudentToParent(
            studentId: any(named: 'studentId'),
            studentName: any(named: 'studentName'),
            schoolId: any(named: 'schoolId'),
            phoneNumber: any(named: 'phoneNumber'),
            parentName: any(named: 'parentName'),
            createdBy: any(named: 'createdBy'),
          ),
        ).thenAnswer((_) async => const Right('PAR001'));
        return bloc;
      },
      seed: () =>
          const EnrollmentSetupWizardState(studentId: 's1', schoolId: 'sc1'),
      act: (bloc) => bloc.add(
        ParentLinkRequested(
          operatorUser: operatorUser,
          phoneNumber: '+256700000000',
        ),
      ),
      verify: (_) {
        verify(
          () => parentLinkingService.linkStudentToParent(
            studentId: any(named: 'studentId'),
            studentName: any(named: 'studentName'),
            schoolId: any(named: 'schoolId'),
            phoneNumber: any(named: 'phoneNumber'),
            parentName: any(named: 'parentName'),
            createdBy: any(named: 'createdBy'),
          ),
        ).called(1);
      },
    );
  });

  group('Draft persistence (Isar-backed resume)', () {
    late FakeEnrollmentSetupDraftLocalDataSource draftDataSource;

    setUp(() {
      draftDataSource = FakeEnrollmentSetupDraftLocalDataSource();
      bloc = EnrollmentSetupWizardBloc(
        studentRepository: studentRepository,
        admissionService: admissionService,
        enrollmentSetupRepository: enrollmentSetupRepository,
        parentLinkingService: parentLinkingService,
        createRelationship: createRelationship,
        identityRepository: identityRepository,
        nfcCredentialRepository: nfcCredentialRepository,
        permissionEvaluator: permissionEvaluator,
        draftLocalDataSource: draftDataSource,
      );
    });

    blocTest<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
      'WizardStarted with no existing draft starts fresh at step 0, '
      'resumedFromDraft is false',
      build: () => bloc,
      act: (bloc) => bloc.add(
        WizardStarted(
          operatorUser: operatorUser,
          studentId: 's1',
          schoolId: 'sc1',
          schoolCode: 'SCH',
          uniqueSystemId: 'usid-1',
          studentCode: 'SCH0001',
          admissionNumber: 'ADM-0001',
          academicYearId: 'year-1',
          classId: 'class-1',
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
            .having((s) => s.resumedFromDraft, 'resumedFromDraft', false)
            .having((s) => s.currentStep, 'currentStep', 0),
      ],
    );

    blocTest<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
      'WizardNextStep persists a draft that a later WizardStarted for the '
      'same student+school resumes from, with resumedFromDraft=true and '
      'the saved currentStep',
      build: () => bloc,
      act: (bloc) async {
        bloc.add(
          WizardStarted(
            operatorUser: operatorUser,
            studentId: 's1',
            schoolId: 'sc1',
            schoolCode: 'SCH',
            uniqueSystemId: 'usid-1',
            studentCode: 'SCH0001',
            admissionNumber: 'ADM-0001',
            academicYearId: 'year-1',
            classId: 'class-1',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const WizardNextStep());
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Fresh bloc instance simulating a killed/reopened app - only the
        // Isar-backed fake data source carries state across.
        final resumedBloc = EnrollmentSetupWizardBloc(
          studentRepository: studentRepository,
          admissionService: admissionService,
          enrollmentSetupRepository: enrollmentSetupRepository,
          parentLinkingService: parentLinkingService,
          createRelationship: createRelationship,
          identityRepository: identityRepository,
          nfcCredentialRepository: nfcCredentialRepository,
          permissionEvaluator: permissionEvaluator,
          draftLocalDataSource: draftDataSource,
        );
        resumedBloc.add(
          WizardStarted(
            operatorUser: operatorUser,
            studentId: 's1',
            schoolId: 'sc1',
            schoolCode: 'SCH',
            uniqueSystemId: 'usid-1',
            studentCode: 'SCH0001',
            admissionNumber: 'ADM-0001',
            academicYearId: 'year-1',
            classId: 'class-1',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(resumedBloc.state.resumedFromDraft, isTrue);
        expect(resumedBloc.state.currentStep, 1);
        await resumedBloc.close();
      },
    );

    blocTest<EnrollmentSetupWizardBloc, EnrollmentSetupWizardState>(
      'a successful ActivationRequested deletes the local draft',
      build: () {
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
        ).thenAnswer((_) async => const Right('s1'));
        return bloc;
      },
      seed: () => const EnrollmentSetupWizardState(
        studentId: 's1',
        schoolId: 'sc1',
        academicYearId: 'y1',
        classId: 'c1',
        studentCode: 'SCH0001',
        parentLinkSkippedFlag: true,
      ),
      act: (bloc) async {
        await draftDataSource.saveDraft(
          schoolId: 'sc1',
          studentId: 's1',
          currentStep: 3,
          completedStepsMask: 7,
          stateJson: const {},
        );
        bloc.add(ActivationRequested(operatorUser));
      },
      wait: const Duration(milliseconds: 20),
      verify: (_) async {
        final remaining = await draftDataSource.getDraft(
          schoolId: 'sc1',
          studentId: 's1',
        );
        expect(remaining, isNull);
      },
    );
  });
}
