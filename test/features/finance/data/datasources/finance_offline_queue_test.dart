import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/features/finance/data/datasources/finance_offline_queue.dart';
import 'package:school_pulse/features/finance/data/datasources/finance_operations_remote_data_source.dart';

class _MockNetwork extends Mock implements NetworkInfo {}

class _MockOps extends Mock implements FinanceOperationsRemoteDataSource {}

/// Audit area 6 — the finance offline queue: only petty-cash disbursements
/// are queued, they persist, replay in order on reconnect with the same
/// idempotency key, a successful send is removed, a failure stops the run
/// and is marked failed, and nothing syncs while offline.
void main() {
  late _MockNetwork network;
  late _MockOps ops;
  late FinanceOfflineQueue queue;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    network = _MockNetwork();
    ops = _MockOps();
    queue = FinanceOfflineQueue(prefs: prefs, network: network, ops: ops);
  });

  test(
    'enqueue persists and pendingFor returns it, scoped by school',
    () async {
      await queue.enqueueDisbursement(
        schoolId: 's1',
        payee: 'Boda',
        category: 'Transport',
        purpose: 'Bank run',
        amountUgx: 20000,
      );
      await queue.enqueueDisbursement(
        schoolId: 's2',
        payee: 'Other',
        category: 'x',
        purpose: 'y',
        amountUgx: 1000,
      );
      expect(queue.pendingFor('s1').length, 1);
      expect(queue.pendingFor('s2').length, 1);
      expect(queue.pendingFor('s1').single.payee, 'Boda');
    },
  );

  test('does not sync while offline', () async {
    when(() => network.isConnected).thenAnswer((_) async => false);
    await queue.enqueueDisbursement(
      schoolId: 's1',
      payee: 'P',
      category: 'C',
      purpose: 'X',
      amountUgx: 5000,
    );
    final n = await queue.sync('s1');
    expect(n, 0);
    expect(queue.pendingFor('s1').length, 1);
    verifyNever(
      () => ops.recordPettyCashDisbursement(
        schoolId: any(named: 'schoolId'),
        payee: any(named: 'payee'),
        category: any(named: 'category'),
        purpose: any(named: 'purpose'),
        amountUgx: any(named: 'amountUgx'),
      ),
    );
  });

  test(
    'sync sends each item with its idempotency key, clears on success',
    () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(
        () => ops.recordPettyCashDisbursement(
          schoolId: any(named: 'schoolId'),
          floatId: any(named: 'floatId'),
          payee: any(named: 'payee'),
          category: any(named: 'category'),
          purpose: any(named: 'purpose'),
          amountUgx: any(named: 'amountUgx'),
          requestedBy: any(named: 'requestedBy'),
          approvedBy: any(named: 'approvedBy'),
          clientRequestId: any(named: 'clientRequestId'),
        ),
      ).thenAnswer((_) async => 0);

      final id1 = await queue.enqueueDisbursement(
        schoolId: 's1',
        payee: 'A',
        category: 'C',
        purpose: 'X',
        amountUgx: 1000,
      );
      await queue.enqueueDisbursement(
        schoolId: 's1',
        payee: 'B',
        category: 'C',
        purpose: 'X',
        amountUgx: 2000,
      );

      final n = await queue.sync('s1');
      expect(n, 2);
      expect(queue.pendingFor('s1'), isEmpty);

      final sent = verify(
        () => ops.recordPettyCashDisbursement(
          schoolId: 's1',
          floatId: any(named: 'floatId'),
          payee: any(named: 'payee'),
          category: any(named: 'category'),
          purpose: any(named: 'purpose'),
          amountUgx: any(named: 'amountUgx'),
          requestedBy: any(named: 'requestedBy'),
          approvedBy: any(named: 'approvedBy'),
          clientRequestId: captureAny(named: 'clientRequestId'),
        ),
      ).captured;
      expect(sent.first, id1); // first enqueued sent first
    },
  );

  test(
    'a failure stops the run and marks the item failed; earlier ones stay cleared',
    () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      var call = 0;
      when(
        () => ops.recordPettyCashDisbursement(
          schoolId: any(named: 'schoolId'),
          floatId: any(named: 'floatId'),
          payee: any(named: 'payee'),
          category: any(named: 'category'),
          purpose: any(named: 'purpose'),
          amountUgx: any(named: 'amountUgx'),
          requestedBy: any(named: 'requestedBy'),
          approvedBy: any(named: 'approvedBy'),
          clientRequestId: any(named: 'clientRequestId'),
        ),
      ).thenAnswer((_) async {
        call++;
        if (call == 2) throw Exception('network blip');
        return 0;
      });

      await queue.enqueueDisbursement(
        schoolId: 's1',
        payee: 'A',
        category: 'C',
        purpose: 'X',
        amountUgx: 1000,
      );
      await queue.enqueueDisbursement(
        schoolId: 's1',
        payee: 'B',
        category: 'C',
        purpose: 'X',
        amountUgx: 2000,
      );
      await queue.enqueueDisbursement(
        schoolId: 's1',
        payee: 'D',
        category: 'C',
        purpose: 'X',
        amountUgx: 3000,
      );

      final n = await queue.sync('s1');
      expect(n, 1); // only the first succeeded
      final left = queue.pendingFor('s1');
      expect(left.length, 2); // second + third remain
      expect(left.first.status, FinanceQueueStatus.failed);
      expect(left.first.payee, 'B');
    },
  );

  test('discard removes a specific item', () async {
    final id = await queue.enqueueDisbursement(
      schoolId: 's1',
      payee: 'A',
      category: 'C',
      purpose: 'X',
      amountUgx: 1,
    );
    await queue.discard(id);
    expect(queue.pendingFor('s1'), isEmpty);
  });
}
