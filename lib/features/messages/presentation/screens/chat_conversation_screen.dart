import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/domain/entities/chat_preferences.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/messaging_context.dart';
import 'package:school_pulse/features/messages/presentation/widgets/attachment_composers.dart';
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

  /// Voice note in progress. [_recordingPath] being non-null is what swaps
  /// the composer for the recording bar.
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordingPath;
  Duration _recordedFor = Duration.zero;
  Timer? _recordingTicker;

  /// Enter-is-send and font size come from Chat Settings.
  ChatPreferences _preferences = const ChatPreferences();

  /// Messages held in memory. Grows when the user scrolls back past the
  /// window, so a long-running class group isn't cut off at the default.
  int _messageLimit = 60;

  /// Long-press "Select" puts the chat into multi-select; an empty set means
  /// normal browsing.
  final Set<String> _selectedIds = {};
  List<ChatMessage> _visibleMessages = const [];

  @override
  void initState() {
    super.initState();
    // The send/mic button swaps on the first character typed.
    _messageController.addListener(_onComposerChanged);
    ChatPreferences.load().then((preferences) {
      if (mounted) setState(() => _preferences = preferences);
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onComposerChanged);
    _messageController.dispose();
    _recordingTicker?.cancel();
    // Leaving the chat mid-recording must release the microphone.
    _recorder.dispose();
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

  void _toggleSelected(String messageId) {
    setState(() {
      if (!_selectedIds.remove(messageId)) _selectedIds.add(messageId);
    });
  }

  List<ChatMessage> get _selectedMessages =>
      _visibleMessages.where((m) => _selectedIds.contains(m.id)).toList();

  /// Replaces the chat header while messages are selected, so the actions
  /// apply to the whole selection rather than one bubble.
  PreferredSizeWidget _buildSelectionAppBar(
    bool isDark,
    UserEntity user,
    ChatConversation conversation,
  ) {
    final selected = _selectedMessages;
    final allMine = selected.isNotEmpty && selected.every((m) => m.isMe);

    return AppBar(
      backgroundColor: isDark ? AppColors.bgDark : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => setState(_selectedIds.clear),
      ),
      title: Text('${selected.length} selected', style: AppTypography.titleMedium),
      actions: [
        IconButton(
          icon: const Icon(Icons.copy),
          tooltip: 'Copy',
          onPressed: () {
            Clipboard.setData(ClipboardData(
              text: selected.map((m) => '${m.senderName}: ${m.content}').join('\n'),
            ));
            setState(_selectedIds.clear);
            context.showMessagingSnack('Copied to clipboard');
          },
        ),
        IconButton(
          icon: const Icon(Icons.star_border),
          tooltip: 'Star',
          onPressed: () async {
            for (final message in selected) {
              await context.messages
                  .setStarred(conversation.id, message.id, user.id, !message.isStarred);
            }
            if (mounted) setState(_selectedIds.clear);
          },
        ),
        IconButton(
          icon: const Icon(Icons.forward),
          tooltip: 'Forward',
          onPressed: () => _forwardMany(user, selected),
        ),
        // Only your own messages can be deleted, so the action disappears
        // rather than failing when the selection includes someone else's.
        if (allMine)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Delete',
            onPressed: () => _confirmDeleteMany(conversation.id, selected),
          ),
      ],
    );
  }

  Widget _buildChat(BuildContext context, UserEntity user, ChatConversation conversation) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_selectedIds.isNotEmpty) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        appBar: _buildSelectionAppBar(isDark, user, conversation),
        body: _buildChatBody(context, isDark, user, conversation),
      );
    }

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
      body: _buildChatBody(context, isDark, user, conversation),
    );
  }

  Widget _buildChatBody(
    BuildContext context,
    bool isDark,
    UserEntity user,
    ChatConversation conversation,
  ) {
    return Column(
        children: [
          if (conversation.pinnedMessageContent != null)
            _buildPinnedBanner(context, isDark, conversation),
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: context.messages
                  .watchMessages(widget.chatId, user.id, limit: _messageLimit),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                _visibleMessages = messages;
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
                return NotificationListener<ScrollNotification>(
                  // The list is reversed, so "scrolled to the end" means the
                  // user has reached the oldest message they have; fetch the
                  // next window rather than stopping dead at the limit.
                  onNotification: (notification) {
                    if (notification.metrics.extentAfter < 200 &&
                        messages.length >= _messageLimit) {
                      setState(() => _messageLimit += 60);
                    }
                    return false;
                  },
                  child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    return MessageBubble(
                      message: message,
                      isGroup: conversation.type != ChatType.direct,
                      textScale: _preferences.textScale,
                      isSelected: _selectedIds.contains(message.id),
                      selectionMode: _selectedIds.isNotEmpty,
                      onToggleSelected: () => _toggleSelected(message.id),
                      onSelect: () => _toggleSelected(message.id),
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
                      onVote: (option) =>
                          context.messages.voteInPoll(conversation.id, message.id, user.id, option),
                      onOpenContact: (contactId) => _openSharedContact(user, contactId),
                    );
                  },
                  ),
                );
              },
            ),
          ),
          if (_uploading) const LinearProgressIndicator(minHeight: 2),
          // The composer is out of the way while a selection is active.
          if (_selectedIds.isNotEmpty)
            const SizedBox.shrink()
          else if (conversation.canPost(user.id))
            _buildInputArea(isDark, user, conversation)
          else
            _buildReadOnlyNotice(isDark),
        ],
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
            if (draft != null && _recordingPath == null) _buildDraftBanner(isDark, draft),
            if (_recordingPath != null)
              _buildRecordingBar(isDark, user, conversation)
            else
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
                      // "Enter is send" turns the return key into a send
                      // button; otherwise it stays a newline.
                      maxLines: _preferences.enterIsSend ? 1 : 4,
                      minLines: 1,
                      textInputAction:
                          _preferences.enterIsSend ? TextInputAction.send : TextInputAction.newline,
                      onSubmitted:
                          _preferences.enterIsSend ? (_) => _send(user, conversation) : null,
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
                          : _startRecording,
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

  Future<void> _forwardMany(UserEntity user, List<ChatMessage> messages) async {
    final conversations = await context.messages.watchConversations(user.id).first;
    if (!mounted) return;

    final selected = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ForwardSheet(conversations: conversations),
    );
    if (selected == null || selected.isEmpty || !mounted) return;

    for (final message in messages) {
      await context.messages.forwardMessage(
        message: message,
        conversationIds: selected,
        sender: user,
      );
    }
    if (!mounted) return;
    setState(_selectedIds.clear);
    context.showMessagingSnack('Forwarded to ${selected.length} chat(s)');
  }

  Future<void> _confirmDeleteMany(String conversationId, List<ChatMessage> messages) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(messages.length == 1
            ? 'Delete message?'
            : 'Delete ${messages.length} messages?'),
        content: const Text('They will be removed for everyone in the chat.'),
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

    for (final message in messages) {
      await context.messages.deleteMessage(conversationId, message.id);
    }
    if (mounted) setState(_selectedIds.clear);
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
        await _sendDocument(user, conversation);
      case AttachmentKind.audio:
        await _startRecording();
      case AttachmentKind.location:
        await _sendLocation(user, conversation);
      case AttachmentKind.contact:
        await _sendContact(user, conversation);
      case AttachmentKind.poll:
        await _sendPoll(user, conversation);
      case AttachmentKind.event:
        await _sendEvent(user, conversation);
    }
  }

  Future<void> _sendDocument(UserEntity user, ChatConversation conversation) async {
    final result = await FilePicker.pickFiles();
    final picked = result?.files.singleOrNull;
    if (picked?.path == null || !mounted) return;

    await _uploadAndSend(
      user: user,
      conversation: conversation,
      file: File(picked!.path!),
      fileName: picked.name,
      type: MessageType.file,
      failureMessage: 'Could not send document',
    );
  }

  Future<void> _sendLocation(UserEntity user, ChatConversation conversation) async {
    if (!await _ensureLocationPermission()) return;

    setState(() => _uploading = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      if (!mounted) return;
      await context.messages.sendMessage(
        conversationId: conversation.id,
        sender: user,
        content: '',
        type: MessageType.location,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      if (mounted) context.showMessagingSnack('Could not get your location: $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  /// Location is only ever requested at the moment the user taps Location -
  /// never at launch - so a denial has to be explained here.
  Future<bool> _ensureLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (mounted) context.showMessagingSnack('Turn on location services to share your location');
      return false;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) context.showMessagingSnack('Location permission is needed to share where you are');
      return false;
    }
    return true;
  }

  Future<void> _sendContact(UserEntity user, ChatConversation conversation) async {
    final contacts = await context.messages.getContacts(user.schoolId, excludeId: user.id);
    if (!mounted) return;

    final picked = await showModalBottomSheet<MessageContact>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ContactPickerSheet(contacts: contacts),
    );
    if (picked == null || !mounted) return;

    await context.messages.sendMessage(
      conversationId: conversation.id,
      sender: user,
      content: picked.name,
      type: MessageType.contact,
      sharedContactId: picked.id,
      sharedContactRole: picked.role,
    );
  }

  Future<void> _sendPoll(UserEntity user, ChatConversation conversation) async {
    final draft = await showModalBottomSheet<PollDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => const PollComposerSheet(),
    );
    if (draft == null || !mounted) return;

    await context.messages.sendMessage(
      conversationId: conversation.id,
      sender: user,
      content: draft.question,
      type: MessageType.poll,
      pollOptions: draft.options,
    );
  }

  Future<void> _sendEvent(UserEntity user, ChatConversation conversation) async {
    final draft = await showModalBottomSheet<EventDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => const EventComposerSheet(),
    );
    if (draft == null || !mounted) return;

    await context.messages.sendMessage(
      conversationId: conversation.id,
      sender: user,
      content: draft.title,
      type: MessageType.event,
      eventStart: draft.start,
      eventLocation: draft.location,
    );
  }

  /// Opens (or reuses) a chat with the person on a shared contact card.
  Future<void> _openSharedContact(UserEntity user, String contactId) async {
    if (contactId == user.id) return;
    final contact = await context.messages.getContact(contactId);
    if (contact == null || !mounted) {
      if (mounted) context.showMessagingSnack('That contact is no longer in the directory');
      return;
    }
    final id = await context.messages.startDirectConversation(me: user, contact: contact);
    if (!mounted) return;
    context.push('/messages/chat/$id');
  }

  Future<void> _sendImage(
    ImageSource source,
    UserEntity user,
    ChatConversation conversation,
  ) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 70);
    if (picked == null || !mounted) return;

    await _uploadAndSend(
      user: user,
      conversation: conversation,
      file: File(picked.path),
      fileName: picked.name,
      type: MessageType.image,
      failureMessage: 'Could not send photo',
    );
  }

  /// Upload-then-post, shared by photos, documents and voice notes: the file
  /// goes to Storage first, and only the resulting URL is written to the
  /// message.
  Future<void> _uploadAndSend({
    required UserEntity user,
    required ChatConversation conversation,
    required File file,
    required String fileName,
    required MessageType type,
    required String failureMessage,
    Duration? audioDuration,
  }) async {
    setState(() => _uploading = true);
    try {
      final url = await context.messages.uploadAttachment(
        schoolId: user.schoolId,
        conversationId: conversation.id,
        file: file,
        fileName: fileName,
      );
      if (!mounted) return;
      await context.messages.sendMessage(
        conversationId: conversation.id,
        sender: user,
        content: '',
        type: type,
        mediaUrl: url,
        fileName: fileName,
        fileSize: _readableSize(await file.length()),
        audioDuration: audioDuration,
      );
    } catch (e) {
      if (mounted) context.showMessagingSnack('$failureMessage: $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // --- Voice notes -------------------------------------------------------

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) {
      if (mounted) context.showMessagingSnack('Microphone permission is needed to record a voice note');
      return;
    }

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    if (!mounted) return;

    setState(() {
      _recordingPath = path;
      _recordedFor = Duration.zero;
    });
    _recordingTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordedFor += const Duration(seconds: 1));
    });
  }

  Future<void> _stopRecording({
    required bool send,
    UserEntity? user,
    ChatConversation? conversation,
  }) async {
    _recordingTicker?.cancel();
    _recordingTicker = null;

    final path = await _recorder.stop();
    final duration = _recordedFor;
    if (!mounted) return;
    setState(() {
      _recordingPath = null;
      _recordedFor = Duration.zero;
    });

    if (path == null) return;
    final file = File(path);

    // Cancelled, or a mis-tap too short to be a message.
    if (!send || duration < const Duration(seconds: 1)) {
      if (send) context.showMessagingSnack('Hold longer to record a voice note');
      if (await file.exists()) await file.delete();
      return;
    }
    if (user == null || conversation == null || !mounted) return;

    await _uploadAndSend(
      user: user,
      conversation: conversation,
      file: file,
      fileName: 'Voice note.m4a',
      type: MessageType.audio,
      audioDuration: duration,
      failureMessage: 'Could not send voice note',
    );
  }

  /// Replaces the composer row while a voice note is being recorded.
  Widget _buildRecordingBar(bool isDark, UserEntity user, ChatConversation conversation) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          tooltip: 'Discard',
          onPressed: () => _stopRecording(send: false),
        ),
        const SizedBox(width: 4),
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Recording  ${formatClipDuration(_recordedFor)}',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.electricBlue,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _stopRecording(send: true, user: user, conversation: conversation),
            ),
          ),
        ),
      ],
    );
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
