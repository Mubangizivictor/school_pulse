import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/domain/services/finance_report_pdf.dart';
import 'package:school_pulse/features/finance/domain/services/finance_reports_service.dart'
    as svc;
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';
import 'package:school_pulse/injection_container.dart';

/// Financial reports — eight real reports built from authoritative finance
/// data (audit area 5). Every report is school-scoped, date-range
/// filterable, shows totals + loading/empty/error, and exports to CSV
/// (all eight) or PDF (cashbook + arrears). The old placeholder
/// "Export report" snackbar is gone.
class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  State<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> {
  svc.FinanceReportType _type = svc.FinanceReportType.cashbook;
  late DateTimeRange _range;
  Future<svc.FinanceReport>? _future;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _range = DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
    _run();
  }

  void _run() {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    setState(() {
      _future = sl<svc.FinanceReportsService>().build(
        _type,
        auth.user.schoolId,
        svc.DateTimeRange(start: _range.start, end: _range.end),
      );
    });
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 3),
      lastDate: DateTime(DateTime.now().year + 1),
      initialDateRange: _range,
    );
    if (picked != null) {
      _range = picked;
      _run();
    }
  }

  Future<void> _exportCsv(svc.FinanceReport report) async {
    final bytes = utf8.encode(report.toCsv());
    final name =
        '${report.type.name}_${DateFormat('yyyyMMdd').format(_range.start)}'
        '-${DateFormat('yyyyMMdd').format(_range.end)}.csv';
    await Share.shareXFiles([
      XFile.fromData(bytes, name: name, mimeType: 'text/csv'),
    ], subject: '${report.title} — ${report.rangeLabel}');
  }

  Future<void> _exportPdf(svc.FinanceReport report) async {
    final auth = context.read<AuthBloc>().state;
    final schoolName = auth is AuthAuthenticated
        ? (auth.user.schoolName ?? 'School')
        : 'School';
    final bytes = await FinanceReportPdf.generate(
      report,
      schoolName: schoolName,
    );
    final name =
        '${report.type.name}_${DateFormat('yyyyMMdd').format(_range.start)}'
        '-${DateFormat('yyyyMMdd').format(_range.end)}.pdf';
    await Share.shareXFiles([
      XFile.fromData(bytes, name: name, mimeType: 'application/pdf'),
    ], subject: '${report.title} — ${report.rangeLabel}');
  }

  @override
  Widget build(BuildContext context) {
    return FinanceScaffold(
      title: 'Financial reports',
      constrainWidth: true,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Column(
              children: [
                DropdownButtonFormField<svc.FinanceReportType>(
                  initialValue: _type,
                  decoration: const InputDecoration(
                    labelText: 'Report',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    for (final t in svc.FinanceReportType.values)
                      DropdownMenuItem(value: t, child: Text(t.label)),
                  ],
                  onChanged: (t) {
                    if (t != null) {
                      _type = t;
                      _run();
                    }
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _pickRange,
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text(
                    '${DateFormat('d MMM yyyy').format(_range.start)}  –  '
                    '${DateFormat('d MMM yyyy').format(_range.end)}',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<svc.FinanceReport>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return FinanceStates.loading();
                }
                if (snap.hasError) {
                  return FinanceStates.error(
                    context,
                    'Could not build this report.',
                    onRetry: _run,
                  );
                }
                final report = snap.data;
                if (report == null) return const SizedBox.shrink();
                if (report.isEmpty) {
                  return FinanceStates.empty(
                    context,
                    icon: Icons.insert_chart_outlined,
                    title: 'Nothing in range',
                    message:
                        'No ${report.title.toLowerCase()} data for the selected dates.',
                  );
                }
                return _ReportView(
                  report: report,
                  onCsv: () => _exportCsv(report),
                  onPdf: report.type.supportsPdf
                      ? () => _exportPdf(report)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportView extends StatelessWidget {
  final svc.FinanceReport report;
  final VoidCallback onCsv;
  final VoidCallback? onPdf;

  const _ReportView({required this.report, required this.onCsv, this.onPdf});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (report.totals.isNotEmpty)
                FinanceCard(
                  child: Column(
                    children: [
                      for (final e in report.totals.entries)
                        KeyValueRow(e.key, e.value, bold: true),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 22,
                  headingRowHeight: 38,
                  dataRowMinHeight: 34,
                  dataRowMaxHeight: 46,
                  columns: [
                    for (final c in report.columns)
                      DataColumn(
                        label: Text(
                          c,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                  rows: [
                    for (final r in report.rows)
                      DataRow(
                        cells: [
                          for (final cell in r)
                            DataCell(
                              Text(cell, style: const TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${report.rows.length} rows · ${report.rangeLabel}',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCsv,
                    icon: const Icon(Icons.table_view_outlined, size: 18),
                    label: const Text('Export CSV'),
                  ),
                ),
                if (onPdf != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      label: const Text('Export PDF'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
