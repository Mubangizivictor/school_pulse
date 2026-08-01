import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class NewMessageTypeScreen extends StatelessWidget {
  const NewMessageTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Message'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          _TypeTile(
            icon: Icons.person_outline,
            title: 'New Chat',
            subtitle: 'Start a one-on-one conversation',
            color: Colors.blue,
            onTap: () => context.push('/messages/new/contacts'),
          ),
          _TypeTile(
            icon: Icons.group_outlined,
            title: 'New Group',
            subtitle: 'Create a group conversation',
            color: Colors.indigo,
            onTap: () => context.push('/messages/new/group'),
          ),
          _TypeTile(
            icon: Icons.campaign_outlined,
            title: 'New Broadcast',
            subtitle: 'Send a message to many',
            color: Colors.blueAccent,
            onTap: () {},
          ),
          _TypeTile(
            icon: Icons.grid_view_outlined,
            title: 'New Channel',
            subtitle: 'Create an announcement channel',
            color: Colors.green,
            onTap: () {},
          ),
          _TypeTile(
            icon: Icons.event_outlined,
            title: 'New Event Conversation',
            subtitle: 'Create a conversation for an event',
            color: Colors.orange,
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.l),
          Text('Frequently Contacted', style: AppTypography.labelLarge.copyWith(color: AppColors.textMuted(context))),
          const SizedBox(height: AppSpacing.m),
          _ContactTile(name: 'Mr. Kofi Mensah', role: 'Science Teacher', avatarUrl: null),
          _ContactTile(name: 'Mrs. Amina', role: 'Class Teacher - P7', avatarUrl: null),
          _ContactTile(name: 'Finance Office', role: 'School Department', avatarUrl: null),
        ],
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _TypeTile({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: AppTypography.titleMedium),
      subtitle: Text(subtitle, style: AppTypography.bodySmall),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final String name;
  final String role;
  final String? avatarUrl;

  const _ContactTile({required this.name, required this.role, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(name),
      subtitle: Text(role),
      onTap: () {},
    );
  }
}
