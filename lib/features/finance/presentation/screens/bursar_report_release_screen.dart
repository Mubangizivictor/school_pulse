import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/domain/entities/report_release_eligibility.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';
import 'package:school_pulse/injection_container.dart';

import '../bloc/report_release/bursar_report_release_bloc.dart';
import '../../data/datasources/bursar_report_release_remote_data_source.dart'
    show BursarReportReleaseRemoteDataSource, ReportCardHistory;
import 'report_release/report_release_action_dialogs.dart';
import 'report_release/report_release_audit_sheet.dart';

/// The Bursar's Report Card Releases area.
///
/// Server-authoritative: every row's status, balance and policy result come
/// from the `getReportCardReleaseEligibility` Cloud Function (which reads the
/// authoritative fee balances + exception records) and every action is a
/// trusted callable. Nothing here writes `financialAccessStatus` directly -
/// Firestore rules deny that entirely.
class BursarReportReleaseScreen extends StatelessWidget {
  const BursarReportReleaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';
    final roles = auth is AuthAuthenticated
        ? auth.user.roles.map((r) => r.name).toList()
        : const <String>[];

    return BlocProvider(
      create: (_) =>
          sl<BursarReportReleaseBloc>()
            ..add(BursarReportReleaseStarted(schoolId)),
      child: _ReportReleaseView(roles: roles),
    );
  }
}

class _ReportReleaseView extends StatelessWidget {
  const _ReportReleaseView({required this.roles});
  final List<String> roles;

  bool get _canApprove =>
      roles.contains('headTeacher') || roles.contains('director');
  bool get _canGrant =>
      roles.contains('bursar') ||
      roles.contains('schoolAdmin') ||
      roles.contains('director');

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BursarReportReleaseBloc, BursarReportReleaseState>(
      listenWhen: (a, b) =>
          a.successMessage != b.successMessage ||
          a.errorMessage != b.errorMessage,
      listener: (context, state) {
        final msg = state.successMessage ?? state.errorMessage;
        if (msg == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: state.errorMessage != null
                  ? AppColors.danger(context)
                  : null,
            ),
          );
        context.read<BursarReportReleaseBloc>().add(
          const BursarReportReleaseFeedbackCleared(),
        );
      },
      builder: (context, state) {
        return FinanceScaffold(
          title: 'Report Card Releases',
          isOffline: false,
          body: Column(
            children: [
              _FilterBar(state: state),
              const Divider(height: 1),
              Expanded(
                child: _Body(state: state, view: this),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bar
// ---------------------------------------------------------------------------

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.state});
  final BursarReportReleaseState state;

  @override
  Widget build(BuildContext context) {
    final facets = state.facets;
    final bloc = context.read<BursarReportReleaseBloc>();

    return Container(
      color: AppColors.background(context),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.l,
        AppSpacing.m,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              _Dropdown(
                label: 'Year',
                value: state.academicYearId.isEmpty
                    ? null
                    : state.academicYearId,
                items: facets?.years ?? const [],
                onChanged: (v) => bloc.add(
                  BursarReportReleaseFiltersChanged(
                    academicYearId: v,
                    termId: state.termId,
                    classId: state.classId,
                  ),
                ),
              ),
              _Dropdown(
                label: 'Term',
                value: state.termId.isEmpty ? null : state.termId,
                items: facets?.terms ?? const [],
                onChanged: (v) => bloc.add(
                  BursarReportReleaseFiltersChanged(
                    academicYearId: state.academicYearId,
                    termId: v,
                    classId: state.classId,
                  ),
                ),
              ),
              _Dropdown(
                label: 'Class',
                value: state.classId,
                items: const ['All'],
                extraItems: facets?.classes ?? const [],
                onChanged: (v) => bloc.add(
                  BursarReportReleaseFiltersChanged(
                    academicYearId: state.academicYearId,
                    termId: state.termId,
                    classId: v == 'All' ? '' : v,
                  ),
                ),
              ),
              if ((facets?.streams ?? const []).isNotEmpty)
                _Dropdown(
                  label: 'Stream',
                  value: state.streamId,
                  items: const ['All'],
                  extraItems: facets!.streams,
                  onChanged: (v) => bloc.add(
                    BursarReportReleaseFiltersChanged(
                      learnerQuery: state.learnerQuery,
                      streamId: v == 'All' ? null : v,
                      clearStream: v == 'All',
                    ),
                  ),
                ),
              _Dropdown(
                label: 'Status',
                value: state.statusFilter?.name,
                items: const ['All'],
                extraItems: ReportReleaseUiStatus.values
                    .map((s) => s.name)
                    .toList(),
                labelFor: (id) => id == 'All'
                    ? 'All'
                    : ReportReleaseUiStatus.fromId(id).label,
                onChanged: (v) => bloc.add(
                  BursarReportReleaseFiltersChanged(
                    learnerQuery: state.learnerQuery,
                    statusFilter: v == 'All'
                        ? null
                        : ReportReleaseUiStatus.fromId(v),
                    clearStatus: v == 'All',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          SizedBox(
            height: 40,
            child: TextField(
              onChanged: (v) => bloc.add(
                BursarReportReleaseFiltersChanged(
                  learnerQuery: v,
                  streamId: state.streamId,
                  statusFilter: state.statusFilter,
                ),
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search learner',
                prefixIcon: const Icon(Icons.search, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    this.extraItems = const [],
    this.labelFor,
    required this.onChanged,
  });
  final String label;
  final String? value;
  final List<String> items;
  final List<String> extraItems;
  final String Function(String)? labelFor;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final all = [...items, ...extraItems];
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 220),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            isDense: true,
            value: all.contains(value) ? value : null,
            hint: Text(labelFor?.call(all.isEmpty ? '' : all.first) ?? '—'),
            items: all
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(
                      labelFor?.call(v) ?? v,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.view});
  final BursarReportReleaseState state;
  final _ReportReleaseView view;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) return FinanceStates.loading();
    if (state.errorMessage != null && state.allRows.isEmpty) {
      return FinanceStates.error(
        context,
        state.errorMessage!,
        onRetry: () => context.read<BursarReportReleaseBloc>().add(
          BursarReportReleaseRequested(
            academicYearId: state.academicYearId,
            termId: state.termId,
            classId: state.classId,
          ),
        ),
      );
    }
    if (!state.canLoad) {
      return FinanceStates.empty(
        context,
        icon: Icons.tune_rounded,
        title: 'Choose a report period',
        message:
            'Pick an academic year and term above to see release status for '
            'every finalized report card.',
      );
    }
    final visible = state.visibleRows;
    if (visible.isEmpty) {
      return FinanceStates.empty(
        context,
        icon: Icons.inbox_outlined,
        title: 'No report cards match',
        message: state.allRows.isEmpty
            ? 'No finalized report cards for this period yet.'
            : 'Try clearing the class, stream, status or search filters.',
      );
    }

    const order = [
      ReportReleaseUiStatus.pendingApproval,
      ReportReleaseUiStatus.withheldForFees,
      ReportReleaseUiStatus.exceptionActive,
      ReportReleaseUiStatus.exceptionExpired,
      ReportReleaseUiStatus.automaticallyAvailable,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.l,
        AppSpacing.x3l,
      ),
      children: [
        _PolicyBanner(state: state),
        const SizedBox(height: AppSpacing.m),
        for (final status in order)
          if (state.section(status).isNotEmpty) ...[
            _SectionHeader(status: status, count: state.section(status).length),
            const SizedBox(height: AppSpacing.s),
            for (final row in state.section(status))
              _ReleaseRowCard(row: row, view: view),
            const SizedBox(height: AppSpacing.l),
          ],
      ],
    );
  }
}

class _PolicyBanner extends StatelessWidget {
  const _PolicyBanner({required this.state});
  final BursarReportReleaseState state;

  @override
  Widget build(BuildContext context) {
    final p = state.policy;
    return FinanceCard(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        children: [
          Icon(
            Icons.policy_outlined,
            size: 18,
            color: AppColors.textMuted(context),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              'Clearance policy: ${p.mode.label}'
              '${p.secondApproverRequired ? ' · second approval above ${CurrencyFormatter.ugx(p.secondApproverArrearsThresholdUgx.toDouble())}' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.status, required this.count});
  final ReportReleaseUiStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          _statusDot(context, status),
          const SizedBox(width: AppSpacing.s),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(BuildContext context, ReportReleaseUiStatus s) =>
    switch (s) {
      ReportReleaseUiStatus.automaticallyAvailable => AppColors.success(
        context,
      ),
      ReportReleaseUiStatus.exceptionActive => AppColors.success(context),
      ReportReleaseUiStatus.withheldForFees => AppColors.danger(context),
      ReportReleaseUiStatus.exceptionExpired => AppColors.danger(context),
      ReportReleaseUiStatus.pendingApproval => AppColors.warning(context),
    };

Widget _statusDot(BuildContext context, ReportReleaseUiStatus s) => Container(
  width: 9,
  height: 9,
  decoration: BoxDecoration(
    color: _statusColor(context, s),
    shape: BoxShape.circle,
  ),
);

// ---------------------------------------------------------------------------
// Row card
// ---------------------------------------------------------------------------

class _ReleaseRowCard extends StatelessWidget {
  const _ReleaseRowCard({required this.row, required this.view});
  final ReportReleaseEligibilityRow row;
  final _ReportReleaseView view;

  @override
  Widget build(BuildContext context) {
    final exc = row.exception;
    final tone = _statusColor(context, row.uiStatus);
    return FinanceCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.studentName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${row.periodLabel} · ${row.classId}'
                      '${row.streamId != null && row.streamId!.isNotEmpty ? ' / ${row.streamId}' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              _MiniChip(label: row.uiStatus.label, color: tone),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.m,
            runSpacing: 4,
            children: [
              _kv(
                context,
                'Balance',
                CurrencyFormatter.ugx(row.balanceUgx.toDouble()),
                emphasise: row.balanceUgx > 0,
              ),
              _kv(context, 'Policy', row.clearance.summary),
              _kv(context, 'Access', _accessLabel(row)),
              if (row.isBursarOverride)
                _kv(context, 'Source', 'Direct Bursar override'),
            ],
          ),
          if (exc != null) ...[
            const SizedBox(height: AppSpacing.s),
            _ExceptionSummary(exc: exc),
          ],
          const SizedBox(height: AppSpacing.s),
          _RowActions(row: row, view: view),
        ],
      ),
    );
  }

  static String _accessLabel(ReportReleaseEligibilityRow r) =>
      switch (r.financialAccessStatus) {
        'released' => 'Visible to parent',
        'revoked' => 'Revoked',
        _ => 'Withheld from parent',
      };

  static Widget _kv(
    BuildContext context,
    String k,
    String v, {
    bool emphasise = false,
  }) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
        children: [
          TextSpan(text: '$k  '),
          TextSpan(
            text: v,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: emphasise
                  ? AppColors.danger(context)
                  : AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _ExceptionSummary extends StatelessWidget {
  const _ExceptionSummary({required this.exc});
  final ReportReleaseException exc;

  @override
  Widget build(BuildContext context) {
    final bits = <String>[
      exc.reasonCode.label,
      if (exc.reasonNote != null && exc.reasonNote!.isNotEmpty) exc.reasonNote!,
      if (exc.expiresAt != null)
        'expires ${_d(exc.expiresAt!)}'
      else
        'no expiry',
      if (exc.authorisedByName != null) 'approved by ${exc.authorisedByName}',
      if (exc.isConsumed) 'used',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(context),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        bits.join(' · '),
        style: TextStyle(
          fontSize: 11.5,
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }

  static String _d(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

class _RowActions extends StatelessWidget {
  const _RowActions({required this.row, required this.view});
  final ReportReleaseEligibilityRow row;
  final _ReportReleaseView view;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BursarReportReleaseBloc>();
    final exc = row.exception;
    final actions = <Widget>[];

    void add(String label, VoidCallback onTap, {bool danger = false}) {
      actions.add(
        OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: danger
                ? AppColors.danger(context)
                : AppColors.textPrimary(context),
            side: BorderSide(color: AppColors.border(context)),
          ),
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
      );
    }

    // Grant is offered whenever there is no live/pending exception and the
    // report isn't already automatically available.
    final hasLiveOrPending =
        exc != null &&
        (exc.status == 'active' || exc.status == 'pendingApproval');
    if (view._canGrant &&
        !hasLiveOrPending &&
        row.uiStatus != ReportReleaseUiStatus.automaticallyAvailable) {
      add(
        'Grant exception',
        () => showGrantExceptionDialog(context, bloc, row),
      );
    }

    if (exc != null && exc.status == 'pendingApproval') {
      if (view._canApprove) {
        add('Approve', () => showApproveDialog(context, bloc, exc));
        add('Reject', () => showRejectDialog(context, bloc, exc), danger: true);
      }
    }
    if (exc != null && exc.status == 'active') {
      add('Revoke', () => showRevokeDialog(context, bloc, exc), danger: true);
    }
    if (exc != null &&
        (exc.status == 'expired' || exc.status == 'revoked') &&
        view._canGrant) {
      add('Renew', () => showRenewDialog(context, bloc, exc));
    }

    add('Audit history', () => _openAudit(context));

    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: actions,
    );
  }

  void _openAudit(BuildContext context) {
    final ds = sl<BursarReportReleaseRemoteDataSource>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background(context),
      builder: (sheetCtx) {
        return FutureBuilder<ReportCardHistory>(
          future: ds.getExceptionHistory(row.reportCardId),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snap.hasError || !snap.hasData) {
              return SizedBox(
                height: 220,
                child: Center(child: Text('Could not load audit history.')),
              );
            }
            return ReportReleaseAuditSheet(
              studentName: row.studentName,
              history: snap.data!,
            );
          },
        );
      },
    );
  }
}
