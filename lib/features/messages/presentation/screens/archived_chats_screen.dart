import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/messages/presentation/widgets/chat_list_tile.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';

class ArchivedChatsScreen extends StatelessWidget {
  const ArchivedChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock archived chats
    final List<ChatConversation> archivedChats = [
      ChatConversation(
        id: 'archived_1',
        title: 'Old Class Project',
        type: ChatType.group,
        unreadCount: 0,
        avatarUrl: 'https://i.pravatar.cc/150?u=project',
        participants: [],
        lastMessage: ChatMessage(
          id: 'm_arch_1',
          senderId: 'user1',
          senderName: 'User',
          content: 'Thanks for the help everyone!',
          timestamp: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ),
      ChatConversation(
        id: 'archived_2',
        title: 'Coach Mike',
        type: ChatType.direct,
        unreadCount: 0,
        avatarUrl: 'https://i.pravatar.cc/150?u=coach',
        participants: [],
        lastMessage: ChatMessage(
          id: 'm_arch_2',
          senderId: 'coach',
          senderName: 'Coach Mike',
          content: 'See you next season.',
          timestamp: DateTime.now().subtract(const Duration(days: 45)),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(
          'Archived',
          style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: archivedChats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.archive_outlined,
                      size: 80,
                      color: AppColors.electricBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'No archived chats',
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'These chats stay archived when new messages are received.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: archivedChats.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ChatListTile(
                    chat: archivedChats[index],
                    onTap: () {},
                  ),
                );
              },
            ),
    );
  }
}
