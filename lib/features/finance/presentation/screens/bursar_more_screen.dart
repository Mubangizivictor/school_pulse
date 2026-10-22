import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';
import 'budget_details_screen.dart';
import 'expenditure_screen.dart';
import 'payment_voucher_screen.dart';
import 'bursar_suppliers_screen.dart';
import 'bursar_petty_cash_screen.dart';
import 'bursar_payroll_screen.dart';
import 'bursar_audit_trail_screen.dart';
import 'financial_reports_screen.dart';
import 'student_eligibility_screen.dart';
import 'bursar_report_release_screen.dart';
import 'clearance_policy_editor_screen.dart';
import 'financial_entitlements_screen.dart';

/// Bursar "More" tab (bottom-nav slot 4).
///
/// The reference "More" screenshot: Budget, Expenses, Suppliers, Petty Cash,
/// Payroll, Tax & NSSF, Reports, Audit trail. Every item now routes to a
/// real screen (read-only where the write flow is still being built).
class BursarMoreScreen extends StatelessWidget {
  const BursarMoreScreen({super.key});

  List<_MoreItem> _items(BuildContext context) => [
    _MoreItem(
      icon: Icons.verified_user_outlined,
      label: 'Financial entitlements',
      builder: (_) => const FinancialEntitlementsScreen(),
    ),
    _MoreItem(
      icon: Icons.pie_chart_outline_rounded,
      label: 'Budget',
      builder: (_) => const BudgetDetailsScreen(),
    ),
    _MoreItem(
      icon: Icons.request_page_outlined,
      label: 'Expenses',
      builder: (_) => const ExpenditureScreen(),
    ),
    _MoreItem(
      icon: Icons.description_outlined,
      label: 'Payment vouchers',
      builder: (_) => const PaymentVouchersListScreen(),
    ),
    _MoreItem(
      icon: Icons.local_shipping_outlined,
      label: 'Suppliers',
      builder: (_) => const BursarSuppliersScreen(),
    ),
    _MoreItem(
      icon: Icons.savings_outlined,
      label: 'Petty Cash',
      builder: (_) => const BursarPettyCashScreen(),
    ),
    _MoreItem(
      icon: Icons.badge_outlined,
      label: 'Payroll',
      builder: (_) => const BursarPayrollScreen(),
    ),
    _MoreItem(
      icon: Icons.receipt_long_outlined,
      label: 'Tax & NSSF',
      builder: (_) => const BursarPayrollScreen(),
    ),
    _MoreItem(
      icon: Icons.assessment_outlined,
      label: 'Reports',
      builder: (_) => const FinancialReportsScreen(),
    ),
    _MoreItem(
      icon: Icons.fact_check_outlined,
      label: 'Audit trail',
      builder: (_) => const BursarAuditTrailScreen(),
    ),
    _MoreItem(
      icon: Icons.lock_open_outlined,
      label: 'Report releases',
      builder: (_) => const BursarReportReleaseScreen(),
    ),
    _MoreItem(
      icon: Icons.rule_folder_outlined,
      label: 'Clearance policy',
      builder: (_) => const ClearancePolicyEditorScreen(),
    ),
    _MoreItem(
      icon: Icons.verified_user_outlined,
      label: 'Eligibility rules',
      builder: (_) => const StudentEligibilityScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = _items(context);
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: AppSpacing.l,
        title: Text(
          'More',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.m,
            AppSpacing.l,
            AppSpacing.x3l,
          ),
          children: [
            for (final item in items)
              FinanceListRow(
                leadingIcon: item.icon,
                title: item.label,
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: item.builder)),
              ),
            const SizedBox(height: AppSpacing.l),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger(context),
                side: BorderSide(color: AppColors.danger(context)),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout_rounded, size: 16),
              label: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutPressed());
              Navigator.pop(dialogContext);
              context.go('/welcome');
            },
            child: Text(
              'Log out',
              style: TextStyle(color: AppColors.danger(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreItem {
  final IconData icon;
  final String label;
  final WidgetBuilder builder;

  const _MoreItem({
    required this.icon,
    required this.label,
    required this.builder,
  });
}
