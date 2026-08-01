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
    final List<ChatThread> archivedChats = [
      ChatThread(
        id: 'archived_1',
        title: 'Old Class Project',
        lastMessage: 'Thanks for the help everyone!',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 30)),
        isGroup: true,
        unreadCount: 0,
        avatarUrl: 'https://i.pravatar.cc/150?u=project',
      ),
      ChatThread(
        id: 'archived_2',
        title: 'Coach Mike',
        lastMessage: 'See you next season.',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 45)),
        unreadCount: 0,
        avatarUrl: 'https://i.pravatar.cc/150?u=coach',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text('Archived', style: AppTypography.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: archivedChats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 80,
                    color: AppColors.royalBlue.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    'No archived chats',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textMuted(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Text(
                      'These chats stay archived when new messages are received.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: archivedChats.length,
              itemBuilder: (context, index) {
                return ChatListTile(
                  chat: archivedChats[index],
                  onTap: () {
                    // In a real app, maybe navigate to chat or show unarchive option
                  },
                );
              },
            ),
    );
  }
}
