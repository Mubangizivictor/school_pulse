import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/director/presentation/widgets/director_drawer.dart';
import 'package:school_pulse/features/announcements/presentation/screens/announcement_editor_screen.dart';
import 'package:school_pulse/features/announcements/presentation/screens/announcements_screen.dart';

/// "Communication" screen from the reference: action tiles for sending
/// announcements/messages and viewing the announcement board.
///
/// Wired to the existing Announcements module (editor + board) and the
/// existing Messages route, which already have real backends - only
/// "Message Templates" has no backing feature yet and stays a labeled TODO
/// shell rather than a route to nowhere.
class CommunicationScreen extends StatelessWidget {
  const CommunicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DirectorDrawer(),
      appBar: AppBar(title: const Text('Communication')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.l,
          AppSpacing.xl,
          AppSpacing.x3l,
        ),
        children: [
          _ActionTile(
            icon: Icons.campaign_outlined,
            color: Colors.blue,
            title: 'Send Announcement',
            subtitle: 'To entire school community',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AnnouncementEditorScreen(),
              ),
            ),
          ),
          _ActionTile(
            icon: Icons.chat_bubble_outline,
            color: Colors.orange,
            title: 'Send Message',
            subtitle: 'To staff, parents or students',
            onTap: () => context.push('/staff/messages'),
          ),
          _ActionTile(
            icon: Icons.dashboard_customize_outlined,
            color: Colors.teal,
            title: 'Announcement Board',
            subtitle: 'View all announcements',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
            ),
          ),
          _ActionTile(
            icon: Icons.description_outlined,
            color: Colors.deepOrange,
            title: 'Message Templates',
            subtitle: 'Quick message templates',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Message templates are coming soon.'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: AppCard(
      onTap: onTap,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    ),
  );
}
