import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/messaging_context.dart';

class NewMessageTypeScreen extends StatelessWidget {
  const NewMessageTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('New Message', style: AppTypography.titleLarge),
      ),
      body: MessagingUserBuilder(
        builder: (context, user) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          children: [
            const SizedBox(height: AppSpacing.s),
            _TypeTile(
              icon: Icons.person_add_outlined,
              title: 'New Chat',
              subtitle: 'Start a one-on-one conversation',
              color: AppColors.electricBlue,
              onTap: () => context.push('/messages/new/contacts'),
            ),
            _TypeTile(
              icon: Icons.group_add_outlined,
              title: 'New Group',
              subtitle: 'Create a group conversation',
              color: AppColors.emeraldGreen,
              onTap: () => context.push('/messages/new/group'),
            ),
            _TypeTile(
              icon: Icons.campaign_outlined,
              title: 'New Broadcast',
              subtitle: 'Send a message to many recipients',
              color: AppColors.goldenYellow,
              onTap: () => context.push('/messages/new/broadcast'),
            ),
            _TypeTile(
              icon: Icons.grid_view_outlined,
              title: 'New Channel',
              subtitle: 'Create an announcement channel',
              color: AppColors.brightCyan,
              onTap: () => context.push('/messages/new/channel'),
            ),
            const SizedBox(height: AppSpacing.l),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.s),
              child: Text(
                'FREQUENTLY CONTACTED',
                style:
                    AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context), letterSpacing: 1.2),
              ),
            ),
            FutureBuilder<List<MessageContact>>(
              future: context.messages.getRecentContacts(user.id, limit: 4),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.l),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final contacts = snapshot.data!;
                if (contacts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                    child: Text(
                      'People you message will show up here.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted(context)),
                    ),
                  );
                }
                return Column(
                  children: contacts
                      .map((contact) => _ContactTile(
                            contact: contact,
                            onTap: () => _openChat(context, user, contact),
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: AppSpacing.x3l),
          ],
        ),
      ),
    );
  }

  Future<void> _openChat(BuildContext context, UserEntity user, MessageContact contact) async {
    try {
      final id = await context.messages.startDirectConversation(me: user, contact: contact);
      if (!context.mounted) return;
      context.push('/messages/chat/$id');
    } catch (e) {
      if (!context.mounted) return;
      context.showMessagingSnack('Could not open the chat: $e');
    }
  }
}

class _TypeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _TypeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted(context)),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.textMuted(context), size: 18),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final MessageContact contact;
  final VoidCallback onTap;

  const _ContactTile({required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final role = UserRole.values.where((r) => r.name == contact.role);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: isDark ? AppColors.surfaceContainerHigh(context) : Colors.grey[200],
        child: Text(
          contact.initials,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.deepNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        contact.name,
        style: AppTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        role.isEmpty ? contact.role : UserRoleDisplay.name(role.first),
        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted(context)),
      ),
    );
  }
}
