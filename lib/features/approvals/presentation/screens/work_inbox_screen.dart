import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/features/approvals/data/repositories/approval_repository.dart';
import 'package:school_pulse/features/approvals/domain/entities/approval_models.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

/// A compact action inbox backed by the immutable approval workflow. It never
/// reads notifications or general activity records.
class WorkInboxScreen extends StatefulWidget {
  const WorkInboxScreen({super.key});
  @override
  State<WorkInboxScreen> createState() => _WorkInboxScreenState();
}

class _WorkInboxScreenState extends State<WorkInboxScreen> {
  final _repository = ApprovalRepository();
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return const SizedBox.shrink();
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<ApprovalRequest>>(
          stream: _repository.watchInbox(auth.user.schoolId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _Failure(onRetry: () => setState(() {}));
            }
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(color: _ink(context)),
              );
            }
            final all = _visible(snapshot.data!, auth.user);
            final open = all.where(_isOpen).toList()..sort(_byUrgency);
            final selected = switch (_filter) {
              _Filter.all => open,
              _Filter.assigned =>
                open
                    .where((r) => r.requiredApprovers.contains(auth.user.id))
                    .toList(),
              _Filter.approvals =>
                open
                    .where(
                      (r) =>
                          r.currentStatus == ApprovalStatus.pending ||
                          r.currentStatus == ApprovalStatus.inReview,
                    )
                    .toList(),
            };
            final attention = selected
                .where((r) => _needsAttention(r))
                .toList();
            final scheduled = selected.where(_scheduledToday).toList();
            final completed =
                all
                    .where((r) => !_isOpen(r) && _isOwnedBy(r, auth.user))
                    .toList()
                  ..sort(
                    (a, b) => (b.resolvedAt ?? b.createdAt).compareTo(
                      a.resolvedAt ?? a.createdAt,
                    ),
                  );
            return RefreshIndicator(
              color: _ink(context),
              onRefresh: () async => setState(() {}),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Work',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Your tasks and approvals',
                              style: TextStyle(
                                fontSize: 13,
                                color: _ink(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => _filterSheet(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _ink(context),
                          side: BorderSide(color: _ink(context)),
                        ),
                        child: const Icon(Icons.tune, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Text(
                        '${selected.length} open',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      _Filters(
                        selected: _filter,
                        onChanged: (value) => setState(() => _filter = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (selected.isEmpty)
                    const _AllClear()
                  else ...[
                    _Group(title: 'Needs attention', items: attention),
                    if (scheduled.isNotEmpty)
                      _Group(title: 'Scheduled for today', items: scheduled),
                    if (completed.isNotEmpty)
                      _Group(
                        title: 'Recently completed',
                        items: completed.take(5).toList(),
                        completed: true,
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _filterSheet(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _Filter.values
            .map(
              (filter) => ListTile(
                title: Text(filter.label),
                trailing: _filter == filter
                    ? const Icon(Icons.check, size: 18)
                    : null,
                onTap: () {
                  setState(() => _filter = filter);
                  Navigator.pop(context);
                },
              ),
            )
            .toList(),
      ),
    ),
  );
}

class _Filters extends StatelessWidget {
  const _Filters({required this.selected, required this.onChanged});
  final _Filter selected;
  final ValueChanged<_Filter> onChanged;
  @override
  Widget build(BuildContext context) => SegmentedButton<_Filter>(
    segments: _Filter.values
        .map((f) => ButtonSegment(value: f, label: Text(f.label)))
        .toList(),
    selected: {selected},
    showSelectedIcon: false,
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? _paper(context)
            : _ink(context),
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? _ink(context)
            : _paper(context),
      ),
      side: WidgetStatePropertyAll(BorderSide(color: _ink(context))),
    ),
    onSelectionChanged: (values) => onChanged(values.first),
  );
}

class _Group extends StatelessWidget {
  const _Group({
    required this.title,
    required this.items,
    this.completed = false,
  });
  final String title;
  final List<ApprovalRequest> items;
  final bool completed;
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _WorkRow(item: item, completed: completed)),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _WorkRow extends StatelessWidget {
  const _WorkRow({required this.item, required this.completed});
  final ApprovalRequest item;
  final bool completed;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: OutlinedButton(
      onPressed: () => context.push(
        item.sourceRoute.isNotEmpty
            ? item.sourceRoute
            : '/staff/admin/approvals',
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: _ink(context),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(16),
        side: BorderSide(color: _ink(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle_outline : _icon(item.moduleKey),
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  completed
                      ? _completedAt(item)
                      : '${item.currentStage.isEmpty ? item.moduleKey : item.currentStage}${item.dueAt == null ? '' : ' · Due ${DateFormat.MMMd().format(item.dueAt!)}'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: _ink(context)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18),
        ],
      ),
    ),
  );
}

class _AllClear extends StatelessWidget {
  const _AllClear();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 46, horizontal: 20),
    decoration: BoxDecoration(
      border: Border.all(color: _ink(context)),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        Icon(Icons.inbox_outlined, size: 32),
        SizedBox(height: 14),
        Text(
          'All clear',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 5),
        Text(
          'New tasks and approvals you can act on will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _ink(context)),
        ),
      ],
    ),
  );
}

class _Failure extends StatelessWidget {
  const _Failure({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: OutlinedButton(
      onPressed: onRetry,
      style: OutlinedButton.styleFrom(
        foregroundColor: _ink(context),
        side: BorderSide(color: _ink(context)),
      ),
      child: const Text('Couldn’t load work. Retry'),
    ),
  );
}

enum _Filter {
  all,
  assigned,
  approvals;

  String get label => switch (this) {
    _Filter.all => 'All',
    _Filter.assigned => 'Assigned',
    _Filter.approvals => 'Approvals',
  };
}

List<ApprovalRequest> _visible(
  List<ApprovalRequest> requests,
  UserEntity user,
) => requests.where((request) {
  // The workflow snapshot carries the permitted user IDs. This is a second
  // client-side projection; it never turns a school-wide collection read
  // into a visible sensitive inbox.
  if (!_isOwnedBy(request, user)) return false;
  if (request.moduleKey == 'finance') return _canSeeFinance(user);
  if (request.moduleKey == 'health' || request.moduleKey == 'security') {
    return user.roles.any(
      (role) =>
          role == UserRole.schoolAdmin ||
          role == UserRole.director ||
          role == UserRole.headTeacher,
    );
  }
  return true;
}).toList();

bool _canSeeFinance(UserEntity user) => user.roles.any(
  (role) =>
      role == UserRole.schoolAdmin ||
      role == UserRole.director ||
      role == UserRole.headTeacher ||
      role == UserRole.bursar,
);

bool _isOpen(ApprovalRequest item) => !{
  ApprovalStatus.approved,
  ApprovalStatus.rejected,
  ApprovalStatus.executed,
  ApprovalStatus.cancelled,
  ApprovalStatus.archived,
  ApprovalStatus.expired,
}.contains(item.currentStatus);
bool _isOwnedBy(ApprovalRequest item, UserEntity user) =>
    item.requiredApprovers.contains(user.id) || item.requestedBy == user.id;
bool _needsAttention(ApprovalRequest item) =>
    item.priority.index >= ApprovalPriority.high.index ||
    (item.dueAt?.isBefore(DateTime.now().add(const Duration(days: 1))) ??
        false);
bool _scheduledToday(ApprovalRequest item) {
  final due = item.dueAt;
  final today = DateTime.now();
  return due != null &&
      due.year == today.year &&
      due.month == today.month &&
      due.day == today.day;
}

int _byUrgency(ApprovalRequest a, ApprovalRequest b) {
  final priority = b.priority.index.compareTo(a.priority.index);
  if (priority != 0) return priority;
  final due = a.dueAt ?? DateTime(9999);
  return due.compareTo(b.dueAt ?? DateTime(9999));
}

IconData _icon(String module) => switch (module) {
  'admissions' => Icons.person_add_alt_outlined,
  'finance' => Icons.account_balance_wallet_outlined,
  'attendance' => Icons.groups_outlined,
  'reports' || 'academics' => Icons.description_outlined,
  _ => Icons.assignment_outlined,
};
String _completedAt(ApprovalRequest item) =>
    DateFormat('MMM d, HH:mm').format(item.resolvedAt ?? item.createdAt);

Color _ink(BuildContext context) => Theme.of(context).colorScheme.onSurface;
Color _paper(BuildContext context) => Theme.of(context).colorScheme.surface;
