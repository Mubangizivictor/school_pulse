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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(context, isDesktop),
                  const SizedBox(height: 24),
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
        const NotificationBellButton(),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.logout),
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
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _StatCard(title: 'Total Staff', value: '84', icon: Icons.people, color: Colors.blue, width: isDesktop ? 200 : (constraints.maxWidth - 16) / 2),
          _StatCard(title: 'Active Recruits', value: '12', icon: Icons.person_add, color: Colors.green, width: isDesktop ? 200 : (constraints.maxWidth - 16) / 2),
          _StatCard(title: 'Leave Requests', value: '5', icon: Icons.time_to_leave, color: Colors.orange, width: isDesktop ? 200 : (constraints.maxWidth - 16) / 2),
          _StatCard(title: 'Pending Appraisals', value: '8', icon: Icons.assessment, color: Colors.purple, width: isDesktop ? 200 : (constraints.maxWidth - 16) / 2),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double width;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
        ],
      ),
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
