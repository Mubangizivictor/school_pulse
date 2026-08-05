import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/entities/custom_field_entities.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/structure/presentation/screens/custom_fields_screen.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _MockStructureBloc extends MockBloc<StructureEvent, StructureState>
    implements StructureBloc {}

const _user = UserEntity(
  id: 'u1',
  name: 'Admin',
  email: 'admin@school.test',
  schoolId: 'school-1',
  roles: [UserRole.schoolAdmin],
);

Widget _wrap(Widget child, {required StructureState structureState}) {
  final authBloc = _MockAuthBloc();
  final structureBloc = _MockStructureBloc();
  when(() => authBloc.state).thenReturn(const AuthAuthenticated(_user));
  when(() => structureBloc.state).thenReturn(structureState);
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<StructureBloc>.value(value: structureBloc),
      ],
      child: child,
    ),
  );
}

void main() {
  testWidgets('renders empty-state hint when no custom fields exist', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const CustomFieldsScreen(), structureState: const StructureState()),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('No custom fields defined yet'), findsOneWidget);
    expect(find.text('Add Field'), findsOneWidget);
  });

  testWidgets('renders a row for each custom field', (tester) async {
    final state = StructureState(
      customFields: [
        const CustomFieldDef(
          id: 'f1',
          schoolId: 'school-1',
          appliesTo: 'Student',
          fieldName: 'Blood Group',
        ),
      ],
    );
    await tester.pumpWidget(
      _wrap(const CustomFieldsScreen(), structureState: state),
    );
    await tester.pumpAndSettle();

    expect(find.text('Blood Group'), findsOneWidget);
  });

  testWidgets('tapping the FAB opens the add-field form sheet', (tester) async {
    await tester.pumpWidget(
      _wrap(const CustomFieldsScreen(), structureState: const StructureState()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Field'));
    await tester.pumpAndSettle();

    expect(find.text('Add Custom Field'), findsOneWidget);
  });
}
