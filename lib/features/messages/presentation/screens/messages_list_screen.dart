import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/domain/entities/chat_preferences.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/bloc/messaging_bloc.dart';
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

  /// Chat Settings › "Keep chats archived". When it is off, an archived chat
  /// has to come back the moment a new message lands in it.
  ChatPreferences _preferences = const ChatPreferences();

  @override
  void initState() {
    super.initState();
    ChatPreferences.load().then((preferences) {
      if (mounted) setState(() => _preferences = preferences);
    });
  }

  /// Firestore has no way to express "unarchive on new activity", so it is
  /// reconciled here: anything archived that has gone unread again is
  /// un-archived once, after the frame that noticed it.
  void _reconcileArchived(List<ChatConversation> conversations) {
    if (_preferences.keepArchived) return;
    final resurfacing = conversations
        .where((c) => c.isArchived && c.unreadCount > 0)
        .toList();
    if (resurfacing.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final chat in resurfacing) {
        context.messagingBloc.add(ConversationArchivedSet(chat.id, false));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inboxSurface = isDark
        ? const Color(0xFF10376F)
        : colors.surfaceContainerHigh;
    final inboxBorder = isDark
        ? const Color(0xFF3466A7)
        : colors.outlineVariant;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Messages',
          style: AppTypography.headlineMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_square, color: colors.onSurface),
            onPressed: () => context.push('/messages/new'),
          ),
        ],
      ),
      body: MessagingUserBuilder(
        builder: (context, user) => BlocBuilder<MessagingBloc, MessagingState>(
          bloc: context.messagingBloc,
          builder: (context, state) {
            final conversations = state.conversations;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: InkWell(
                    onTap: () => context.push('/messages/search'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: inboxSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: inboxBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: colors.onSurfaceVariant,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Search messages',
                            style: AppTypography.bodyLarge.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView(
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
                        onTap: () =>
                            setState(() => _filter = _InboxFilter.unread),
                      ),
                      _FilterChip(
                        label: 'Groups',
                        isSelected: _filter == _InboxFilter.groups,
                        onTap: () =>
                            setState(() => _filter = _InboxFilter.groups),
                      ),
                      _FilterChip(
                        label: 'Official',
                        isSelected: _filter == _InboxFilter.official,
                        onTap: () =>
                            setState(() => _filter = _InboxFilter.official),
                      ),
                      _FilterChip(
                        label: 'Archived',
                        isSelected: false,
                        onTap: () => context.push('/messages/archived'),
                      ),
                      // Only appears when something is actually waiting,
                      // so the chip row stays as short as it was for
                      // most people.
                      if (_pendingRequests(conversations) > 0)
                        _FilterChip(
                          label:
                              'Requests (${_pendingRequests(conversations)})',
                          isSelected: false,
                          onTap: () => context.push('/messages/requests'),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state.conversationsError != null) {
                        return _buildError(state.conversationsError!);
                      }
                      if (conversations == null) {
                        return const Center(child: SchoolPulseLoader());
                      }

                      _reconcileArchived(conversations);
                      final visible = _applyFilter(conversations);
                      if (visible.isEmpty) {
                        return _buildEmptyState();
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final chat = visible[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ChatListTile(
                              chat: chat,
                              onTap: () =>
                                  context.push('/messages/chat/${chat.id}'),
                              onLongPress: () =>
                                  _showChatActions(context, user, chat),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
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
            .where(
              (c) => c.type == ChatType.broadcast || c.type == ChatType.channel,
            )
            .toList();
    }
  }

  void _showChatActions(
    BuildContext context,
    UserEntity user,
    ChatConversation chat,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
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
                style: AppTypography.titleMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                chat.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              title: Text(
                chat.isPinned ? 'Unpin' : 'Pin to top',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                context.messagingBloc.add(
                  ConversationPinnedSet(chat.id, !chat.isPinned),
                );
              },
            ),
            ListTile(
              leading: Icon(
                chat.isMuted
                    ? Icons.notifications_off
                    : Icons.notifications_none,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              title: Text(
                chat.isMuted ? 'Unmute' : 'Mute',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                context.messagingBloc.add(
                  ConversationMutedSet(chat.id, !chat.isMuted),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.archive_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              title: Text(
                'Archive',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                context.messagingBloc.add(
                  ConversationArchivedSet(chat.id, true),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              title: Text(
                chat.type == ChatType.direct ? 'Delete chat' : 'Exit group',
                style: const TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                context.messagingBloc.add(ConversationLeaveRequested(chat.id));
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
            Icon(
              Icons.cloud_off,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Could not load your messages',
              style: AppTypography.titleMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0D315F)
                    : colors.surfaceContainerHigh,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2D5B98)
                      : colors.outlineVariant,
                ),
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
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Stay connected with teachers, parents, and school staff. Start a new conversation below.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                child: const Text(
                  'Start Messaging',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
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

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap?.call(),
        selectedColor: colors.primary,
        backgroundColor: isDark
            ? const Color(0xFF10376F)
            : colors.surfaceContainerHigh,
        labelStyle: TextStyle(
          color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? colors.primary
                : isDark
                ? const Color(0xFF3466A7)
                : colors.outlineVariant,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }
}
