import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'expenditure_screen.dart';
import 'budget_management_screen.dart';
import 'fee_configuration_screen.dart';
import 'financial_reports_screen.dart';
import 'student_eligibility_screen.dart';
import 'package:school_pulse/features/hr/presentation/screens/payroll_management_screen.dart';

class _MoreItem {
  final IconData icon;
  final String label;
  final Color color;
  final WidgetBuilder builder;

  const _MoreItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.builder,
  });
}

/// Bursar More tab — Finance Operations center. Grid of core finance ops
/// plus a list of secondary items, routed to existing real finance screens.
class BursarMoreScreen extends StatelessWidget {
  const BursarMoreScreen({super.key});

  static final _operations = [
    _MoreItem(
      icon: Icons.request_page_rounded,
      label: 'Expenditure\nRequests',
      color: Colors.orange,
      builder: (_) => const ExpenditureScreen(),
    ),
    _MoreItem(
      icon: Icons.fact_check_rounded,
      label: 'Approvals',
      color: Colors.deepPurple,
      builder: (_) => const ExpenditureScreen(),
    ),
    _MoreItem(
      icon: Icons.pie_chart_rounded,
      label: 'Budget\nManagement',
      color: Colors.blue,
      builder: (_) => const BudgetManagementScreen(),
    ),
    _MoreItem(
      icon: Icons.settings_applications_rounded,
      label: 'Fee\nStructures',
      color: Colors.teal,
      builder: (_) => const FeeConfigurationScreen(),
    ),
    _MoreItem(
      icon: Icons.verified_user_rounded,
      label: 'Eligibility\nRules',
      color: Colors.green,
      builder: (_) => const StudentEligibilityScreen(),
    ),
    _MoreItem(
      icon: Icons.payments_rounded,
      label: 'Payroll',
      color: Colors.indigo,
      builder: (_) => const PayrollManagementScreen(),
    ),
  ];

  static final _other = [
    _MoreItem(
      icon: Icons.assessment_rounded,
      label: 'Financial Reports',
      color: Colors.purple,
      builder: (_) => const FinancialReportsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background(context),
            elevation: 0,
            title: const Text(
              'More',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.m,
              AppSpacing.l,
              AppSpacing.xl,
            ),
            sliver: SliverList.list(
              children: [
                _SectionLabel(title: 'Finance Operations'),
                const SizedBox(height: AppSpacing.s),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.s,
                  mainAxisSpacing: AppSpacing.s,
                  childAspectRatio: 0.95,
                  children: _operations
                      .map((item) => _GridTile(item: item))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.xl),
                _SectionLabel(title: 'Other'),
                const SizedBox(height: AppSpacing.s),
                for (final item in _other) _MoreRow(item: item),
                const SizedBox(height: AppSpacing.l),
                _LogoutRow(onTap: () => _confirmLogout(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
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
              'Logout',
              style: TextStyle(color: AppColors.danger(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary(context),
      ),
    );
  }
}

class _GridTile extends StatelessWidget {
  final _MoreItem item;
  const _GridTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.large,
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute(builder: item.builder)),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  final _MoreItem item;
  const _MoreRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute(builder: item.builder)),
      borderRadius: AppRadius.large,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.m,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: AppRadius.medium,
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutRow extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.large,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.l,
        ),
        decoration: BoxDecoration(
          color: AppColors.danger(context).withValues(alpha: 0.08),
          borderRadius: AppRadius.large,
          border: Border.all(
            color: AppColors.danger(context).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.danger(context)),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
