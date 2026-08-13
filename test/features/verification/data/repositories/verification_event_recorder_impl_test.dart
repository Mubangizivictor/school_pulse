import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/gate.dart';
import 'package:school_pulse/features/verification/data/datasources/verification_local_data_source.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_cache_records.dart';
import 'package:school_pulse/features/verification/data/repositories/verification_event_recorder_impl.dart';
import 'package:school_pulse/features/verification/domain/entities/resolved_identity.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_decision.dart';

class MockVerificationLocalDataSource extends Mock
    implements VerificationLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class ThrowingFirebaseFirestore extends Fake implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    throw Exception('simulated Firestore write failure');
  }
}

void main() {
  late MockVerificationLocalDataSource localDataSource;
  late MockNetworkInfo networkInfo;

  const gate = Gate(
    id: 'gate-1',
    name: 'Main Gate',
    type: 'Main Entrance',
    location: 'Front',
    assignedOfficerIds: [],
    operatingHours: {},
    allowedUserRoles: [],
    requiredVerificationMethods: [],
    schoolId: 'school-1',
  );

  const operatorUser = UserEntity(
    id: 'op-1',
    name: 'Gate Officer',
    email: 'officer@example.com',
    schoolId: 'school-1',
    roles: [UserRole.gatekeeper],
  );

  final context = VerificationContext(
    gate: gate,
    operatorUser: operatorUser,
    purpose: 'security.identity.verify',
    deviceId: 'device-1',
    requestedAt: DateTime(2026, 1, 1),
  );

  final credential = QrScanCredential(
    rawPayload: 'SP-0001',
    scannedAt: DateTime.now(),
  );

  const student = StudentResolvedIdentity(
    id: 'student-1',
    name: 'Jane Student',
    studentCode: 'SP-0001',
    classId: 'class-1',
  );

  const decision = VerificationDecision(
    outcome: VerificationOutcome.allowed,
    identity: student,
    message: 'Identity verified.',
    suggestedDirection: 'In',
  );

  setUpAll(() {
    registerFallbackValue(
      VerificationEvent(
        eventId: '',
        schoolId: '',
        gateId: '',
        operatorId: '',
        credentialKind: 'qr',
        identityId: '',
        identityType: 'student',
        outcome: 'allowed',
        direction: 'In',
        timestamp: DateTime(2026),
        deviceId: '',
        isSynced: false,
      ),
    );
  });

  setUp(() {
    localDataSource = MockVerificationLocalDataSource();
    networkInfo = MockNetworkInfo();
    when(
      () => localDataSource.saveVerificationEvent(any()),
    ).thenAnswer((_) async {});
  });

  test(
    'while online, pushes to Firestore immediately and marks the event synced',
    () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final firestore = FakeFirebaseFirestore();
      final recorder = VerificationEventRecorderImpl(
        localDataSource: localDataSource,
        firestore: firestore,
        networkInfo: networkInfo,
      );

      final result = await recorder.record(
        decision: decision,
        context: context,
        credential: credential,
        direction: 'In',
      );

      expect(result.isRight(), isTrue);
      final saved = verify(
        () => localDataSource.saveVerificationEvent(captureAny()),
      ).captured;
      // Called twice: once with isSynced=false before the push, once with
      // isSynced=true after it succeeds.
      expect(saved.length, 2);
      expect((saved.last as VerificationEvent).isSynced, isTrue);

      final docs = await firestore
          .collection('schools')
          .doc('school-1')
          .collection('verification_events')
          .get();
      expect(docs.docs, hasLength(1));
      expect(docs.docs.first.data()['outcome'], 'allowed');
      expect(docs.docs.first.data()['direction'], 'In');
    },
  );

  test(
    'while offline, saves locally as unsynced and never attempts a push',
    () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      final firestore = FakeFirebaseFirestore();
      final recorder = VerificationEventRecorderImpl(
        localDataSource: localDataSource,
        firestore: firestore,
        networkInfo: networkInfo,
      );

      final result = await recorder.record(
        decision: decision,
        context: context,
        credential: credential,
        direction: 'In',
      );

      expect(result.isRight(), isTrue);
      final saved = verify(
        () => localDataSource.saveVerificationEvent(captureAny()),
      ).captured;
      expect(saved, hasLength(1));
      expect((saved.single as VerificationEvent).isSynced, isFalse);

      final docs = await firestore
          .collection('schools')
          .doc('school-1')
          .collection('verification_events')
          .get();
      expect(docs.docs, isEmpty);
    },
  );

  test(
    'when online but the Firestore push itself throws, the event stays unsynced and record() still succeeds',
    () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final recorder = VerificationEventRecorderImpl(
        localDataSource: localDataSource,
        firestore: ThrowingFirebaseFirestore(),
        networkInfo: networkInfo,
      );

      final result = await recorder.record(
        decision: decision,
        context: context,
        credential: credential,
        direction: 'In',
      );

      // The whole operation must not fail just because the remote push
      // failed - the local record already succeeded, and a failed sync must
      // stay retryable, never silently marked as synced.
      expect(result.isRight(), isTrue);
      final saved = verify(
        () => localDataSource.saveVerificationEvent(captureAny()),
      ).captured;
      expect(saved, hasLength(1));
      expect((saved.single as VerificationEvent).isSynced, isFalse);
    },
  );

  test(
    'syncPendingEvents pushes every unsynced event and marks each as synced',
    () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      final firestore = FakeFirebaseFirestore();
      final recorder = VerificationEventRecorderImpl(
        localDataSource: localDataSource,
        firestore: firestore,
        networkInfo: networkInfo,
      );

      final pendingEvent = VerificationEvent(
        eventId: 'evt-1',
        schoolId: 'school-1',
        gateId: 'gate-1',
        operatorId: 'op-1',
        credentialKind: 'qr',
        identityId: 'student-1',
        identityType: 'student',
        outcome: 'allowed',
        direction: 'In',
        timestamp: DateTime.now(),
        deviceId: 'device-1',
        isSynced: false,
      );

      when(
        () => localDataSource.getUnsyncedEvents(),
      ).thenAnswer((_) async => [pendingEvent]);
      when(
        () => localDataSource.markEventSynced('evt-1'),
      ).thenAnswer((_) async {});

      final result = await recorder.syncPendingEvents();

      expect(result.isRight(), isTrue);
      verify(() => localDataSource.markEventSynced('evt-1')).called(1);
      final docs = await firestore
          .collection('schools')
          .doc('school-1')
          .collection('verification_events')
          .get();
      expect(docs.docs, hasLength(1));
    },
  );

  test(
    'syncPendingEvents fails fast when offline, without touching the queue',
    () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      final recorder = VerificationEventRecorderImpl(
        localDataSource: localDataSource,
        firestore: FakeFirebaseFirestore(),
        networkInfo: networkInfo,
      );

      final result = await recorder.syncPendingEvents();

      expect(result.isLeft(), isTrue);
      verifyNever(() => localDataSource.getUnsyncedEvents());
    },
  );
}
