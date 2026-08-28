import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/utils.dart'
    show CurrencyFormatter, DateFormatter;
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/data/repositories/bursar_ops_read_repository.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';
import 'package:school_pulse/injection_container.dart';

/// Shared, server-backed payroll workspace. Firestore may cache reads, but
/// all approval, payment and remittance transitions are online callables.
class BursarPayrollScreen extends StatefulWidget {
  const BursarPayrollScreen({super.key});
  @override
  State<BursarPayrollScreen> createState() => _BursarPayrollScreenState();
}

class _BursarPayrollScreenState extends State<BursarPayrollScreen> {
  bool _working = false;

  Future<void> _call(String name, Map<String, dynamic> data) async {
    if (!await sl<NetworkInfo>().isConnected) {
      if (mounted)
        _toast('This action needs internet; payroll is read-only offline.');
      return;
    }
    setState(() => _working = true);
    try {
      await FirebaseFunctions.instance.httpsCallable(name).call(data);
      if (mounted) _toast('Saved securely.');
    } on FirebaseFunctionsException catch (e) {
      if (mounted)
        _toast(e.message ?? 'Payroll action could not be completed.');
    } catch (_) {
      if (mounted)
        _toast('Payroll action could not be completed. Try again online.');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _toast(String value) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(value)));

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';
    final roles = auth is AuthAuthenticated
        ? auth.user.roles.map((role) => role.name).toList()
        : const <String>[];
    final repo = sl<BursarOpsReadRepository>();
    return StreamBuilder<PayrollRun?>(
      stream: repo.watchLatestPayrollRun(schoolId),
      builder: (context, snapshot) {
        if (!snapshot.hasData &&
            snapshot.connectionState != ConnectionState.active) {
          return FinanceScaffold(
            title: 'Payroll & Compliance',
            body: FinanceStates.loading(),
          );
        }
        final run = snapshot.data;
        if (run == null) {
          return FinanceScaffold(
            title: 'Payroll & Compliance',
            body: FinanceStates.empty(
              context,
              icon: Icons.badge_outlined,
              title: 'No payroll run yet',
              message:
                  'An authorised payroll preparation will appear here when ready.',
            ),
          );
        }
        return StreamBuilder<List<PayrollRemittance>>(
          stream: repo.watchPayrollRemittances(schoolId, run.id),
          builder: (context, remittances) => _workspace(
            context,
            schoolId,
            roles,
            run,
            remittances.data ?? const [],
          ),
        );
      },
    );
  }

  Widget _workspace(
    BuildContext context,
    String schoolId,
    List<String> roles,
    PayrollRun run,
    List<PayrollRemittance> all,
  ) {
    final desktop =
        ResponsiveBuilder.getLayout(context) != ResponsiveLayout.mobile;
    final paye = _find(all, 'paye');
    final nssf = _find(all, 'nssf');
    final body = ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          'PAYROLL SUMMARY — ${run.periodLabel.toUpperCase()}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        if (desktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _summary(run)),
              const SizedBox(width: AppSpacing.l),
              Expanded(flex: 2, child: _statusCard(paye, nssf)),
            ],
          )
        else ...[
          _summary(run),
          const SizedBox(height: AppSpacing.l),
          _deadline(run, paye, nssf),
          const SizedBox(height: AppSpacing.l),
          _statusCard(paye, nssf),
        ],
        const SizedBox(height: AppSpacing.l),
        _reviewCard(run, desktop),
        const SizedBox(height: AppSpacing.l),
        _remittanceCard(run, paye, nssf),
      ],
    );
    return FinanceScaffold(
      title: 'Payroll & Compliance',
      body: body,
      bottomBar: desktop
          ? null
          : PrimaryActionBar(
              label: _actionLabel(run, roles),
              onPressed: _working
                  ? null
                  : () => _primaryAction(schoolId, run, roles),
            ),
      actions: desktop
          ? [
              TextButton.icon(
                onPressed: _working
                    ? null
                    : () => _primaryAction(schoolId, run, roles),
                icon: const Icon(Icons.lock_outline),
                label: Text(_actionLabel(run, roles)),
              ),
            ]
          : null,
    );
  }

  PayrollRemittance? _find(List<PayrollRemittance> all, String type) {
    for (final row in all) {
      if (row.type.toLowerCase() == type) return row;
    }
    return null;
  }

  Widget _summary(PayrollRun run) => SectionCard(
    child: Column(
      children: [
        KeyValueRow('Status', _pretty(run.status), bold: true),
        KeyValueRow(
          'Gross pay',
          CurrencyFormatter.ugx(run.grossPayUgx.toDouble()),
        ),
        KeyValueRow(
          'PAYE (withholding tax)',
          CurrencyFormatter.ugx(run.payeUgx.toDouble()),
        ),
        KeyValueRow(
          'NSSF (employer)',
          CurrencyFormatter.ugx(run.nssfEmployerUgx.toDouble()),
        ),
        KeyValueRow(
          'NSSF (employee)',
          CurrencyFormatter.ugx(run.nssfEmployeeUgx.toDouble()),
        ),
        const Divider(height: AppSpacing.x2l),
        KeyValueRow(
          'Net pay',
          CurrencyFormatter.ugx(run.netPayUgx.toDouble()),
          bold: true,
        ),
        KeyValueRow('Staff on payroll', '${run.staffCount}', dense: true),
      ],
    ),
  );

  Widget _deadline(
    PayrollRun run,
    PayrollRemittance? paye,
    PayrollRemittance? nssf,
  ) {
    final date = paye?.dueDate ?? nssf?.dueDate ?? run.submissionDeadline;
    if (date == null) return const SizedBox.shrink();
    final days = date.difference(DateTime.now()).inDays;
    final urgent = days <= 3;
    final color = urgent
        ? AppColors.danger(context)
        : AppColors.textPrimary(context);
    return InkWell(
      onTap: () => _toast('Open PAYE and NSSF remittance tasks below.'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: urgent
              ? AppColors.dangerSurface(context)
              : AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: urgent
                ? AppColors.danger(context)
                : AppColors.border(context),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.event_rounded, color: color),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payroll submission deadline: ${DateFormatter.format(date)}',
                    style: TextStyle(fontWeight: FontWeight.w700, color: color),
                  ),
                  Text(
                    days < 0
                        ? '${-days} days overdue'
                        : days == 0
                        ? 'Due today'
                        : '$days days remaining',
                    style: TextStyle(color: color),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(PayrollRemittance? paye, PayrollRemittance? nssf) =>
      SectionCard(
        title: 'COMPLIANCE STATUS',
        child: Column(
          children: [
            _compliance('PAYE', paye),
            const SizedBox(height: AppSpacing.s),
            _compliance('NSSF', nssf),
          ],
        ),
      );
  Widget _compliance(String label, PayrollRemittance? remittance) {
    final verified = remittance?.isVerified == true;
    final color = verified
        ? AppColors.success(context)
        : AppColors.danger(context);
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const Spacer(),
        Text(
          verified
              ? 'Compliant'
              : remittance == null
              ? 'Not submitted'
              : _pretty(remittance.status),
          style: TextStyle(fontWeight: FontWeight.w700, color: color),
        ),
        const SizedBox(width: 6),
        Icon(
          verified
              ? Icons.check_circle_outline_rounded
              : Icons.error_outline_rounded,
          size: 18,
          color: color,
        ),
      ],
    );
  }

  Widget _reviewCard(PayrollRun run, bool desktop) => SectionCard(
    title: 'PAYROLL REVIEW',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Immutable server snapshot • ${run.lines.length} staff entries',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        const SizedBox(height: AppSpacing.m),
        if (run.lines.isEmpty)
          Text(
            'Staff-by-staff entries are available from the authorised preparation snapshot.',
            style: TextStyle(color: AppColors.textMuted(context)),
          )
        else
          SizedBox(
            height: desktop ? 190 : 130,
            child: ListView.separated(
              itemCount: run.lines.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => ListTile(
                dense: true,
                title: Text(run.lines[i].label),
                trailing: Text(
                  CurrencyFormatter.ugx(run.lines[i].amountUgx.toDouble()),
                ),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _remittanceCard(
    PayrollRun run,
    PayrollRemittance? paye,
    PayrollRemittance? nssf,
  ) => SectionCard(
    title: 'REMITTANCE OBLIGATIONS',
    child: Column(
      children: [
        _remittanceRow('PAYE', run.payeUgx, paye),
        const Divider(),
        _remittanceRow('NSSF', run.nssfEmployerUgx + run.nssfEmployeeUgx, nssf),
      ],
    ),
  );
  Widget _remittanceRow(
    String name,
    int amount,
    PayrollRemittance? row,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
    subtitle: Text(
      row == null
          ? 'Awaiting authorised submission'
          : '${_pretty(row.status)}${row.reference.isEmpty ? '' : ' • ${row.reference}'}${row.verifierName == null ? '' : ' • verified by ${row.verifierName}'}',
    ),
    trailing: Text(
      CurrencyFormatter.ugx(amount.toDouble()),
      style: const TextStyle(fontWeight: FontWeight.w700),
    ),
  );

  String _actionLabel(PayrollRun run, List<String> roles) {
    if (run.status == 'draft' || run.status == 'rejected')
      return 'Submit for approval';
    if (run.status == 'reviewed' &&
        roles.any(
          (r) => ['headTeacher', 'director', 'schoolAdmin'].contains(r),
        ))
      return 'Approve payroll';
    if (run.status == 'approved') return 'Finalise payment';
    return _pretty(run.status);
  }

  Future<void> _primaryAction(
    String schoolId,
    PayrollRun run,
    List<String> roles,
  ) async {
    if (run.status == 'draft' || run.status == 'rejected')
      return _call('submitPayrollForApproval', {
        'schoolId': schoolId,
        'runId': run.id,
      });
    if (run.status == 'reviewed')
      return _call('decidePayrollApproval', {
        'schoolId': schoolId,
        'runId': run.id,
        'decision': 'approve',
      });
    if (run.status == 'approved') {
      return _finalisePayment(schoolId, run);
    }
  }

  /// Finalise an approved payroll run's payment (audit area 4). Requires a
  /// cash/bank account with enough balance for the net pay and a payment
  /// reference; calls the existing `finalisePayrollPayment` callable, which
  /// locks the run.
  Future<void> _finalisePayment(String schoolId, PayrollRun run) async {
    final accounts = await sl<BursarOpsReadRepository>()
        .watchBankAccounts(schoolId)
        .first;
    final payable = accounts
        .where((a) => a.kind == 'bank' || a.kind == 'cash')
        .toList();
    if (!mounted) return;
    if (payable.isEmpty) {
      _toast('No cash or bank account to pay from.');
      return;
    }
    final reference = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Finalise payroll payment',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(sheetContext),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Net pay ${CurrencyFormatter.ugx(run.netPayUgx.toDouble())} · '
                'once finalised the run is locked.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted(sheetContext),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: reference,
                decoration: const InputDecoration(
                  labelText: 'Bank/cash payment reference *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    final navigator = Navigator.of(sheetContext);
                    _call('finalisePayrollPayment', {
                      'schoolId': schoolId,
                      'runId': run.id,
                      'reference': reference.text.trim(),
                    }).then((_) {
                      if (navigator.canPop()) navigator.pop();
                    });
                  },
                  child: const Text('Finalise & lock'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _pretty(String value) => value.isEmpty
      ? 'Draft'
      : '${value[0].toUpperCase()}${value.substring(1).replaceAll('_', ' ')}';
}
