import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/messaging_context.dart';
import 'package:school_pulse/features/messages/presentation/widgets/chat_list_tile.dart';

/// The inbox. Shared by every role - parents, students and staff all route
/// here (/parent/messages, /student/messages, /staff/messages and the
/// top-level /messages), so it must never assume a role-specific shape.
class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

enum _InboxFilter { all, unread, groups, official }

class _MessagesListScreenState extends State<MessagesListScreen> {
  _InboxFilter _filter = _InboxFilter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Messages',
          style: AppTypography.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, color: Colors.white),
            onPressed: () => context.push('/messages/new'),
          ),
        ],
      ),
      body: MessagingUserBuilder(
        builder: (context, user) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () => context.push('/messages/search'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white54, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        'Search messages',
                        style: AppTypography.bodyLarge.copyWith(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 48,
              child: StreamBuilder<List<ChatConversation>>(
                stream: context.messages.watchConversations(user.id),
                builder: (context, snapshot) => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: _filter == _InboxFilter.all,
                    onTap: () => setState(() => _filter = _InboxFilter.all),
                  ),
                  _FilterChip(
                    label: 'Unread',
                    isSelected: _filter == _InboxFilter.unread,
                    onTap: () => setState(() => _filter = _InboxFilter.unread),
                  ),
                  _FilterChip(
                    label: 'Groups',
                    isSelected: _filter == _InboxFilter.groups,
                    onTap: () => setState(() => _filter = _InboxFilter.groups),
                  ),
                  _FilterChip(
                    label: 'Official',
                    isSelected: _filter == _InboxFilter.official,
                    onTap: () => setState(() => _filter = _InboxFilter.official),
                  ),
                  _FilterChip(
                    label: 'Archived',
                    isSelected: false,
                    onTap: () => context.push('/messages/archived'),
                  ),
                  // Only appears when something is actually waiting, so the
                  // chip row stays as short as it was for most people.
                  if (_pendingRequests(snapshot.data) > 0)
                    _FilterChip(
                      label: 'Requests (${_pendingRequests(snapshot.data)})',
                      isSelected: false,
                      onTap: () => context.push('/messages/requests'),
                    ),
                ],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ChatConversation>>(
                stream: context.messages.watchConversations(user.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildError(snapshot.error!);
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final conversations = _applyFilter(snapshot.data!);
                  if (conversations.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final chat = conversations[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ChatListTile(
                          chat: chat,
                          onTap: () => context.push('/messages/chat/${chat.id}'),
                          onLongPress: () => _showChatActions(context, user, chat),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A 1:1 chat someone started that this user hasn't accepted yet. Only
  /// happens between two non-staff accounts - see
  /// MessagesRepositoryImpl.startDirectConversation.
  static bool _isRequest(ChatConversation chat) =>
      chat.type == ChatType.direct && !chat.isAccepted;

  int _pendingRequests(List<ChatConversation>? all) =>
      all == null ? 0 : all.where(_isRequest).length;

  List<ChatConversation> _applyFilter(List<ChatConversation> all) {
    // Archived chats and unaccepted requests each live behind their own
    // screen; everything else is filtered by the chip row.
    final visible = all.where((c) => !c.isArchived && !_isRequest(c));
    switch (_filter) {
      case _InboxFilter.all:
        return visible.toList();
      case _InboxFilter.unread:
        return visible.where((c) => c.unreadCount > 0).toList();
      case _InboxFilter.groups:
        return visible.where((c) => c.type == ChatType.group).toList();
      case _InboxFilter.official:
        // "Official" is the school's one-way traffic: broadcast lists and
        // announcement channels.
        return visible
            .where((c) => c.type == ChatType.broadcast || c.type == ChatType.channel)
            .toList();
    }
  }

  void _showChatActions(BuildContext context, UserEntity user, ChatConversation chat) {
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
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Text(
                chat.title,
                style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Icon(chat.isPinned ? Icons.push_pin : Icons.push_pin_outlined, color: Colors.white70),
              title: Text(chat.isPinned ? 'Unpin' : 'Pin to top', style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(sheetContext);
                context.messages.setPinned(chat.id, user.id, !chat.isPinned);
              },
            ),
            ListTile(
              leading: Icon(
                chat.isMuted ? Icons.notifications_off : Icons.notifications_none,
                color: Colors.white70,
              ),
              title: Text(chat.isMuted ? 'Unmute' : 'Mute', style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(sheetContext);
                context.messages.setMuted(chat.id, user.id, !chat.isMuted);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined, color: Colors.white70),
              title: const Text('Archive', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(sheetContext);
                context.messages.setArchived(chat.id, user.id, true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: Text(
                chat.type == ChatType.direct ? 'Delete chat' : 'Exit group',
                style: const TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                context.messages.leaveConversation(chat.id, user.id);
              },
            ),
            const SizedBox(height: AppSpacing.s),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 56, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Could not load your messages',
              style: AppTypography.titleMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 80,
                color: AppColors.electricBlue.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Conversations Yet',
              style: AppTypography.headlineSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Stay connected with teachers, parents, and school staff. Start a new conversation below.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white60,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/messages/new'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text('Start Messaging', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterChip({required this.label, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap?.call(),
        selectedColor: AppColors.electricBlue,
        backgroundColor: AppColors.surfaceDark,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white60,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isSelected ? AppColors.electricBlue : Colors.white.withValues(alpha: 0.05)),
        ),
        showCheckmark: false,
      ),
    );
  }
}
