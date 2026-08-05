import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/admin/presentation/pages/user_management_page.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/student/domain/usecases/manage_parent_access_codes.dart';
import 'package:school_pulse/injection_container.dart' as di;

class MockStudentRepository extends Mock implements StudentRepository {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockStudentRepository mockRepo;
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockRepo = MockStudentRepository();
    di.sl.registerLazySingleton<GetAllStudents>(() => GetAllStudents(mockRepo));
    di.sl.registerLazySingleton<GetAllAccessCodes>(
      () => GetAllAccessCodes(mockRepo),
    );
    di.sl.registerLazySingleton<CreateAccessCode>(
      () => CreateAccessCode(mockRepo),
    );

    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(
      const AuthAuthenticated(
        UserEntity(
          id: 'staff1',
          name: 'Admin User',
          email: 'admin@school.test',
          schoolId: 'school1',
          roles: [UserRole.schoolAdmin],
        ),
      ),
    );

    when(
      () => mockRepo.getAllStudents(schoolId: any(named: 'schoolId')),
    ).thenAnswer(
      (_) async => Right([
        Student(
          id: 's1',
          schoolId: 'school1',
          name: 'Jane Doe',
          studentCode: 'STU001',
          admissionNumber: 'STU001',
          dateOfBirth: DateTime(2015, 1, 1),
          gender: Gender.female,
          classId: 'P.1',
          academicYearId: 'ay1',
          status: StudentStatus.active,
          level: EducationLevel.primary,
        ),
      ]),
    );
    when(
      () => mockRepo.getAllAccessCodes(schoolId: any(named: 'schoolId')),
    ).thenAnswer((_) async => const Right([]));
  });

  tearDown(() {
    di.sl.reset();
  });

  testWidgets(
    'Generate Parent Access Code dialog: no overflow on a small screen, and the loading spinner actually resolves',
    (tester) async {
      // The reported bug ("overflow in the preview") only shows up when the
      // dialog's fixed content doesn't fit the viewport - force a small
      // screen so a real regression would actually surface here.
      tester.view.physicalSize = const Size(360, 690);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(
        () => mockRepo.createAccessCode(
          studentIds: any(named: 'studentIds'),
          phoneNumber: any(named: 'phoneNumber'),
          parentName: any(named: 'parentName'),
          schoolId: any(named: 'schoolId'),
        ),
      ).thenAnswer((_) async => const Right('KHA1234'));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const Scaffold(body: ParentCodesListView()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Initial tab render should not throw/overflow',
      );

      // Open the "Generate Access Code" dialog.
      await tester.tap(find.byIcon(Icons.vpn_key));
      await tester.pumpAndSettle();
      expect(find.text('Generate Access Code'), findsOneWidget);
      expect(
        tester.takeException(),
        isNull,
        reason:
            'Opening the dialog should not throw a RenderFlex overflow/unbounded-height error',
      );

      // Fill in the required fields: phone number and at least one student.
      final phoneField = find.widgetWithText(TextField, 'Phone Number');
      expect(phoneField, findsOneWidget);
      await tester.enterText(phoneField, '0772123456');
      await tester.pump();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Typing into the phone field should not throw',
      );

      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.pump();

      final generateButton = find.widgetWithText(FilledButton, 'Generate Code');
      expect(generateButton, findsOneWidget);
      final button = tester.widget<FilledButton>(generateButton);
      expect(
        button.onPressed,
        isNotNull,
        reason:
            'Generate Code should be enabled once phone + a student are provided',
      );

      // Submit and make sure it resolves to a success confirmation instead
      // of hanging or throwing.
      await tester.tap(generateButton);
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Submitting should not throw/overflow',
      );
      expect(find.textContaining('Access code generated'), findsOneWidget);
    },
  );
}
