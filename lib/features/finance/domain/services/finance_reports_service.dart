import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/features/finance/data/repositories/bursar_ops_read_repository.dart';

/// One report, ready to render or export.
class FinanceReport {
  final FinanceReportType type;
  final String title;
  final DateTimeRange range;
  final List<String> columns;

  /// Rows as display strings (already formatted). [rawRows] mirrors them for
  /// CSV so numbers stay unformatted where that matters.
  final List<List<String>> rows;

  /// Label → formatted value shown in the totals band.
  final Map<String, String> totals;

  /// True when the query succeeded but produced no rows.
  final bool isEmpty;

  const FinanceReport({
    required this.type,
    required this.title,
    required this.range,
    required this.columns,
    required this.rows,
    this.totals = const {},
  }) : isEmpty = rows.length == 0;

  String get rangeLabel {
    final f = DateFormat('d MMM yyyy');
    return '${f.format(range.start)} – ${f.format(range.end)}';
  }

  /// RFC-4180-ish CSV. First lines carry the report title + range so an
  /// exported file is self-describing and never ambiguous about scope.
  String toCsv() {
    final b = StringBuffer();
    b.writeln(_csvRow([title]));
    b.writeln(_csvRow(['Period', rangeLabel]));
    b.writeln('');
    b.writeln(_csvRow(columns));
    for (final r in rows) {
      b.writeln(_csvRow(r));
    }
    if (totals.isNotEmpty) {
      b.writeln('');
      totals.forEach((k, v) => b.writeln(_csvRow([k, v])));
    }
    return b.toString();
  }

  static String _csvRow(List<String> cells) => cells
      .map((c) {
        final needsQuote =
            c.contains(',') || c.contains('"') || c.contains('\n');
        final escaped = c.replaceAll('"', '""');
        return needsQuote ? '"$escaped"' : escaped;
      })
      .join(',');
}

enum FinanceReportType {
  cashbook('Cashbook'),
  trialBalance('Trial balance'),
  arrears('Student arrears'),
  incomeExpenditure('Income vs expenditure'),
  budgetPerformance('Budget performance'),
  supplierPayables('Supplier payables'),
  pettyCashActivity('Petty cash activity'),
  payrollSummary('Payroll & remittance summary');

  const FinanceReportType(this.label);
  final String label;

  /// The two report types we also render as PDF (most often printed/shared).
  bool get supportsPdf =>
      this == FinanceReportType.cashbook || this == FinanceReportType.arrears;
}

/// Builds each finance report from authoritative Firestore data, scoped to
/// one school and a date range. Read-only; no report writes anything.
///
/// Point-in-time collections (bank ledger, suppliers, petty cash, payroll)
/// are read once via a `.get()` on the same paths the read repository
/// streams — so a report reflects the same numbers the screens show, and
/// tenant isolation is the collection path (`schools/{schoolId}/…`) plus
/// firestore.rules, exactly as elsewhere.
class FinanceReportsService {
  final FirebaseFirestore _db;
  FinanceReportsService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(
    String schoolId,
    String name,
  ) => _db.collection('schools').doc(schoolId).collection(name);

  final _money = NumberFormat('#,##0', 'en_US');
  String _ugx(num v) => 'UGX ${_money.format(v)}';

  Future<FinanceReport> build(
    FinanceReportType type,
    String schoolId,
    DateTimeRange range,
  ) {
    switch (type) {
      case FinanceReportType.cashbook:
        return _cashbook(schoolId, range);
      case FinanceReportType.trialBalance:
        return _trialBalance(schoolId, range);
      case FinanceReportType.arrears:
        return _arrears(schoolId, range);
      case FinanceReportType.incomeExpenditure:
        return _incomeExpenditure(schoolId, range);
      case FinanceReportType.budgetPerformance:
        return _budgetPerformance(schoolId, range);
      case FinanceReportType.supplierPayables:
        return _supplierPayables(schoolId, range);
      case FinanceReportType.pettyCashActivity:
        return _pettyCashActivity(schoolId, range);
      case FinanceReportType.payrollSummary:
        return _payrollSummary(schoolId, range);
    }
  }

  bool _inRange(DateTime? d, DateTimeRange r) =>
      d != null &&
      !d.isBefore(DateTime(r.start.year, r.start.month, r.start.day)) &&
      !d.isAfter(DateTime(r.end.year, r.end.month, r.end.day, 23, 59, 59));

  DateTime? _ts(Object? v) => v is Timestamp
      ? v.toDate()
      : v is DateTime
      ? v
      : null;
  int _int(Object? v) => (v as num?)?.toInt() ?? 0;
  final _df = DateFormat('yyyy-MM-dd');

  // --- Cashbook: every bank-ledger movement in range, running total ------
  Future<FinanceReport> _cashbook(String schoolId, DateTimeRange r) async {
    final snap = await _col(schoolId, 'bank_ledger').get();
    final entries =
        snap.docs
            .map(LedgerEntry.fromDoc)
            .where((e) => _inRange(e.date, r))
            .toList()
          ..sort(
            (a, b) => (a.date ?? DateTime(0)).compareTo(b.date ?? DateTime(0)),
          );
    var running = 0;
    var totalIn = 0;
    var totalOut = 0;
    final rows = <List<String>>[];
    for (final e in entries) {
      running += e.amountUgx;
      if (e.amountUgx >= 0) {
        totalIn += e.amountUgx;
      } else {
        totalOut += -e.amountUgx;
      }
      rows.add([
        e.date != null ? _df.format(e.date!) : '',
        e.description,
        e.type,
        e.amountUgx >= 0 ? _money.format(e.amountUgx) : '',
        e.amountUgx < 0 ? _money.format(-e.amountUgx) : '',
        _money.format(running),
        e.reconciled ? 'matched' : 'unmatched',
      ]);
    }
    return FinanceReport(
      type: FinanceReportType.cashbook,
      title: 'Cashbook',
      range: r,
      columns: const [
        'Date',
        'Description',
        'Type',
        'Money in',
        'Money out',
        'Running balance',
        'Reconciliation',
      ],
      rows: rows,
      totals: {
        'Total in': _ugx(totalIn),
        'Total out': _ugx(totalOut),
        'Net movement': _ugx(totalIn - totalOut),
      },
    );
  }

  // --- Trial balance: closing balances of every finance holding ---------
  Future<FinanceReport> _trialBalance(String schoolId, DateTimeRange r) async {
    final results = await Future.wait([
      _col(schoolId, 'bank_accounts').get(),
      _col(schoolId, 'petty_cash').get(),
      _col(schoolId, 'finance_suppliers').get(),
      _col(schoolId, 'student_financials').get(),
    ]);
    final rows = <List<String>>[];
    var debit = 0;
    var credit = 0;

    for (final d in results[0].docs) {
      final bal = _int(d.data()['balanceUgx']);
      rows.add([d.data()['name']?.toString() ?? d.id, _money.format(bal), '']);
      debit += bal;
    }
    for (final d in results[1].docs) {
      final bal = _int(d.data()['currentFloatUgx']);
      rows.add([
        'Petty cash — ${d.data()['location'] ?? d.id}',
        _money.format(bal),
        '',
      ]);
      debit += bal;
    }
    var payables = 0;
    for (final d in results[2].docs) {
      payables += _int(d.data()['payableBalanceUgx']);
    }
    if (payables != 0) {
      rows.add(['Supplier payables', '', _money.format(payables)]);
      credit += payables;
    }
    var arrears = 0;
    for (final d in results[3].docs) {
      final owed = _int(d.data()['totalBilled']) - _int(d.data()['totalPaid']);
      if (owed > 0) arrears += owed;
    }
    if (arrears != 0) {
      rows.add(['Fees receivable (arrears)', _money.format(arrears), '']);
      debit += arrears;
    }

    return FinanceReport(
      type: FinanceReportType.trialBalance,
      title: 'Trial balance',
      range: r,
      columns: const ['Account', 'Debit (UGX)', 'Credit (UGX)'],
      rows: rows,
      totals: {
        'Total debit': _ugx(debit),
        'Total credit': _ugx(credit),
        'Difference': _ugx(debit - credit),
      },
    );
  }

  // --- Arrears: students with an outstanding balance -------------------
  Future<FinanceReport> _arrears(String schoolId, DateTimeRange r) async {
    final snap = await _col(schoolId, 'student_financials').get();
    final rows = <List<String>>[];
    var total = 0;
    for (final d in snap.docs) {
      final j = d.data();
      final billed = _int(j['totalBilled']);
      final paid = _int(j['totalPaid']);
      final owed = billed - paid;
      if (owed <= 0) continue;
      total += owed;
      rows.add([
        j['studentName']?.toString() ?? d.id,
        j['className']?.toString() ?? '',
        _money.format(billed),
        _money.format(paid),
        _money.format(owed),
      ]);
    }
    rows.sort(
      (a, b) => int.parse(
        b[4].replaceAll(',', ''),
      ).compareTo(int.parse(a[4].replaceAll(',', ''))),
    );
    return FinanceReport(
      type: FinanceReportType.arrears,
      title: 'Student arrears',
      range: r,
      columns: const ['Student', 'Class', 'Billed', 'Paid', 'Outstanding'],
      rows: rows,
      totals: {
        'Students in arrears': '${rows.length}',
        'Total outstanding': _ugx(total),
      },
    );
  }

  // --- Income vs expenditure -----------------------------------------
  Future<FinanceReport> _incomeExpenditure(
    String schoolId,
    DateTimeRange r,
  ) async {
    final results = await Future.wait([
      _col(schoolId, 'payments').get(),
      _col(schoolId, 'expenditures').get(),
      _col(schoolId, 'payment_vouchers').get(),
    ]);
    var income = 0;
    for (final d in results[0].docs) {
      if (_inRange(_ts(d.data()['date']), r)) {
        income += _int(d.data()['amount']);
      }
    }
    var expenditure = 0;
    for (final d in results[1].docs) {
      final j = d.data();
      if ((j['status'] == 'approved' || j['status'] == 'released') &&
          _inRange(_ts(j['decidedAt'] ?? j['createdAt']), r)) {
        expenditure += _int(j['amount']);
      }
    }
    var vouchers = 0;
    for (final d in results[2].docs) {
      final j = d.data();
      if (j['status'] == 'paid' && _inRange(_ts(j['paidAt']), r)) {
        vouchers += _int(j['amountUgx']);
      }
    }
    final rows = <List<String>>[
      ['Income', 'Fee & other collections', _money.format(income)],
      ['Expenditure', 'Approved expenditures', _money.format(expenditure)],
      ['Expenditure', 'Paid payment vouchers', _money.format(vouchers)],
    ];
    final surplus = income - expenditure - vouchers;
    return FinanceReport(
      type: FinanceReportType.incomeExpenditure,
      title: 'Income vs expenditure',
      range: r,
      columns: const ['Section', 'Line', 'Amount (UGX)'],
      rows: rows,
      totals: {
        'Total income': _ugx(income),
        'Total expenditure': _ugx(expenditure + vouchers),
        'Surplus / (deficit)': _ugx(surplus),
      },
    );
  }

  // --- Budget performance ------------------------------------------
  Future<FinanceReport> _budgetPerformance(
    String schoolId,
    DateTimeRange r,
  ) async {
    final snap = await _col(schoolId, 'budgets').get();
    final rows = <List<String>>[];
    var alloc = 0;
    var spent = 0;
    for (final d in snap.docs) {
      final j = d.data();
      final a = _int(j['allocatedAmount']);
      final s = _int(j['spentAmount']);
      alloc += a;
      spent += s;
      final pct = a > 0 ? (s / a * 100).round() : 0;
      rows.add([
        j['name']?.toString() ?? d.id,
        '${j['academicYear'] ?? ''} ${j['term'] ?? ''}'.trim(),
        _money.format(a),
        _money.format(s),
        _money.format(a - s),
        '$pct%',
      ]);
    }
    return FinanceReport(
      type: FinanceReportType.budgetPerformance,
      title: 'Budget performance',
      range: r,
      columns: const [
        'Budget line',
        'Period',
        'Allocated',
        'Spent',
        'Remaining',
        'Utilisation',
      ],
      rows: rows,
      totals: {
        'Total allocated': _ugx(alloc),
        'Total spent': _ugx(spent),
        'Overall utilisation': alloc > 0
            ? '${(spent / alloc * 100).round()}%'
            : '0%',
      },
    );
  }

  // --- Supplier payables ------------------------------------------
  Future<FinanceReport> _supplierPayables(
    String schoolId,
    DateTimeRange r,
  ) async {
    final results = await Future.wait([
      _col(schoolId, 'finance_suppliers').get(),
      _col(schoolId, 'supplier_invoices').get(),
    ]);
    final openBySupplier = <String, int>{};
    for (final d in results[1].docs) {
      final j = d.data();
      if (j['status'] == 'approved') {
        openBySupplier[j['supplierId']?.toString() ?? ''] =
            (openBySupplier[j['supplierId']?.toString() ?? ''] ?? 0) +
            _int(j['amountUgx']);
      }
    }
    final rows = <List<String>>[];
    var total = 0;
    for (final d in results[0].docs) {
      final j = d.data();
      final bal = _int(j['payableBalanceUgx']);
      if (bal == 0 && (openBySupplier[d.id] ?? 0) == 0) continue;
      total += bal;
      rows.add([
        j['name']?.toString() ?? d.id,
        j['category']?.toString() ?? '',
        _money.format(openBySupplier[d.id] ?? 0),
        _money.format(bal),
      ]);
    }
    return FinanceReport(
      type: FinanceReportType.supplierPayables,
      title: 'Supplier payables',
      range: r,
      columns: const [
        'Supplier',
        'Category',
        'Approved unpaid',
        'Payable balance',
      ],
      rows: rows,
      totals: {'Total payable': _ugx(total)},
    );
  }

  // --- Petty cash activity ---------------------------------------
  Future<FinanceReport> _pettyCashActivity(
    String schoolId,
    DateTimeRange r,
  ) async {
    final snap = await _col(schoolId, 'petty_cash_ledger').get();
    final entries =
        snap.docs
            .map(LedgerEntry.fromDoc)
            .where((e) => _inRange(e.date, r))
            .toList()
          ..sort(
            (a, b) => (a.date ?? DateTime(0)).compareTo(b.date ?? DateTime(0)),
          );
    var inSum = 0;
    var outSum = 0;
    final rows = <List<String>>[];
    for (final e in entries) {
      if (e.amountUgx >= 0) {
        inSum += e.amountUgx;
      } else {
        outSum += -e.amountUgx;
      }
      rows.add([
        e.date != null ? _df.format(e.date!) : '',
        e.description,
        e.type,
        e.amountUgx >= 0 ? _money.format(e.amountUgx) : '',
        e.amountUgx < 0 ? _money.format(-e.amountUgx) : '',
        e.balanceUgx != null ? _money.format(e.balanceUgx!) : '',
      ]);
    }
    return FinanceReport(
      type: FinanceReportType.pettyCashActivity,
      title: 'Petty cash activity',
      range: r,
      columns: const ['Date', 'Description', 'Type', 'In', 'Out', 'Balance'],
      rows: rows,
      totals: {
        'Replenished': _ugx(inSum),
        'Disbursed': _ugx(outSum),
        'Net': _ugx(inSum - outSum),
      },
    );
  }

  // --- Payroll & remittance summary ---------------------------
  Future<FinanceReport> _payrollSummary(
    String schoolId,
    DateTimeRange r,
  ) async {
    final runsSnap = await _col(
      schoolId,
      'payroll_runs',
    ).orderBy('periodOrder', descending: true).limit(12).get();
    final rows = <List<String>>[];
    var gross = 0;
    var paye = 0;
    var nssf = 0;
    var net = 0;
    for (final d in runsSnap.docs) {
      final run = PayrollRun.fromDoc(d);
      gross += run.grossPayUgx;
      paye += run.payeUgx;
      nssf += run.nssfEmployerUgx + run.nssfEmployeeUgx;
      net += run.netPayUgx;
      final remSnap = await _col(
        schoolId,
        'payroll_remittances',
      ).where('runId', isEqualTo: run.id).get();
      final rem = remSnap.docs.map(PayrollRemittance.fromDoc).toList();
      final payeState = rem
          .firstWhere(
            (x) => x.type.toLowerCase() == 'paye',
            orElse: () => const PayrollRemittance(
              id: '',
              type: 'paye',
              amountUgx: 0,
              dueDate: null,
              status: 'pending',
              reference: '',
              remittedAt: null,
            ),
          )
          .status;
      final nssfState = rem
          .firstWhere(
            (x) => x.type.toLowerCase() == 'nssf',
            orElse: () => const PayrollRemittance(
              id: '',
              type: 'nssf',
              amountUgx: 0,
              dueDate: null,
              status: 'pending',
              reference: '',
              remittedAt: null,
            ),
          )
          .status;
      rows.add([
        run.periodLabel,
        run.status,
        _money.format(run.grossPayUgx),
        _money.format(run.payeUgx),
        _money.format(run.nssfEmployerUgx + run.nssfEmployeeUgx),
        _money.format(run.netPayUgx),
        'PAYE: $payeState / NSSF: $nssfState',
      ]);
    }
    return FinanceReport(
      type: FinanceReportType.payrollSummary,
      title: 'Payroll & remittance summary',
      range: r,
      columns: const [
        'Period',
        'Run status',
        'Gross',
        'PAYE',
        'NSSF',
        'Net',
        'Remittance',
      ],
      rows: rows,
      totals: {
        'Total gross': _ugx(gross),
        'Total PAYE': _ugx(paye),
        'Total NSSF': _ugx(nssf),
        'Total net': _ugx(net),
      },
    );
  }
}

/// Minimal date range (avoids a Material import in the domain layer).
class DateTimeRange {
  final DateTime start;
  final DateTime end;
  const DateTimeRange({required this.start, required this.end});
}
