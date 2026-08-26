import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/features/relationships/domain/entities/parent_student_relationship.dart';
import 'package:school_pulse/features/relationships/domain/repositories/relationship_repository.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/student_identity/domain/entities/student_identity.dart';
import 'package:school_pulse/features/student_identity/domain/services/primary_guardian_lookup_service.dart';
import 'package:school_pulse/features/student_identity/presentation/bloc/student_identity_bloc.dart';
import 'package:school_pulse/features/student_identity/presentation/bloc/student_identity_event.dart';
import 'package:school_pulse/features/student_identity/presentation/bloc/student_identity_state.dart';
import 'package:school_pulse/features/student_identity/presentation/screens/student_id_card_screen.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/injection_container.dart';

class _MockStudentIdentityBloc
    extends MockBloc<StudentIdentityEvent, StudentIdentityState>
    implements StudentIdentityBloc {}

class _MockStructureBloc extends MockBloc<StructureEvent, StructureState>
    implements StructureBloc {}

class _FakeNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

class _FakeRelationshipRepository extends Mock
    implements RelationshipRepository {}

class _FakeStudentRepository extends Mock implements StudentRepository {}

final student = Student(
  id: 'student-1',
  schoolId: 'school-1',
  name: 'Amina Nakato',
  studentCode: 'VHS-2026-00128',
  admissionNumber: 'VHS-ADM-2026-00128',
  dateOfBirth: DateTime(2016, 8, 14),
  gender: Gender.female,
  classId: 'class-p3',
  academicYearId: 'year-2026',
  status: StudentStatus.active,
  level: EducationLevel.primary,
);

const uniqueSystemId = 'SP-STUDENT-a82jd92kx';
const rawCardUid = 'CARD-SUPER-SECRET-001';
const rawQrToken = 'SPQR1.superSecretTokenValueThatMustNeverRenderAsText';

const baseIdentity = StudentIdentity(
  studentId: 'student-1',
  schoolId: 'school-1',
  uniqueSystemId: uniqueSystemId,
  schoolStudentId: 'VHS-2026-00128',
  qrCodeData: rawQrToken,
  nfcStatus: 'unassigned',
);

Widget _wrap({
  required StudentIdentityBloc bloc,
  RelationshipRepository? relationshipRepository,
}) {
  if (sl.isRegistered<NetworkInfo>()) sl.unregister<NetworkInfo>();
  sl.registerSingleton<NetworkInfo>(_FakeNetworkInfo());

  if (sl.isRegistered<RelationshipRepository>()) {
    sl.unregister<RelationshipRepository>();
  }
  final relationshipRepo =
      relationshipRepository ?? _FakeRelationshipRepository();
  if (relationshipRepo is _FakeRelationshipRepository) {
    when(
      () => relationshipRepo.getRelationshipsForStudent(any(), any()),
    ).thenAnswer((_) async => const Right(<ParentStudentRelationship>[]));
  }
  sl.registerSingleton<RelationshipRepository>(relationshipRepo);

  if (sl.isRegistered<StudentRepository>()) {
    sl.unregister<StudentRepository>();
  }
  sl.registerSingleton<StudentRepository>(_FakeStudentRepository());

  if (sl.isRegistered<PrimaryGuardianLookupService>()) {
    sl.unregister<PrimaryGuardianLookupService>();
  }
  sl.registerSingleton<PrimaryGuardianLookupService>(
    PrimaryGuardianLookupService(
      relationshipRepository: sl(),
      studentRepository: sl(),
    ),
  );

  final structureBloc = _MockStructureBloc();
  when(() => structureBloc.state).thenReturn(const StructureState());

  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<StudentIdentityBloc>.value(value: bloc),
        BlocProvider<StructureBloc>.value(value: structureBloc),
      ],
      child: StudentIdCardScreen(student: student),
    ),
  );
}

/// Scans the whole widget tree for any Text widget whose data contains
/// [needle] - the regression check for "never render raw credential
/// identifiers" required by the card redesign.
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
    if (sl.isRegistered<RelationshipRepository>()) {
      sl.unregister<RelationshipRepository>();
    }
    if (sl.isRegistered<StudentRepository>()) {
      sl.unregister<StudentRepository>();
    }
    if (sl.isRegistered<PrimaryGuardianLookupService>()) {
      sl.unregister<PrimaryGuardianLookupService>();
    }
  });

  testWidgets('shows a loading indicator while identity is loading', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(StudentIdentityLoading());

    await tester.pumpWidget(_wrap(bloc: bloc));

    expect(find.byWidgetPredicate((w) => w.runtimeType.toString() == 'SchoolPulseLoader'), findsOneWidget);
  });

  testWidgets('shows an error state with retry button', (tester) async {
    when(
      () => bloc.state,
    ).thenReturn(const StudentIdentityError('Something went wrong.'));

    await tester.pumpWidget(_wrap(bloc: bloc));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Something went wrong.'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('a permission-denied error shows a locked message with no retry', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(
      const StudentIdentityError('permission-denied: staff only.'),
    );

    await tester.pumpWidget(_wrap(bloc: bloc));
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.text('You do not have permission to view this card.'),
      findsOneWidget,
    );
    expect(find.text('Try Again'), findsNothing);
  });

  testWidgets('no-card state shows an Issue ID call to action', (
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

    await tester.pumpWidget(_wrap(bloc: bloc));
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.text('No identity has been issued for this learner yet.'),
      findsOneWidget,
    );
    expect(find.text('Issue ID'), findsOneWidget);
  });

  testWidgets(
    'front card renders the real front-face fields and never a raw '
    'uniqueSystemId, card UID or QR token as text anywhere',
    (tester) async {
      when(() => bloc.state).thenReturn(
        const StudentIdentityLoaded(baseIdentity, assignedCardUid: null),
      );

      await tester.pumpWidget(_wrap(bloc: bloc));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Amina Nakato'), findsOneWidget);
      expect(find.text(student.studentCode), findsOneWidget);
      expect(find.text(student.admissionNumber), findsOneWidget);
      expect(find.text('NFC not set up'), findsOneWidget);

      _expectNeverRendersRaw(tester, uniqueSystemId);
      _expectNeverRendersRaw(tester, rawCardUid);
      _expectNeverRendersRaw(tester, rawQrToken);
    },
  );

  testWidgets(
    'switching to Back shows the QR image (never the raw token as text) '
    'and the student number',
    (tester) async {
      when(() => bloc.state).thenReturn(
        const StudentIdentityLoaded(baseIdentity, assignedCardUid: null),
      );

      await tester.pumpWidget(_wrap(bloc: bloc));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Back'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text('Scan to verify learner'), findsOneWidget);
      expect(find.text(student.studentCode), findsOneWidget);

      _expectNeverRendersRaw(tester, rawQrToken);
    },
  );

  testWidgets('active NFC status shows "NFC enabled" on the front card', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(
      StudentIdentityLoaded(
        baseIdentity.copyWith(nfcStatus: 'active'),
        assignedCardUid: rawCardUid,
      ),
    );

    await tester.pumpWidget(_wrap(bloc: bloc));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('NFC enabled'), findsOneWidget);
    _expectNeverRendersRaw(tester, rawCardUid);
  });

  testWidgets('card status panel reflects revoked state', (tester) async {
    when(() => bloc.state).thenReturn(
      StudentIdentityLoaded(
        baseIdentity.copyWith(nfcStatus: 'revoked'),
        assignedCardUid: rawCardUid,
      ),
    );

    await tester.pumpWidget(_wrap(bloc: bloc));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Card revoked'), findsOneWidget);
    expect(find.text('REVOKED'), findsOneWidget);
  });

  testWidgets('card status panel shows active by default', (tester) async {
    when(() => bloc.state).thenReturn(
      const StudentIdentityLoaded(baseIdentity, assignedCardUid: null),
    );

    await tester.pumpWidget(_wrap(bloc: bloc));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Card active'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
  });

  testWidgets(
    'tapping Replace with no NFC card assigned offers only the QR replace '
    'confirmation dialog',
    (tester) async {
      when(() => bloc.state).thenReturn(
        const StudentIdentityLoaded(baseIdentity, assignedCardUid: null),
      );

      await tester.pumpWidget(_wrap(bloc: bloc));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.ensureVisible(find.text('Replace'));
      await tester.tap(find.text('Replace'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Replace QR credential?'), findsOneWidget);

      await tester.tap(find.text('Replace').last);
      await tester.pump(const Duration(milliseconds: 300));

      verify(
        () => bloc.add(const RegenerateQrCredentialEvent(baseIdentity)),
      ).called(1);
    },
  );

  testWidgets(
    'tapping Revoke with no NFC card assigned shows the QR-revoke '
    'confirmation and dispatches a regenerate on confirm',
    (tester) async {
      when(() => bloc.state).thenReturn(
        const StudentIdentityLoaded(baseIdentity, assignedCardUid: null),
      );

      await tester.pumpWidget(_wrap(bloc: bloc));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.ensureVisible(find.text('Revoke'));
      await tester.tap(find.text('Revoke'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Revoke QR credential?'), findsOneWidget);

      await tester.tap(find.text('Revoke').last);
      await tester.pump(const Duration(milliseconds: 300));

      verify(
        () => bloc.add(const RegenerateQrCredentialEvent(baseIdentity)),
      ).called(1);
    },
  );

  testWidgets(
    'tapping Replace with an NFC card assigned offers a QR-vs-NFC choice',
    (tester) async {
      when(() => bloc.state).thenReturn(
        StudentIdentityLoaded(
          baseIdentity.copyWith(nfcStatus: 'active'),
          assignedCardUid: rawCardUid,
        ),
      );

      await tester.pumpWidget(_wrap(bloc: bloc));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.ensureVisible(find.text('Replace'));
      await tester.tap(find.text('Replace'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Replace QR credential'), findsOneWidget);
      expect(find.text('Replace NFC card'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping Revoke with an NFC card assigned goes straight to the reason '
    'sheet (no QR-vs-NFC ambiguity - the card itself is revoked)',
    (tester) async {
      when(() => bloc.state).thenReturn(
        StudentIdentityLoaded(
          baseIdentity.copyWith(nfcStatus: 'active'),
          assignedCardUid: rawCardUid,
        ),
      );

      await tester.pumpWidget(_wrap(bloc: bloc));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.ensureVisible(find.text('Revoke'));
      await tester.tap(find.text('Revoke'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Reason'), findsOneWidget);
      expect(find.text('Lost'), findsOneWidget);
    },
  );
}
