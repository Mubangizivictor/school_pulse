import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/design_system/theme/app_theme.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/entities/institution_profile.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/structure/presentation/widgets/institution_tab.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockStructureBloc extends MockBloc<StructureEvent, StructureState>
    implements StructureBloc {}

void main() {
  late MockAuthBloc authBloc;
  late MockStructureBloc structureBloc;

  const user = UserEntity(
    id: 'u1',
    name: 'Test Admin',
    email: 'admin@example.com',
    schoolId: 'school-123',
    roles: [UserRole.schoolAdmin],
  );

  const profile = InstitutionProfile(
    name: 'Riverside Academy',
    shortName: 'RVA',
    schoolType: 'Secondary',
    schoolCategory: 'Private',
    country: 'Uganda',
    district: 'Wakiso',
  );

  setUpAll(() {
    registerFallbackValue(
      const UpdateInstitutionProfileRequested(profile, 'school-123'),
    );
  });

  setUp(() {
    authBloc = MockAuthBloc();
    structureBloc = MockStructureBloc();
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(user));
    when(() => structureBloc.state).thenReturn(
      const StructureState(isLoading: false, institutionProfile: profile),
    );
  });

  Widget buildSubject({GlobalKey<InstitutionTabState>? tabKey}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<StructureBloc>.value(value: structureBloc),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(body: InstitutionTab(key: tabKey)),
      ),
    );
  }

  testWidgets(
    'renders every section with the school\'s real saved data, not sample copy',
    (tester) async {
      tester.view.physicalSize = const Size(430, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildSubject());

      expect(find.text('School Identity'), findsOneWidget);
      expect(find.text('Branding'), findsOneWidget);
      expect(find.text('Institution Classification'), findsOneWidget);
      expect(find.text('Registration'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Contact'), findsOneWidget);
      // Regional Settings (time zone/currency/language/date format) is no
      // longer editable per-school: Uganda schools share one fixed locale,
      // so the section and its own Save button were removed - saving now
      // happens only via the wizard's shared Save & Continue.
      expect(find.text('Regional Settings'), findsNothing);
      expect(
        find.widgetWithText(FilledButton, 'Save Institution'),
        findsNothing,
      );

      expect(find.text('Riverside Academy'), findsOneWidget);
      expect(find.text('RVA'), findsOneWidget);
      expect(find.text('St. Mary\'s Academy'), findsNothing);
      expect(find.text('SMA/REG/2024/0012'), findsNothing);
    },
  );

  testWidgets(
    'dispatches UpdateInstitutionProfileRequested for the authenticated school on save',
    (tester) async {
      tester.view.physicalSize = const Size(430, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final tabKey = GlobalKey<InstitutionTabState>();
      await tester.pumpWidget(buildSubject(tabKey: tabKey));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Institution Name'),
        'New Name',
      );
      await tester.pump();

      // Save is no longer triggered by a button inside the form - the
      // wizard's shared Save & Continue calls this exposed API instead.
      final saved = await tabKey.currentState!.saveIfDirty();
      await tester.pumpAndSettle();

      expect(saved, isTrue);
      final captured = verify(
        () => structureBloc.add(
          captureAny(that: isA<UpdateInstitutionProfileRequested>()),
        ),
      ).captured;
      expect(captured, hasLength(1));
      final event = captured.first as UpdateInstitutionProfileRequested;
      expect(event.schoolId, 'school-123');
      expect(event.profile.name, 'New Name');
    },
  );
}
