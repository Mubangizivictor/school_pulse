import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:just_audio/just_audio.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Quick reactions offered on long-press. Kept short on purpose - a school
/// chat doesn't need a full emoji keyboard.
const List<String> kQuickReactions = ['❤️', '👍', '🔥', '😂', '😮', '🙏'];

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  /// Group and channel threads label each bubble with its sender; a 1:1 chat
  /// doesn't need to.
  final bool isGroup;

  final VoidCallback? onReply;
  final VoidCallback? onForward;
  final VoidCallback? onStar;
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;
  final ValueChanged<String>? onReact;

  /// Casts a vote on a poll bubble, by option index.
  final ValueChanged<int>? onVote;

  /// Opens a chat with the person on a shared contact card.
  final ValueChanged<String>? onOpenContact;

  /// Enters multi-select from the long-press menu.
  final VoidCallback? onSelect;

  /// Adds or removes this bubble from an active selection.
  final VoidCallback? onToggleSelected;

  final bool isSelected;

  /// While true a plain tap selects instead of opening the message, and
  /// long-press does nothing.
  final bool selectionMode;

  /// Message text multiplier from Chat Settings › Font size.
  final double textScale;

  const MessageBubble({
    super.key,
    required this.message,
    this.isGroup = true,
    this.onSelect,
    this.onToggleSelected,
    this.isSelected = false,
    this.selectionMode = false,
    this.textScale = 1.0,
    this.onReply,
    this.onForward,
    this.onStar,
    this.onCopy,
    this.onEdit,
    this.onDelete,
    this.onPin,
    this.onReact,
    this.onVote,
    this.onOpenContact,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      // A selected row is tinted edge to edge, the way a list selection reads.
      color: isSelected
          ? (isDark ? AppColors.grey850 : AppColors.grey100)
          : null,
      child: Column(
        crossAxisAlignment: message.isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!message.isMe && isGroup)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                message.senderName.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: isDark ? AppColors.white : AppColors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ),
          GestureDetector(
            onTap: selectionMode ? onToggleSelected : null,
            onLongPress: message.isDeleted || selectionMode
                ? null
                : () => _showMessageActions(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              decoration: BoxDecoration(
                color: message.isMe
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? AppColors.grey850 : AppColors.grey50),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.black,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.replyToId != null) _buildQuote(context, isDark),
                  if (!message.isDeleted) _buildAttachment(context, isDark),
                  if (message.isDeleted)
                    Text(
                      'This message was deleted',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        color: message.isMe
                            ? (isDark ? Colors.black : Colors.white)
                            : AppColors.textMuted(context),
                      ),
                    )
                  else if (message.content.isNotEmpty)
                    Text(
                      message.content,
                      textScaler: TextScaler.linear(textScale),
                      style: AppTypography.bodyMedium.copyWith(
                        color: message.isMe
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? Colors.white : Colors.black),
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.isStarred) ...[
                        Icon(
                          Icons.star,
                          size: 10,
                          color: message.isMe
                              ? (isDark ? Colors.black : Colors.white)
                              : (isDark ? Colors.white : Colors.black),
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (message.isPinned) ...[
                        Icon(
                          Icons.push_pin,
                          size: 10,
                          color: message.isMe
                              ? (isDark ? Colors.black : Colors.white)
                              : (isDark ? Colors.white : Colors.black),
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (message.editedAt != null) ...[
                        Text(
                          'edited',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: message.isMe
                                ? (isDark ? Colors.black : Colors.white)
                                : AppColors.textMuted(context),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        DateFormat('HH:mm').format(message.timestamp),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: message.isMe
                              ? (isDark ? Colors.black : Colors.white)
                              : AppColors.textMuted(context),
                        ),
                      ),
                      if (message.isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 12,
                          color: isDark ? Colors.black : Colors.white,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (message.reactions.isNotEmpty) _buildReactions(context, isDark),
        ],
      ),
    );
  }

  Widget _buildQuote(BuildContext context, bool isDark) {
    final onBubble = message.isMe
        ? (isDark ? Colors.black : Colors.white)
        : (isDark ? Colors.white : Colors.black);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: message.isMe
            ? (isDark ? AppColors.grey100 : AppColors.grey900)
            : (isDark ? AppColors.grey900 : AppColors.grey100),
        border: Border(left: BorderSide(color: onBubble, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.replyToSender?.toUpperCase() ?? '',
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 10,
              color: onBubble,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message.replyToContent ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              color: onBubble.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Renders whatever hangs above the message text - a photo, a voice note,
  /// a document row, or one of the location / contact / poll / event cards.
  /// Plain text messages get nothing.
  Widget _buildAttachment(BuildContext context, bool isDark) {
    switch (message.type) {
      case MessageType.text:
        return const SizedBox.shrink();
      case MessageType.image:
      case MessageType.video:
        return message.mediaUrl == null
            ? const SizedBox.shrink()
            : _buildImage(context);
      case MessageType.audio:
        return message.mediaUrl == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: VoiceNoteBubble(
                  url: message.mediaUrl!,
                  duration: message.audioDuration,
                  onDark: message.isMe,
                ),
              );
      case MessageType.file:
        return _buildFileRow(context);
      case MessageType.location:
        return _buildLocationCard(context);
      case MessageType.contact:
        return _buildContactCard(context);
      case MessageType.poll:
        return _buildPoll(context, isDark);
      case MessageType.event:
        return _buildEventCard(context);
    }
  }

  Color _accent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return message.isMe
        ? (isDark ? Colors.black : Colors.white)
        : (isDark ? Colors.white : Colors.black);
  }

  Color _onBubble(BuildContext context) => _accent(context);

  /// Panel behind a card inside the bubble
  BoxDecoration _cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: message.isMe
          ? (isDark ? AppColors.grey100 : AppColors.grey900)
          : (isDark ? AppColors.grey900 : AppColors.grey100),
      border: Border.all(color: _accent(context).withOpacity(0.2)),
    );
  }

  Widget _buildFileRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: message.mediaUrl == null
            ? null
            : () => _openUrl(context, message.mediaUrl!),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: _cardDecoration(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _fileIcon(message.fileName),
                size: 24,
                color: _accent(context),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.fileName ?? 'Attachment',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _onBubble(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (message.fileSize != null)
                      Text(
                        message.fileSize!,
                        style: TextStyle(
                          fontSize: 11,
                          color: message.isMe
                              ? Colors.white
                              : AppColors.textMuted(context),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.file_download_outlined,
                size: 18,
                color: _accent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _fileIcon(String? fileName) {
    final extension = (fileName ?? '').toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildLocationCard(BuildContext context) {
    if (message.latitude == null || message.longitude == null) {
      return const SizedBox.shrink();
    }
    final coordinates =
        '${message.latitude!.toStringAsFixed(5)}, ${message.longitude!.toStringAsFixed(5)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () => _openUrl(
          context,
          // Geo URIs open the default map app on Android; iOS follows the
          // https form, which works on both.
          'https://maps.google.com/?q=${message.latitude},${message.longitude}',
        ),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(10),
          decoration: _cardDecoration(context),
          child: Row(
            children: [
              Icon(Icons.location_on, color: _accent(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Shared location',
                      style: TextStyle(
                        color: _onBubble(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      coordinates,
                      style: TextStyle(
                        fontSize: 11,
                        color: message.isMe
                            ? Colors.white
                            : AppColors.textMuted(context),
                      ),
                    ),
                    Text(
                      'Tap to open in Maps',
                      style: TextStyle(
                        fontSize: 11,
                        color: _accent(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: message.sharedContactId == null || onOpenContact == null
            ? null
            : () => onOpenContact!(message.sharedContactId!),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(10),
          decoration: _cardDecoration(context),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: message.isMe ? Colors.white : Colors.black,
                  border: Border.all(
                    color: _accent(context),
                    width: 1,
                  ),
                ),
                child: Icon(Icons.person, size: 20, color: _accent(context)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _onBubble(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _roleLabel(message.sharedContactRole),
                      style: TextStyle(
                        fontSize: 11,
                        color: message.isMe
                            ? Colors.white
                            : AppColors.textMuted(context),
                      ),
                    ),
                    if (onOpenContact != null)
                      Text(
                        'Tap to message',
                        style: TextStyle(
                          fontSize: 11,
                          color: _accent(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context) {
    if (message.eventStart == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(10),
        decoration: _cardDecoration(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.event, color: _accent(context)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('EEE, d MMM y').format(message.eventStart!),
                    style: TextStyle(
                      color: _onBubble(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('h:mm a').format(message.eventStart!),
                    style: TextStyle(
                      fontSize: 12,
                      color: message.isMe
                          ? Colors.white
                          : AppColors.textMuted(context),
                    ),
                  ),
                  if (message.eventLocation != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 12,
                            color: _accent(context),
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              message.eventLocation!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: message.isMe
                                    ? Colors.white
                                    : AppColors.textMuted(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoll(BuildContext context, bool isDark) {
    final options = message.pollOptions ?? const [];
    if (options.isEmpty) return const SizedBox.shrink();

    final tallies = message.pollVotes ?? const {};
    final total = tallies.values.fold<int>(0, (sum, count) => sum + count);

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: SizedBox(
        width: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < options.length; i++)
              _buildPollOption(
                context,
                i,
                options[i],
                tallies['$i'] ?? 0,
                total,
              ),
            const SizedBox(height: 2),
            Text(
              total == 1 ? '1 vote' : '$total votes',
              style: TextStyle(
                fontSize: 11,
                color: message.isMe
                    ? Colors.white
                    : AppColors.textMuted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollOption(
    BuildContext context,
    int index,
    String label,
    int votes,
    int total,
  ) {
    final chosen = message.myPollVote == index;
    // Bar fills proportionally once anyone has voted.
    final share = total == 0 ? 0.0 : votes / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: onVote == null ? null : () => onVote!(index),
        child: Stack(
          children: [
            Container(height: 34, decoration: _cardDecoration(context)),
            // The filled portion, drawn over the track.
            FractionallySizedBox(
              widthFactor: share,
              child: Container(
                height: 34,
                decoration: BoxDecoration(
                  color: message.isMe ? Colors.white : AppColors.electricBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(
              height: 34,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Icon(
                      chosen
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 14,
                      color: _accent(context),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: _onBubble(context),
                          fontWeight: chosen
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    Text(
                      '$votes',
                      style: TextStyle(
                        fontSize: 12,
                        color: message.isMe
                            ? Colors.white
                            : AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(String? roleName) {
    if (roleName == null || roleName.isEmpty) return 'School contact';
    final role = UserRole.values.where((r) => r.name == roleName);
    return role.isEmpty ? roleName : UserRoleDisplay.name(role.first);
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $url')));
    }
  }

  Widget _buildImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () => _openImage(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            message.mediaUrl!,
            width: 220,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const SizedBox(
                    width: 220,
                    height: 160,
                    child: Center(child: SchoolPulseLoader()),
                  ),
            errorBuilder: (context, error, stack) => const SizedBox(
              width: 220,
              height: 160,
              child: Center(
                child: Icon(Icons.broken_image_outlined, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(message.mediaUrl!, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactions(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: message.reactions.entries.map((entry) {
          final mine = message.myReaction == entry.key;
          return GestureDetector(
            onTap: onReact == null ? null : () => onReact!(entry.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgDark : Colors.white,
                border: Border.all(
                  color: mine
                      ? (isDark ? Colors.white : Colors.black)
                      : AppColors.grey300,
                  width: mine ? 2 : 1,
                ),
              ),
              child: Text(
                '${entry.key} ${entry.value}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showMessageActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MessageActionsMenu(
        message: message,
        onReply: onReply,
        onForward: onForward,
        onStar: onStar,
        onCopy: onCopy,
        onEdit: onEdit,
        onDelete: onDelete,
        onPin: onPin,
        onReact: onReact,
        onSelect: onSelect,
      ),
    );
  }
}

/// Play/pause row for a voice note, with a scrub bar and a running time.
///
/// Each bubble owns its own player so two voice notes can't fight over one:
/// [AudioPlayer] holds a platform decoder, hence the dispose in [dispose].
class VoiceNoteBubble extends StatefulWidget {
  final String url;
  final Duration? duration;

  /// True inside the sender's blue bubble, where everything is white.
  final bool onDark;

  const VoiceNoteBubble({
    super.key,
    required this.url,
    this.duration,
    required this.onDark,
  });

  @override
  State<VoiceNoteBubble> createState() => _VoiceNoteBubbleState();
}

class _VoiceNoteBubbleState extends State<VoiceNoteBubble> {
  final AudioPlayer _player = AudioPlayer();
  bool _loaded = false;
  bool _failed = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  /// The clip is only fetched on the first tap - loading every voice note in
  /// a scrollback would be a lot of wasted data on a school network.
  Future<void> _toggle() async {
    if (_failed) return;
    try {
      if (!_loaded) {
        await _player.setUrl(widget.url);
        _loaded = true;
      }
      if (_player.playing) {
        await _player.pause();
      } else {
        // Replay from the start once it has run to the end.
        if (_player.processingState == ProcessingState.completed) {
          await _player.seek(Duration.zero);
        }
        await _player.play();
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final foreground = widget.onDark ? Colors.white : AppColors.electricBlue;
    final muted = widget.onDark ? Colors.white : AppColors.textMuted(context);

    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: widget.onDark ? Colors.white : Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: StreamBuilder<PlayerState>(
        stream: _player.playerStateStream,
        builder: (context, snapshot) {
          final playing = snapshot.data?.playing ?? false;
          return Row(
            children: [
              GestureDetector(
                onTap: _toggle,
                child: Icon(
                  _failed
                      ? Icons.error_outline
                      : (playing
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill),
                  size: 32,
                  color: foreground,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, positionSnapshot) {
                    final total =
                        _player.duration ?? widget.duration ?? Duration.zero;
                    final position = positionSnapshot.data ?? Duration.zero;
                    final progress = total.inMilliseconds == 0
                        ? 0.0
                        : (position.inMilliseconds / total.inMilliseconds)
                              .clamp(0.0, 1.0);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          backgroundColor: muted,
                          valueColor: AlwaysStoppedAnimation(foreground),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _failed
                              ? 'Unavailable'
                              : formatClipDuration(
                                  position > Duration.zero ? position : total,
                                ),
                          style: TextStyle(fontSize: 11, color: muted),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// m:ss, the way a chat app shows clip length.
String formatClipDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class MessageActionsMenu extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onReply;
  final VoidCallback? onForward;
  final VoidCallback? onStar;
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;
  final ValueChanged<String>? onReact;
  final VoidCallback? onSelect;

  const MessageActionsMenu({
    super.key,
    required this.message,
    this.onReply,
    this.onForward,
    this.onStar,
    this.onCopy,
    this.onEdit,
    this.onDelete,
    this.onPin,
    this.onReact,
    this.onSelect,
  });

  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : Colors.white,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.black,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: kQuickReactions.map((emoji) {
                  final mine = message.myReaction == emoji;
                  return GestureDetector(
                    onTap: onReact == null
                        ? null
                        : () {
                            Navigator.pop(context);
                            onReact!(emoji);
                          },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: mine
                            ? (isDark ? Colors.white : Colors.black)
                            : null,
                        border: mine
                            ? null
                            : Border.all(color: AppColors.grey300),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1, thickness: 1),
            if (onReply != null)
              _ActionItem(icon: Icons.reply, label: 'REPLY', onTap: onReply!),
            if (onForward != null)
              _ActionItem(
                icon: Icons.forward,
                label: 'FORWARD',
                onTap: onForward!,
              ),
            if (onStar != null)
              _ActionItem(
                icon: message.isStarred ? Icons.star : Icons.star_border,
                label: message.isStarred ? 'UNSTAR' : 'STAR',
                onTap: onStar!,
              ),
            if (onPin != null)
              _ActionItem(
                icon: message.isPinned
                    ? Icons.push_pin
                    : Icons.push_pin_outlined,
                label: message.isPinned ? 'UNPIN' : 'PIN',
                onTap: onPin!,
              ),
            if (onCopy != null)
              _ActionItem(icon: Icons.copy, label: 'COPY', onTap: onCopy!),
            if (onEdit != null)
              _ActionItem(
                icon: Icons.edit_outlined,
                label: 'EDIT',
                onTap: onEdit!,
              ),
            if (onDelete != null)
              _ActionItem(
                icon: Icons.delete_outline,
                label: 'DELETE',
                onTap: onDelete!,
              ),
            if (onSelect != null)
              _ActionItem(
                icon: Icons.check_circle_outline,
                label: 'SELECT',
                onTap: onSelect!,
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white : Colors.black,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 13,
          letterSpacing: 1.1,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
