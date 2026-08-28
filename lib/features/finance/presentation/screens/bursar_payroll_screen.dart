import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils.dart'
    show CurrencyFormatter, DateFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/data/repositories/bursar_ops_read_repository.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

/// Payroll & Compliance — read-only summary matching the reference: gross
/// pay, PAYE (withholding tax), NSSF (employer), net pay, a submission
/// deadline banner (red when close), and PAYE / NSSF compliance status.
/// Figures come from a seeded `payroll_runs` doc; statutory amounts are
/// taken as stored, never recomputed here.
class BursarPayrollScreen extends StatelessWidget {
  const BursarPayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';
    final repo = sl<BursarOpsReadRepository>();

    return FinanceScaffold(
      title: 'Payroll & Compliance',
      bottomBar: PrimaryActionBar(
        label: 'Review payroll',
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payroll review is coming soon.')),
        ),
      ),
      body: StreamBuilder<PayrollRun?>(
        stream: repo.watchLatestPayrollRun(schoolId),
        builder: (context, snap) {
          if (!snap.hasData && snap.connectionState != ConnectionState.active) {
            return FinanceStates.loading();
          }
          final run = snap.data;
          if (run == null) {
            return FinanceStates.empty(
              context,
              icon: Icons.badge_outlined,
              title: 'No payroll run yet',
              message:
                  'Once a payroll period is prepared it will show here '
                  'with its compliance status.',
            );
          }
          final deadline = run.submissionDeadline;
          final daysLeft = deadline?.difference(DateTime.now()).inDays;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              SectionCard(
                title: 'PAYROLL SUMMARY — ${run.periodLabel.toUpperCase()}',
                child: Column(
                  children: [
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
                    if (run.nssfEmployeeUgx > 0)
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
                    if (run.staffCount > 0)
                      KeyValueRow(
                        'Staff on payroll',
                        '${run.staffCount}',
                        dense: true,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              if (deadline != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSurface(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.danger(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_rounded,
                        size: 18,
                        color: AppColors.danger(context),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payroll submission deadline: '
                              '${DateFormatter.format(deadline)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.danger(context),
                              ),
                            ),
                            if (daysLeft != null)
                              Text(
                                daysLeft <= 0
                                    ? 'Due today'
                                    : '$daysLeft day${daysLeft == 1 ? '' : 's'} remaining',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.danger(context),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.danger(context),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.l),
              SectionCard(
                title: 'COMPLIANCE STATUS',
                child: Column(
                  children: [
                    _ComplianceRow(label: 'PAYE', compliant: run.payeCompliant),
                    const SizedBox(height: AppSpacing.s),
                    _ComplianceRow(label: 'NSSF', compliant: run.nssfCompliant),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ComplianceRow extends StatelessWidget {
  final String label;
  final bool compliant;
  const _ComplianceRow({required this.label, required this.compliant});

  @override
  Widget build(BuildContext context) {
    final color = compliant
        ? AppColors.success(context)
        : AppColors.danger(context);
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
        const Spacer(),
        Text(
          compliant ? 'Compliant' : 'Action needed',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          compliant
              ? Icons.check_circle_outline_rounded
              : Icons.error_outline_rounded,
          size: 16,
          color: color,
        ),
      ],
    );
  }
}
