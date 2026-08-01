import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:intl/intl.dart';

class ChatListTile extends StatelessWidget {
  final ChatConversation chat;
  final VoidCallback onTap;

  const ChatListTile({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.electricBlue.withValues(alpha: 0.1),
            child: chat.avatarUrl != null 
              ? ClipOval(child: Image.network(chat.avatarUrl!, fit: BoxFit.cover))
              : Text(
                  chat.title.substring(0, chat.title.startsWith('P7') ? 2 : 1),
                  style: const TextStyle(color: AppColors.electricBlue, fontWeight: FontWeight.bold),
                ),
          ),
          if (chat.type == ChatType.group)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.group, size: 12, color: AppColors.electricBlue),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chat.title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            DateFormat('HH:mm').format(chat.lastMessage.timestamp),
            style: AppTypography.labelSmall.copyWith(
              color: chat.unreadCount > 0 ? AppColors.electricBlue : AppColors.textMuted(context),
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              chat.lastMessage.content,
              style: AppTypography.bodySmall.copyWith(
                color: chat.unreadCount > 0 
                  ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)
                  : AppColors.textMuted(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (chat.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.electricBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                chat.unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
