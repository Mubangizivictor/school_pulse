import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student_identity/domain/entities/credential_history_entry.dart';
import 'package:school_pulse/features/student_identity/domain/entities/student_identity.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/features/student_identity/presentation/bloc/student_identity_bloc.dart';
import 'package:school_pulse/features/student_identity/presentation/bloc/student_identity_event.dart';
import 'package:school_pulse/features/student_identity/presentation/bloc/student_identity_state.dart';
import 'package:school_pulse/features/student_identity/presentation/screens/identity_and_cards_screen.dart';
import 'package:school_pulse/injection_container.dart';

class _MockStudentIdentityBloc
    extends MockBloc<StudentIdentityEvent, StudentIdentityState>
    implements StudentIdentityBloc {}

class _FakeNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

class _FakeStudentIdentityRepository extends Mock
    implements StudentIdentityRepository {}

final student = Student(
  id: 'student-1',
  schoolId: 'school-1',
  name: 'Amina Nakato',
  studentCode: 'VHS-2026-00128',
  admissionNumber: 'VHS-2026-00128',
  dateOfBirth: DateTime(2018, 1, 1),
  gender: Gender.female,
  classId: 'class-p3',
  academicYearId: 'year-2026',
  status: StudentStatus.active,
  level: EducationLevel.primary,
);

const uniqueSystemId = 'SP-STUDENT-a82jd92kx';
const rawCardUid = 'CARD-SUPER-SECRET-001';
const rawQrToken = 'SPQR1.superSecretTokenValueThatMustNeverRender';

const baseIdentity = StudentIdentity(
  studentId: 'student-1',
  schoolId: 'school-1',
  uniqueSystemId: uniqueSystemId,
  schoolStudentId: 'VHS-2026-00128',
  qrCodeData: rawQrToken,
  nfcStatus: 'unassigned',
);

Widget _wrap(
  Widget Function(BuildContext) bodyBuilder, {
  required StudentIdentityBloc bloc,
  StudentIdentityRepository? repository,
}) {
  if (sl.isRegistered<NetworkInfo>()) sl.unregister<NetworkInfo>();
  sl.registerSingleton<NetworkInfo>(_FakeNetworkInfo());

  if (sl.isRegistered<StudentIdentityRepository>()) {
    sl.unregister<StudentIdentityRepository>();
  }
  final repo = repository ?? _FakeStudentIdentityRepository();
  if (repo is _FakeStudentIdentityRepository) {
    when(
      () => repo.getCredentialHistory(
        studentId: any(named: 'studentId'),
        schoolId: any(named: 'schoolId'),
      ),
    ).thenAnswer((_) async => const Right(<CredentialHistoryEntry>[]));
  }
  sl.registerSingleton<StudentIdentityRepository>(repo);

  final router = GoRouter(
    initialLocation: '/identity',
    routes: [
      GoRoute(
        path: '/identity',
        builder: (context, state) => Scaffold(
          body: BlocProvider<StudentIdentityBloc>.value(
            value: bloc,
            child: Builder(builder: bodyBuilder),
          ),
        ),
      ),
    ],
  );

  return MaterialApp.router(
    theme: AppTheme.light(),
    routerConfig: router,
  );
}

/// Scans the whole widget tree for any Text widget whose data contains
/// [needle] - the regression check for "never render raw credential
/// identifiers" required by the Identity tab redesign.
void _expectNeverRendersRaw(WidgetTester tester, String needle) {
  final textFinder = find.byType(Text);
  for (final element in textFinder.evaluate()) {
    final widget = element.widget as Text;
    final data = widget.data ?? '';
    expect(
      data.contains(needle),
      isFalse,
      reason: 'Found raw value "$needle" rendered in Text: "$data"',
    );
  }
}

/// StatusBadge uppercases its label at build time, so badge-text assertions
/// must be case-insensitive.
Finder _findTextIgnoringCase(String needle) {
  final upper = needle.toUpperCase();
  return find.byWidgetPredicate(
    (widget) => widget is Text && (widget.data ?? '').contains(upper),
  );
}

void main() {
  late _MockStudentIdentityBloc bloc;

  setUpAll(() {
    registerFallbackValue(const LoadStudentIdentityEvent('x', schoolId: 'y'));
  });

  setUp(() {
    bloc = _MockStudentIdentityBloc();
  });

  tearDown(() {
    if (sl.isRegistered<NetworkInfo>()) sl.unregister<NetworkInfo>();
    if (sl.isRegistered<StudentIdentityRepository>()) {
      sl.unregister<StudentIdentityRepository>();
    }
  });

  testWidgets('shows a loading indicator while identity is loading', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(StudentIdentityLoading());

    await tester.pumpWidget(
      _wrap(
        (_) => IdentityAndCardsBody(student: student, canMutate: true),
        bloc: bloc,
      ),
    );

    expect(find.byType(SchoolPulseLoader), findsWidgets);
  });

  testWidgets('shows an error state with retry button', (tester) async {
    when(
      () => bloc.state,
    ).thenReturn(const StudentIdentityError('Something went wrong.'));

    await tester.pumpWidget(
      _wrap(
        (_) => IdentityAndCardsBody(student: student, canMutate: true),
        bloc: bloc,
      ),
    );

    expect(find.text('Something went wrong.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets(
    'unassigned NFC state shows "Assign NFC card" only, and never renders '
    'raw uniqueSystemId, card UID, or QR token anywhere in the tree',
    (tester) async {
      when(() => bloc.state).thenReturn(
        const StudentIdentityLoaded(baseIdentity, assignedCardUid: null),
      );

      await tester.pumpWidget(
        _wrap(
          (_) => IdentityAndCardsBody(student: student, canMutate: true),
          bloc: bloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(_findTextIgnoringCase('No active card'), findsOneWidget);
      expect(find.text('Assign NFC card'), findsOneWidget);
      // The QR card's own "Replace" action is independent of NFC status and
      // is expected here since baseIdentity has an issued QR credential -
      // only the NFC card's own revoke/reactivate must be absent.
      expect(find.text('Revoke'), findsNothing);
      expect(find.text('Reactivate'), findsNothing);

      _expectNeverRendersRaw(tester, uniqueSystemId);
      _expectNeverRendersRaw(tester, rawCardUid);
      _expectNeverRendersRaw(tester, rawQrToken);
    },
  );

  testWidgets(
    'active NFC state shows Replace and Revoke, never Assign or Reactivate',
    (tester) async {
      when(() => bloc.state).thenReturn(
        StudentIdentityLoaded(
          baseIdentity.copyWith(nfcStatus: 'active'),
          assignedCardUid: rawCardUid,
        ),
      );

      await tester.pumpWidget(
        _wrap(
          (_) => IdentityAndCardsBody(student: student, canMutate: true),
          bloc: bloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(_findTextIgnoringCase('Active'), findsWidgets);
      expect(find.text('Replace'), findsWidgets);
      expect(find.text('Revoke'), findsOneWidget);
      expect(find.text('Assign NFC card'), findsNothing);
      expect(find.text('Assign replacement card'), findsNothing);
      expect(find.text('Reactivate'), findsNothing);

      _expectNeverRendersRaw(tester, rawCardUid);
    },
  );

  testWidgets('revoked NFC state shows Reactivate only', (tester) async {
    when(() => bloc.state).thenReturn(
      StudentIdentityLoaded(
        baseIdentity.copyWith(nfcStatus: 'revoked'),
        assignedCardUid: rawCardUid,
      ),
    );

    await tester.pumpWidget(
      _wrap(
        (_) => IdentityAndCardsBody(student: student, canMutate: true),
        bloc: bloc,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reactivate'), findsOneWidget);
    // The QR card's own "Replace" action is independent of NFC status and
    // is expected to still show here since baseIdentity has an issued QR
    // credential - only the NFC card's replace/revoke must be absent.
    expect(find.text('Replace'), findsOneWidget);
    expect(find.text('Revoke'), findsNothing);
  });

  testWidgets('canMutate: false hides every mutation action', (tester) async {
    when(() => bloc.state).thenReturn(
      StudentIdentityLoaded(
        baseIdentity.copyWith(nfcStatus: 'active'),
        assignedCardUid: rawCardUid,
      ),
    );

    await tester.pumpWidget(
      _wrap(
        (_) => IdentityAndCardsBody(student: student, canMutate: false),
        bloc: bloc,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Assign NFC card'), findsNothing);
    expect(find.text('Replace'), findsNothing);
    expect(find.text('Revoke'), findsNothing);
    expect(find.text('Reactivate'), findsNothing);
    expect(find.text('Issue ID'), findsNothing);
    // Read-only actions remain available.
    expect(find.text('View card history'), findsOneWidget);
  });

  testWidgets(
    'tapping "Preview or print ID" dispatches RecordIdentityPreviewedEvent',
    (tester) async {
      // Navigation to 'student-id-card' itself is not asserted here: it
      // uses a relative context.push (matching the router's sibling-route
      // convention documented on _SchoolIdCard), which a bare test harness
      // without the full app's route tree cannot resolve reliably. The
      // audit-dispatch behavior owned by this widget is what's under test.
      when(
        () => bloc.state,
      ).thenReturn(const StudentIdentityLoaded(baseIdentity));

      await tester.pumpWidget(
        _wrap(
          (_) => IdentityAndCardsBody(student: student, canMutate: true),
          bloc: bloc,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Preview or print ID'));
      await tester.pump(const Duration(milliseconds: 500));

      verify(
        () => bloc.add(
          const RecordIdentityPreviewedEvent(
            studentId: 'student-1',
            schoolId: 'school-1',
            kind: 'school_id',
          ),
        ),
      ).called(1);
    },
  );

  testWidgets('not-yet-issued School ID shows an empty state', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(
      const StudentIdentityLoaded(
        StudentIdentity(
          studentId: 'student-1',
          schoolId: 'school-1',
          uniqueSystemId: uniqueSystemId,
          schoolStudentId: 'VHS-2026-00128',
          qrCodeData: '',
        ),
      ),
    );

    await tester.pumpWidget(
      _wrap(
        (_) => IdentityAndCardsBody(student: student, canMutate: true),
        bloc: bloc,
      ),
    );
    await tester.pumpAndSettle();

    expect(_findTextIgnoringCase('Not yet issued'), findsWidgets);
    expect(find.text('Issue ID'), findsOneWidget);
    expect(find.text('Preview or print ID'), findsNothing);
  });
}
