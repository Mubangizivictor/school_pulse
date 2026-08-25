import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/messages/presentation/bloc/messaging_bloc.dart';
import 'package:school_pulse/features/messages/presentation/messaging_context.dart';
import 'package:school_pulse/features/messages/presentation/widgets/chat_list_tile.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';

class ArchivedChatsScreen extends StatelessWidget {
  const ArchivedChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          'Archived',
          style: AppTypography.titleLarge.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: MessagingUserBuilder(
        builder: (context, user) => BlocBuilder<MessagingBloc, MessagingState>(
          bloc: context.messagingBloc,
          builder: (context, state) {
            final conversations = state.conversations;
            if (conversations == null) {
              return const Center(child: SchoolPulseLoader());
            }
            final archived = conversations.where((c) => c.isArchived).toList();
            if (archived.isEmpty) return _buildEmptyState(context);

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
                    onLongPress: () => _confirmUnarchive(context, chat),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _confirmUnarchive(BuildContext context, ChatConversation chat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.unarchive_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              title: Text(
                'Unarchive',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                context.messagingBloc.add(
                  ConversationArchivedSet(chat.id, false),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.black),
              title: const Text(
                'Delete',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                context.messagingBloc.add(ConversationLeaveRequested(chat.id));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.archive_outlined,
              size: 80,
              color: AppColors.electricBlue,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'No archived chats',
            style: AppTypography.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
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
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
