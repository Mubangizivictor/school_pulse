import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/messaging_context.dart';

class PinnedMessagesScreen extends StatelessWidget {
  const PinnedMessagesScreen({super.key});

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
        title: Text('Pinned Messages', style: AppTypography.titleLarge),
      ),
      body: MessagingUserBuilder(
        builder: (context, user) => StreamBuilder<List<ChatMessageRef>>(
          stream: context.messages.watchPinnedMessages(user.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildMessage(
                context,
                'Could not load pinned messages.\n${snapshot.error}',
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: SchoolPulseLoader());
            }
            final pinned = snapshot.data!;
            if (pinned.isEmpty) {
              return _buildMessage(
                context,
                'Long-press an important message and tap Pin to keep it at the top of a chat.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.m),
              itemCount: pinned.length,
              itemBuilder: (context, index) {
                final ref = pinned[index];
                return InkWell(
                  onTap: () =>
                      context.push('/messages/chat/${ref.conversationId}'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.m),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.zero,
                      border: Border.all(color: AppColors.textPrimary(context), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.push_pin,
                                size: 16,
                                color: AppColors.textPrimary(context),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'PINNED BY ${ref.message.senderName.toUpperCase()}',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textPrimary(context),
                                    fontWeight: FontWeight.w900,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'dd/MM/yy',
                                ).format(ref.message.timestamp),
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textMuted(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            ref.message.content.isEmpty
                                ? (ref.message.fileName ?? 'Attachment')
                                : ref.message.content,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'in ${ref.conversationTitle}',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textMuted(context),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.messages.setMessagePinned(
                                      ref.conversationId,
                                      ref.message,
                                      false,
                                    ),
                                child: Text(
                                  'UNPIN',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textPrimary(context),
                                    fontWeight: FontWeight.w900,
                                  ),
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
