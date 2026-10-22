import 'package:flutter/material.dart';

import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/finance/domain/entities/report_release_eligibility.dart';

import '../../bloc/report_release/bursar_report_release_bloc.dart';

/// Grant a release exception. Requires a reason code, an optional note
/// (mandatory for "custom"), an optional expiry date, and an explicit
/// confirmation toggle before the action is enabled.
Future<void> showGrantExceptionDialog(
  BuildContext context,
  BursarReportReleaseBloc bloc,
  ReportReleaseEligibilityRow row,
) async {
  await showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      var reason = ExceptionReasonCode.paymentPlan;
      final noteCtrl = TextEditingController();
      DateTime? expiry;
      var confirmed = false;

      return StatefulBuilder(
        builder: (ctx, setState) {
          final needsNote = reason == ExceptionReasonCode.custom;
          final noteOk = !needsNote || noteCtrl.text.trim().isNotEmpty;
          return AlertDialog(
            title: Text('Grant release exception · ${row.studentName}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report period ${row.periodLabel}. Outstanding balance '
                    '${CurrencyFormatter.ugx(row.balanceUgx.toDouble())} will be '
                    'recorded on this exception and cannot change afterwards.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(ctx),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  DropdownButtonFormField<ExceptionReasonCode>(
                    initialValue: reason,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      isDense: true,
                    ),
                    items: ExceptionReasonCode.values
                        .map(
                          (r) =>
                              DropdownMenuItem(value: r, child: Text(r.label)),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => reason = v!),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  TextField(
                    controller: noteCtrl,
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: needsNote
                          ? 'Reason detail (required)'
                          : 'Notes (optional)',
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          expiry == null
                              ? 'No expiry'
                              : 'Expires ${_fmt(expiry!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(ctx),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 730),
                            ),
                            initialDate: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                          );
                          if (picked != null) setState(() => expiry = picked);
                        },
                        child: const Text('Set expiry'),
                      ),
                      if (expiry != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () => setState(() => expiry = null),
                        ),
                    ],
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: confirmed,
                    onChanged: (v) => setState(() => confirmed = v ?? false),
                    title: const Text(
                      'I confirm this authorised release exception',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: (confirmed && noteOk)
                    ? () {
                        bloc.add(
                          BursarReleaseExceptionGranted(
                            studentId: row.studentId,
                            academicYearId: row.academicYearId,
                            termId: row.termId,
                            reasonCode: reason.id,
                            reasonNote: noteCtrl.text.trim().isEmpty
                                ? null
                                : noteCtrl.text.trim(),
                            expiresAt: expiry,
                          ),
                        );
                        Navigator.pop(dialogCtx);
                      }
                    : null,
                child: const Text('Grant'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> showApproveDialog(
  BuildContext context,
  BursarReportReleaseBloc bloc,
  ReportReleaseException exc,
) => _noteDialog(
  context,
  title: 'Approve release exception',
  body:
      '${exc.reasonCode.label}. Arrears at grant time '
      '${CurrencyFormatter.ugx(exc.outstandingBalanceUgxAtRelease.toDouble())}.',
  actionLabel: 'Approve',
  noteLabel: 'Approval note (optional)',
  requireNote: false,
  onSubmit: (note) =>
      bloc.add(BursarReleaseExceptionApproved(exc.id, note: note)),
);

Future<void> showRejectDialog(
  BuildContext context,
  BursarReportReleaseBloc bloc,
  ReportReleaseException exc,
) => _noteDialog(
  context,
  title: 'Reject release exception',
  body: 'This pending exception will be recorded as rejected. Reason required.',
  actionLabel: 'Reject',
  noteLabel: 'Reason (required)',
  requireNote: true,
  danger: true,
  onSubmit: (note) => bloc.add(BursarReleaseExceptionRejected(exc.id, note!)),
);

Future<void> showRevokeDialog(
  BuildContext context,
  BursarReportReleaseBloc bloc,
  ReportReleaseException exc,
) => _noteDialog(
  context,
  title: 'Revoke release exception',
  body:
      'The report will be re-gated against the current fee-clearance policy. '
      'This cannot be undone; a new exception must be granted to restore access.',
  actionLabel: 'Revoke',
  noteLabel: 'Reason (required)',
  requireNote: true,
  danger: true,
  requireConfirm: true,
  onSubmit: (note) => bloc.add(BursarReleaseExceptionRevoked(exc.id, note!)),
);

Future<void> showRenewDialog(
  BuildContext context,
  BursarReportReleaseBloc bloc,
  ReportReleaseException exc,
) async {
  await showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      DateTime newExpiry = DateTime.now().add(const Duration(days: 30));
      final noteCtrl = TextEditingController();
      return StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Renew release exception'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Creates a new exception linked to the previous one, with a '
                'fresh balance snapshot. The old record is preserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(ctx),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(child: Text('New expiry ${_fmt(newExpiry)}')),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 730)),
                        initialDate: newExpiry,
                      );
                      if (picked != null) setState(() => newExpiry = picked);
                    },
                    child: const Text('Change'),
                  ),
                ],
              ),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  isDense: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                bloc.add(
                  BursarReleaseExceptionRenewed(
                    exc.id,
                    newExpiry,
                    reasonNote: noteCtrl.text.trim().isEmpty
                        ? null
                        : noteCtrl.text.trim(),
                  ),
                );
                Navigator.pop(dialogCtx);
              },
              child: const Text('Renew'),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _noteDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String actionLabel,
  required String noteLabel,
  required bool requireNote,
  required void Function(String? note) onSubmit,
  bool danger = false,
  bool requireConfirm = false,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      final ctrl = TextEditingController();
      var confirmed = !requireConfirm;
      return StatefulBuilder(
        builder: (ctx, setState) {
          final ok = (!requireNote || ctrl.text.trim().isNotEmpty) && confirmed;
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(ctx),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                TextField(
                  controller: ctrl,
                  maxLines: 3,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: noteLabel,
                    isDense: true,
                  ),
                ),
                if (requireConfirm)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: confirmed,
                    onChanged: (v) => setState(() => confirmed = v ?? false),
                    title: const Text(
                      'I understand this cannot be undone',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: danger
                    ? FilledButton.styleFrom(
                        backgroundColor: AppColors.danger(ctx),
                      )
                    : null,
                onPressed: ok
                    ? () {
                        onSubmit(
                          ctrl.text.trim().isEmpty ? null : ctrl.text.trim(),
                        );
                        Navigator.pop(dialogCtx);
                      }
                    : null,
                child: Text(actionLabel),
              ),
            ],
          );
        },
      );
    },
  );
}

String _fmt(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
