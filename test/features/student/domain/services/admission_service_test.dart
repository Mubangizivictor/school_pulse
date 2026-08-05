import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/finance/domain/usecases/initialize_student_financials.dart';
import 'package:school_pulse/features/student/domain/entities/admission_application.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/student/domain/services/admission_service.dart';
import 'package:school_pulse/features/student_identity/domain/entities/student_identity.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/features/student_identity/domain/services/id_generator_service.dart';

class MockStudentRepository extends Mock implements StudentRepository {}

class MockIdGeneratorService extends Mock implements IdGeneratorService {}

class MockStudentIdentityRepository extends Mock
    implements StudentIdentityRepository {}

class MockInitializeStudentFinancials extends Mock
    implements InitializeStudentFinancials {}

void main() {
  late AdmissionService service;
  late MockStudentRepository repository;
  late MockIdGeneratorService idGenerator;
  late MockStudentIdentityRepository identityRepository;
  late MockInitializeStudentFinancials initializeFinancials;

  const applicationId = 'app-1';
  const schoolId = 'school-1';
  const schoolCode = 'MH';
  const academicYear = '2026';
  const academicYearId = 'ay-2026';
  const admissionNumber = 'SP-2026-0007';
  const studentCode = 'MH-2026-000007';
  const uniqueSystemId = 'SP-STUDENT-abc123';
  const studentId = 'student-123';

  final identity = const StudentIdentity(
    studentId: studentId,
    uniqueSystemId: uniqueSystemId,
    schoolStudentId: studentCode,
    qrCodeData: uniqueSystemId,
  );

  setUpAll(() {
    registerFallbackValue(Student.empty());
  });

  setUp(() {
    repository = MockStudentRepository();
    idGenerator = MockIdGeneratorService();
    identityRepository = MockStudentIdentityRepository();
    initializeFinancials = MockInitializeStudentFinancials();

    service = AdmissionService(
      repository,
      idGenerator: idGenerator,
      identityRepository: identityRepository,
      initializeFinancials: initializeFinancials,
    );

    when(
      () => repository.generateAdmissionNumber(schoolId, academicYearId),
    ).thenAnswer((_) async => const Right(admissionNumber));
    when(
      () => idGenerator.generateSchoolStudentId(
        schoolPrefix: any(named: 'schoolPrefix'),
        year: any(named: 'year'),
        sequenceNumber: any(named: 'sequenceNumber'),
      ),
    ).thenReturn(studentCode);
    when(() => idGenerator.generateUniqueSystemId()).thenReturn(uniqueSystemId);
    when(
      () => repository.finalizeAdmission(
        any(),
        studentCode: any(named: 'studentCode'),
        admissionNumber: any(named: 'admissionNumber'),
        qrReference: any(named: 'qrReference'),
      ),
    ).thenAnswer((_) async => const Right(studentId));
    when(
      () => identityRepository.generateStudentIdentity(
        any(),
        uniqueSystemId: any(named: 'uniqueSystemId'),
        schoolStudentId: any(named: 'schoolStudentId'),
      ),
    ).thenAnswer((_) async => Right(identity));
  });

  group('admitStudent', () {
    Future<Either<Failure, void>> call({
      String? term,
      String? feeStructureId,
      double? totalBilled,
    }) {
      return service.admitStudent(
        applicationId,
        schoolId,
        schoolCode,
        academicYear,
        academicYearId,
        term: term,
        feeStructureId: feeStructureId,
        totalBilled: totalBilled,
      );
    }

    test(
      'derives the studentCode sequence from the minted admission number',
      () async {
        await call();

        verify(
          () => idGenerator.generateSchoolStudentId(
            schoolPrefix: schoolCode,
            year: any(named: 'year'),
            sequenceNumber: 7,
          ),
        ).called(1);
      },
    );

    test(
      'finalizes admission with the generated studentCode and qrReference',
      () async {
        await call();

        verify(
          () => repository.finalizeAdmission(
            applicationId,
            studentCode: studentCode,
            admissionNumber: admissionNumber,
            qrReference: uniqueSystemId,
          ),
        ).called(1);
      },
    );

    test(
      'generates the StudentIdentity using the same codes just written to the student record',
      () async {
        await call();

        final captured = verify(
          () => identityRepository.generateStudentIdentity(
            captureAny(),
            uniqueSystemId: uniqueSystemId,
            schoolStudentId: studentCode,
          ),
        ).captured;

        expect((captured.single as Student).id, studentId);
      },
    );

    test(
      'returns Right(studentId) when no financial parameters are supplied',
      () async {
        final result = await call();

        expect(result, const Right<Failure, String>(studentId));
        verifyNever(
          () => initializeFinancials(
            studentId: any(named: 'studentId'),
            schoolId: any(named: 'schoolId'),
            academicYear: any(named: 'academicYear'),
            term: any(named: 'term'),
            feeStructureId: any(named: 'feeStructureId'),
            totalBilled: any(named: 'totalBilled'),
          ),
        );
      },
    );

    test(
      'initializes financials when term/feeStructureId/totalBilled are supplied',
      () async {
        when(
          () => initializeFinancials(
            studentId: any(named: 'studentId'),
            schoolId: any(named: 'schoolId'),
            academicYear: any(named: 'academicYear'),
            term: any(named: 'term'),
            feeStructureId: any(named: 'feeStructureId'),
            totalBilled: any(named: 'totalBilled'),
          ),
        ).thenAnswer((_) async => const Right(null));

        final result = await call(
          term: 'Term 1',
          feeStructureId: 'fee-1',
          totalBilled: 500,
        );

        expect(result, const Right<Failure, String>(studentId));
        verify(
          () => initializeFinancials(
            studentId: studentId,
            schoolId: schoolId,
            academicYear: academicYear,
            term: 'Term 1',
            feeStructureId: 'fee-1',
            totalBilled: 500,
          ),
        ).called(1);
      },
    );

    test(
      'short-circuits and never finalizes admission when the admission number fails to generate',
      () async {
        when(
          () => repository.generateAdmissionNumber(schoolId, academicYearId),
        ).thenAnswer((_) async => Left(ServerFailure('boom')));

        final result = await call();

        expect(result, Left(ServerFailure('boom')));
        verifyNever(
          () => repository.finalizeAdmission(
            any(),
            studentCode: any(named: 'studentCode'),
            admissionNumber: any(named: 'admissionNumber'),
            qrReference: any(named: 'qrReference'),
          ),
        );
        verifyNever(
          () => identityRepository.generateStudentIdentity(
            any(),
            uniqueSystemId: any(named: 'uniqueSystemId'),
            schoolStudentId: any(named: 'schoolStudentId'),
          ),
        );
      },
    );

    test(
      'propagates finalizeAdmission failure without generating an identity',
      () async {
        when(
          () => repository.finalizeAdmission(
            any(),
            studentCode: any(named: 'studentCode'),
            admissionNumber: any(named: 'admissionNumber'),
            qrReference: any(named: 'qrReference'),
          ),
        ).thenAnswer((_) async => Left(ServerFailure('finalize failed')));

        final result = await call();

        expect(result, Left(ServerFailure('finalize failed')));
        verifyNever(
          () => identityRepository.generateStudentIdentity(
            any(),
            uniqueSystemId: any(named: 'uniqueSystemId'),
            schoolStudentId: any(named: 'schoolStudentId'),
          ),
        );
      },
    );

    test(
      'propagates identity generation failure without initializing financials',
      () async {
        when(
          () => identityRepository.generateStudentIdentity(
            any(),
            uniqueSystemId: any(named: 'uniqueSystemId'),
            schoolStudentId: any(named: 'schoolStudentId'),
          ),
        ).thenAnswer((_) async => Left(ServerFailure('identity failed')));

        final result = await call(
          term: 'Term 1',
          feeStructureId: 'fee-1',
          totalBilled: 500,
        );

        expect(result, Left(ServerFailure('identity failed')));
        verifyNever(
          () => initializeFinancials(
            studentId: any(named: 'studentId'),
            schoolId: any(named: 'schoolId'),
            academicYear: any(named: 'academicYear'),
            term: any(named: 'term'),
            feeStructureId: any(named: 'feeStructureId'),
            totalBilled: any(named: 'totalBilled'),
          ),
        );
      },
    );
  });

  group('checkForDuplicates', () {
    AdmissionApplication buildApplication({
      required String id,
      required String name,
      required DateTime dob,
    }) {
      return AdmissionApplication(
        id: id,
        schoolId: schoolId,
        studentName: name,
        dateOfBirth: dob,
        gender: Gender.female,
        targetClassId: 'class-1',
        academicYearId: academicYearId,
        applicantParentName: 'Parent',
        applicantParentPhone: '0700000000',
        status: AdmissionStatus.application,
        appliedAt: DateTime(2026, 1, 1),
      );
    }

    test('returns matches with the same name and date of birth', () async {
      final existing = buildApplication(
        id: 'app-1',
        name: 'Jane Doe',
        dob: DateTime(2015, 6, 1),
      );
      when(
        () => repository.getApplications(schoolId),
      ).thenAnswer((_) async => Right([existing]));

      final result = await service.checkForDuplicates(
        schoolId,
        'Jane Doe',
        DateTime(2015, 6, 1),
      );

      expect(result.getOrElse(() => []), [existing]);
    });

    test('matching is case-insensitive and trims whitespace', () async {
      final existing = buildApplication(
        id: 'app-1',
        name: 'Jane Doe',
        dob: DateTime(2015, 6, 1),
      );
      when(
        () => repository.getApplications(schoolId),
      ).thenAnswer((_) async => Right([existing]));

      final result = await service.checkForDuplicates(
        schoolId,
        '  jane doe  ',
        DateTime(2015, 6, 1),
      );

      expect(result.getOrElse(() => []), [existing]);
    });

    test('returns no matches when the name differs', () async {
      final existing = buildApplication(
        id: 'app-1',
        name: 'Jane Doe',
        dob: DateTime(2015, 6, 1),
      );
      when(
        () => repository.getApplications(schoolId),
      ).thenAnswer((_) async => Right([existing]));

      final result = await service.checkForDuplicates(
        schoolId,
        'John Doe',
        DateTime(2015, 6, 1),
      );

      expect(result.getOrElse(() => []), isEmpty);
    });

    test('returns no matches when the date of birth differs', () async {
      final existing = buildApplication(
        id: 'app-1',
        name: 'Jane Doe',
        dob: DateTime(2015, 6, 1),
      );
      when(
        () => repository.getApplications(schoolId),
      ).thenAnswer((_) async => Right([existing]));

      final result = await service.checkForDuplicates(
        schoolId,
        'Jane Doe',
        DateTime(2016, 6, 1),
      );

      expect(result.getOrElse(() => []), isEmpty);
    });

    test('propagates a repository failure', () async {
      when(
        () => repository.getApplications(schoolId),
      ).thenAnswer((_) async => Left(ServerFailure('boom')));

      final result = await service.checkForDuplicates(
        schoolId,
        'Jane Doe',
        DateTime(2015, 6, 1),
      );

      expect(result, Left(ServerFailure('boom')));
    });
  });
}
