import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
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

enum _InboxFilter { all, unread, groups, official, school, teachers }

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
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Messages',
          style: AppTypography.titleLarge.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      // The empty state owns the first-conversation affordance.  Showing the
      // pen alongside it duplicates the same action and makes the empty
      // screen visually noisy.  Once there is any conversation, the FAB
      // becomes the compact compose affordance.
      floatingActionButton: BlocBuilder<MessagingBloc, MessagingState>(
        bloc: context.messagingBloc,
        builder: (context, state) {
          final hasConversations = state.conversations?.isNotEmpty ?? false;
          if (!hasConversations) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => context.push('/messages/new'),
            tooltip: 'New message',
            backgroundColor: colors.onSurface,
            foregroundColor: colors.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.edit_rounded),
          );
        },
      ),
      body: MessagingUserBuilder(
        builder: (context, user) => BlocBuilder<MessagingBloc, MessagingState>(
          bloc: context.messagingBloc,
          builder: (context, state) {
            final conversations = state.conversations;
            _reconcileArchivedIfNeeded(conversations);
            final isParent = user.roles.contains(UserRole.parent);
            return ResponsiveBuilder(
              builder: (context, layout) {
                final searchBar = _buildSearchBar(context);
                final filterRow = _buildFilterRow(context, user, conversations);
                final lockNotice = isParent
                    ? _buildParentLockNotice(context)
                    : const SizedBox.shrink();
                final content = Builder(
                  builder: (context) {
                    if (state.conversationsError != null) {
                      return _buildError(state.conversationsError!);
                    }
                    if (conversations == null) {
                      return const Center(child: SchoolPulseLoader());
                    }
                    final visible = _applyFilter(conversations, user);
                    if (visible.isEmpty) {
                      return _buildEmptyState(
                        isWide: layout != ResponsiveLayout.mobile,
                      );
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
                );

                if (layout == ResponsiveLayout.mobile) {
                  return Column(
                    children: [
                      lockNotice,
                      searchBar,
                      filterRow,
                      Expanded(child: content),
                    ],
                  );
                }

                final isDesktop = layout == ResponsiveLayout.desktop;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isDesktop ? 32 : 20,
                        20,
                        isDesktop ? 32 : 20,
                        24,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                lockNotice,
                                searchBar,
                                filterRow,
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colors.surface,
                                      border: Border.all(
                                        color: colors.onSurface,
                                        width: 1,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: content,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isDesktop) ...[
                            const SizedBox(width: 24),
                            const _MessagingTipsPanel(),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _reconcileArchivedIfNeeded(List<ChatConversation>? conversations) {
    if (conversations != null) _reconcileArchived(conversations);
  }

  Widget _buildParentLockNotice(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 14,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            'You can message school contacts only',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Semantics(
        button: true,
        label: 'Search messages',
        child: InkWell(
          onTap: () => context.push('/messages/search'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: colors.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Search conversations',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow(
    BuildContext context,
    UserEntity user,
    List<ChatConversation>? conversations,
  ) {
    final isParent = user.roles.contains(UserRole.parent);
    final filters = isParent
        ? [_InboxFilter.all, _InboxFilter.school, _InboxFilter.teachers]
        : [
            _InboxFilter.all,
            _InboxFilter.unread,
            _InboxFilter.groups,
            _InboxFilter.official,
          ];

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        children: [
          ...filters.map(
            (f) => _FilterChip(
              label: _filterLabel(f),
              isSelected: _filter == f,
              onTap: () => setState(() => _filter = f),
            ),
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
              label: 'Requests (${_pendingRequests(conversations)})',
              isSelected: false,
              onTap: () => context.push('/messages/requests'),
            ),
        ],
      ),
    );
  }

  String _filterLabel(_InboxFilter filter) {
    switch (filter) {
      case _InboxFilter.all:
        return 'All';
      case _InboxFilter.unread:
        return 'Unread';
      case _InboxFilter.groups:
        return 'Groups';
      case _InboxFilter.official:
        return 'Official';
      case _InboxFilter.school:
        return 'School';
      case _InboxFilter.teachers:
        return 'Teachers';
    }
  }

  /// A 1:1 chat someone started that this user hasn't accepted yet. Only
  /// happens between two non-staff accounts - see
  /// MessagesRepositoryImpl.startDirectConversation.
  static bool _isRequest(ChatConversation chat) =>
      chat.type == ChatType.direct && !chat.isAccepted;

  int _pendingRequests(List<ChatConversation>? all) =>
      all == null ? 0 : all.where(_isRequest).length;

  List<ChatConversation> _applyFilter(
    List<ChatConversation> all,
    UserEntity user,
  ) {
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
      case _InboxFilter.school:
        // "Official" / "School" is the school's one-way traffic: broadcast
        // lists and announcement channels.
        return visible
            .where(
              (c) => c.type == ChatType.broadcast || c.type == ChatType.channel,
            )
            .toList();
      case _InboxFilter.teachers:
        // Filter conversations involving teachers.
        return visible.where((c) {
          return c.participants.any(
            (p) =>
                p.id != user.id &&
                (p.role.toLowerCase().contains('teacher') ||
                    p.role.toLowerCase().contains('head') ||
                    p.role.toLowerCase().contains('tutor')),
          );
        }).toList();
    }
  }

  void _showChatActions(
    BuildContext context,
    UserEntity user,
    ChatConversation chat,
  ) {
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (sheetContext) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.onSurface, width: 1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Text(
                  chat.title.toUpperCase(),
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  chat.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: colors.onSurface,
                ),
                title: Text(
                  (chat.isPinned ? 'Unpin' : 'Pin to top').toUpperCase(),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
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
                  color: colors.onSurface,
                ),
                title: Text(
                  (chat.isMuted ? 'Unmute' : 'Mute').toUpperCase(),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
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
                leading: Icon(Icons.archive_outlined, color: colors.onSurface),
                title: Text(
                  'ARCHIVE',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
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
                leading: Icon(Icons.delete_outline, color: colors.onSurface),
                title: Text(
                  (chat.type == ChatType.direct ? 'Delete chat' : 'Exit group')
                      .toUpperCase(),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.messagingBloc.add(
                    ConversationLeaveRequested(chat.id),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.s),
            ],
          ),
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

  Widget _buildEmptyState({bool isWide = false}) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 380 : 360),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 38,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No conversations yet',
                style: AppTypography.headlineSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Start a conversation with teachers, parents, or school staff.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.onSurface,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 240,
                child: ElevatedButton(
                  onPressed: () => context.push('/messages/new'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.onSurface,
                    foregroundColor: colors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start a conversation',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wide-viewport (desktop) side panel: static guidance only, no live data,
/// no new message actions - matches the reference "Messaging tips" panel.
class _MessagingTipsPanel extends StatelessWidget {
  const _MessagingTipsPanel();

  static const _tips = [
    (
      Icons.groups_outlined,
      'Stay in the loop',
      'Communicate with staff, parents, and teachers in one place.',
    ),
    (
      Icons.notifications_none,
      'Never miss important updates',
      'Check unread messages and enable notifications.',
    ),
    (
      Icons.verified_user_outlined,
      'Keep conversations organized',
      'Use groups and filters to find what you need quickly.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MESSAGING TIPS',
            style: AppTypography.titleMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          for (final tip in _tips) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.onSurface, width: 1),
                  ),
                  child: Icon(tip.$1, size: 18, color: colors.onSurface),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.$2.toUpperCase(),
                        style: AppTypography.bodyMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip.$3.toUpperCase(),
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurface,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ],
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
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap?.call(),
        selectedColor: colors.onSurface,
        backgroundColor: colors.surfaceContainerHighest,
        labelStyle: TextStyle(
          color: isSelected ? colors.surface : colors.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.transparent),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        visualDensity: VisualDensity.compact,
        showCheckmark: false,
      ),
    );
  }
}
