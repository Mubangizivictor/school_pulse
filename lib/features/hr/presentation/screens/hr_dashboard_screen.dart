// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/features/hr/presentation/screens/leave_management_screen.dart';
import 'package:school_pulse/features/hr/presentation/screens/staff_appraisals_screen.dart';
import 'package:school_pulse/features/hr/presentation/screens/payroll_management_screen.dart';

class HRDashboardScreen extends StatelessWidget {
  const HRDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isDesktop),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(context, isDesktop),
                  const SizedBox(height: 15),
                  _buildMainGrid(context, isDesktop),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDesktop) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 80,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Human Resources', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
          Text('Staff Management & Recruitment', style: TextStyle(fontSize: 12)),
        ],
      ),
      actions: [
        NotificationBellButton(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          color: Theme.of(context).colorScheme.error,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
          onPressed: () {
            context.read<AuthBloc>().add(LogoutPressed());
            context.go('/welcome');
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, bool isDesktop) {
    return LayoutBuilder(builder: (context, constraints) {
      if (isDesktop) {
        return Row(
          children: [
            Expanded(child: DashboardStatCard(title: 'Total Staff', value: 84, icon: Icons.people, color: Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: DashboardStatCard(title: 'Recruits', value: 12, icon: Icons.person_add, color: Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: DashboardStatCard(title: 'Leave', value: 5, icon: Icons.time_to_leave, color: Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: DashboardStatCard(title: 'Appraisals', value: 8, icon: Icons.assessment, color: Colors.purple)),
          ],
        );
      }

      return Column(
        children: [
          Row(
            children: [
              Expanded(child: DashboardStatCard(title: 'Total Staff', value: 84, icon: Icons.people, color: Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: DashboardStatCard(title: 'Recruits', value: 12, icon: Icons.person_add, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: DashboardStatCard(title: 'Leave', value: 5, icon: Icons.time_to_leave, color: Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: DashboardStatCard(title: 'Appraisals', value: 8, icon: Icons.assessment, color: Colors.purple)),
            ],
          ),
        ],
      );
    });
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
          color: Colors.blue,
          onTap: () {},
        ),
        _MenuTile(
          icon: Icons.history_edu,
          label: 'Contracts',
          subtitle: 'Staff agreements & terms',
          color: Colors.teal,
          onTap: () {},
        ),
        _MenuTile(
          icon: Icons.event_note,
          label: 'Leave Management',
          subtitle: 'Requests, approvals & balances',
          color: Colors.orange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LeaveManagementScreen()),
          ),
        ),
        _MenuTile(
          icon: Icons.trending_up,
          label: 'Appraisals',
          subtitle: 'Performance reviews & scores',
          color: Colors.purple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffAppraisalsScreen()),
          ),
        ),
        _MenuTile(
          icon: Icons.payments,
          label: 'Payroll (PAYE/NSSF)',
          subtitle: 'Uganda tax & social security',
          color: Colors.green,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PayrollManagementScreen()),
          ),
        ),
        _MenuTile(
          icon: Icons.warning_amber,
          label: 'Staff Warnings',
          subtitle: 'Disciplinary records',
          color: Colors.red,
          onTap: () {},
        ),
        _MenuTile(
          icon: Icons.folder_shared,
          label: 'Staff Documents',
          subtitle: 'IDs, certificates & forms',
          color: Colors.indigo,
          onTap: () {},
        ),
        _MenuTile(
          icon: Icons.exit_to_app,
          label: 'Exit Management',
          subtitle: 'Resignations & terminations',
          color: Colors.blueGrey,
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

  const _MenuTile({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

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
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
