import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/messaging_context.dart';

class StarredMessagesScreen extends StatelessWidget {
  const StarredMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Starred Messages', style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.textPrimary(context)),
            onPressed: () => context.push('/messages/search'),
          ),
        ],
      ),
      body: MessagingUserBuilder(
        builder: (context, user) => StreamBuilder<List<ChatMessageRef>>(
          stream: context.messages.watchStarredMessages(user.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildMessage(context, 'Could not load starred messages.\n${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final starred = snapshot.data!;
            if (starred.isEmpty) {
              return _buildMessage(
                context,
                'Long-press any message and tap Star to keep it here.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.m),
              itemCount: starred.length,
              itemBuilder: (context, index) {
                final ref = starred[index];
                return InkWell(
                  onTap: () => context.push('/messages/chat/${ref.conversationId}'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.m),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.royalBlue,
                                child: Text(
                                  ref.message.senderName.isEmpty
                                      ? '?'
                                      : ref.message.senderName[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ref.message.senderName, style: AppTypography.titleSmall),
                                    Text('in ${ref.conversationTitle}',
                                        style: AppTypography.labelSmall
                                            .copyWith(color: AppColors.textMuted(context))),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.star, size: 18, color: AppColors.goldenYellow),
                                onPressed: () => context.messages.setStarred(
                                  ref.conversationId,
                                  ref.message.id,
                                  user.id,
                                  false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            ref.message.content.isEmpty
                                ? (ref.message.fileName ?? 'Attachment')
                                : ref.message.content,
                            style: AppTypography.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                DateFormat('h:mm a • dd/MM/yy').format(ref.message.timestamp),
                                style: AppTypography.labelSmall
                                    .copyWith(color: AppColors.textMuted(context)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessage(BuildContext context, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3l),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted(context)),
        ),
      ),
    );
  }
}
