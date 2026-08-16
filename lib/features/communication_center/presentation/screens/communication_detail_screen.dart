import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/communication_center/data/models/communication_campaign_model.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_campaign.dart';
import 'package:school_pulse/features/communication_center/presentation/bloc/communication_bloc.dart';
import 'package:school_pulse/features/communication_center/presentation/bloc/communication_event.dart';
import 'package:school_pulse/features/communication_center/presentation/bloc/communication_state.dart';
import 'package:school_pulse/features/communication_center/presentation/widgets/campaign_status_chip.dart';
import 'package:school_pulse/injection_container.dart' as di;

class CommunicationDetailScreen extends StatelessWidget {
  final String campaignId;
  const CommunicationDetailScreen({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: SchoolPulseLoader()));
    }
    return BlocProvider(
      create: (_) => di.sl<CommunicationBloc>(),
      child: _DetailView(schoolId: auth.user.schoolId, campaignId: campaignId),
    );
  }
}

class _DetailView extends StatelessWidget {
  final String schoolId;
  final String campaignId;
  const _DetailView({required this.schoolId, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(title: 'Communication'),
      body: BlocListener<CommunicationBloc, CommunicationState>(
        listener: (context, state) {
          if (state is CommunicationActionDenied ||
              state is CommunicationError) {
            final message = state is CommunicationActionDenied
                ? state.message
                : (state as CommunicationError).message;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
          if (state is CommunicationActionSuccess &&
              state.message.contains('corrected draft') &&
              state.campaignId != null) {
            context.pushReplacement(
              '/staff/admin/communication-center/compose?campaignId=${state.campaignId}',
            );
          }
        },
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('schools')
              .doc(schoolId)
              .collection('communication_campaigns')
              .doc(campaignId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: SchoolPulseLoader());
            }
            if (!snapshot.data!.exists) {
              return const Center(
                child: Text('This communication no longer exists.'),
              );
            }
            final campaign = CommunicationCampaignModel.fromFirestore(
              snapshot.data!,
            );
            return _DetailBody(campaign: campaign);
          },
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final CommunicationCampaign campaign;
  const _DetailBody({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final dateFormat = DateFormat('MMM d, y • h:mm a');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                campaign.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            CampaignStatusChip(status: campaign.status),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${campaign.communicationType.label} • ${campaign.senderNameSnapshot}'
          '${campaign.senderRoleSnapshot != null ? ' (${campaign.senderRoleSnapshot})' : ''}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (campaign.publishedAt != null)
          Text('Published ${dateFormat.format(campaign.publishedAt!)}'),
        if (campaign.scheduledAt != null && campaign.publishedAt == null)
          Text('Scheduled for ${dateFormat.format(campaign.scheduledAt!)}'),
        const Divider(height: 32),
        if (campaign.imageUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(campaign.imageUrl!, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
        ],
        Text(campaign.body),
        if (campaign.attachmentRefs.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Attachments', style: Theme.of(context).textTheme.titleSmall),
          ...campaign.attachmentRefs.map(
            (url) => ListTile(
              leading: const Icon(Icons.attach_file),
              title: Text(url.split('/').last),
              onTap: () {},
            ),
          ),
        ],
        const Divider(height: 32),
        Text('Audience', style: Theme.of(context).textTheme.titleSmall),
        Text(campaign.audienceDefinition.description),
        Text('Channels: ${campaign.deliveryChannels.join(', ')}'),
        if (campaign.audienceSnapshot != null) ...[
          const SizedBox(height: 8),
          Text(
            'Addressed to ${campaign.audienceSnapshot!.recipientCount} recipient(s)'
            '${campaign.audienceSnapshot!.truncated ? ' (large audience)' : ''} '
            'at the moment this was published.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        BlocBuilder<CommunicationBloc, CommunicationState>(
          builder: (context, state) {
            final canViewDelivery =
                state is CommunicationLoaded && state.canViewDelivery;
            if (!canViewDelivery && campaign.status.isSent) {
              return const SizedBox.shrink();
            }
            if (!campaign.status.isSent) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 32),
                Text('Delivery', style: Theme.of(context).textTheme.titleSmall),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _StatChip(
                      label: 'Audience',
                      value: '${campaign.deliverySummary.totalAudience}',
                    ),
                    _StatChip(
                      label: 'Delivered',
                      value: '${campaign.deliverySummary.pushSent}',
                    ),
                    _StatChip(
                      label: 'Failed',
                      value: '${campaign.deliverySummary.pushFailed}',
                    ),
                  ],
                ),
                if (campaign.failureReason != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Failure reason: ${campaign.failureReason}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        if (auth is AuthAuthenticated)
          Wrap(
            spacing: 12,
            children: [
              if (campaign.acknowledgementRequired && campaign.status.isSent)
                FilledButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Acknowledge'),
                  onPressed: () => context.read<CommunicationBloc>().add(
                    AcknowledgeCommunicationCampaignRequested(
                      schoolId: campaign.schoolId,
                      campaignId: campaign.campaignId,
                    ),
                  ),
                ),
              if (campaign.status.isCancellable)
                OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel'),
                  onPressed: () => context.read<CommunicationBloc>().add(
                    CancelCommunicationCampaignRequested(
                      schoolId: campaign.schoolId,
                      campaignId: campaign.campaignId,
                      operatorUser: auth.user,
                    ),
                  ),
                ),
              if (campaign.status.isEditable)
                FilledButton.icon(
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit draft'),
                  onPressed: () => context.push(
                    '/staff/admin/communication-center/compose?campaignId=${campaign.campaignId}',
                  ),
                ),
              if (campaign.status.isSent)
                OutlinedButton.icon(
                  icon: const Icon(Icons.content_copy_outlined),
                  label: const Text('Send a correction'),
                  onPressed: () => context.read<CommunicationBloc>().add(
                    SupersedeCommunicationCampaignRequested(
                      schoolId: campaign.schoolId,
                      campaignId: campaign.campaignId,
                      operatorUser: auth.user,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}
