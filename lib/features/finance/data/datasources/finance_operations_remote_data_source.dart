import 'package:cloud_functions/cloud_functions.dart';

/// Callable-only writes for Suppliers + Petty Cash (audit area 3).
///
/// Backed by `functions/finance_operations.js`. Every method is
/// tenant/role gated, idempotent (pass a stable [clientRequestId] per user
/// action), and — for money moves — keeps the bank/float balance
/// authoritative server-side and writes a `finance_audit_events` entry in
/// the same transaction.
class FinanceOperationsRemoteDataSource {
  final FirebaseFunctions functions;
  FinanceOperationsRemoteDataSource({required this.functions});

  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> data,
  ) async {
    final res = await functions
        .httpsCallable(name)
        .call<Map<String, dynamic>>(data);
    return Map<String, dynamic>.from(res.data as Map);
  }

  // ---- Suppliers -----------------------------------------------------

  Future<String> saveSupplier({
    required String schoolId,
    String? supplierId,
    required String name,
    String? category,
    String? phone,
    String? email,
    String? notes,
    bool unarchive = false,
    String? clientRequestId,
  }) async {
    final r = await _call('saveSupplier', {
      'schoolId': schoolId,
      'supplierId': ?supplierId,
      'name': name,
      'category': ?category,
      'phone': ?phone,
      'email': ?email,
      'notes': ?notes,
      if (unarchive) 'unarchive': true,
      'clientRequestId': ?clientRequestId,
    });
    return (r['supplierId'] ?? '').toString();
  }

  Future<void> archiveSupplier({
    required String schoolId,
    required String supplierId,
    bool archived = true,
  }) => _call('archiveSupplier', {
    'schoolId': schoolId,
    'supplierId': supplierId,
    'archived': archived,
  });

  // ---- Supplier invoices -------------------------------------------

  Future<String> recordSupplierInvoice({
    required String schoolId,
    String? invoiceId,
    required String supplierId,
    required String invoiceNumber,
    String? reference,
    String? category,
    required int amountUgx,
    DateTime? issuedAt,
    DateTime? dueAt,
    List<String> attachmentPaths = const [],
    String? clientRequestId,
  }) async {
    final r = await _call('recordSupplierInvoice', {
      'schoolId': schoolId,
      'invoiceId': ?invoiceId,
      'supplierId': supplierId,
      'invoiceNumber': invoiceNumber,
      'reference': ?reference,
      'category': ?category,
      'amountUgx': amountUgx,
      'issuedAt': ?issuedAt?.toIso8601String(),
      'dueAt': ?dueAt?.toIso8601String(),
      'attachmentPaths': attachmentPaths,
      'clientRequestId': ?clientRequestId,
    });
    return (r['invoiceId'] ?? '').toString();
  }

  /// [decision] is `approve` | `reject` | `return`.
  Future<String> decideSupplierInvoice({
    required String schoolId,
    required String invoiceId,
    required String decision,
    String? comment,
  }) async {
    final r = await _call('decideSupplierInvoice', {
      'schoolId': schoolId,
      'invoiceId': invoiceId,
      'decision': decision,
      'comment': ?comment,
    });
    return (r['status'] ?? '').toString();
  }

  Future<String> paySupplierInvoice({
    required String schoolId,
    required String invoiceId,
    required String accountId,
    required String paymentReference,
    String? paymentMethod,
    String? proofPath,
  }) async {
    final r = await _call('paySupplierInvoice', {
      'schoolId': schoolId,
      'invoiceId': invoiceId,
      'accountId': accountId,
      'paymentReference': paymentReference,
      'paymentMethod': ?paymentMethod,
      'proofPath': ?proofPath,
    });
    return (r['status'] ?? '').toString();
  }

  // ---- Petty cash --------------------------------------------------

  Future<int> recordPettyCashDisbursement({
    required String schoolId,
    String floatId = 'main',
    required String payee,
    required String category,
    required String purpose,
    required int amountUgx,
    DateTime? spentAt,
    String? requestedBy,
    String? approvedBy,
    String? receiptPath,
    String? clientRequestId,
  }) async {
    final r = await _call('recordPettyCashDisbursement', {
      'schoolId': schoolId,
      'floatId': floatId,
      'payee': payee,
      'category': category,
      'purpose': purpose,
      'amountUgx': amountUgx,
      'spentAt': ?spentAt?.toIso8601String(),
      'requestedBy': ?requestedBy,
      'approvedBy': ?approvedBy,
      'receiptPath': ?receiptPath,
      'clientRequestId': ?clientRequestId,
    });
    return (r['balanceUgx'] as num?)?.toInt() ?? 0;
  }

  Future<int> replenishPettyCash({
    required String schoolId,
    String floatId = 'main',
    required String accountId,
    required int amountUgx,
    required String reference,
    String? location,
    String? clientRequestId,
  }) async {
    final r = await _call('replenishPettyCash', {
      'schoolId': schoolId,
      'floatId': floatId,
      'accountId': accountId,
      'amountUgx': amountUgx,
      'reference': reference,
      'location': ?location,
      'clientRequestId': ?clientRequestId,
    });
    return (r['floatBalanceUgx'] as num?)?.toInt() ?? 0;
  }

  // ---- Cash & Bank reconciliation (audit area 4) ------------------

  /// Mark [entryId] reconciled — against a [statementReference] or paired
  /// with [counterEntryId] (opposite sign, equal magnitude).
  Future<void> matchBankLedgerEntry({
    required String schoolId,
    required String entryId,
    String? counterEntryId,
    String? statementReference,
    DateTime? statementDate,
    String? note,
  }) => _call('matchBankLedgerEntry', {
    'schoolId': schoolId,
    'entryId': entryId,
    'counterEntryId': ?counterEntryId,
    'statementReference': ?statementReference,
    'statementDate': ?statementDate?.toIso8601String(),
    'note': ?note,
  });

  Future<void> unmatchBankLedgerEntry({
    required String schoolId,
    required String entryId,
    required String reason,
  }) => _call('unmatchBankLedgerEntry', {
    'schoolId': schoolId,
    'entryId': entryId,
    'reason': reason,
  });

  /// Post a manual adjustment / journal entry ([amountUgx] signed).
  Future<int> recordBankLedgerAdjustment({
    required String schoolId,
    required String accountId,
    required int amountUgx,
    required String description,
    required String reference,
    String? clientRequestId,
  }) async {
    final r = await _call('recordBankLedgerAdjustment', {
      'schoolId': schoolId,
      'accountId': accountId,
      'amountUgx': amountUgx,
      'description': description,
      'reference': reference,
      'clientRequestId': ?clientRequestId,
    });
    return (r['balanceUgx'] as num?)?.toInt() ?? 0;
  }

  /// Finalise an approved payroll run's payment (existing
  /// `payroll_compliance.js` callable) with a bank/cash [reference].
  Future<void> finalisePayrollPayment({
    required String schoolId,
    required String runId,
    required String reference,
  }) => _call('finalisePayrollPayment', {
    'schoolId': schoolId,
    'runId': runId,
    'reference': reference,
  });
}
