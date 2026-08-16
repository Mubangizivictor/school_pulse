import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_campaign.dart';
import 'package:school_pulse/features/communication_center/presentation/bloc/communication_bloc.dart';
import 'package:school_pulse/features/communication_center/presentation/bloc/communication_event.dart';
import 'package:school_pulse/features/communication_center/presentation/bloc/communication_state.dart';
import 'package:school_pulse/features/communication_center/presentation/widgets/campaign_status_chip.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Communication history: search + filter over every campaign this
/// institution has sent, scheduled, or drafted. Create/schedule/publish/
/// cancel all happen through CommunicationBloc, which orchestrates the
/// existing notification delivery engine rather than a second one.
class CommunicationCenterScreen extends StatelessWidget {
  const CommunicationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: SchoolPulseLoader()));
    }
    return BlocProvider(
      create: (_) => di.sl<CommunicationBloc>()
        ..add(
          WatchCommunicationCampaignsRequested(
            schoolId: auth.user.schoolId,
            operatorUser: auth.user,
          ),
        ),
      child: const _CommunicationCenterView(),
    );
  }
}

class _CommunicationCenterView extends StatefulWidget {
  const _CommunicationCenterView();

  @override
  State<_CommunicationCenterView> createState() =>
      _CommunicationCenterViewState();
}

class _CommunicationCenterViewState extends State<_CommunicationCenterView> {
  String _search = '';
  String _statusFilter = 'all';

  static const _statusFilters = {
    'all': 'All',
    'draft': 'Draft',
    'scheduled': 'Scheduled',
    'published': 'Published',
    'failed': 'Failed',
    'cancelled': 'Cancelled',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminAppBar(
        title: 'Communication Center',
        actions: [
          BlocBuilder<CommunicationBloc, CommunicationState>(
            builder: (context, state) {
              final canManageTemplates =
                  state is CommunicationLoaded && state.canManageTemplates;
              if (!canManageTemplates) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.description_outlined),
                tooltip: 'Templates',
                onPressed: () =>
                    context.push('/staff/admin/communication-center/templates'),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<CommunicationBloc, CommunicationState>(
        listener: (context, state) {
          if (state is CommunicationActionDenied) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is CommunicationLoading || state is CommunicationInitial) {
            return const Center(child: SchoolPulseLoader());
          }
          if (state is CommunicationError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Couldn’t load communications',
              message: state.message,
            );
          }
          if (state is! CommunicationLoaded) return const SizedBox.shrink();

          final rows = state.campaigns.where((c) {
            final matchesSearch =
                _search.isEmpty ||
                c.title.toLowerCase().contains(_search.toLowerCase()) ||
                c.senderNameSnapshot.toLowerCase().contains(
                  _search.toLowerCase(),
                );
            final matchesStatus =
                _statusFilter == 'all' ||
                c.status.wireName == _statusFilter ||
                (_statusFilter == 'published' && c.status.isSent);
            return matchesSearch && matchesStatus;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onChanged: (v) => setState(() => _search = v),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search title or sender…',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _statusFilters.entries.map((e) {
                        return ChoiceChip(
                          label: Text(e.value),
                          selected: _statusFilter == e.key,
                          onSelected: (_) =>
                              setState(() => _statusFilter = e.key),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: rows.isEmpty
                    ? const EmptyState(
                        icon: Icons.campaign_outlined,
                        title: 'No communications yet',
                        message:
                            'Announcements, notices and alerts you send will appear here.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: rows.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) =>
                            _CampaignTile(campaign: rows[index]),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<CommunicationBloc, CommunicationState>(
        builder: (context, state) {
          final canManage = state is CommunicationLoaded && state.canManage;
          if (!canManage) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () =>
                context.push('/staff/admin/communication-center/compose'),
            icon: const Icon(Icons.add),
            label: const Text('New communication'),
          );
        },
      ),
    );
  }
}

class _CampaignTile extends StatelessWidget {
  final CommunicationCampaign campaign;
  const _CampaignTile({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          campaign.isEmergency
              ? Icons.emergency_outlined
              : Icons.campaign_outlined,
          color: campaign.isEmergency
              ? Theme.of(context).colorScheme.error
              : null,
        ),
        title: Text(
          campaign.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${campaign.communicationType.label} • ${campaign.senderNameSnapshot} • ${campaign.audienceDefinition.description}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: CampaignStatusChip(status: campaign.status),
        onTap: () => context.push(
          '/staff/admin/communication-center/${campaign.campaignId}',
        ),
      ),
    );
  }
}
