import 'package:flutter/material.dart';

import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/finance/domain/entities/report_release_eligibility.dart';

import '../../../data/datasources/bursar_report_release_remote_data_source.dart'
    show ReportCardHistory, ReportAuditEntry;

/// Safe, redacted audit history for one report card: the report's own
/// immutable audit-log entries plus every release exception (any status)
/// that has covered its period. Shows names, never raw uids; no balances of
/// other learners, no internal notes beyond what staff already authored.
class ReportReleaseAuditSheet extends StatelessWidget {
  const ReportReleaseAuditSheet({
    super.key,
    required this.studentName,
    required this.history,
  });

  final String studentName;
  final ReportCardHistory history;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Audit history · $studentName',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            _sectionLabel(context, 'Report access log'),
            if (history.reportAudit.isEmpty)
              _muted(context, 'No access-log entries yet.')
            else
              ...history.reportAudit.map((e) => _ReportAuditTile(entry: e)),
            const SizedBox(height: AppSpacing.l),
            _sectionLabel(context, 'Release exceptions'),
            if (history.exceptions.isEmpty)
              _muted(context, 'No release exceptions for this period.')
            else
              ...history.exceptions.map((x) => _ExceptionCard(exc: x)),
            const SizedBox(height: AppSpacing.x3l),
          ],
        );
      },
    );
  }

  Widget _sectionLabel(BuildContext context, String s) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.s),
    child: Text(
      s,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary(context),
        letterSpacing: 0.2,
      ),
    ),
  );

  Widget _muted(BuildContext context, String s) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.m),
    child: Text(
      s,
      style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
    ),
  );
}

class _ReportAuditTile extends StatelessWidget {
  const _ReportAuditTile({required this.entry});
  final ReportAuditEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 6, color: AppColors.textMuted(context)),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_pretty(entry.action)} · ${entry.actorName}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                if (entry.reason != null && entry.reason!.isNotEmpty)
                  Text(
                    entry.reason!,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                if (entry.at != null)
                  Text(
                    _dt(entry.at!),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted(context),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExceptionCard extends StatelessWidget {
  const _ExceptionCard({required this.exc});
  final ReportReleaseException exc;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${exc.reasonCode.label} · ${exc.status}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.ugx(
                  exc.outstandingBalanceUgxAtRelease.toDouble(),
                ),
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),
          if (exc.reasonNote != null && exc.reasonNote!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                exc.reasonNote!,
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.s),
          ...exc.auditTrail.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                '• ${_pretty(a.action)} — ${a.actorName}'
                '${a.note != null && a.note!.isNotEmpty ? ' (${a.note})' : ''}'
                '${a.at != null ? '  ${_dt(a.at!)}' : ''}',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _pretty(String action) => action
    .replaceAll('financial_access.', '')
    .replaceAll('report_card_exception.', '')
    .replaceAll('_', ' ');

String _dt(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
