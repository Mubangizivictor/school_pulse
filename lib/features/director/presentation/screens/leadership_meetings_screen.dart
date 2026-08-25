import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../../data/repositories/director_governance_repository.dart';
import '../../domain/entities/leadership_meeting.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/director_drawer.dart';

class LeadershipMeetingsScreen extends StatefulWidget {
  const LeadershipMeetingsScreen({super.key});
  @override
  State<LeadershipMeetingsScreen> createState() =>
      _LeadershipMeetingsScreenState();
}

class _LeadershipMeetingsScreenState extends State<LeadershipMeetingsScreen> {
  final _repository = DirectorGovernanceRepository();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Sign in to view meetings.')),
      );
    }
    final schoolId = auth.user.schoolId;
    return Scaffold(
      drawer: const DirectorDrawer(),
      appBar: AppBar(
        title: const Text('Leadership Meetings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New meeting',
            onPressed: () => _openMeetingEditor(context, schoolId),
          ),
        ],
      ),
      body: StreamBuilder<List<LeadershipMeeting>>(
        stream: _repository.watchMeetings(schoolId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load meetings: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final meetings = snapshot.data!;
          if (meetings.isEmpty) {
            return const Center(
              child: Text('No meetings recorded yet. Tap + to add one.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: meetings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _MeetingCard(
              meeting: meetings[i],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _MeetingDetailScreen(
                    repository: _repository,
                    schoolId: schoolId,
                    meeting: meetings[i],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openMeetingEditor(BuildContext context, String schoolId) async {
    final titleController = TextEditingController();
    final agendaController = TextEditingController();
    final participantsController = TextEditingController();
    var type = MeetingType.management;
    var scheduledAt = DateTime.now();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New meeting'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: agendaController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Agenda'),
                ),
                TextField(
                  controller: participantsController,
                  decoration: const InputDecoration(
                    labelText: 'Participants (comma separated)',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<MeetingType>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: MeetingType.values
                      .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => type = v ?? type),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(
                    DateFormat.yMMMd().add_jm().format(scheduledAt),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: scheduledAt,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => scheduledAt = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved != true || !context.mounted) return;
    if (titleController.text.trim().isEmpty) return;

    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;

    await _repository.saveMeeting(
      schoolId,
      LeadershipMeeting(
        meetingId: '',
        institutionId: schoolId,
        title: titleController.text.trim(),
        agenda: agendaController.text.trim(),
        type: type,
        participants: participantsController.text
            .split(',')
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty)
            .toList(),
        decisions: const [],
        actions: const [],
        scheduledAt: scheduledAt,
        createdAt: DateTime.now(),
        createdBy: auth.user.id,
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final LeadershipMeeting meeting;
  final VoidCallback onTap;
  const _MeetingCard({required this.meeting, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pendingActions = meeting.actions.where((a) => !a.completed).length;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(switch (meeting.type) {
            MeetingType.board => Icons.gavel,
            MeetingType.management => Icons.groups,
            MeetingType.department => Icons.account_tree,
          }, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${meeting.type.name} • ${DateFormat.yMMMd().format(meeting.scheduledAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (pendingActions > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$pendingActions open',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MeetingDetailScreen extends StatefulWidget {
  final DirectorGovernanceRepository repository;
  final String schoolId;
  final LeadershipMeeting meeting;
  const _MeetingDetailScreen({
    required this.repository,
    required this.schoolId,
    required this.meeting,
  });

  @override
  State<_MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<_MeetingDetailScreen> {
  late LeadershipMeeting _meeting;

  @override
  void initState() {
    super.initState();
    _meeting = widget.meeting;
  }

  Future<void> _addDecision() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add decision'),
        content: TextField(
          controller: controller,
          maxLines: 2,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (text == null || text.isEmpty) return;
    final updated = LeadershipMeeting(
      meetingId: _meeting.meetingId,
      institutionId: _meeting.institutionId,
      title: _meeting.title,
      agenda: _meeting.agenda,
      type: _meeting.type,
      participants: _meeting.participants,
      decisions: [..._meeting.decisions, text],
      actions: _meeting.actions,
      scheduledAt: _meeting.scheduledAt,
      createdAt: _meeting.createdAt,
      createdBy: _meeting.createdBy,
    );
    await widget.repository.saveMeeting(widget.schoolId, updated);
    setState(() => _meeting = updated);
  }

  Future<void> _addAction() async {
    final descController = TextEditingController();
    final assigneeController = TextEditingController();
    var deadline = DateTime.now().add(const Duration(days: 7));
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add action item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: assigneeController,
                decoration: const InputDecoration(labelText: 'Assignee'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Deadline'),
                subtitle: Text(DateFormat.yMMMd().format(deadline)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: deadline,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => deadline = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    if (saved != true || descController.text.trim().isEmpty) return;
    final updated = LeadershipMeeting(
      meetingId: _meeting.meetingId,
      institutionId: _meeting.institutionId,
      title: _meeting.title,
      agenda: _meeting.agenda,
      type: _meeting.type,
      participants: _meeting.participants,
      decisions: _meeting.decisions,
      actions: [
        ..._meeting.actions,
        MeetingAction(
          description: descController.text.trim(),
          assignee: assigneeController.text.trim(),
          deadline: deadline,
        ),
      ],
      scheduledAt: _meeting.scheduledAt,
      createdAt: _meeting.createdAt,
      createdBy: _meeting.createdBy,
    );
    await widget.repository.saveMeeting(widget.schoolId, updated);
    setState(() => _meeting = updated);
  }

  Future<void> _toggleAction(int index) async {
    await widget.repository.toggleActionCompleted(
      widget.schoolId,
      _meeting,
      index,
    );
    final updatedActions = [..._meeting.actions];
    updatedActions[index] = updatedActions[index].copyWith(
      completed: !updatedActions[index].completed,
    );
    setState(() {
      _meeting = LeadershipMeeting(
        meetingId: _meeting.meetingId,
        institutionId: _meeting.institutionId,
        title: _meeting.title,
        agenda: _meeting.agenda,
        type: _meeting.type,
        participants: _meeting.participants,
        decisions: _meeting.decisions,
        actions: updatedActions,
        scheduledAt: _meeting.scheduledAt,
        createdAt: _meeting.createdAt,
        createdBy: _meeting.createdBy,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_meeting.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${_meeting.type.name} • ${DateFormat.yMMMd().add_jm().format(_meeting.scheduledAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          if (_meeting.agenda.isNotEmpty) ...[
            const Text('Agenda', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_meeting.agenda),
            const SizedBox(height: 16),
          ],
          if (_meeting.participants.isNotEmpty) ...[
            const Text(
              'Participants',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _meeting.participants
                  .map(
                    (p) => Chip(
                      label: Text(p),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Decisions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _addDecision,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          if (_meeting.decisions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('No decisions recorded.'),
            )
          else
            ..._meeting.decisions.map(
              (d) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.check_circle_outline, size: 18),
                title: Text(d),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Action items',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _addAction,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          if (_meeting.actions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('No action items yet.'),
            )
          else
            ..._meeting.actions.asMap().entries.map(
              (e) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: e.value.completed,
                onChanged: (_) => _toggleAction(e.key),
                title: Text(
                  e.value.description,
                  style: TextStyle(
                    decoration: e.value.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                subtitle: Text(
                  '${e.value.assignee} • Due ${DateFormat.yMMMd().format(e.value.deadline)}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
