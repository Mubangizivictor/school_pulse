import 'package:cloud_firestore/cloud_firestore.dart';

/// Read-only access to the Bursar Phase 2/3 collections (Cash & Bank,
/// Petty Cash, Suppliers, Payment Vouchers, Payroll). Every write to these
/// paths is server-side only per firestore.rules; the app only ever reads.
///
/// The shapes here mirror what the demo seed script (`functions/scripts/
/// seed_bursar_demo.js`) writes, so the screens render a complete picture
/// while the real write flows are still being built.
class BursarOpsReadRepository {
  final FirebaseFirestore _db;

  BursarOpsReadRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(
    String schoolId,
    String name,
  ) => _db.collection('schools').doc(schoolId).collection(name);

  // ---- Cash & Bank ---------------------------------------------------------

  Stream<List<BankAccount>> watchBankAccounts(String schoolId) =>
      _col(schoolId, 'bank_accounts')
          .orderBy('sortOrder')
          .snapshots()
          .map((s) => s.docs.map(BankAccount.fromDoc).toList());

  Stream<List<LedgerEntry>> watchBankLedger(
    String schoolId, {
    int limit = 40,
  }) => _col(schoolId, 'bank_ledger')
      .orderBy('date', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map(LedgerEntry.fromDoc).toList());

  // ---- Petty Cash --------------------------------------------------------

  Stream<PettyCashFloat?> watchPettyCashFloat(String schoolId) =>
      _col(schoolId, 'petty_cash')
          .doc('main')
          .snapshots()
          .map((d) => d.exists ? PettyCashFloat.fromDoc(d) : null);

  Stream<List<LedgerEntry>> watchPettyCashLedger(
    String schoolId, {
    int limit = 40,
  }) => _col(schoolId, 'petty_cash_ledger')
      .orderBy('date', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map(LedgerEntry.fromDoc).toList());

  // ---- Suppliers -------------------------------------------------------

  Stream<List<Supplier>> watchSuppliers(String schoolId) =>
      _col(schoolId, 'finance_suppliers')
          .orderBy('name')
          .snapshots()
          .map((s) => s.docs.map(Supplier.fromDoc).toList());

  Stream<List<SupplierInvoice>> watchSupplierInvoices(
    String schoolId, {
    String? supplierId,
  }) {
    Query<Map<String, dynamic>> q = _col(schoolId, 'supplier_invoices');
    if (supplierId != null) q = q.where('supplierId', isEqualTo: supplierId);
    return q
        .orderBy('issuedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(SupplierInvoice.fromDoc).toList());
  }

  // ---- Payment Vouchers -----------------------------------------------

  Stream<List<PaymentVoucher>> watchPaymentVouchers(String schoolId) =>
      _col(schoolId, 'payment_vouchers')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map(PaymentVoucher.fromDoc).toList());

  Future<PaymentVoucher?> getPaymentVoucher(
    String schoolId,
    String voucherId,
  ) async {
    final d = await _col(schoolId, 'payment_vouchers').doc(voucherId).get();
    return d.exists ? PaymentVoucher.fromDoc(d) : null;
  }

  // ---- Payroll --------------------------------------------------------

  Stream<PayrollRun?> watchLatestPayrollRun(String schoolId) =>
      _col(schoolId, 'payroll_runs')
          .orderBy('periodOrder', descending: true)
          .limit(1)
          .snapshots()
          .map((s) => s.docs.isEmpty ? null : PayrollRun.fromDoc(s.docs.first));

  // ---- Audit trail --------------------------------------------------

  Stream<List<AuditEvent>> watchAuditEvents(
    String schoolId, {
    int limit = 50,
  }) => _col(schoolId, 'finance_audit_events')
      .orderBy('at', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map(AuditEvent.fromDoc).toList());
}

int _int(Object? v) => (v as num?)?.toInt() ?? 0;
DateTime? _date(Object? v) => v is Timestamp
    ? v.toDate()
    : v is DateTime
    ? v
    : null;

class BankAccount {
  final String id;
  final String name;
  final String kind; // cash | bank | mobile_money
  final int balanceUgx;
  final int reconciledPercent;
  final int unmatchedCount;

  BankAccount({
    required this.id,
    required this.name,
    required this.kind,
    required this.balanceUgx,
    required this.reconciledPercent,
    required this.unmatchedCount,
  });

  factory BankAccount.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final j = d.data() ?? const {};
    return BankAccount(
      id: d.id,
      name: j['name'] as String? ?? '',
      kind: j['kind'] as String? ?? 'bank',
      balanceUgx: _int(j['balanceUgx']),
      reconciledPercent: _int(j['reconciledPercent']),
      unmatchedCount: _int(j['unmatchedCount']),
    );
  }
}

class LedgerEntry {
  final String id;
  final DateTime? date;
  final String description;
  final String type; // Receipt | Payment | Deposit
  final int amountUgx; // signed
  final int? balanceUgx;

  LedgerEntry({
    required this.id,
    required this.date,
    required this.description,
    required this.type,
    required this.amountUgx,
    this.balanceUgx,
  });

  factory LedgerEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final j = d.data() ?? const {};
    return LedgerEntry(
      id: d.id,
      date: _date(j['date']),
      description: j['description'] as String? ?? '',
      type: j['type'] as String? ?? '',
      amountUgx: _int(j['amountUgx']),
      balanceUgx: j['balanceUgx'] == null ? null : _int(j['balanceUgx']),
    );
  }
}

class PettyCashFloat {
  final String location;
  final int currentFloatUgx;
  final int totalInUgx;
  final int totalOutUgx;

  PettyCashFloat({
    required this.location,
    required this.currentFloatUgx,
    required this.totalInUgx,
    required this.totalOutUgx,
  });

  factory PettyCashFloat.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final j = d.data() ?? const {};
    return PettyCashFloat(
      location: j['location'] as String? ?? 'Main Office',
      currentFloatUgx: _int(j['currentFloatUgx']),
      totalInUgx: _int(j['totalInUgx']),
      totalOutUgx: _int(j['totalOutUgx']),
    );
  }
}

class Supplier {
  final String id;
  final String name;
  final String category;
  final int payableBalanceUgx;
  final String? phone;

  Supplier({
    required this.id,
    required this.name,
    required this.category,
    required this.payableBalanceUgx,
    this.phone,
  });

  factory Supplier.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final j = d.data() ?? const {};
    return Supplier(
      id: d.id,
      name: j['name'] as String? ?? '',
      category: j['category'] as String? ?? '',
      payableBalanceUgx: _int(j['payableBalanceUgx']),
      phone: j['phone'] as String?,
    );
  }
}

class SupplierInvoice {
  final String id;
  final String supplierId;
  final String supplierName;
  final String reference;
  final DateTime? issuedAt;
  final int amountUgx;
  final String status; // paid | outstanding | overdue

  SupplierInvoice({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.reference,
    required this.issuedAt,
    required this.amountUgx,
    required this.status,
  });

  factory SupplierInvoice.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final j = d.data() ?? const {};
    return SupplierInvoice(
      id: d.id,
      supplierId: j['supplierId'] as String? ?? '',
      supplierName: j['supplierName'] as String? ?? '',
      reference: j['reference'] as String? ?? '',
      issuedAt: _date(j['issuedAt']),
      amountUgx: _int(j['amountUgx']),
      status: j['status'] as String? ?? 'outstanding',
    );
  }
}

class VoucherLine {
  final String description;
  final int amountUgx;
  VoucherLine({required this.description, required this.amountUgx});
  factory VoucherLine.fromMap(Map<String, dynamic> j) => VoucherLine(
    description: j['description'] as String? ?? '',
    amountUgx: _int(j['amountUgx']),
  );
}

class PaymentVoucher {
  final String id;
  final String number;
  final String supplierName;
  final int amountUgx;
  final String budgetVote;
  final String fundingAccount;
  final String? attachmentName;
  final List<String> approvalRoute;
  final String narration;
  final String status; // draft | submitted | approved | paid | rejected
  final DateTime? createdAt;
  final List<VoucherLine> lines;

  PaymentVoucher({
    required this.id,
    required this.number,
    required this.supplierName,
    required this.amountUgx,
    required this.budgetVote,
    required this.fundingAccount,
    required this.attachmentName,
    required this.approvalRoute,
    required this.narration,
    required this.status,
    required this.createdAt,
    required this.lines,
  });

  factory PaymentVoucher.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final j = d.data() ?? const {};
    return PaymentVoucher(
      id: d.id,
      number: j['number'] as String? ?? d.id,
      supplierName: j['supplierName'] as String? ?? '',
      amountUgx: _int(j['amountUgx']),
      budgetVote: j['budgetVote'] as String? ?? '',
      fundingAccount: j['fundingAccount'] as String? ?? '',
      attachmentName: j['attachmentName'] as String?,
      approvalRoute: ((j['approvalRoute'] as List?) ?? const [])
          .map((e) => '$e')
          .toList(),
      narration: j['narration'] as String? ?? '',
      status: j['status'] as String? ?? 'draft',
      createdAt: _date(j['createdAt']),
      lines: ((j['lines'] as List?) ?? const [])
          .map((e) => VoucherLine.fromMap((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

class PayrollLine {
  final String label;
  final int amountUgx;
  PayrollLine({required this.label, required this.amountUgx});
  factory PayrollLine.fromMap(Map<String, dynamic> j) => PayrollLine(
    label: j['label'] as String? ?? '',
    amountUgx: _int(j['amountUgx']),
  );
}

class PayrollRun {
  final String id;
  final String periodLabel;
  final int grossPayUgx;
  final int payeUgx;
  final int nssfEmployerUgx;
  final int nssfEmployeeUgx;
  final int netPayUgx;
  final int staffCount;
  final DateTime? submissionDeadline;
  final bool payeCompliant;
  final bool nssfCompliant;
  final List<PayrollLine> lines;

  PayrollRun({
    required this.id,
    required this.periodLabel,
    required this.grossPayUgx,
    required this.payeUgx,
    required this.nssfEmployerUgx,
    required this.nssfEmployeeUgx,
    required this.netPayUgx,
    required this.staffCount,
    required this.submissionDeadline,
    required this.payeCompliant,
    required this.nssfCompliant,
    required this.lines,
  });

  factory PayrollRun.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final j = d.data() ?? const {};
    return PayrollRun(
      id: d.id,
      periodLabel: j['periodLabel'] as String? ?? '',
      grossPayUgx: _int(j['grossPayUgx']),
      payeUgx: _int(j['payeUgx']),
      nssfEmployerUgx: _int(j['nssfEmployerUgx']),
      nssfEmployeeUgx: _int(j['nssfEmployeeUgx']),
      netPayUgx: _int(j['netPayUgx']),
      staffCount: _int(j['staffCount']),
      submissionDeadline: _date(j['submissionDeadline']),
      payeCompliant: j['payeCompliant'] as bool? ?? false,
      nssfCompliant: j['nssfCompliant'] as bool? ?? false,
      lines: ((j['lines'] as List?) ?? const [])
          .map((e) => PayrollLine.fromMap((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

class AuditEvent {
  final String id;
  final DateTime? at;
  final String action;
  final String actor;
  final String summary;
  final int? amountUgx;

  AuditEvent({
    required this.id,
    required this.at,
    required this.action,
    required this.actor,
    required this.summary,
    this.amountUgx,
  });

  factory AuditEvent.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final j = d.data() ?? const {};
    return AuditEvent(
      id: d.id,
      at: _date(j['at']),
      action: j['action'] as String? ?? '',
      actor: j['actor'] as String? ?? j['actorName'] as String? ?? 'System',
      summary: j['summary'] as String? ?? j['description'] as String? ?? '',
      amountUgx: j['amountUgx'] == null ? null : _int(j['amountUgx']),
    );
  }
}
