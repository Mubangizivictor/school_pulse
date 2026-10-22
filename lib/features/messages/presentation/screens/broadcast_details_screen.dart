import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/bloc/conversation_bloc.dart';
import 'package:school_pulse/features/messages/presentation/messaging_context.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Info screen for a broadcast list or announcement channel - who receives
/// it, when it was created, and (for its admins) how to take it down.
class BroadcastDetailsScreen extends StatelessWidget {
  final String broadcastId;

  const BroadcastDetailsScreen({super.key, required this.broadcastId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConversationBloc>(
      create: (_) => di.sl<ConversationBloc>(),
      child: _BroadcastDetailsView(broadcastId: broadcastId),
    );
  }
}

class _BroadcastDetailsView extends StatefulWidget {
  final String broadcastId;
  const _BroadcastDetailsView({required this.broadcastId});

  @override
  State<_BroadcastDetailsView> createState() => _BroadcastDetailsViewState();
}

class _BroadcastDetailsViewState extends State<_BroadcastDetailsView> {
  static const int _previewCount = 5;
  bool _showAllRecipients = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          'Broadcast Info',
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
        builder: (context, user) {
          context.read<ConversationBloc>().add(
            ConversationOpened(widget.broadcastId, user),
          );
          return BlocBuilder<ConversationBloc, ConversationState>(
            builder: (context, convoState) {
              final conversation = convoState.conversation;
              if (conversation == null) {
                return Center(
                  child: convoState.conversationMissing
                      ? Text(
                          'Broadcast not found',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        )
                      : const SchoolPulseLoader(),
                );
              }
              return _buildBody(context, user, conversation);
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    UserEntity user,
    ChatConversation conversation,
  ) {
    final recipients = conversation.participants
        .where((p) => p.id != user.id)
        .toList();
    final visible = _showAllRecipients
        ? recipients
        : recipients.take(_previewCount).toList();
    final amAdmin = conversation.isAdmin(user.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.electricBlue, width: 1),
                    image: conversation.avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(conversation.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: conversation.avatarUrl != null
                      ? null
                      : const Icon(
                          Icons.campaign_rounded,
                          size: 50,
                          color: AppColors.electricBlue,
                        ),
                ),
                const SizedBox(height: AppSpacing.l),
                Text(
                  conversation.title,
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${conversation.type == ChatType.channel ? 'Channel' : 'Broadcast'} • '
                  '${recipients.length} recipients',
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x3l),
          Text(
            'Recipients',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.electricBlue,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white),
            ),
            child: Column(
              children: [
                // A broadcast is one-way: recipients must not be able to
                // enumerate each other, so only its admins see the list.
                if (!amAdmin)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Text(
                            'Recipients are only visible to whoever manages this list.',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (recipients.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Text(
                      'No recipients yet',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visible.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.white, indent: 72),
                    itemBuilder: (context, index) {
                      final recipient = visible[index];
                      final role = UserRole.values.where(
                        (r) => r.name == recipient.role,
                      );
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.electricBlue,
                          child: Text(
                            recipient.name.isEmpty
                                ? '?'
                                : recipient.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          recipient.name,
                          style: AppTypography.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          role.isEmpty
                              ? recipient.role
                              : UserRoleDisplay.name(role.first),
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        trailing: amAdmin
                            ? IconButton(
                                icon: const Icon(
                                  Icons.person_remove_outlined,
                                  size: 18,
                                  color: Colors.black,
                                ),
                                onPressed: () =>
                                    context.read<ConversationBloc>().add(
                                      ConversationMemberRemoved(
                                        conversation.adminIds,
                                        recipient.id,
                                      ),
                                    ),
                              )
                            : null,
                      );
                    },
                  ),
                if (amAdmin && recipients.length > _previewCount) ...[
                  const Divider(height: 1, color: Colors.white),
                  TextButton(
                    onPressed: () => setState(
                      () => _showAllRecipients = !_showAllRecipients,
                    ),
                    child: Text(
                      _showAllRecipients
                          ? 'Show fewer'
                          : 'View all ${recipients.length} recipients',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.electricBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x3l),
          if (conversation.description != null &&
              conversation.description!.isNotEmpty)
            _buildInfoTile(
              context,
              icon: Icons.info_outline,
              title: 'Description',
              subtitle: conversation.description!,
            ),
          _buildInfoTile(
            context,
            icon: Icons.calendar_today_outlined,
            title: 'Created',
            subtitle: conversation.createdAt == null
                ? 'Unknown'
                : DateFormat('MMMM d, y').format(conversation.createdAt!),
          ),
          _buildInfoTile(
            context,
            icon: Icons.admin_panel_settings_outlined,
            title: 'Who can send messages?',
            subtitle: conversation.messagePolicy == MessagePolicy.everyone
                ? 'All members'
                : 'Admins only',
          ),
          const SizedBox(height: AppSpacing.x3l),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () =>
                  _confirmDelete(context, user, conversation, amAdmin),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.black, width: 1),
                ),
              ),
              child: Text(
                amAdmin ? 'Delete Broadcast List' : 'Leave Broadcast List',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    UserEntity user,
    ChatConversation conversation,
    bool amAdmin,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          amAdmin ? 'Delete broadcast list?' : 'Leave broadcast list?',
        ),
        content: Text(
          amAdmin
              ? 'Recipients will stop receiving messages from this list.'
              : 'You will stop receiving messages from this list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              amAdmin ? 'Delete' : 'Leave',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    context.read<ConversationBloc>().add(const ConversationLeft());
    context.go('/messages');
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
