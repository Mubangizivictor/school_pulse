import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/matron/domain/entities/matron_entities.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_bloc.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_event.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_state.dart';

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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is MatronError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Theme.of(context).colorScheme.error),
            );
          }
        },
        buildWhen: (previous, current) => current is AnnouncementsLoaded || current is MatronLoading,
        builder: (context, state) {
          if (state is! AnnouncementsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.announcements.isEmpty) {
            return const EmptyState(
              icon: Icons.campaign_outlined,
              title: 'No Announcements Yet',
              message: 'Tap + to send a boarding announcement.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.announcements.length,
            itemBuilder: (context, index) {
              final a = state.announcements[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.campaign_outlined, color: Colors.orange),
                  title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(a.content),
                      if (a.targetGroups.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: a.targetGroups
                              .map((g) => Chip(
                                    label: Text(g, style: const TextStyle(fontSize: 10)),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(DateFormat('MMM d, yyyy h:mm a').format(a.date), style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
              );
            },
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
            Text('New Announcement', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()),
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
                onPressed: (_titleController.text.isEmpty || _contentController.text.isEmpty)
                    ? null
                    : () {
                        context.read<MatronBloc>().add(PostAnnouncementEvent(BoardingAnnouncement(
                              id: '',
                              title: _titleController.text.trim(),
                              content: _contentController.text.trim(),
                              date: DateTime.now(),
                              authorName: widget.authorName,
                              targetGroups: _selectedGroups.toList(),
                            )));
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
