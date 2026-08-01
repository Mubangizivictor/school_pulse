import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/messaging_context.dart';
import 'package:school_pulse/features/messages/presentation/widgets/message_bubble.dart';

class ChatConversationScreen extends StatefulWidget {
  final String chatId;
  const ChatConversationScreen({super.key, required this.chatId});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();

  /// The message being quoted, and the message being edited - never both.
  ChatMessage? _replyTo;
  ChatMessage? _editing;

  bool _uploading = false;

  /// Guards against re-issuing the read receipt write on every stream tick.
  bool _markingRead = false;

  @override
  void initState() {
    super.initState();
    // The send/mic button swaps on the first character typed.
    _messageController.addListener(_onComposerChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onComposerChanged);
    _messageController.dispose();
    super.dispose();
  }

  bool _composerHadText = false;
  void _onComposerChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _composerHadText) {
      setState(() => _composerHadText = hasText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MessagingUserBuilder(
      builder: (context, user) => StreamBuilder<ChatConversation?>(
        stream: context.messages.watchConversation(widget.chatId, user.id),
        builder: (context, snapshot) {
          final conversation = snapshot.data;
          if (conversation == null) {
            return Scaffold(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.bgDark
                  : AppColors.bgLight,
              appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
              body: Center(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const CircularProgressIndicator()
                    : Text('This conversation is no longer available',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted(context))),
              ),
            );
          }
          _scheduleReadReceipt(conversation, user);
          return _buildChat(context, user, conversation);
        },
      ),
    );
  }

  /// Clearing the badge is a write, so it can't happen during build - defer
  /// it to the end of the frame and only while something is actually unread.
  void _scheduleReadReceipt(ChatConversation conversation, UserEntity user) {
    if (conversation.unreadCount == 0 || _markingRead) return;
    _markingRead = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.messages.markConversationRead(conversation.id, user.id);
      if (mounted) _markingRead = false;
    });
  }

  Widget _buildChat(BuildContext context, UserEntity user, ChatConversation conversation) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.bgDark : Colors.white,
        elevation: 0,
        leadingWidth: 40,
        titleSpacing: 0,
        title: InkWell(
          // Broadcast lists and channels have their own info screen (it is
          // about recipients and delivery, not group membership).
          onTap: () => context.push(
            conversation.type == ChatType.broadcast || conversation.type == ChatType.channel
                ? '/messages/broadcast/${widget.chatId}'
                : '/messages/chat/${widget.chatId}/info',
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.electricBlue,
                backgroundImage:
                    conversation.avatarUrl != null ? NetworkImage(conversation.avatarUrl!) : null,
                child: conversation.avatarUrl != null
                    ? null
                    : Text(
                        _initials(conversation.title),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.title,
                      style: AppTypography.titleMedium.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      conversation.subtitle ?? '',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () => context.showMessagingSnack('Video calls are not available yet'),
          ),
          IconButton(
            icon: const Icon(Icons.phone_outlined),
            onPressed: () => context.showMessagingSnack('Voice calls are not available yet'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          if (conversation.pinnedMessageContent != null)
            _buildPinnedBanner(context, isDark, conversation),
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: context.messages.watchMessages(widget.chatId, user.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.x3l),
                      child: Text(
                        'No messages yet. Say hello!',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted(context)),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    return MessageBubble(
                      message: message,
                      isGroup: conversation.type != ChatType.direct,
                      onReply: () => setState(() {
                        _replyTo = message;
                        _editing = null;
                      }),
                      onForward: () => _forward(user, message),
                      onStar: () => context.messages
                          .setStarred(conversation.id, message.id, user.id, !message.isStarred),
                      onCopy: () {
                        Clipboard.setData(ClipboardData(text: message.content));
                        context.showMessagingSnack('Copied to clipboard');
                      },
                      onEdit: message.isMe && message.type == MessageType.text
                          ? () {
                              setState(() {
                                _editing = message;
                                _replyTo = null;
                                _messageController.text = message.content;
                              });
                            }
                          : null,
                      onDelete: message.isMe ? () => _confirmDelete(conversation.id, message) : null,
                      onPin: () => context.messages
                          .setMessagePinned(conversation.id, message, !message.isPinned),
                      onReact: (emoji) =>
                          context.messages.react(conversation.id, message.id, user.id, emoji),
                    );
                  },
                );
              },
            ),
          ),
          if (_uploading) const LinearProgressIndicator(minHeight: 2),
          if (conversation.canPost(user.id))
            _buildInputArea(isDark, user, conversation)
          else
            _buildReadOnlyNotice(isDark),
        ],
      ),
    );
  }

  Widget _buildPinnedBanner(BuildContext context, bool isDark, ChatConversation conversation) {
    return InkWell(
      onTap: () => context.push('/messages/pinned'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: isDark ? AppColors.electricBlue.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.05),
        child: Row(
          children: [
            const Icon(Icons.push_pin, size: 14, color: AppColors.electricBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pinned: ${conversation.pinnedMessageContent}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.electricBlue,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: AppColors.electricBlue),
              onPressed: () => context.messages.setMessagePinned(
                conversation.id,
                ChatMessage(
                  id: conversation.pinnedMessageId ?? '',
                  senderId: '',
                  senderName: conversation.pinnedMessageSender ?? '',
                  content: conversation.pinnedMessageContent ?? '',
                  timestamp: DateTime.now(),
                ),
                false,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyNotice(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.m, horizontal: AppSpacing.l),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : Colors.white,
        border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
      ),
      child: SafeArea(
        child: Text(
          'Only admins can send messages here',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted(context)),
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark, UserEntity user, ChatConversation conversation) {
    final draft = _replyTo ?? _editing;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.s),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : Colors.white,
        border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (draft != null) _buildDraftBanner(isDark, draft),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.electricBlue, size: 28),
                  onPressed: () => _showAttachmentMenu(context, user, conversation),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.bgLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                    child: TextField(
                      controller: _messageController,
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        suffixIcon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey, size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.electricBlue,
                    child: IconButton(
                      icon: Icon(_composerHadText ? Icons.send : Icons.mic, color: Colors.white, size: 20),
                      onPressed: _composerHadText
                          ? () => _send(user, conversation)
                          : () => context.showMessagingSnack('Voice notes are not available yet'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// The strip above the composer that shows what is being replied to or
  /// edited, with an X to back out.
  Widget _buildDraftBanner(bool isDark, ChatMessage draft) {
    final isEditing = _editing != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
      decoration: BoxDecoration(
        color: AppColors.electricBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: AppColors.electricBlue, width: 3)),
      ),
      child: Row(
        children: [
          Icon(isEditing ? Icons.edit_outlined : Icons.reply, size: 16, color: AppColors.electricBlue),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Editing message' : 'Replying to ${draft.senderName}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.electricBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  draft.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted(context)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => setState(() {
              _replyTo = null;
              if (_editing != null) {
                _editing = null;
                _messageController.clear();
              }
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _send(UserEntity user, ChatConversation conversation) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final replyTo = _replyTo;
    final editing = _editing;
    _messageController.clear();
    setState(() {
      _replyTo = null;
      _editing = null;
    });

    try {
      if (editing != null) {
        await context.messages.editMessage(conversation.id, editing.id, text);
      } else {
        await context.messages.sendMessage(
          conversationId: conversation.id,
          sender: user,
          content: text,
          replyTo: replyTo,
        );
      }
    } catch (e) {
      if (!mounted) return;
      // Put the text back so a failed send isn't a lost message.
      _messageController.text = text;
      context.showMessagingSnack('Could not send: $e');
    }
  }

  Future<void> _forward(UserEntity user, ChatMessage message) async {
    final conversations = await context.messages.watchConversations(user.id).first;
    if (!mounted) return;

    final selected = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ForwardSheet(conversations: conversations),
    );
    if (selected == null || selected.isEmpty || !mounted) return;

    await context.messages.forwardMessage(
      message: message,
      conversationIds: selected,
      sender: user,
    );
    if (!mounted) return;
    context.showMessagingSnack('Forwarded to ${selected.length} chat(s)');
  }

  Future<void> _confirmDelete(String conversationId, ChatMessage message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete message?'),
        content: const Text('This message will be removed for everyone in the chat.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.messages.deleteMessage(conversationId, message.id);
  }

  void _showAttachmentMenu(BuildContext context, UserEntity user, ChatConversation conversation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => AttachmentsMenu(
        onSelected: (kind) {
          Navigator.pop(sheetContext);
          _handleAttachment(kind, user, conversation);
        },
      ),
    );
  }

  Future<void> _handleAttachment(
    AttachmentKind kind,
    UserEntity user,
    ChatConversation conversation,
  ) async {
    switch (kind) {
      case AttachmentKind.photos:
      case AttachmentKind.camera:
        await _sendImage(
          kind == AttachmentKind.camera ? ImageSource.camera : ImageSource.gallery,
          user,
          conversation,
        );
      case AttachmentKind.document:
      case AttachmentKind.audio:
      case AttachmentKind.location:
      case AttachmentKind.contact:
      case AttachmentKind.poll:
      case AttachmentKind.event:
        context.showMessagingSnack('${kind.label} attachments are not available yet');
    }
  }

  Future<void> _sendImage(
    ImageSource source,
    UserEntity user,
    ChatConversation conversation,
  ) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 70);
    if (picked == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      final file = File(picked.path);
      final url = await context.messages.uploadAttachment(
        schoolId: user.schoolId,
        conversationId: conversation.id,
        file: file,
        fileName: picked.name,
      );
      if (!mounted) return;
      await context.messages.sendMessage(
        conversationId: conversation.id,
        sender: user,
        content: '',
        type: MessageType.image,
        mediaUrl: url,
        fileName: picked.name,
        fileSize: _readableSize(await file.length()),
      );
    } catch (e) {
      if (mounted) context.showMessagingSnack('Could not send photo: $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  String _readableSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _initials(String title) {
    final parts = title.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return (parts.first.length >= 2 ? parts.first.substring(0, 2) : parts.first).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

enum AttachmentKind {
  photos('Photos'),
  camera('Camera'),
  document('Document'),
  audio('Audio'),
  location('Location'),
  contact('Contact'),
  poll('Poll'),
  event('Event');

  final String label;
  const AttachmentKind(this.label);
}

class AttachmentsMenu extends StatelessWidget {
  final ValueChanged<AttachmentKind>? onSelected;

  const AttachmentsMenu({super.key, this.onSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            mainAxisSpacing: AppSpacing.m,
            children: [
              _AttachmentItem(
                  icon: Icons.image,
                  kind: AttachmentKind.photos,
                  color: Colors.purple,
                  onSelected: onSelected),
              _AttachmentItem(
                  icon: Icons.camera_alt,
                  kind: AttachmentKind.camera,
                  color: Colors.pink,
                  onSelected: onSelected),
              _AttachmentItem(
                  icon: Icons.insert_drive_file,
                  kind: AttachmentKind.document,
                  color: Colors.blue,
                  onSelected: onSelected),
              _AttachmentItem(
                  icon: Icons.headset,
                  kind: AttachmentKind.audio,
                  color: Colors.orange,
                  onSelected: onSelected),
              _AttachmentItem(
                  icon: Icons.location_on,
                  kind: AttachmentKind.location,
                  color: Colors.green,
                  onSelected: onSelected),
              _AttachmentItem(
                  icon: Icons.person,
                  kind: AttachmentKind.contact,
                  color: Colors.teal,
                  onSelected: onSelected),
              _AttachmentItem(
                  icon: Icons.poll,
                  kind: AttachmentKind.poll,
                  color: Colors.amber,
                  onSelected: onSelected),
              _AttachmentItem(
                  icon: Icons.event,
                  kind: AttachmentKind.event,
                  color: Colors.cyan,
                  onSelected: onSelected),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _AttachmentItem extends StatelessWidget {
  final IconData icon;
  final AttachmentKind kind;
  final Color color;
  final ValueChanged<AttachmentKind>? onSelected;

  const _AttachmentItem({
    required this.icon,
    required this.kind,
    required this.color,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected == null ? null : () => onSelected!(kind),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(kind.label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

/// Multi-select chat picker used by "Forward".
class _ForwardSheet extends StatefulWidget {
  final List<ChatConversation> conversations;
  const _ForwardSheet({required this.conversations});

  @override
  State<_ForwardSheet> createState() => _ForwardSheetState();
}

class _ForwardSheetState extends State<_ForwardSheet> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.m),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Forward to', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.s),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.conversations.length,
              itemBuilder: (context, index) {
                final chat = widget.conversations[index];
                final selected = _selected.contains(chat.id);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.electricBlue.withValues(alpha: 0.1),
                    child: Text(
                      chat.title.isEmpty ? '?' : chat.title[0].toUpperCase(),
                      style: const TextStyle(color: AppColors.electricBlue),
                    ),
                  ),
                  title: Text(chat.title, style: AppTypography.titleSmall),
                  subtitle: Text(
                    chat.subtitle ?? '',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted(context)),
                  ),
                  trailing: Icon(
                    selected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: selected ? AppColors.electricBlue : Colors.grey,
                  ),
                  onTap: () => setState(() {
                    selected ? _selected.remove(chat.id) : _selected.add(chat.id);
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selected.isEmpty ? null : () => Navigator.pop(context, _selected.toList()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Forward', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
