import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StudentAppBar(title: 'More'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuSection(
            context,
            'Services',
            [
              _MenuTile(
                icon: Icons.calendar_month_outlined,
                title: 'School Calendar',
                onTap: () => context.push('/parent/calendar'),
              ),
              _MenuTile(
                icon: Icons.health_and_safety_outlined,
                title: 'Health',
                onTap: () => context.push('/parent/health'),
              ),
              _MenuTile(
                icon: Icons.library_books_outlined,
                title: 'Library',
                onTap: () => context.push('/parent/library'),
              ),
              _MenuTile(
                icon: Icons.gavel_outlined,
                title: 'Discipline',
                onTap: () => context.push('/parent/discipline'),
              ),
              _MenuTile(
                icon: Icons.directions_bus_outlined,
                title: 'Transport',
                onTap: () => context.push('/parent/transport'),
              ),
              _MenuTile(
                icon: Icons.bed_outlined,
                title: 'Boarding',
                onTap: () => context.push('/parent/boarding'),
              ),
              _MenuTile(
                icon: Icons.security_outlined,
                title: 'Security & Safety',
                onTap: () => context.push('/parent/security'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildMenuSection(
            context,
            'Account',
            [
              _MenuTile(
                icon: Icons.person_outline,
                title: 'Profile',
                onTap: () => context.push('/parent/profile'),
              ),
              _MenuTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () => context.push('/parent/notifications'),
              ),
              _MenuTile(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () => context.push('/parent/profile'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildMenuSection(
            context,
            'Support',
            [
              _MenuTile(
                icon: Icons.help_outline,
                title: 'Help Center',
                onTap: () => _showHelpDialog(context),
              ),
              _MenuTile(
                icon: Icons.info_outline,
                title: 'About School Pulse',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'School Pulse',
                  applicationVersion: '1.0.0',
                  applicationLegalese:
                      'A school management platform for Uganda.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SecondaryButton(
            label: 'Logout',
            onPressed: () {
              context.read<AuthBloc>().add(LogoutPressed());
              context.go('/welcome');
            },
            icon: Icons.logout,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help Center'),
        content: const Text(
          'For help with your account or the app, please contact your '
          'school\'s administration office. They can reset access codes, '
          'update your contact details, and answer questions about fees, '
          'academics, and other records shown in this app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: children.asMap().entries.map((entry) {
              final idx = entry.key;
              final child = entry.value;
              return Column(
                children: [
                  child,
                  if (idx < children.length - 1)
                    const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
