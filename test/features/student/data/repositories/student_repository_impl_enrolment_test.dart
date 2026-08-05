import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/matron/data/sources/matron_remote_data_source.dart';
import 'package:school_pulse/features/relationships/domain/repositories/relationship_repository.dart';
import 'package:school_pulse/features/student/data/datasources/student_remote_data_source.dart';
import 'package:school_pulse/features/student/data/models/student_model.dart';
import 'package:school_pulse/features/student/data/repositories/student_repository_impl.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';

class MockStudentRemoteDataSource extends Mock
    implements StudentRemoteDataSource {}

class MockMatronRemoteDataSource extends Mock
    implements MatronRemoteDataSource {}

class MockRelationshipRepository extends Mock
    implements RelationshipRepository {}

void main() {
  late StudentRepositoryImpl repository;
  late MockStudentRemoteDataSource remoteDataSource;
  late MockMatronRemoteDataSource matronRemoteDataSource;
  late MockRelationshipRepository relationshipRepository;

  const schoolId = 'school-1';
  const studentId = 'student-1';

  StudentModel buildStudent({
    required String classId,
    String? streamId,
    required String academicYearId,
  }) {
    return StudentModel(
      id: studentId,
      schoolId: schoolId,
      name: 'Jane Doe',
      studentCode: 'SMAC260001',
      admissionNumber: 'SP-2026-0001',
      dateOfBirth: DateTime(2015, 1, 1),
      gender: Gender.female,
      classId: classId,
      streamId: streamId,
      academicYearId: academicYearId,
      status: StudentStatus.active,
      level: EducationLevel.primary,
    );
  }

  setUpAll(() {
    registerFallbackValue(buildStudent(classId: 'p6', academicYearId: '2026'));
  });

  setUp(() {
    remoteDataSource = MockStudentRemoteDataSource();
    matronRemoteDataSource = MockMatronRemoteDataSource();
    relationshipRepository = MockRelationshipRepository();
    repository = StudentRepositoryImpl(
      remoteDataSource: remoteDataSource,
      matronRemoteDataSource: matronRemoteDataSource,
      relationshipRepository: relationshipRepository,
    );
  });

  group('updateStudent', () {
    test(
      'records an enrolment change when placement actually changes',
      () async {
        when(() => remoteDataSource.getStudentById(studentId)).thenAnswer(
          (_) async => buildStudent(classId: 'p6', academicYearId: '2026'),
        );
        when(
          () => remoteDataSource.updateStudent(any()),
        ).thenAnswer((_) async {});
        when(
          () => relationshipRepository.recordEnrolmentChange(
            schoolId: any(named: 'schoolId'),
            studentId: any(named: 'studentId'),
            classId: any(named: 'classId'),
            streamId: any(named: 'streamId'),
            academicYearId: any(named: 'academicYearId'),
            recordedBy: any(named: 'recordedBy'),
            reason: any(named: 'reason'),
          ),
        ).thenAnswer((_) async => const Right(null));

        final updated = buildStudent(classId: 'p7', academicYearId: '2026');
        final result = await repository.updateStudent(
          updated,
          recordedBy: 'staff-1',
        );

        expect(result.isRight(), isTrue);
        verify(
          () => relationshipRepository.recordEnrolmentChange(
            schoolId: schoolId,
            studentId: studentId,
            classId: 'p7',
            streamId: null,
            academicYearId: '2026',
            recordedBy: 'staff-1',
            reason: 'correction',
          ),
        ).called(1);
      },
    );

    test(
      'does not record an enrolment change when placement is unchanged',
      () async {
        when(() => remoteDataSource.getStudentById(studentId)).thenAnswer(
          (_) async => buildStudent(classId: 'p6', academicYearId: '2026'),
        );
        when(
          () => remoteDataSource.updateStudent(any()),
        ).thenAnswer((_) async {});

        final updated = buildStudent(classId: 'p6', academicYearId: '2026');
        final result = await repository.updateStudent(
          updated,
          recordedBy: 'staff-1',
        );

        expect(result.isRight(), isTrue);
        verifyNever(
          () => relationshipRepository.recordEnrolmentChange(
            schoolId: any(named: 'schoolId'),
            studentId: any(named: 'studentId'),
            classId: any(named: 'classId'),
            academicYearId: any(named: 'academicYearId'),
            recordedBy: any(named: 'recordedBy'),
          ),
        );
      },
    );
  });

  group('promoteStudents', () {
    test('records an enrolment change for every promoted student', () async {
      when(() => remoteDataSource.getStudentById(any())).thenAnswer(
        (_) async => buildStudent(classId: 'p6', academicYearId: '2026'),
      );
      when(
        () => remoteDataSource.batchUpdateStudents(any()),
      ).thenAnswer((_) async {});
      when(
        () => relationshipRepository.recordEnrolmentChange(
          schoolId: any(named: 'schoolId'),
          studentId: any(named: 'studentId'),
          classId: any(named: 'classId'),
          streamId: any(named: 'streamId'),
          academicYearId: any(named: 'academicYearId'),
          recordedBy: any(named: 'recordedBy'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async => const Right(null));

      final result = await repository.promoteStudents(
        schoolId: schoolId,
        studentIds: ['student-1', 'student-2'],
        targetClassId: 'p7',
        targetAcademicYearId: '2027',
        recordedBy: 'staff-1',
      );

      expect(result.isRight(), isTrue);
      verify(
        () => relationshipRepository.recordEnrolmentChange(
          schoolId: schoolId,
          studentId: any(named: 'studentId'),
          classId: 'p7',
          streamId: null,
          academicYearId: '2027',
          recordedBy: 'staff-1',
          reason: 'promotion',
        ),
      ).called(2);
    });

    test(
      'propagates a batch update failure without recording enrolment history',
      () async {
        when(() => remoteDataSource.getStudentById(any())).thenAnswer(
          (_) async => buildStudent(classId: 'p6', academicYearId: '2026'),
        );
        when(
          () => remoteDataSource.batchUpdateStudents(any()),
        ).thenThrow(Exception('write failed'));

        final result = await repository.promoteStudents(
          schoolId: schoolId,
          studentIds: ['student-1'],
          targetClassId: 'p7',
          targetAcademicYearId: '2027',
          recordedBy: 'staff-1',
        );

        expect(result, isA<Left<Failure, void>>());
        verifyNever(
          () => relationshipRepository.recordEnrolmentChange(
            schoolId: any(named: 'schoolId'),
            studentId: any(named: 'studentId'),
            classId: any(named: 'classId'),
            academicYearId: any(named: 'academicYearId'),
            recordedBy: any(named: 'recordedBy'),
          ),
        );
      },
    );
  });
}
