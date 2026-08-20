import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/matron/domain/entities/matron_entities.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_bloc.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_event.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_state.dart';
import 'package:school_pulse/features/shared/boarding/boarding_list_widgets.dart';

const _kTargetGroups = ['Parents', 'Matrons (Girls)', 'All Staff'];

class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({super.key});

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(WatchAnnouncements());
  }

  String _currentUserName(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.name : 'Matron';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boarding Communication')),
      body: BlocConsumer<MatronBloc, MatronState>(
        listener: (context, state) {
          if (state is MatronActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is MatronError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is AnnouncementsLoaded || current is MatronLoading,
        builder: (context, state) {
          if (state is! AnnouncementsLoaded) {
            return const Center(child: SchoolPulseLoader());
          }
          if (state.announcements.isEmpty) {
            return const EmptyState(
              icon: Icons.campaign_outlined,
              title: 'No Announcements Yet',
              message: 'Tap + to send a boarding announcement.',
            );
          }
          // Tabs use only fields that actually exist on
          // BoardingAnnouncement (targetDormitoryId) - no fabricated
          // "Urgent" tab since nothing backs an urgency flag.
          return TabbedListScaffold<BoardingAnnouncement>(
            tabLabels: const ['All', 'General', 'Dormitory'],
            items: state.announcements,
            filter: (tabIndex, a) => switch (tabIndex) {
              1 => a.targetDormitoryId == null,
              2 => a.targetDormitoryId != null,
              _ => true,
            },
            emptyIcon: Icons.campaign_outlined,
            emptyTitle: 'No Announcements',
            emptyMessage: 'Nothing to show for this tab yet.',
            padding: const EdgeInsets.all(AppSpacing.l),
            itemBuilder: (context, a) => _AnnouncementCard(announcement: a),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showComposeSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Compose'),
      ),
    );
  }

  void _showComposeSheet(BuildContext context) {
    final bloc = context.read<MatronBloc>();
    final authorName = _currentUserName(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: bloc,
        child: _ComposeSheet(authorName: authorName),
      ),
    );
  }
}

class _ComposeSheet extends StatefulWidget {
  final String authorName;
  const _ComposeSheet({required this.authorName});

  @override
  State<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends State<_ComposeSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final Set<String> _selectedGroups = {'Parents'};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: BlocListener<MatronBloc, MatronState>(
        listener: (context, state) {
          if (state is MatronActionSuccess) Navigator.pop(context);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Announcement',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Text('Send to', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _kTargetGroups.map((group) {
                final selected = _selectedGroups.contains(group);
                return FilterChip(
                  label: Text(group),
                  selected: selected,
                  onSelected: (val) => setState(() {
                    if (val) {
                      _selectedGroups.add(group);
                    } else {
                      _selectedGroups.remove(group);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    (_titleController.text.isEmpty ||
                        _contentController.text.isEmpty)
                    ? null
                    : () {
                        context.read<MatronBloc>().add(
                          PostAnnouncementEvent(
                            BoardingAnnouncement(
                              id: '',
                              title: _titleController.text.trim(),
                              content: _contentController.text.trim(),
                              date: DateTime.now(),
                              authorName: widget.authorName,
                              targetGroups: _selectedGroups.toList(),
                            ),
                          ),
                        );
                      },
                child: const Text('Send Announcement'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final BoardingAnnouncement announcement;
  const _AnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_outlined, color: Colors.orange, size: 20),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  announcement.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(announcement.content),
          if (announcement.targetGroups.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: 6,
              children: announcement.targetGroups
                  .map(
                    (g) => Chip(
                      label: Text(g, style: const TextStyle(fontSize: 10)),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          Text(
            DateFormat('MMM d, yyyy h:mm a').format(announcement.date),
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
