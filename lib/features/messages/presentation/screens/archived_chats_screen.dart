import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/messages/presentation/messaging_context.dart';
import 'package:school_pulse/features/messages/presentation/widgets/chat_list_tile.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';

class ArchivedChatsScreen extends StatelessWidget {
  const ArchivedChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: MessagingUserBuilder(
        builder: (context, user) => StreamBuilder<List<ChatConversation>>(
          stream: context.messages.watchConversations(user.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final archived = snapshot.data!.where((c) => c.isArchived).toList();
            if (archived.isEmpty) return _buildEmptyState();

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: archived.length,
              itemBuilder: (context, index) {
                final chat = archived[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ChatListTile(
                    chat: chat,
                    onTap: () => context.push('/messages/chat/${chat.id}'),
                    // Long-press is the only way back out of the archive.
                    onLongPress: () => _confirmUnarchive(context, user.id, chat),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _confirmUnarchive(BuildContext context, String userId, ChatConversation chat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.unarchive_outlined, color: Colors.white70),
              title: const Text('Unarchive', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(sheetContext);
                context.messages.setArchived(chat.id, userId, false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(sheetContext);
                context.messages.leaveConversation(chat.id, userId);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
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
    );
  }
}
