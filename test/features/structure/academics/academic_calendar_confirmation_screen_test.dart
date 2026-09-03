import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/billing/data/datasources/subscription_cycle_remote_data_source.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/structure/presentation/screens/billing/academic_calendar_confirmation_screen.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _MockStructureBloc extends MockBloc<StructureEvent, StructureState>
    implements StructureBloc {}

class _FakeStructureEvent extends Fake implements StructureEvent {}

const _user = UserEntity(
  id: 'u1',
  name: 'Admin',
  email: 'admin@school.test',
  schoolId: 'school-1',
  roles: [UserRole.schoolAdmin],
);

Widget _wrap(
  _MockStructureBloc structureBloc, {
  FakeFirebaseFirestore? firestore,
}) {
  final authBloc = _MockAuthBloc();
  when(() => authBloc.state).thenReturn(const AuthAuthenticated(_user));
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<StructureBloc>.value(value: structureBloc),
      ],
      child: AcademicCalendarConfirmationScreen(
        cycleDataSource: SubscriptionCycleRemoteDataSource(
          firestore: firestore ?? FakeFirebaseFirestore(),
        ),
      ),
    ),
  );
}

AcademicYear _year({bool isCurrent = true}) => AcademicYear(
  id: 'year-1',
  schoolId: 'school-1',
  name: '2026 Academic Year',
  startDate: DateTime(2026, 1, 1),
  endDate: DateTime(2026, 12, 15),
  isCurrent: isCurrent,
);

AcademicTerm _term({
  required String id,
  required int order,
  required DateTime start,
  required DateTime end,
  bool isConfirmed = false,
}) => AcademicTerm(
  id: id,
  schoolId: 'school-1',
  academicYearId: 'year-1',
  name: 'Term $order',
  order: order,
  startDate: start,
  endDate: end,
  isConfirmed: isConfirmed,
);

void main() {
  late _MockStructureBloc structureBloc;

  setUpAll(() => registerFallbackValue(_FakeStructureEvent()));

  setUp(() {
    structureBloc = _MockStructureBloc();
  });

  testWidgets(
    'no calendar yet: offers to generate a draft template rather than confirming automatically',
    (tester) async {
      when(() => structureBloc.state).thenReturn(const StructureState());

      await tester.pumpWidget(_wrap(structureBloc));
      await tester.pumpAndSettle();

      expect(find.text('No academic year set up yet'), findsOneWidget);
      expect(find.text('Generate draft calendar'), findsOneWidget);
      // Nothing is silently confirmed - no confirm button is shown yet.
      expect(find.text('Confirm academic calendar'), findsNothing);

      await tester.tap(find.text('Generate draft calendar'));
      await tester.pump();

      // Generating the draft dispatches a year + 3 term saves via the
      // existing plain-write path (SaveAcademicYearRequested /
      // SaveAcademicTermRequested) - never anything that marks confirmed.
      verify(
        () => structureBloc.add(any(that: isA<SaveAcademicYearRequested>())),
      ).called(1);
      verify(
        () => structureBloc.add(any(that: isA<SaveAcademicTermRequested>())),
      ).called(3);
    },
  );

  testWidgets(
    'valid non-overlapping terms: shows a draft badge and an enabled confirm button',
    (tester) async {
      final state = StructureState(
        academicYears: [_year()],
        academicTerms: [
          _term(
            id: 't1',
            order: 1,
            start: DateTime(2026, 1, 10),
            end: DateTime(2026, 4, 10),
          ),
          _term(
            id: 't2',
            order: 2,
            start: DateTime(2026, 5, 1),
            end: DateTime(2026, 8, 10),
          ),
          _term(
            id: 't3',
            order: 3,
            start: DateTime(2026, 9, 1),
            end: DateTime(2026, 12, 10),
          ),
        ],
      );
      when(() => structureBloc.state).thenReturn(state);

      await tester.pumpWidget(_wrap(structureBloc));
      await tester.pumpAndSettle();

      expect(find.text('Draft - review before confirming'), findsOneWidget);
      expect(find.text('Fix before confirming'), findsNothing);

      final confirmButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirm academic calendar'),
      );
      expect(confirmButton.onPressed, isNotNull);

      await tester.tap(
        find.widgetWithText(FilledButton, 'Confirm academic calendar'),
      );
      await tester.pump();

      verify(
        () => structureBloc.add(
          any(that: isA<ConfirmAcademicCalendarRequested>()),
        ),
      ).called(1);
    },
  );

  testWidgets(
    'overlapping terms: validation error is shown and confirm is disabled',
    (tester) async {
      final state = StructureState(
        academicYears: [_year()],
        academicTerms: [
          _term(
            id: 't1',
            order: 1,
            start: DateTime(2026, 1, 10),
            end: DateTime(2026, 4, 10),
          ),
          // Overlaps t1.
          _term(
            id: 't2',
            order: 2,
            start: DateTime(2026, 3, 1),
            end: DateTime(2026, 8, 10),
          ),
        ],
      );
      when(() => structureBloc.state).thenReturn(state);

      await tester.pumpWidget(_wrap(structureBloc));
      await tester.pumpAndSettle();

      expect(find.text('Fix before confirming'), findsOneWidget);
      expect(find.textContaining('overlaps'), findsWidgets);

      final confirmButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirm academic calendar'),
      );
      expect(confirmButton.onPressed, isNull);
    },
  );

  testWidgets(
    'end-before-start term: validation error is shown and confirm is disabled',
    (tester) async {
      final state = StructureState(
        academicYears: [_year()],
        academicTerms: [
          _term(
            id: 't1',
            order: 1,
            start: DateTime(2026, 4, 10),
            end: DateTime(2026, 1, 10),
          ),
        ],
      );
      when(() => structureBloc.state).thenReturn(state);

      await tester.pumpWidget(_wrap(structureBloc));
      await tester.pumpAndSettle();

      final confirmButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirm academic calendar'),
      );
      expect(confirmButton.onPressed, isNull);
    },
  );

  testWidgets('confirm button shows a spinner while confirming', (
    tester,
  ) async {
    final state = StructureState(
      academicYears: [_year()],
      academicTerms: [
        _term(
          id: 't1',
          order: 1,
          start: DateTime(2026, 1, 10),
          end: DateTime(2026, 4, 10),
        ),
      ],
      isConfirmingCalendar: true,
    );
    when(() => structureBloc.state).thenReturn(state);

    await tester.pumpWidget(_wrap(structureBloc));
    // Not pumpAndSettle - CircularProgressIndicator animates indefinitely.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final confirmButton = tester.widget<FilledButton>(
      find.byWidgetPredicate(
        (w) => w is FilledButton && w.child is SizedBox,
      ),
    );
    expect(confirmButton.onPressed, isNull);
  });

  testWidgets(
    'confirmed term with a subscription_cycles doc shows the Upcoming renewal section',
    (tester) async {
      final state = StructureState(
        academicYears: [_year()],
        academicTerms: [
          _term(
            id: 't1',
            order: 1,
            start: DateTime(2026, 1, 10),
            end: DateTime(2026, 4, 10),
            isConfirmed: true,
          ),
        ],
      );
      when(() => structureBloc.state).thenReturn(state);

      final firestore = FakeFirebaseFirestore();
      await firestore.collection('subscription_cycles').doc('school-1_t1').set({
        'schoolId': 'school-1',
        'subscriptionId': 'school-1',
        'academicYearId': 'year-1',
        'termId': 't1',
        'termNumber': 1,
        'termStart': Timestamp.fromDate(DateTime(2026, 1, 10)),
        'termEnd': Timestamp.fromDate(DateTime(2026, 4, 10)),
        'paymentDueAt': Timestamp.fromDate(DateTime(2026, 1, 5)),
        'graceEndsAt': Timestamp.fromDate(DateTime(2026, 1, 15)),
        'planSnapshot': {
          'planId': 'plan-basic',
          'planName': 'Basic',
          'features': <String>[],
          'price': 500000,
          'currency': 'UGX',
        },
        'paymentStatus': 'unpaid',
        'cycleStatus': 'upcoming',
      });

      await tester.pumpWidget(_wrap(structureBloc, firestore: firestore));
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Upcoming renewal'), findsOneWidget);
      expect(find.text('Term 1'), findsWidgets);
      // StatusBadge upper-cases its label.
      expect(find.text('UPCOMING'), findsOneWidget);
      // Financial detail (price/discount) must never show on this screen.
      expect(find.textContaining('500'), findsNothing);
      expect(find.textContaining('UGX'), findsNothing);
    },
  );

  testWidgets(
    'no subscription_cycles docs yet: Upcoming renewal section is absent',
    (tester) async {
      final state = StructureState(
        academicYears: [_year()],
        academicTerms: [
          _term(
            id: 't1',
            order: 1,
            start: DateTime(2026, 1, 10),
            end: DateTime(2026, 4, 10),
            isConfirmed: true,
          ),
        ],
      );
      when(() => structureBloc.state).thenReturn(state);

      await tester.pumpWidget(_wrap(structureBloc));
      await tester.pumpAndSettle();

      expect(find.text('Upcoming renewal'), findsNothing);
    },
  );
}
