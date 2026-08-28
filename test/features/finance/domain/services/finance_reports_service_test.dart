import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/finance/domain/services/finance_reports_service.dart';

/// Audit area 5 — report value object: CSV is self-describing (title +
/// period header), quoting is correct, totals are appended, and every
/// report type declares whether it supports PDF.
void main() {
  final range = DateTimeRange(
    start: DateTime(2026, 3, 1),
    end: DateTime(2026, 3, 31),
  );

  FinanceReport report({
    List<List<String>> rows = const [
      [
        '2026-03-04',
        'Tuition, term 1',
        'Receipt',
        '500000',
        '',
        '500000',
        'matched',
      ],
    ],
    Map<String, String> totals = const {'Total in': 'UGX 500,000'},
  }) => FinanceReport(
    type: FinanceReportType.cashbook,
    title: 'Cashbook',
    range: range,
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
    totals: totals,
  );

  test('rangeLabel spans the selected dates', () {
    expect(report().rangeLabel, '1 Mar 2026 – 31 Mar 2026');
  });

  test('isEmpty is true only when there are no rows', () {
    expect(report(rows: const []).isEmpty, isTrue);
    expect(report().isEmpty, isFalse);
  });

  test('CSV carries a title + period header and the column row', () {
    final csv = report().toCsv();
    final lines = csv.trimRight().split('\n');
    expect(lines.first.trim(), 'Cashbook');
    expect(lines[1].trim(), 'Period,1 Mar 2026 – 31 Mar 2026');
    expect(
      lines,
      contains(
        'Date,Description,Type,Money in,Money out,Running balance,Reconciliation',
      ),
    );
  });

  test('CSV quotes a cell that contains a comma', () {
    final csv = report().toCsv();
    expect(csv, contains('"Tuition, term 1"'));
  });

  test('CSV appends the totals block (value with a comma is quoted)', () {
    final csv = report().toCsv();
    expect(csv, contains('Total in,"UGX 500,000"'));
  });

  test('only cashbook and arrears support PDF', () {
    for (final t in FinanceReportType.values) {
      final expected =
          t == FinanceReportType.cashbook || t == FinanceReportType.arrears;
      expect(t.supportsPdf, expected, reason: '${t.name}.supportsPdf');
    }
  });

  test('all eight report types are present with labels', () {
    expect(FinanceReportType.values.length, 8);
    for (final t in FinanceReportType.values) {
      expect(t.label, isNotEmpty);
    }
  });
}
