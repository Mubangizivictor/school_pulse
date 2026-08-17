part of 'messaging_bloc.dart';

enum MessagingActionStatus { idle, submitting, success, failure }

class MessagingState extends Equatable {
  /// Null until the first snapshot arrives; the inbox streams live for as
  /// long as the bloc does, so this never goes back to null once populated.
  final List<ChatConversation>? conversations;
  final Object? conversationsError;

  /// The role/context the signed-in user is currently acting as. Every
  /// permission decision (send, start conversation, create group, broadcast)
  /// is evaluated against this, not `user.roles.first` - see spec §6 and
  /// MessagingPermissionPolicy.
  final UserRole? activeRole;

  final UserEntity? user;

  /// Result of the most recent gated action, so a screen can show a snack or
  /// a refusal reason without re-deriving it itself.
  final MessagingActionStatus actionStatus;
  final MessagingDecision? lastDecision;
  final String? lastActionError;

  /// Populated by a successful DirectConversationRequested/
  /// ConversationCreateRequested/BroadcastRequested, so the screen knows
  /// which conversation to navigate into.
  final String? createdConversationId;

  const MessagingState({
    this.conversations,
    this.conversationsError,
    this.activeRole,
    this.user,
    this.actionStatus = MessagingActionStatus.idle,
    this.lastDecision,
    this.lastActionError,
    this.createdConversationId,
  });

  /// Sum of unread counters across every non-archived conversation - the
  /// number the Messages tab badge and app-level badge both read from, so
  /// they can never drift from what the inbox itself shows.
  int get totalUnreadCount =>
      (conversations ?? const [])
          .where((c) => !c.isArchived)
          .fold(0, (sum, c) => sum + c.unreadCount);

  MessagingState copyWith({
    List<ChatConversation>? conversations,
    Object? conversationsError,
    bool clearConversationsError = false,
    UserRole? activeRole,
    UserEntity? user,
    MessagingActionStatus? actionStatus,
    MessagingDecision? lastDecision,
    bool clearLastDecision = false,
    String? lastActionError,
    bool clearLastActionError = false,
    String? createdConversationId,
    bool clearCreatedConversationId = false,
  }) {
    return MessagingState(
      conversations: conversations ?? this.conversations,
      conversationsError: clearConversationsError
          ? null
          : (conversationsError ?? this.conversationsError),
      activeRole: activeRole ?? this.activeRole,
      user: user ?? this.user,
      actionStatus: actionStatus ?? this.actionStatus,
      lastDecision: clearLastDecision ? null : (lastDecision ?? this.lastDecision),
      lastActionError: clearLastActionError
          ? null
          : (lastActionError ?? this.lastActionError),
      createdConversationId: clearCreatedConversationId
          ? null
          : (createdConversationId ?? this.createdConversationId),
    );
  }

  @override
  List<Object?> get props => [
    conversations,
    conversationsError,
    activeRole,
    user,
    actionStatus,
    lastDecision,
    lastActionError,
    createdConversationId,
  ];
}
