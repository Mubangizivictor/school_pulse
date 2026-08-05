import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/messaging_context.dart';
import 'package:share_plus/share_plus.dart';

/// Reached from a 1:1 chat, so [contactId] is the *conversation* id - the
/// person is whichever participant isn't the signed-in user. Falls back to
/// treating the id as a directory entry when it isn't a conversation.
class ContactProfileScreen extends StatelessWidget {
  final String contactId;
  const ContactProfileScreen({super.key, required this.contactId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.textPrimary(context)),
            onPressed: () => context.showMessagingSnack(
              'No further options for this contact',
            ),
          ),
        ],
      ),
      body: MessagingUserBuilder(
        builder: (context, user) => FutureBuilder<_ProfileData?>(
          future: _resolve(context, user),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data;
            if (data == null) {
              return Center(
                child: Text(
                  'Contact not found',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
              );
            }
            return _buildBody(context, user, data);
          },
        ),
      ),
    );
  }

  Future<_ProfileData?> _resolve(BuildContext context, UserEntity user) async {
    final conversation = await context.messages
        .watchConversation(contactId, user.id)
        .first;
    if (conversation != null && conversation.type == ChatType.direct) {
      final others = conversation.participants.where((p) => p.id != user.id);
      if (others.isNotEmpty) {
        final other = others.first;
        return _ProfileData(
          contact: MessageContact(
            id: other.id,
            name: other.name,
            role: other.role,
          ),
          conversationId: conversation.id,
        );
      }
    }
    if (!context.mounted) return null;

    final contact = await context.messages.getContact(contactId);
    return contact == null
        ? null
        : _ProfileData(contact: contact, conversationId: null);
  }

  Widget _buildBody(BuildContext context, UserEntity user, _ProfileData data) {
    final contact = data.contact;
    final role = UserRole.values.where((r) => r.name == contact.role);
    final roleLabel = role.isEmpty
        ? contact.role
        : UserRoleDisplay.name(role.first);

    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      contact.initials,
                      style: const TextStyle(
                        fontSize: 32,
                        color: AppColors.electricBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Text(contact.name, style: AppTypography.headlineSmall),
                Text(
                  '$roleLabel • ${user.schoolName ?? 'School'}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.message_outlined,
                  label: 'Message',
                  onTap: () => _openChat(context, user, data),
                ),
                _ActionButton(
                  icon: Icons.phone_outlined,
                  label: 'Call',
                  onTap: () => context.showMessagingSnack(
                    'Phone numbers are not shared through the school directory',
                  ),
                ),
                _ActionButton(
                  icon: Icons.videocam_outlined,
                  label: 'Video',
                  onTap: () => context.showMessagingSnack(
                    'Video calls are not available yet',
                  ),
                ),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () => Share.share('${contact.name} — $roleLabel'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(context, [
            _buildDetailItem(context, 'Role', roleLabel, Icons.badge_outlined),
            _buildDetailItem(
              context,
              'School',
              user.schoolName ?? user.schoolId,
              Icons.business_outlined,
            ),
          ]),
          _buildSection(context, [
            _buildDetailItem(
              context,
              'Groups in Common',
              '—',
              Icons.group_outlined,
              onTap: () => _showGroupsInCommon(context, user, contact),
            ),
            _buildDetailItem(
              context,
              'Starred Messages',
              'View all',
              Icons.star_border_outlined,
              onTap: () => context.push('/messages/starred'),
            ),
          ]),
          const SizedBox(height: AppSpacing.l),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Column(
              children: [
                _buildActionRow(
                  Icons.block,
                  'Block ${contact.name}',
                  Colors.red,
                  () => _block(context, user, data),
                ),
                _buildActionRow(
                  Icons.report_gmailerrorred,
                  'Report Contact',
                  Colors.red,
                  () => _report(context, user, data),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x3l),
        ],
      ),
    );
  }

  Future<void> _openChat(
    BuildContext context,
    UserEntity user,
    _ProfileData data,
  ) async {
    final id =
        data.conversationId ??
        await context.messages.startDirectConversation(
          me: user,
          contact: data.contact,
        );
    if (!context.mounted) return;
    context.go('/messages/chat/$id');
  }

  Future<void> _showGroupsInCommon(
    BuildContext context,
    UserEntity user,
    MessageContact contact,
  ) async {
    final conversations = await context.messages
        .watchConversations(user.id)
        .first;
    if (!context.mounted) return;

    final shared = conversations
        .where(
          (c) =>
              c.type != ChatType.direct &&
              c.participants.any((p) => p.id == contact.id),
        )
        .map((c) => c.title)
        .toList();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Groups in common'),
        content: Text(shared.isEmpty ? 'None yet.' : shared.join('\n')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Only meaningful once there is a conversation to point staff at - there
  /// is nothing to review about a directory entry on its own.
  Future<void> _report(
    BuildContext context,
    UserEntity user,
    _ProfileData data,
  ) async {
    final conversationId = data.conversationId;
    if (conversationId == null) {
      context.showMessagingSnack(
        'Open a chat with this person first, then report it',
      );
      return;
    }

    final reasonController = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Report ${data.contact.name}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('A school administrator will review this conversation.'),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'What is the problem?',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Report', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (submitted != true || !context.mounted) return;

    await context.messages.reportConversation(
      conversationId: conversationId,
      reporter: user,
      reason: reasonController.text.trim(),
      reportedUserId: data.contact.id,
    );
    if (!context.mounted) return;
    context.showMessagingSnack('Reported to the school administrator');
  }

  Future<void> _block(
    BuildContext context,
    UserEntity user,
    _ProfileData data,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Block ${data.contact.name}?'),
        content: const Text(
          'The chat will be removed from your inbox and filed as spam. School staff can still reach you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final conversationId = data.conversationId;
    if (conversationId != null) {
      await context.messages.markSpam(conversationId, user.id);
      if (!context.mounted) return;
      await context.messages.leaveConversation(conversationId, user.id);
    }
    if (!context.mounted) return;
    context.go('/messages');
  }

  Widget _buildSection(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.electricBlue, size: 20),
      title: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textMuted(context),
        ),
      ),
      subtitle: Text(
        value,
        style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, size: 20)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildActionRow(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}

class _ProfileData {
  final MessageContact contact;
  final String? conversationId;

  const _ProfileData({required this.contact, this.conversationId});
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.electricBlue),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.electricBlue),
          ),
        ],
      ),
    );
  }
}
