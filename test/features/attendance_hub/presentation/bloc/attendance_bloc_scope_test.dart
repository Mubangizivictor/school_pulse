import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_access_context.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_category.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_record.dart';
import 'package:school_pulse/features/attendance_hub/domain/repositories/attendance_repository.dart';
import 'package:school_pulse/features/attendance_hub/domain/services/attendance_participant_resolver.dart';
import 'package:school_pulse/features/attendance_hub/presentation/bloc/attendance_bloc.dart';
import 'package:school_pulse/features/attendance_hub/presentation/bloc/attendance_event.dart';
import 'package:school_pulse/features/attendance_hub/presentation/bloc/attendance_state.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';

class _Repository extends Mock implements AttendanceRepository {}

class _Permissions extends Mock implements PermissionEvaluator {}

class _Resolver extends Mock implements AttendanceParticipantResolver {}

class _RecordFake extends Fake implements AttendanceRecord {}

const _teacher = UserEntity(
  id: 'teacher-blue',
  name: 'P5 Blue Teacher',
  email: 'blue@example.com',
  schoolId: 'school-a',
  roles: [UserRole.classTeacher],
);

void main() {
  setUpAll(() {
    registerFallbackValue(_teacher);
    registerFallbackValue(_RecordFake());
  });

  late _Repository repository;
  late _Permissions permissions;
  late _Resolver resolver;
  late AttendanceBloc bloc;

  setUp(() {
    repository = _Repository();
    permissions = _Permissions();
    resolver = _Resolver();
    bloc = AttendanceBloc(
      repository: repository,
      permissionEvaluator: permissions,
      participantResolver: resolver,
    );
    when(
      () => permissions.can(any(), any()),
    ).thenAnswer((_) async => const Right(true));
    when(() => resolver.resolve(any())).thenAnswer(
      (_) async => const Right(
        AttendanceAccessContext(
          userId: 'teacher-blue',
          schoolId: 'school-a',
          allowedDomains: {AttendanceCategory.students},
          allowedClassIds: {'p5-blue'},
          assignmentIdByClassId: {'p5-blue': 'assignment-blue'},
        ),
      ),
    );
  });

  tearDown(() => bloc.close());

  AttendanceRecord redRecord(AttendanceMethod method) => AttendanceRecord(
    id: '',
    schoolId: 'school-a',
    category: AttendanceCategory.students,
    scopeId: 'p5-red',
    scopeName: 'P5 Red',
    date: DateTime(2026, 8, 16),
    personId: 'student-red',
    personName: 'P5 Red learner',
    status: AttendanceStatus.present,
    method: method,
    operatorId: _teacher.id,
    createdAt: DateTime(2026, 8, 16),
  );

  test(
    'Class Teacher cannot mark P5 Red by manual, NFC, or QR attendance',
    () async {
      for (final method in AttendanceMethod.values) {
        bloc.add(
          MarkAttendanceRequested(
            record: redRecord(method),
            operatorUser: _teacher,
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(bloc.state, isA<AttendanceActionDenied>());
      }

      verifyNever(() => repository.markAttendance(any()));
    },
  );
}
