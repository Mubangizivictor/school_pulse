import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/hr/presentation/screens/payroll_management_screen.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';
import 'budget_management_screen.dart';
import 'expenditure_screen.dart';
import 'financial_reports_screen.dart';
import 'student_eligibility_screen.dart';

/// Bursar "More" tab (bottom-nav slot 4).
///
/// The reference "More" screenshot lists: Budget, Expenses, Suppliers,
/// Petty Cash, Payroll, Tax & NSSF, Reports, Audit trail. Items whose
/// backend lands in a later phase (Suppliers, Petty Cash, Tax & NSSF, Audit
/// trail) route to the shared "coming soon" state so nothing here shows
/// fabricated data.
class BursarMoreScreen extends StatelessWidget {
  const BursarMoreScreen({super.key});

  List<_MoreItem> _items(BuildContext context) => [
    _MoreItem(
      icon: Icons.pie_chart_outline_rounded,
      label: 'Budget',
      builder: (_) => const BudgetManagementScreen(),
    ),
    _MoreItem(
      icon: Icons.request_page_outlined,
      label: 'Expenses',
      builder: (_) => const ExpenditureScreen(),
    ),
    _MoreItem(
      icon: Icons.local_shipping_outlined,
      label: 'Suppliers',
      builder: (_) => const _ComingSoonScreen(
        title: 'Suppliers',
        detail:
            'Supplier profiles, invoices and payable balances are '
            'being built.',
      ),
    ),
    _MoreItem(
      icon: Icons.savings_outlined,
      label: 'Petty Cash',
      builder: (_) => const _ComingSoonScreen(
        title: 'Petty Cash',
        detail:
            'Float, cash-in/out ledger, vouchers and replenishment '
            'are being built.',
      ),
    ),
    _MoreItem(
      icon: Icons.badge_outlined,
      label: 'Payroll',
      builder: (_) => const PayrollManagementScreen(),
    ),
    _MoreItem(
      icon: Icons.receipt_long_outlined,
      label: 'Tax & NSSF',
      builder: (_) => const _ComingSoonScreen(
        title: 'Tax & NSSF',
        detail:
            'PAYE and NSSF compliance summaries and submission '
            'reminders are being built.',
      ),
    ),
    _MoreItem(
      icon: Icons.assessment_outlined,
      label: 'Reports',
      builder: (_) => const FinancialReportsScreen(),
    ),
    _MoreItem(
      icon: Icons.fact_check_outlined,
      label: 'Audit trail',
      builder: (_) => const _ComingSoonScreen(
        title: 'Audit trail',
        detail:
            'A read-only viewer over finance_audit_events is being '
            'built.',
      ),
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

class _ComingSoonScreen extends StatelessWidget {
  final String title;
  final String detail;

  const _ComingSoonScreen({required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    return FinanceScaffold(
      title: title,
      body: FinanceStates.comingSoon(context, feature: title, detail: detail),
    );
  }
}
