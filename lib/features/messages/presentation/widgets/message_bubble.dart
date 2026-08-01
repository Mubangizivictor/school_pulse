import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:intl/intl.dart';

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

  const MessageBubble({
    super.key,
    required this.message,
    this.isGroup = true,
    this.onReply,
    this.onForward,
    this.onStar,
    this.onCopy,
    this.onEdit,
    this.onDelete,
    this.onPin,
    this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Column(
        crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!message.isMe && isGroup)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                message.senderName,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.electricBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          GestureDetector(
            onLongPress: message.isDeleted ? null : () => _showMessageActions(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: message.isMe
                    ? AppColors.electricBlue
                    : (isDark ? AppColors.surfaceContainerHigh(context) : Colors.grey[200]),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isMe ? 16 : 4),
                  bottomRight: Radius.circular(message.isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.replyToId != null) _buildQuote(context, isDark),
                  if (message.mediaUrl != null && !message.isDeleted) _buildMedia(context),
                  if (message.isDeleted)
                    Text(
                      'This message was deleted',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: message.isMe ? Colors.white70 : AppColors.textMuted(context),
                      ),
                    )
                  else if (message.content.isNotEmpty)
                    Text(
                      message.content,
                      style: TextStyle(
                        color: message.isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.isStarred) ...[
                        Icon(
                          Icons.star,
                          size: 10,
                          color: message.isMe ? Colors.white70 : AppColors.goldenYellow,
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (message.isPinned) ...[
                        Icon(
                          Icons.push_pin,
                          size: 10,
                          color: message.isMe ? Colors.white70 : AppColors.textMuted(context),
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (message.editedAt != null) ...[
                        Text(
                          'edited',
                          style: TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: message.isMe ? Colors.white70 : AppColors.textMuted(context),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        DateFormat('HH:mm').format(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: message.isMe ? Colors.white70 : AppColors.textMuted(context),
                        ),
                      ),
                      if (message.isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 12,
                          color: Colors.white70,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: message.isMe ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: message.isMe ? Colors.white : AppColors.electricBlue,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.replyToSender ?? '',
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: message.isMe ? Colors.white : AppColors.electricBlue,
            ),
          ),
          Text(
            message.replyToContent ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              color: message.isMe ? Colors.white70 : AppColors.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedia(BuildContext context) {
    if (message.type != MessageType.image) {
      // Any other uploaded file renders as a download row.
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file,
                size: 20, color: message.isMe ? Colors.white : AppColors.electricBlue),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.fileName ?? 'Attachment',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: message.isMe ? Colors.white : null),
              ),
            ),
          ],
        ),
      );
    }

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
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
            errorBuilder: (context, error, stack) => const SizedBox(
              width: 220,
              height: 160,
              child: Center(child: Icon(Icons.broken_image_outlined, color: Colors.white54)),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: mine ? AppColors.electricBlue : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '${entry.key} ${entry.value}',
                style: const TextStyle(fontSize: 11),
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
      ),
    );
  }
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
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
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
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: mine ? AppColors.electricBlue.withValues(alpha: 0.2) : null,
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1),
            if (onReply != null) _ActionItem(icon: Icons.reply, label: 'Reply', onTap: onReply!),
            if (onForward != null) _ActionItem(icon: Icons.forward, label: 'Forward', onTap: onForward!),
            if (onStar != null)
              _ActionItem(
                icon: message.isStarred ? Icons.star : Icons.star_border,
                label: message.isStarred ? 'Unstar' : 'Star',
                onTap: onStar!,
              ),
            if (onPin != null)
              _ActionItem(
                icon: message.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                label: message.isPinned ? 'Unpin' : 'Pin',
                onTap: onPin!,
              ),
            if (onCopy != null) _ActionItem(icon: Icons.copy, label: 'Copy', onTap: onCopy!),
            if (onEdit != null) _ActionItem(icon: Icons.edit_outlined, label: 'Edit', onTap: onEdit!),
            if (onDelete != null)
              _ActionItem(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: Colors.red,
                onTap: onDelete!,
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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
  final Color? color;
  final VoidCallback onTap;

  const _ActionItem({required this.icon, required this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
