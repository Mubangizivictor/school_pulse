import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/finance/data/datasources/finance_operations_remote_data_source.dart';

class _MockFunctions extends Mock implements FirebaseFunctions {}

class _MockCallable extends Mock implements HttpsCallable {}

class _MockResult extends Mock
    implements HttpsCallableResult<Map<String, dynamic>> {}

/// Audit area 3 — the Suppliers + Petty Cash data source calls the right
/// callable with a correctly-shaped payload (money as whole ints, decision
/// verbs verbatim, no `spentAmount`/balance fields leaking from the client).
void main() {
  late _MockFunctions functions;
  late _MockCallable callable;
  late _MockResult result;
  late FinanceOperationsRemoteDataSource ds;

  setUp(() {
    functions = _MockFunctions();
    callable = _MockCallable();
    result = _MockResult();
    when(() => functions.httpsCallable(any())).thenReturn(callable);
    when(
      () => callable.call<Map<String, dynamic>>(any()),
    ).thenAnswer((_) async => result);
    when(() => result.data).thenReturn(<String, dynamic>{
      'supplierId': 'sup_1',
      'invoiceId': 'inv_1',
      'status': 'approved',
      'balanceUgx': 480000,
      'floatBalanceUgx': 600000,
    });
    ds = FinanceOperationsRemoteDataSource(functions: functions);
  });

  Map<String, dynamic> lastPayload() {
    final captured = verify(
      () => callable.call<Map<String, dynamic>>(captureAny()),
    ).captured;
    return Map<String, dynamic>.from(captured.last as Map);
  }

  test(
    'saveSupplier: calls saveSupplier, name required, no balance field',
    () async {
      await ds.saveSupplier(schoolId: 's1', name: 'Acme', category: 'Supplies');
      verify(() => functions.httpsCallable('saveSupplier')).called(1);
      final p = lastPayload();
      expect(p['schoolId'], 's1');
      expect(p['name'], 'Acme');
      expect(p.containsKey('payableBalanceUgx'), isFalse);
    },
  );

  test(
    'recordSupplierInvoice: amount is an int, dates are ISO strings',
    () async {
      await ds.recordSupplierInvoice(
        schoolId: 's1',
        supplierId: 'sup_1',
        invoiceNumber: 'INV-9',
        amountUgx: 750000,
        issuedAt: DateTime(2026, 3, 4),
      );
      verify(() => functions.httpsCallable('recordSupplierInvoice')).called(1);
      final p = lastPayload();
      expect(p['amountUgx'], 750000);
      expect(p['amountUgx'], isA<int>());
      expect(p['issuedAt'], startsWith('2026-03-04'));
    },
  );

  test('decideSupplierInvoice: passes the verb verbatim + comment', () async {
    await ds.decideSupplierInvoice(
      schoolId: 's1',
      invoiceId: 'inv_1',
      decision: 'reject',
      comment: 'over budget',
    );
    final p = lastPayload();
    expect(p['decision'], 'reject');
    expect(p['comment'], 'over budget');
  });

  test(
    'paySupplierInvoice: requires account + reference, returns status',
    () async {
      final status = await ds.paySupplierInvoice(
        schoolId: 's1',
        invoiceId: 'inv_1',
        accountId: 'acc_1',
        paymentReference: 'TXN-1',
      );
      expect(status, 'approved'); // from stubbed result.data['status']
      final p = lastPayload();
      expect(p['accountId'], 'acc_1');
      expect(p['paymentReference'], 'TXN-1');
    },
  );

  test(
    'recordPettyCashDisbursement: whole-int amount, returns new balance',
    () async {
      final bal = await ds.recordPettyCashDisbursement(
        schoolId: 's1',
        payee: 'Boda',
        category: 'Transport',
        purpose: 'Bank run',
        amountUgx: 20000,
      );
      expect(bal, 480000);
      verify(
        () => functions.httpsCallable('recordPettyCashDisbursement'),
      ).called(1);
      final p = lastPayload();
      expect(p['amountUgx'], 20000);
      expect(p['floatId'], 'main');
    },
  );

  test(
    'replenishPettyCash: sends account + reference + amount, returns float',
    () async {
      final bal = await ds.replenishPettyCash(
        schoolId: 's1',
        accountId: 'acc_1',
        amountUgx: 600000,
        reference: 'PC-1',
      );
      expect(bal, 600000);
      final p = lastPayload();
      expect(p['accountId'], 'acc_1');
      expect(p['reference'], 'PC-1');
      expect(p['amountUgx'], 600000);
    },
  );

  test('archiveSupplier: passes archived flag', () async {
    await ds.archiveSupplier(schoolId: 's1', supplierId: 'sup_1');
    final p = lastPayload();
    expect(p['archived'], true);
  });

  // ---- Area 4: reconciliation + payroll finalisation ----------------

  test('matchBankLedgerEntry: statement-reference form', () async {
    await ds.matchBankLedgerEntry(
      schoolId: 's1',
      entryId: 'e1',
      statementReference: 'STMT-9',
    );
    verify(() => functions.httpsCallable('matchBankLedgerEntry')).called(1);
    final p = lastPayload();
    expect(p['entryId'], 'e1');
    expect(p['statementReference'], 'STMT-9');
    expect(p.containsKey('counterEntryId'), isFalse);
  });

  test('matchBankLedgerEntry: pair form', () async {
    await ds.matchBankLedgerEntry(
      schoolId: 's1',
      entryId: 'e1',
      counterEntryId: 'e2',
    );
    final p = lastPayload();
    expect(p['counterEntryId'], 'e2');
    expect(p.containsKey('statementReference'), isFalse);
  });

  test('unmatchBankLedgerEntry: reason is passed through', () async {
    await ds.unmatchBankLedgerEntry(
      schoolId: 's1',
      entryId: 'e1',
      reason: 'wrong match',
    );
    final p = lastPayload();
    expect(p['reason'], 'wrong match');
  });

  test('recordBankLedgerAdjustment: signed int amount + reference', () async {
    final bal = await ds.recordBankLedgerAdjustment(
      schoolId: 's1',
      accountId: 'acc1',
      amountUgx: -15000,
      description: 'Bank charge',
      reference: 'CHG-1',
    );
    expect(bal, 480000); // stubbed result.data['balanceUgx']
    final p = lastPayload();
    expect(p['amountUgx'], -15000);
    expect(p['reference'], 'CHG-1');
  });

  test(
    'finalisePayrollPayment: calls the payroll_compliance callable',
    () async {
      await ds.finalisePayrollPayment(
        schoolId: 's1',
        runId: 'run1',
        reference: 'PAYRUN-1',
      );
      verify(() => functions.httpsCallable('finalisePayrollPayment')).called(1);
      final p = lastPayload();
      expect(p['runId'], 'run1');
      expect(p['reference'], 'PAYRUN-1');
    },
  );
}
