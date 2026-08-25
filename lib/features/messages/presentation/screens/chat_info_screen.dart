import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/bloc/conversation_bloc.dart';
import 'package:school_pulse/features/messages/presentation/bloc/messaging_bloc.dart';
import 'package:school_pulse/features/messages/presentation/messaging_context.dart';
import 'package:school_pulse/features/messages/presentation/widgets/action_button.dart';
import 'package:school_pulse/injection_container.dart' as di;

class ChatInfoScreen extends StatelessWidget {
  final String chatId;
  const ChatInfoScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConversationBloc>(
      create: (_) => di.sl<ConversationBloc>(),
      child: _ChatInfoView(chatId: chatId),
    );
  }
}

class _ChatInfoView extends StatelessWidget {
  final String chatId;
  const _ChatInfoView({required this.chatId});

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
            onPressed: () => context.push('/messages/settings'),
          ),
        ],
      ),
      body: MessagingUserBuilder(
        builder: (context, user) {
          context.read<ConversationBloc>().add(
            ConversationOpened(chatId, user),
          );
          return BlocBuilder<ConversationBloc, ConversationState>(
            builder: (context, convoState) {
              final conversation = convoState.conversation;
              if (conversation == null) {
                return Center(
                  child: convoState.conversationMissing
                      ? const Text('Conversation not found')
                      : const SchoolPulseLoader(),
                );
              }
              return _buildBody(context, isDark, user, conversation);
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    bool isDark,
    UserEntity user,
    ChatConversation conversation,
  ) {
    final isGroup = conversation.type != ChatType.direct;
    final amAdmin = conversation.isAdmin(user.id);

    return ListView(
      children: [
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.royalBlue,
                      shape: BoxShape.circle,
                      image: conversation.avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(conversation.avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricBlue,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: conversation.avatarUrl != null
                        ? null
                        : Center(
                            child: Text(
                              _initials(conversation.title),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  if (isGroup && amAdmin)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () => _changeAvatar(context, user, conversation),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.electricBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? AppColors.bgDark : Colors.white,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              Text(conversation.title, style: AppTypography.headlineSmall),
              const SizedBox(height: 4),
              Text(
                isGroup
                    ? '${_typeLabel(conversation.type)} • ${conversation.participants.length} members'
                    : _roleLabel(
                        _otherParticipant(conversation, user.id)?.role ?? '',
                      ),
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
              ActionButton(
                icon: Icons.add_moderator_outlined,
                label: 'Manage',
                onTap: () => _manage(context, user, conversation, amAdmin),
              ),
              ActionButton(
                icon: Icons.person_add_outlined,
                label: 'Add',
                onTap: () => _addMembers(context, user, conversation, amAdmin),
              ),
              ActionButton(
                icon: Icons.search,
                label: 'Search',
                onTap: () => context.push('/messages/search'),
              ),
              ActionButton(
                icon: conversation.isMuted
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
                label: conversation.isMuted ? 'Unmute' : 'Mute',
                onTap: () => context.messagingBloc.add(
                  ConversationMutedSet(conversation.id, !conversation.isMuted),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildInfoSection(context, [
          if (conversation.description != null &&
              conversation.description!.isNotEmpty)
            _buildInfoTile(
              context,
              Icons.info_outline,
              'Description',
              conversation.description!,
              showChevron: false,
            ),
          _buildInfoTile(
            context,
            Icons.perm_media_outlined,
            'Media, Links & Docs',
            'View all',
            onTap: () => context.push('/messages/chat/$chatId/media'),
          ),
          _buildInfoTile(
            context,
            Icons.star_border,
            'Starred Messages',
            'View all',
            onTap: () => context.push('/messages/starred'),
          ),
        ]),
        _buildInfoSection(context, [
          _buildInfoTile(
            context,
            Icons.notifications_none,
            'Notifications',
            conversation.isMuted ? 'Muted' : 'On',
            onTap: () => context.messagingBloc.add(
              ConversationMutedSet(conversation.id, !conversation.isMuted),
            ),
          ),
          _buildInfoTile(
            context,
            conversation.isArchived
                ? Icons.unarchive_outlined
                : Icons.archive_outlined,
            'Archive',
            conversation.isArchived ? 'Archived' : 'Not archived',
            onTap: () => context.messagingBloc.add(
              ConversationArchivedSet(
                conversation.id,
                !conversation.isArchived,
              ),
            ),
          ),
          if (isGroup)
            _buildInfoTile(
              context,
              Icons.admin_panel_settings_outlined,
              'Who can send messages?',
              conversation.messagePolicy == MessagePolicy.everyone
                  ? 'All Members'
                  : 'Admins Only',
              onTap: amAdmin
                  ? () => context.read<ConversationBloc>().add(
                      ConversationInfoUpdated(
                        conversation.adminIds,
                        messagePolicy:
                            conversation.messagePolicy == MessagePolicy.everyone
                            ? MessagePolicy.adminsOnly
                            : MessagePolicy.everyone,
                      ),
                    )
                  : null,
            ),
        ]),
        if (isGroup) ...[
          _buildSectionHeader(
            context,
            '${conversation.participants.length} MEMBERS',
          ),
          ...conversation.participants.map(
            (participant) => _buildMemberTile(
              context,
              participant,
              isMe: participant.id == user.id,
              isAdmin: conversation.isAdmin(participant.id),
              onRemove: amAdmin && participant.id != user.id
                  ? () => context.read<ConversationBloc>().add(
                      ConversationMemberRemoved(
                        conversation.adminIds,
                        participant.id,
                      ),
                    )
                  : null,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        _buildDangerTile(
          isGroup ? Icons.exit_to_app : Icons.delete_outline,
          isGroup ? 'Exit Group' : 'Delete Chat',
          () => _confirmLeave(context, user, conversation, isGroup),
        ),
        _buildDangerTile(
          Icons.report_gmailerrorred,
          isGroup ? 'Report Group' : 'Report Contact',
          () => _report(context, user, conversation),
        ),
        const SizedBox(height: AppSpacing.x3l),
      ],
    );
  }

  MessageParticipant? _otherParticipant(
    ChatConversation conversation,
    String userId,
  ) {
    final others = conversation.participants.where((p) => p.id != userId);
    return others.isEmpty ? null : others.first;
  }

  Future<void> _addMembers(
    BuildContext context,
    UserEntity user,
    ChatConversation conversation,
    bool amAdmin,
  ) async {
    if (conversation.type == ChatType.direct) {
      context.showMessagingSnack('Start a group to add more people');
      return;
    }
    if (!amAdmin) {
      context.showMessagingSnack('Only group admins can add members');
      return;
    }

    final contacts = await context.messages.getContacts(
      user.schoolId,
      excludeId: user.id,
    );
    if (!context.mounted) return;

    final existing = conversation.participants.map((p) => p.id).toSet();
    final candidates = contacts.where((c) => !existing.contains(c.id)).toList();
    if (candidates.isEmpty) {
      context.showMessagingSnack(
        'Everyone in your school is already in this group',
      );
      return;
    }

    final picked = await showModalBottomSheet<List<MessageContact>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _MemberPickerSheet(candidates: candidates),
    );
    if (picked == null || picked.isEmpty || !context.mounted) return;

    context.read<ConversationBloc>().add(
      ConversationMembersAdded(conversation.adminIds, picked),
    );
    context.showMessagingSnack('Added ${picked.length} member(s)');
  }

  void _manage(
    BuildContext context,
    UserEntity user,
    ChatConversation conversation,
    bool amAdmin,
  ) {
    if (conversation.type == ChatType.direct) {
      context.push('/messages/chat/$chatId/profile');
      return;
    }
    if (!amAdmin) {
      context.showMessagingSnack('Only group admins can manage this group');
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Colors.white),
              title: const Text(
                'Edit name & description',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _editGroup(context, conversation);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.white,
              ),
              title: Text(
                conversation.messagePolicy == MessagePolicy.everyone
                    ? 'Restrict posting to admins'
                    : 'Let all members post',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                context.read<ConversationBloc>().add(
                  ConversationInfoUpdated(
                    conversation.adminIds,
                    messagePolicy:
                        conversation.messagePolicy == MessagePolicy.everyone
                        ? MessagePolicy.adminsOnly
                        : MessagePolicy.everyone,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Files a report against this chat for staff to review. The reason is
  /// asked for rather than assumed - an empty report is not much use to
  /// whoever picks it up.
  Future<void> _report(
    BuildContext context,
    UserEntity user,
    ChatConversation conversation,
  ) async {
    final reasonController = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report to the school'),
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
            child: const Text('Report', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
    if (submitted != true || !context.mounted) return;

    await context.messages.reportConversation(
      conversationId: conversation.id,
      reporter: user,
      reason: reasonController.text.trim(),
      reportedUserId: conversation.type == ChatType.direct
          ? _otherParticipant(conversation, user.id)?.id
          : null,
    );
    if (!context.mounted) return;
    context.showMessagingSnack('Reported to the school administrator');
  }

  Future<void> _changeAvatar(
    BuildContext context,
    UserEntity user,
    ChatConversation conversation,
  ) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null || !context.mounted) return;

    try {
      final url = await context.messages.uploadAttachment(
        schoolId: user.schoolId,
        conversationId: conversation.id,
        file: File(picked.path),
        fileName: 'avatar.jpg',
      );
      if (!context.mounted) return;
      context.read<ConversationBloc>().add(
        ConversationInfoUpdated(conversation.adminIds, avatarUrl: url),
      );
    } catch (e) {
      if (context.mounted) {
        context.showMessagingSnack('Could not update the photo: $e');
      }
    }
  }

  Future<void> _editGroup(
    BuildContext context,
    ChatConversation conversation,
  ) async {
    final nameController = TextEditingController(text: conversation.title);
    final descController = TextEditingController(
      text: conversation.description ?? '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved != true || !context.mounted) return;

    context.read<ConversationBloc>().add(
      ConversationInfoUpdated(
        conversation.adminIds,
        title: nameController.text.trim(),
        description: descController.text.trim(),
      ),
    );
  }

  Future<void> _confirmLeave(
    BuildContext context,
    UserEntity user,
    ChatConversation conversation,
    bool isGroup,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isGroup ? 'Exit group?' : 'Delete chat?'),
        content: Text(
          isGroup
              ? 'You will stop receiving messages from this group.'
              : 'This chat will be removed from your inbox.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              isGroup ? 'Exit' : 'Delete',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    context.read<ConversationBloc>().add(const ConversationLeft());
    context.go('/messages');
  }

  Widget _buildInfoSection(BuildContext context, List<Widget> children) {
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xl,
        top: AppSpacing.l,
        bottom: AppSpacing.s,
      ),
      child: Text(
        title,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textMuted(context),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildMemberTile(
    BuildContext context,
    MessageParticipant participant, {
    bool isMe = false,
    bool isAdmin = false,
    VoidCallback? onRemove,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.electricBlue,
        child: Text(
          participant.name.isEmpty ? '?' : participant.name[0].toUpperCase(),
          style: const TextStyle(color: AppColors.electricBlue),
        ),
      ),
      title: Text(
        isMe ? '${participant.name} (You)' : participant.name,
        style: AppTypography.titleSmall,
      ),
      subtitle: Text(
        _roleLabel(participant.role),
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textMuted(context),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.emeraldGreen),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Admin',
                style: TextStyle(color: AppColors.emeraldGreen, fontSize: 10),
              ),
            ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(
                Icons.person_remove_outlined,
                size: 18,
                color: Colors.black,
              ),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }

  Widget _buildDangerTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String title,
    String value, {
    VoidCallback? onTap,
    bool showChevron = true,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.electricBlue, size: 22),
      title: Text(title, style: AppTypography.titleSmall),
      subtitle: Text(
        value,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textMuted(context),
        ),
      ),
      trailing: showChevron && onTap != null
          ? const Icon(Icons.chevron_right, size: 20)
          : null,
      onTap: onTap,
    );
  }

  String _typeLabel(ChatType type) {
    switch (type) {
      case ChatType.broadcast:
        return 'Broadcast';
      case ChatType.channel:
        return 'Channel';
      default:
        return 'Group';
    }
  }

  String _initials(String title) {
    final parts = title
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return (parts.first.length >= 2
              ? parts.first.substring(0, 2)
              : parts.first)
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _roleLabel(String roleName) {
    final role = UserRole.values.where((r) => r.name == roleName);
    return role.isEmpty ? roleName : UserRoleDisplay.name(role.first);
  }
}

class _MemberPickerSheet extends StatefulWidget {
  final List<MessageContact> candidates;
  const _MemberPickerSheet({required this.candidates});

  @override
  State<_MemberPickerSheet> createState() => _MemberPickerSheetState();
}

class _MemberPickerSheetState extends State<_MemberPickerSheet> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.m),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Add members',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.candidates.length,
              itemBuilder: (context, index) {
                final contact = widget.candidates[index];
                final selected = _selected.contains(contact.id);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.electricBlue,
                    child: Text(
                      contact.initials,
                      style: const TextStyle(color: AppColors.electricBlue),
                    ),
                  ),
                  title: Text(contact.name, style: AppTypography.titleSmall),
                  trailing: Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: selected ? AppColors.electricBlue : Colors.black,
                  ),
                  onTap: () => setState(() {
                    selected
                        ? _selected.remove(contact.id)
                        : _selected.add(contact.id);
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selected.isEmpty
                  ? null
                  : () => Navigator.pop(
                      context,
                      widget.candidates
                          .where((c) => _selected.contains(c.id))
                          .toList(),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Add',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
