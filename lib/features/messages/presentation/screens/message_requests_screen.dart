import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/bloc/messaging_bloc.dart';
import 'package:school_pulse/features/messages/presentation/messaging_context.dart';

/// Chats started by another parent or student that the signed-in user hasn't
/// accepted yet. Anything involving a staff account is school business and
/// never lands here - see MessagesRepositoryImpl.startDirectConversation.
class MessageRequestsScreen extends StatelessWidget {
  const MessageRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Message Requests', style: AppTypography.titleLarge),
          bottom: TabBar(
            labelColor: AppColors.electricBlue,
            unselectedLabelColor: AppColors.textMuted(context),
            indicatorColor: AppColors.electricBlue,
            labelStyle: AppTypography.titleSmall,
            tabs: const [
              Tab(text: 'You May Know'),
              Tab(text: 'Spam'),
            ],
          ),
        ),
        body: MessagingUserBuilder(
          builder: (context, user) =>
              BlocBuilder<MessagingBloc, MessagingState>(
                bloc: context.messagingBloc,
                builder: (context, state) {
                  final conversations = state.conversations;
                  if (conversations == null) {
                    return const Center(child: SchoolPulseLoader());
                  }
                  final pending = conversations
                      .where((c) => c.type == ChatType.direct && !c.isAccepted)
                      .toList();

                  return TabBarView(
                    children: [
                      _buildRequestsList(context, pending, spam: false),
                      _buildRequestsList(context, pending, spam: true),
                    ],
                  );
                },
              ),
        ),
      ),
    );
  }

  Widget _buildRequestsList(
    BuildContext context,
    List<ChatConversation> requests, {
    required bool spam,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = requests.where((c) => c.isSpam == spam).toList();

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: AppColors.textMuted(context).withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                spam ? 'No Spam Requests' : 'No Pending Requests',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textMuted(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                spam
                    ? 'Messages you mark as spam will appear here.'
                    : 'Chats started by people outside your usual contacts will appear here.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final request = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.m),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.electricBlue.withValues(
                        alpha: 0.1,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.electricBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(request.title, style: AppTypography.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            request.hasMessages
                                ? request.lastMessage.content
                                : 'Wants to message you',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      request.hasMessages
                          ? DateFormat(
                              'dd/MM',
                            ).format(request.lastMessage.timestamp)
                          : '',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.messagingBloc.add(
                          ConversationLeaveRequested(request.id),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (!spam) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.messagingBloc.add(
                            ConversationMarkedSpam(request.id),
                          ),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Spam'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          context.messagingBloc.add(
                            ConversationRequestAccepted(request.id),
                          );
                          context.push('/messages/chat/${request.id}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.emeraldGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
