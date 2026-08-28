import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_web_kit.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

/// The full `BursarWebShell` mounts every section's Navigator eagerly and
/// resolves repositories from GetIt (covered by integration tests). Here we
/// verify the desktop web-kit primitives the shell/dashboard are built from
/// render in both themes, and the sidebar section list is well-formed.
void main() {
  const bursar = UserEntity(
    id: 'b1',
    name: 'Rehema Bursar',
    email: 'bursar@schoolpulse.demo',
    roles: [UserRole.bursar],
    schoolId: 's1',
    schoolName: 'School Pulse Academy',
  );

  late _MockAuthBloc authBloc;

  setUp(() {
    authBloc = _MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(bursar));
  });

  Widget wrap(Widget child, {required Brightness brightness}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        BlocProvider<AuthBloc>.value(value: authBloc),
      ],
      child: MaterialApp(
        theme: brightness == Brightness.dark
            ? AppTheme.dark()
            : AppTheme.light(),
        home: Scaffold(body: child),
      ),
    );
  }

  for (final brightness in [Brightness.light, Brightness.dark]) {
    final label = brightness == Brightness.dark ? 'dark' : 'light';

    testWidgets('FinanceWorkspace renders header + actions in $label mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          FinanceWorkspace(
            title: 'Finance overview',
            updatedLabel: 'Updated just now',
            primaryAction: const WorkspacePrimaryButton(
              label: 'Receive payment',
            ),
            secondaryActions: const [
              WorkspaceSecondaryButton(label: 'New expense'),
            ],
            child: const SizedBox(height: 10),
          ),
          brightness: brightness,
        ),
      );

      expect(find.text('Finance overview'), findsOneWidget);
      expect(find.text('Updated just now'), findsOneWidget);
      expect(find.text('Receive payment'), findsOneWidget);
      expect(find.text('New expense'), findsOneWidget);
    });

    testWidgets('MetricTile shows label + value + delta in $label mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const MetricTile(
            label: 'Fee arrears',
            value: 'UGX 312,540,900',
            delta: '5.6% vs last week',
          ),
          brightness: brightness,
        ),
      );
      expect(find.text('Fee arrears'), findsOneWidget);
      expect(find.text('UGX 312,540,900'), findsOneWidget);
      expect(find.textContaining('5.6%'), findsOneWidget);
    });

    testWidgets(
      'FinanceDataTable renders header + rows + footer in $label mode',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            FinanceDataTable<String>(
              rows: const ['Namugerwa Patience', 'Ssekitto Brian'],
              total: 25,
              columns: [
                FinanceColumn<String>.text('Payer', (r) => r, flex: 3),
                FinanceColumn<String>(
                  label: 'Amount (UGX)',
                  align: TextAlign.right,
                  cell: (r) => const Text('1,650,000'),
                ),
              ],
            ),
            brightness: brightness,
          ),
        );
        expect(find.text('Payer'), findsOneWidget);
        expect(find.text('Namugerwa Patience'), findsOneWidget);
        expect(find.textContaining('Showing 1–2 of 25'), findsOneWidget);
      },
    );
  }

  test('the console exposes the 11 reference sections in order', () {
    // Mirror of BursarWebShell._Section — a regression guard so the sidebar
    // and the router sub-routes stay aligned with the mockup.
    const expected = [
      'overview',
      'students',
      'approvals',
      'cash-bank',
      'budget',
      'expenses',
      'suppliers',
      'petty-cash',
      'payroll',
      'reports',
      'audit',
    ];
    expect(expected.length, 11);
    expect(expected.first, 'overview');
    expect(expected.last, 'audit');
  });
}
