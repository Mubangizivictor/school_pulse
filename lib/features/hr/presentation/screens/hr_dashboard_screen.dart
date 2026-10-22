import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';

import 'package:school_pulse/features/hr/presentation/screens/leave_management_screen.dart';
import 'package:school_pulse/features/hr/presentation/screens/staff_appraisals_screen.dart';
import 'package:school_pulse/features/hr/presentation/screens/payroll_management_screen.dart';
import 'package:school_pulse/features/shared/staff_dashboard/staff_dashboard_widgets.dart';

class HRDashboardScreen extends StatelessWidget {
  const HRDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: staffDashboardAppBar(context, roleLabel: 'Human Resources'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(context),
              const SizedBox(height: 15),
              _buildMainGrid(context, isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return StaffHeroSummaryCard(
      greetingNameFallback: 'there',
      kpis: [
        StaffKpiData(
          title: 'Total Staff',
          valueText: '84',
          subtitle: 'Employed',
          icon: Icons.people,
          color: Colors.black,
        ),
        StaffKpiData(
          title: 'Recruits',
          valueText: '12',
          subtitle: 'In pipeline',
          icon: Icons.person_add,
          color: Colors.black,
        ),
        StaffKpiData(
          title: 'On Leave',
          valueText: '5',
          subtitle: 'Currently away',
          icon: Icons.time_to_leave,
          color: Colors.black,
        ),
        StaffKpiData(
          title: 'Appraisals',
          valueText: '8',
          subtitle: 'Pending review',
          icon: Icons.assessment,
          color: Colors.black,
        ),
      ],
    );
  }

  Widget _buildMainGrid(BuildContext context, bool isDesktop) {
    return GridView.count(
      crossAxisCount: isDesktop ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _MenuTile(
          icon: Icons.assignment_ind,
          label: 'Staff Recruitment',
          subtitle: 'Manage job openings & interviews',
          color: Colors.black,
          onTap: () {},
        ),
        _MenuTile(
          icon: Icons.history_edu,
          label: 'Contracts',
          subtitle: 'Staff agreements & terms',
          color: Colors.black,
          onTap: () {},
        ),
        _MenuTile(
          icon: Icons.event_note,
          label: 'Leave Management',
          subtitle: 'Requests, approvals & balances',
          color: Colors.black,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LeaveManagementScreen(),
            ),
          ),
        ),
        _MenuTile(
          icon: Icons.trending_up,
          label: 'Appraisals',
          subtitle: 'Performance reviews & scores',
          color: Colors.black,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StaffAppraisalsScreen(),
            ),
          ),
        ),
        _MenuTile(
          icon: Icons.payments,
          label: 'Payroll (PAYE/NSSF)',
          subtitle: 'Uganda tax & social security',
          color: Colors.black,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PayrollManagementScreen(),
            ),
          ),
        ),
        _MenuTile(
          icon: Icons.warning_amber,
          label: 'Staff Warnings',
          subtitle: 'Disciplinary records',
          color: Colors.black,
          onTap: () {},
        ),
        _MenuTile(
          icon: Icons.folder_shared,
          label: 'Staff Documents',
          subtitle: 'IDs, certificates & forms',
          color: Colors.black,
          onTap: () {},
        ),
        _MenuTile(
          icon: Icons.exit_to_app,
          label: 'Exit Management',
          subtitle: 'Resignations & terminations',
          color: Colors.black,
          onTap: () {},
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.outline,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
