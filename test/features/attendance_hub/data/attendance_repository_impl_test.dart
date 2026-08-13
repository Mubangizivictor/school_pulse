import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/attendance_hub/data/datasources/attendance_remote_data_source.dart';
import 'package:school_pulse/features/attendance_hub/data/repositories/attendance_repository_impl.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_access_context.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_category.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';

class _MockAttendanceRemoteDataSource extends Mock
    implements AttendanceRemoteDataSource {}

class _MockStructureRepository extends Mock implements StructureRepository {}

class _MockStudentRepository extends Mock implements StudentRepository {}

class _MockGetStaffMembers extends Mock implements GetStaffMembers {}

void main() {
  late _MockStudentRepository students;
  late AttendanceRepositoryImpl repository;

  setUp(() {
    students = _MockStudentRepository();
    repository = AttendanceRepositoryImpl(
      remoteDataSource: _MockAttendanceRemoteDataSource(),
      structureRepository: _MockStructureRepository(),
      studentRepository: students,
      getStaffMembers: _MockGetStaffMembers(),
    );
  });

  test(
    'loads a manual student roster through the scoped canonical query',
    () async {
    final active = Student(
        id: 'student-a',
        schoolId: 'school-a',
        name: 'Active Student',
        studentCode: 'SPA001',
        admissionNumber: 'SPA001',
        dateOfBirth: DateTime(2010),
        gender: Gender.other,
        classId: 'class-a',
        academicYearId: 'year-a',
        status: StudentStatus.active,
        level: EducationLevel.primary,
      );
    final withdrawn = Student(
        id: 'student-b',
        schoolId: 'school-a',
        name: 'Withdrawn Student',
        studentCode: 'SPA002',
        admissionNumber: 'SPA002',
        dateOfBirth: DateTime(2010),
        gender: Gender.other,
        classId: 'class-a',
        academicYearId: 'year-a',
        status: StudentStatus.withdrawn,
        level: EducationLevel.primary,
      );
      when(
        () => students.searchStudents(schoolId: 'school-a', classId: 'class-a'),
      ).thenAnswer((_) async => Right([active, withdrawn]));

      final result = await repository.getRoster(
        'school-a',
        AttendanceCategory.students,
        'class-a',
        const AttendanceAccessContext(
          userId: 'staff-a',
          schoolId: 'school-a',
          allowedDomains: {AttendanceCategory.students},
          allowedClassIds: {'class-a'},
        ),
      );

      final roster = result.getOrElse(
        () => throw StateError('Expected roster'),
      );
      expect(roster, hasLength(1));
      expect(roster.single.id, 'student-a');
      expect(roster.single.subtitle, 'SPA001');
      verify(
        () => students.searchStudents(schoolId: 'school-a', classId: 'class-a'),
      ).called(1);
    },
  );
}
