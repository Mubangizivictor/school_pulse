import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/parent/data/parent_report_card_remote_data_source.dart';
import 'package:school_pulse/features/parent_offline/data/datasources/parent_cache_data_source.dart';
import 'package:school_pulse/features/parent_offline/data/datasources/parent_local_pin_store.dart';
import 'package:school_pulse/features/parent_offline/domain/parent_offline_cache_service.dart';
import 'package:school_pulse/core/network/network_info.dart';

class MockFunctions extends Mock implements FirebaseFunctions {}

class MockNetwork extends Mock implements NetworkInfo {}

class MockPinStore extends Mock implements ParentLocalPinStore {}

/// Minimal in-memory cache for the offline-behaviour tests.
class _MemoryCache implements ParentCacheDataSource {
  final Map<String, String> _store = {};
  String _k(String t, String p, String l, String c) => '$t|$p|$l|$c';

  @override
  Future<void> put({
    required String tenantId,
    required String parentId,
    String learnerId = '',
    required String cacheKey,
    required String payloadJson,
  }) async {
    _store[_k(tenantId, parentId, learnerId, cacheKey)] = payloadJson;
  }

  @override
  Future<ParentCacheReadResult?> get({
    required String tenantId,
    required String parentId,
    String learnerId = '',
    required String cacheKey,
  }) async {
    final v = _store[_k(tenantId, parentId, learnerId, cacheKey)];
    return v == null
        ? null
        : ParentCacheReadResult(payloadJson: v, updatedAt: DateTime.now());
  }

  @override
  Future<void> clearLearner({
    required String tenantId,
    required String parentId,
    required String learnerId,
  }) async {
    _store.removeWhere(
      (k, _) => k.startsWith('$tenantId|$parentId|$learnerId|'),
    );
  }

  @override
  Future<void> clearParent({
    required String tenantId,
    required String parentId,
  }) async {
    _store.removeWhere((k, _) => k.startsWith('$tenantId|$parentId|'));
  }
}

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFunctions functions;
  late MockNetwork network;
  late ParentOfflineCacheService cache;
  late ParentReportCardRemoteDataSource ds;

  const school = 'schoolA';
  const student = 'studentA';
  const parent = 'parentA';

  Future<void> seedReport(String id, {required String access}) => firestore
      .collection('schools')
      .doc(school)
      .collection('reportCards')
      .doc(id)
      .set({
        'schoolId': school,
        'studentId': student,
        'studentName': 'Student A',
        'academicYearId': '2026',
        'termId': 't2',
        'classId': 'p7',
        'isFinalized': true,
        'financialAccessStatus': access,
        'version': 1,
      });

  setUp(() {
    firestore = FakeFirebaseFirestore();
    functions = MockFunctions();
    network = MockNetwork();
    cache = ParentOfflineCacheService(
      cache: _MemoryCache(),
      pinStore: MockPinStore(),
      networkInfo: network,
    );
    ds = ParentReportCardRemoteDataSource(
      firestore: firestore,
      functions: functions,
      offlineCache: cache,
    );
  });

  test(
    'online fetch returns only released reports and caches exactly those',
    () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      await seedReport('rcReleased', access: 'released');
      await seedReport('rcHeld', access: 'held');

      final online = await ds.getReleasedReportCards(
        schoolId: school,
        studentId: student,
        parentId: parent,
      );
      expect(online.map((c) => c.reportCardId), ['rcReleased']);

      // Now go offline - the cache must serve exactly the released one, never
      // the held report.
      when(() => network.isConnected).thenAnswer((_) async => false);
      final offline = await ds.getReleasedReportCards(
        schoolId: school,
        studentId: student,
        parentId: parent,
      );
      expect(offline.map((c) => c.reportCardId), ['rcReleased']);
    },
  );

  test(
    'a report revoked server-side drops out of the cache on next sync',
    () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      await seedReport('rc1', access: 'released');
      await ds.getReleasedReportCards(
        schoolId: school,
        studentId: student,
        parentId: parent,
      );

      // Server revokes access.
      await firestore
          .collection('schools')
          .doc(school)
          .collection('reportCards')
          .doc('rc1')
          .update({'financialAccessStatus': 'revoked'});

      // Next online fetch returns nothing and overwrites the cache.
      final afterSync = await ds.getReleasedReportCards(
        schoolId: school,
        studentId: student,
        parentId: parent,
      );
      expect(afterSync, isEmpty);

      when(() => network.isConnected).thenAnswer((_) async => false);
      final offline = await ds.getReleasedReportCards(
        schoolId: school,
        studentId: student,
        parentId: parent,
      );
      expect(
        offline,
        isEmpty,
        reason: 'stale cache must not resurrect a revoked report',
      );
    },
  );

  test(
    'offline with no prior cache shows nothing (never a stale/held report)',
    () async {
      when(() => network.isConnected).thenAnswer((_) async => false);
      await seedReport('rcHeld', access: 'held');
      final offline = await ds.getReleasedReportCards(
        schoolId: school,
        studentId: student,
        parentId: parent,
      );
      expect(offline, isEmpty);
    },
  );

  test('getRestrictionMessage reads the configured policy message', () async {
    await firestore.doc('schools/$school/configs/reportReleasePolicy').set({
      'financialClearance': {
        'mode': 'fullBalance',
        'restrictionMessage': 'Kindly clear fees with the bursar.',
      },
    });
    final msg = await ds.getRestrictionMessage(school);
    expect(msg, 'Kindly clear fees with the bursar.');
  });

  test('getRestrictionMessage falls back to the default when unset', () async {
    final msg = await ds.getRestrictionMessage(school);
    expect(msg, contains('awaiting financial clearance'));
  });
}
