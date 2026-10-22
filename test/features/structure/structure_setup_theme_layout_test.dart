import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/structure/presentation/screens/structure_screen.dart';

class _MockStructureBloc extends MockBloc<StructureEvent, StructureState>
    implements StructureBloc {}

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

const _user = UserEntity(
  id: 'u1',
  name: 'Admin',
  email: 'admin@school.test',
  schoolId: 'school-1',
  roles: [],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // StructureScreen is a sequential, index-driven wizard (Institution ->
  // Academic Year -> ... -> Review) - it renders exactly one step at a
  // time starting from step 0, with Back/Continue advancing the index.
  // This asserts that render + navigating through every step never
  // overflows or throws in either theme.
  Future<void> pumpSetup(
    WidgetTester tester, {
    required ThemeData theme,
  }) async {
    final bloc = _MockStructureBloc();
    final authBloc = _MockAuthBloc();
    when(() => bloc.state).thenReturn(const StructureState());
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(_user));

    final router = GoRouter(
      initialLocation: '/structure',
      routes: [
        GoRoute(
          path: '/structure',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<StructureBloc>.value(value: bloc),
              BlocProvider<AuthBloc>.value(value: authBloc),
            ],
            child: const StructureScreen(),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(theme: theme, routerConfig: router),
    );
    await tester.pumpAndSettle();
  }

  for (final entry in <({String name, ThemeData theme, Size viewport})>[
    (
      name: 'light mobile',
      theme: _theme(Brightness.light),
      viewport: const Size(430, 932),
    ),
    (
      name: 'dark desktop',
      theme: _theme(Brightness.dark),
      viewport: const Size(1440, 960),
    ),
  ]) {
    testWidgets(
      'Structure Setup renders every step without overflow in ${entry.name} mode',
      (tester) async {
        tester.view.physicalSize = entry.viewport;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await pumpSetup(tester, theme: entry.theme);
        expect(tester.takeException(), isNull, reason: 'initial step');
        // Step 0 embeds InstitutionSettingsScreen with showAppBar: false
        // (see _InstitutionProfileStep in structure_screen.dart) - the
        // wizard supplies its own step chrome instead of that screen's
        // AdminAppBar, so "Institution Settings" (the standalone editor's
        // app-bar title) never renders here. The compact mobile header
        // folds the step title into its "N of 16 · Institution profile"
        // progress row; the wide/web layout renders it as its own heading.
        expect(
          find.textContaining('Institution profile'),
          findsAtLeastNWidgets(1),
        );
        // Regression guard: the footer must occupy only its natural height.
        // If it expands to the entire Scaffold bottom-navigation slot, this
        // scroll view is laid out at height zero and the wizard looks blank.
        expect(
          tester.getSize(find.byType(ListView).first).height,
          greaterThan(0),
        );

        // Step through every wizard step backed purely by StructureBloc
        // state (Institution through Subjects) via Save & Continue,
        // verifying no overflow/exception is thrown at any step along the
        // way. Later steps (Curriculum onward) construct their own
        // Firestore-backed repositories directly in initState and are
        // covered by their own dedicated widget/integration tests instead,
        // since a plain widget test has no Firebase app to attach to.
        const stepsBackedByStructureBloc = 6;
        for (var guard = 0; guard < stepsBackedByStructureBloc; guard++) {
          expect(
            find.text('Save & Continue'),
            findsOneWidget,
            reason: 'step index $guard',
          );
          await tester.tap(find.text('Save & Continue'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'step index $guard');
        }
      },
    );
  }
}

ThemeData _theme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: dark ? AppColors.electricBlue : AppColors.royalBlue,
    brightness: brightness,
    surface: dark ? AppColors.surfaceDark : AppColors.surfaceLight,
    onSurface: dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    onSurfaceVariant: dark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight,
    outline: dark ? AppColors.borderDark : AppColors.borderLight,
    outlineVariant: dark ? AppColors.borderDark : AppColors.borderLight,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? AppColors.bgDark : AppColors.bgLight,
  );
}
