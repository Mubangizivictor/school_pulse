import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_resource.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_resources/class_resource_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';
import 'package:school_pulse/features/teacher/presentation/screens/resources/resources_home_screen.dart';

class _MockClassResourceBloc
    extends MockBloc<ClassResourceEvent, ClassResourceState>
    implements ClassResourceBloc {}

class _MockClassTeacherContextBloc
    extends MockBloc<ClassTeacherContextEvent, ClassTeacherContextState>
    implements ClassTeacherContextBloc {}

class _FakeClassResourceEvent extends Fake implements ClassResourceEvent {}

class _FakeClassContextEvent extends Fake implements ClassTeacherContextEvent {}

void main() {
  late _MockClassResourceBloc resourceBloc;
  late _MockClassTeacherContextBloc contextBloc;

  final assignment = StaffRoleAssignment(
    id: 'a1',
    schoolId: 'school1',
    staffId: 'staff1',
    userId: 'user1',
    roleType: StaffResponsibilityType.classTeacher,
    academicYearId: '2026',
    classId: 'p5',
    className: 'Primary 5',
    startDate: DateTime(2026, 1, 1),
    assignedAt: DateTime(2026, 1, 1),
  );

  final activeContext = ActiveResponsibilityContext.fromAssignment(
    assignment,
    termId: 't2',
    termName: 'Term 2',
    academicYearName: '2025/2026',
  );

  setUpAll(() {
    registerFallbackValue(_FakeClassResourceEvent());
    registerFallbackValue(_FakeClassContextEvent());
  });

  setUp(() {
    resourceBloc = _MockClassResourceBloc();
    contextBloc = _MockClassTeacherContextBloc();
    when(
      () => contextBloc.state,
    ).thenReturn(ClassTeacherContextState(active: activeContext));
  });

  Widget buildSubject() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ClassResourceBloc>.value(value: resourceBloc),
          BlocProvider<ClassTeacherContextBloc>.value(value: contextBloc),
        ],
        child: const ResourcesHomeScreen(),
      ),
    );
  }

  testWidgets('shows header, stats and empty state with no resources', (
    tester,
  ) async {
    whenListen(
      resourceBloc,
      Stream<ClassResourceState>.empty(),
      initialState: const ClassResourceState(),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Resources'), findsOneWidget);
    expect(find.text('Primary 5'), findsOneWidget);
    expect(find.text('2025/2026'), findsOneWidget);
    expect(find.text('Total Resources'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
    expect(find.text('No resources yet'), findsOneWidget);
    expect(find.text('Upload Your First Resource'), findsOneWidget);
  });

  testWidgets('shows recent resources and stat counts when files exist', (
    tester,
  ) async {
    final resources = [
      ClassResource(
        id: 'r1',
        schoolId: 'school1',
        classId: 'p5',
        academicYearId: '2026',
        name: 'Notes.pdf',
        kind: ClassResourceKind.document,
        sizeBytes: 2048,
        uploadedAt: DateTime(2026, 1, 5),
      ),
    ];

    whenListen(
      resourceBloc,
      Stream<ClassResourceState>.empty(),
      initialState: ClassResourceState(resources: resources),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Notes.pdf'), findsOneWidget);
    expect(find.text('No resources yet'), findsNothing);
    expect(find.text('1'), findsWidgets);
  });
}
