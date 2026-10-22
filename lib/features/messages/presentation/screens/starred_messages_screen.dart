import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
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
        title: Text(
          'STARRED MESSAGES',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
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
              return _buildMessage(
                context,
                'Could not load starred messages.\n${snapshot.error}',
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: SchoolPulseLoader());
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
                  onTap: () =>
                      context.push('/messages/chat/${ref.conversationId}'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.m),
                    decoration: BoxDecoration(
                      color: AppColors.background(context),
                      border: Border.all(
                        color: AppColors.border(context),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.background(context),
                                  border: Border.all(
                                    color: AppColors.border(context),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    ref.message.senderName.isEmpty
                                        ? '?'
                                        : ref.message.senderName[0]
                                            .toUpperCase(),
                                    style: TextStyle(
                                      color: AppColors.textPrimary(context),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ref.message.senderName.toUpperCase(),
                                      style: AppTypography.titleSmall.copyWith(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      'IN ${ref.conversationTitle.toUpperCase()}',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.textPrimary(context),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.star,
                                  size: 18,
                                  color: AppColors.textPrimary(context),
                                ),
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
                            (ref.message.content.isEmpty
                                    ? (ref.message.fileName ?? 'Attachment')
                                    : ref.message.content)
                                .toUpperCase(),
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                DateFormat(
                                  'h:mm a • dd/MM/yy',
                                ).format(ref.message.timestamp).toUpperCase(),
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textPrimary(context),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 8,
                                ),
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
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textMuted(context),
          ),
        ),
      ),
    );
  }
}
