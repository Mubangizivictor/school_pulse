import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:intl/intl.dart';

class ChatListTile extends StatelessWidget {
  final ChatConversation chat;
  final VoidCallback onTap;

  /// Opens the pin / mute / archive / delete sheet. Optional so the archived
  /// and search lists can reuse the tile without those actions.
  final VoidCallback? onLongPress;

  const ChatListTile({
    super.key,
    required this.chat,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        ListTile(
          onTap: onTap,
          onLongPress: onLongPress,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: 8,
          ),
          leading: Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey850 : AppColors.grey100,
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.black,
                  ),
                  image: chat.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(chat.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: chat.avatarUrl != null
                    ? null
                    : Text(
                        _avatarLabel(chat.title),
                        style: AppTypography.titleMedium.copyWith(
                          color: isDark ? AppColors.white : AppColors.black,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
              if (chat.type == ChatType.group)
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.white : AppColors.black,
                      border: Border.all(
                        color: isDark ? AppColors.bgDark : Colors.white,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.group,
                      size: 10,
                      color: isDark ? AppColors.black : AppColors.white,
                    ),
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
                    fontWeight:
                        chat.unreadCount > 0 ? FontWeight.w900 : FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.black,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                chat.hasMessages ? _timeLabel(chat.lastMessage.timestamp) : '',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: chat.unreadCount > 0
                      ? (isDark ? AppColors.white : AppColors.black)
                      : AppColors.grey500,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    chat.hasMessages
                        ? chat.lastMessage.content
                        : 'No messages yet',
                    style: AppTypography.bodySmall.copyWith(
                      color: chat.unreadCount > 0
                          ? (isDark ? Colors.white : AppColors.black)
                          : AppColors.grey500,
                      fontWeight: chat.unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (chat.unreadCount > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.white : AppColors.black,
                      border: Border.all(
                        color: isDark ? AppColors.black : AppColors.white,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      chat.unreadCount.toString(),
                      style: TextStyle(
                        color: isDark ? AppColors.black : AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          indent: 88,
          endIndent: 0,
          color: isDark ? AppColors.borderDark : AppColors.grey100,
        ),
      ],
    );
  }

  /// Two characters for a titled group ("P7 - Parents" -> "P7"), one for a
  /// person's name.
  String _avatarLabel(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return '?';
    final firstWord = trimmed.split(RegExp(r'\s+')).first;
    final wantsTwo = firstWord.length >= 2 && firstWord.contains(RegExp(r'\d'));
    return trimmed.substring(0, wantsTwo ? 2 : 1).toUpperCase();
  }

  /// Today shows a clock, this week a weekday, anything older a date - the
  /// inbox reaches back further than a single day.
  String _timeLabel(DateTime timestamp) {
    final now = DateTime.now();
    final sameDay =
        now.year == timestamp.year &&
        now.month == timestamp.month &&
        now.day == timestamp.day;
    if (sameDay) return DateFormat('HH:mm').format(timestamp);
    if (now.difference(timestamp).inDays < 7) {
      return DateFormat('EEE').format(timestamp);
    }
    return DateFormat('dd/MM/yy').format(timestamp);
  }
}
