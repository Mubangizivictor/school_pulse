import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/finance/domain/usecases/initialize_student_financials.dart';
import 'package:school_pulse/features/student/domain/entities/admission_application.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/student/domain/services/admission_service.dart';
import 'package:school_pulse/features/student/presentation/bloc/admission_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/admission_event.dart';
import 'package:school_pulse/features/student/presentation/bloc/admission_state.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/features/student_identity/domain/entities/student_identity.dart';
import 'package:school_pulse/features/student_identity/domain/services/id_generator_service.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';

class MockStudentRepository extends Mock implements StudentRepository {}

class MockIdGeneratorService extends Mock implements IdGeneratorService {}

class MockStudentIdentityRepository extends Mock implements StudentIdentityRepository {}

class MockInitializeStudentFinancials extends Mock implements InitializeStudentFinancials {}

class MockPermissionEvaluator extends Mock implements PermissionEvaluator {}

void main() {
  late AdmissionBloc bloc;
  late AdmissionService admissionService;
  late MockStudentRepository repository;
  late MockIdGeneratorService idGenerator;
  late MockStudentIdentityRepository identityRepository;
  late MockInitializeStudentFinancials initializeFinancials;
  late MockPermissionEvaluator permissionEvaluator;

  const schoolId = 'school-1';
  const operatorUser = UserEntity(
    id: 'staff-1',
    name: 'Admin User',
    email: 'admin@example.com',
    schoolId: schoolId,
    roles: [UserRole.schoolAdmin],
  );

  final application = AdmissionApplication(
    id: 'app-1',
    schoolId: schoolId,
    studentName: 'Jane Doe',
    dateOfBirth: DateTime(2015, 1, 1),
    gender: Gender.female,
    targetClassId: 'class-1',
    academicYearId: 'ay-2026',
    applicantParentName: 'John Doe',
    applicantParentPhone: '0700000000',
    status: AdmissionStatus.application,
    appliedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(application);
    registerFallbackValue(Student.empty());
    registerFallbackValue(AdmissionStatus.approved);
  });

  setUp(() {
    repository = MockStudentRepository();
    idGenerator = MockIdGeneratorService();
    identityRepository = MockStudentIdentityRepository();
    initializeFinancials = MockInitializeStudentFinancials();
    permissionEvaluator = MockPermissionEvaluator();

    admissionService = AdmissionService(
      repository,
      idGenerator: idGenerator,
      identityRepository: identityRepository,
      initializeFinancials: initializeFinancials,
    );

    bloc = AdmissionBloc(
      admissionService: admissionService,
      permissionEvaluator: permissionEvaluator,
    );
  });

  tearDown(() => bloc.close());

  group('LoadApplicationsRequested', () {
    blocTest<AdmissionBloc, AdmissionState>(
      'emits [Loading, ApplicationsLoaded] on success',
      build: () {
        when(() => repository.getApplications(schoolId))
            .thenAnswer((_) async => Right([application]));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadApplicationsRequested(schoolId)),
      expect: () => [
        AdmissionLoading(),
        AdmissionApplicationsLoaded([application]),
      ],
    );

    blocTest<AdmissionBloc, AdmissionState>(
      'emits [Loading, Error] on failure',
      build: () {
        when(() => repository.getApplications(schoolId))
            .thenAnswer((_) async => Left(ServerFailure('boom')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadApplicationsRequested(schoolId)),
      expect: () => [AdmissionLoading(), const AdmissionError('boom')],
    );
  });

  group('ReviewApplicationRequested', () {
    blocTest<AdmissionBloc, AdmissionState>(
      'emits ActionSuccess with an approval message when approve is true',
      build: () {
        when(() => repository.updateApplicationStatus(
              any(),
              any(),
              reviewerId: any(named: 'reviewerId'),
              comments: any(named: 'comments'),
            )).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const ReviewApplicationRequested(
        applicationId: 'app-1',
        reviewerId: 'staff-1',
        approve: true,
      )),
      expect: () => [const AdmissionActionSuccess('Application approved')],
    );

    blocTest<AdmissionBloc, AdmissionState>(
      'emits ActionSuccess with a rejection message when approve is false',
      build: () {
        when(() => repository.updateApplicationStatus(
              any(),
              any(),
              reviewerId: any(named: 'reviewerId'),
              comments: any(named: 'comments'),
            )).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const ReviewApplicationRequested(
        applicationId: 'app-1',
        reviewerId: 'staff-1',
        approve: false,
      )),
      expect: () => [const AdmissionActionSuccess('Application rejected')],
    );
  });

  group('EnrollStudentRequested', () {
    final enrollEvent = const EnrollStudentRequested(
      operatorUser: operatorUser,
      applicationId: 'app-1',
      schoolId: schoolId,
      schoolCode: 'MH',
      academicYear: '2026',
      academicYearId: 'ay-2026',
    );

    blocTest<AdmissionBloc, AdmissionState>(
      'emits ActionDenied and never calls AdmissionService when the operator lacks admission.enroll',
      build: () {
        when(() => permissionEvaluator.can(Permission.admissionEnroll, operatorUser))
            .thenAnswer((_) async => const Right(false));
        return bloc;
      },
      act: (bloc) => bloc.add(enrollEvent),
      expect: () => [
        const AdmissionActionDenied('You do not have permission to enroll students.'),
      ],
      verify: (_) {
        verifyNever(() => repository.generateAdmissionNumber(any(), any()));
      },
    );

    blocTest<AdmissionBloc, AdmissionState>(
      'emits ActionSuccess when the operator has admission.enroll and admission succeeds',
      build: () {
        when(() => permissionEvaluator.can(Permission.admissionEnroll, operatorUser))
            .thenAnswer((_) async => const Right(true));
        when(() => repository.generateAdmissionNumber(schoolId, 'ay-2026'))
            .thenAnswer((_) async => const Right('SP-2026-0001'));
        when(() => idGenerator.generateSchoolStudentId(
              schoolPrefix: any(named: 'schoolPrefix'),
              year: any(named: 'year'),
              sequenceNumber: any(named: 'sequenceNumber'),
            )).thenReturn('MH-2026-000001');
        when(() => idGenerator.generateUniqueSystemId()).thenReturn('SP-STUDENT-xyz');
        when(() => repository.finalizeAdmission(
              any(),
              studentCode: any(named: 'studentCode'),
              admissionNumber: any(named: 'admissionNumber'),
              qrReference: any(named: 'qrReference'),
            )).thenAnswer((_) async => const Right('student-1'));
        when(() => identityRepository.generateStudentIdentity(
              any(),
              uniqueSystemId: any(named: 'uniqueSystemId'),
              schoolStudentId: any(named: 'schoolStudentId'),
            )).thenAnswer((_) async => const Right(StudentIdentity(
              studentId: 'student-1',
              uniqueSystemId: 'SP-STUDENT-xyz',
              schoolStudentId: 'MH-2026-000001',
              qrCodeData: 'SP-STUDENT-xyz',
            )));
        return bloc;
      },
      act: (bloc) => bloc.add(enrollEvent),
      expect: () => [const AdmissionActionSuccess('Student enrolled')],
    );
  });
}
