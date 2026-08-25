import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_bloc.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_event.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_state.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/messages/presentation/widgets/messages_nav_icon.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Tenant-scoped School Admin home. All metric values come from the existing
/// dashboard BLoC; action counts and pins are read from the active tenant.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => di.sl<AdminDashboardBloc>()..add(LoadAdminDashboardStats()),
    child: const _AdminHome(),
  );
}

class _AdminHome extends StatelessWidget {
  const _AdminHome();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return const SizedBox.shrink();
    final user = auth.user;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: _ink(context),
          onRefresh: () async {
            context.read<AdminDashboardBloc>().add(LoadAdminDashboardStats());
            await context.read<AdminDashboardBloc>().stream.firstWhere(
              (state) => state is! AdminDashboardLoading,
            );
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(user: user),
                    const SizedBox(height: 28),
                    _ContextRow(user: user),
                    const SizedBox(height: 32),
                    _AttentionSection(user: user),
                    const SizedBox(height: 32),
                    _GlanceSection(user: user),
                    const SizedBox(height: 32),
                    _ContinueWorking(user: user),
                    const SizedBox(height: 32),
                    _PinnedSection(user: user),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});
  final UserEntity user;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          border: Border.all(color: _ink(context)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.school_outlined),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.schoolName?.isNotEmpty == true ? user.schoolName! : 'School',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              'School Admin',
              style: TextStyle(fontSize: 12, color: _ink(context)),
            ),
          ],
        ),
      ),
      Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: () => context.push('/staff/notifications'),
            icon: const Icon(Icons.notifications_none_rounded, size: 22),
          ),
          Positioned(
            right: 8,
            top: 7,
            child: CircleAvatar(radius: 3.5, backgroundColor: _ink(context)),
          ),
        ],
      ),
      IconButton(
        onPressed: () => context.push('/staff/messages'),
        icon: const MessagesNavIcon(
          icon: Icons.chat_bubble_outline_rounded,
          size: 22,
        ),
      ),
    ],
  );
}

class _ContextRow extends StatelessWidget {
  const _ContextRow({required this.user});
  final UserEntity user;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      OutlinedButton.icon(
        onPressed: () => _showTermPicker(context, user),
        icon: const Icon(Icons.calendar_today_outlined),
        label: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
          builder: (_, state) => Text(
            state is AdminDashboardLoaded
                ? state.stats.currentPeriodLabel ?? 'Select term'
                : 'Select term',
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _ink(context),
          side: BorderSide(color: _ink(context)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
      const Spacer(),
      Flexible(
        child: Text(
          DateFormat('EEEE, d MMMM').format(DateTime.now()),
          textAlign: TextAlign.end,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    ],
  );
}

class _AttentionSection extends StatelessWidget {
  const _AttentionSection({required this.user});
  final UserEntity user;
  @override
  Widget build(BuildContext context) => StreamBuilder<List<_WorkItem>>(
    stream: _watchWork(user),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return _Retry(
          message: 'Couldn\'t load work.',
          onRetry: () =>
              context.read<AdminDashboardBloc>().add(LoadAdminDashboardStats()),
        );
      }
      if (!snapshot.hasData) return const _LoadingBlock();
      final items = snapshot.data!;
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: _ink(context)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today needs your attention',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'You’re all caught up.',
                  style: TextStyle(fontSize: 13, color: _ink(context)),
                ),
              )
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 64,
                    child: Column(
                      children: [
                        Text(
                          '${items.fold<int>(0, (value, item) => value + item.count)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'items',
                          style: TextStyle(fontSize: 11, color: _ink(context)),
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(color: _ink(context), width: 1),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: items
                          .take(3)
                          .map((item) => _WorkRow(item: item))
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/staff/admin/approvals'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ink(context),
                  foregroundColor: _paper(context),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('View all work', style: TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _WorkRow extends StatelessWidget {
  const _WorkRow({required this.item});
  final _WorkItem item;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => context.push(item.route),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _paper(context),
              border: Border.all(color: _ink(context)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${item.count} ${item.label}',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const Icon(Icons.chevron_right, size: 18),
        ],
      ),
    ),
  );
}

class _GlanceSection extends StatelessWidget {
  const _GlanceSection({required this.user});
  final UserEntity user;
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
    builder: (context, state) {
      if (state is AdminDashboardError) {
        return _Retry(
          message: 'Couldn\'t load school metrics.',
          onRetry: () =>
              context.read<AdminDashboardBloc>().add(LoadAdminDashboardStats()),
        );
      }
      if (state is! AdminDashboardLoaded) return const _LoadingBlock();
      final stats = state.stats;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'School at a glance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Active learners',
                  value: '${stats.totalStudentsCount}',
                  subtitle: stats.isHistoricalTerm
                      ? 'Active now'
                      : 'Selected term',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Metric(
                  label: 'Staff',
                  value: '${stats.activeStaffCount}',
                  subtitle: 'Active staff',
                ),
              ),
              if (_canSeeFinance(user)) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _Metric(
                    label: 'Fees',
                    value: stats.termFeesCollected == null
                        ? '—'
                        : 'UGX ${_money(stats.termFeesCollected!)}',
                    subtitle:
                        '${stats.currentPeriodLabel ?? 'Selected term'} collected',
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    },
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.subtitle,
  });
  final String label, value, subtitle;
  @override
  Widget build(BuildContext context) => Container(
    height: 96,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: _ink(context)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: _ink(context), fontSize: 12),
        ),
      ],
    ),
  );
}

class _ContinueWorking extends StatelessWidget {
  const _ContinueWorking({required this.user});
  final UserEntity user;
  @override
  Widget build(BuildContext context) {
    final actions = <_Shortcut>[
      if (_canTakeAttendance(user)) _catalog['attendance']!,
      _catalog['school']!,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Continue working',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        ...actions.map((action) => _ActionCard(action: action)),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});
  final _Shortcut action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: OutlinedButton(
      onPressed: () => context.push(action.route),
      style: OutlinedButton.styleFrom(
        foregroundColor: _ink(context),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(12),
        side: BorderSide(color: _ink(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(action.icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  action.description,
                  style: TextStyle(fontSize: 12, color: _ink(context)),
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

class _PinnedSection extends StatelessWidget {
  const _PinnedSection({required this.user});
  final UserEntity user;
  @override
  Widget build(
    BuildContext context,
  ) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .collection('dashboard_preferences')
        .doc(user.schoolId)
        .snapshots(),
    builder: (context, snapshot) {
      final ids =
          ((snapshot.data?.data()?['pinned'] as List?)
                      ?.whereType<String>()
                      .toList() ??
                  _defaults(user))
              .where(
                (id) =>
                    _catalog.containsKey(id) && _allowed(_catalog[id]!, user),
              )
              .take(4)
              .toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Pinned',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _editPins(context, user, ids),
                child: Text('Edit', style: TextStyle(color: _ink(context))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (ids.isEmpty)
            const Text('Pin frequently used permitted modules.')
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ids.map((id) => _Pin(shortcut: _catalog[id]!)).toList(),
            ),
        ],
      );
    },
  );
}

class _Pin extends StatelessWidget {
  const _Pin({required this.shortcut});
  final _Shortcut shortcut;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 180,
    child: OutlinedButton(
      onPressed: () => context.push(shortcut.route),
      style: OutlinedButton.styleFrom(
        foregroundColor: _ink(context),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(12),
        side: BorderSide(color: _ink(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(shortcut.icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              shortcut.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const Icon(Icons.chevron_right, size: 16),
        ],
      ),
    ),
  );
}

Future<void> _editPins(
  BuildContext context,
  UserEntity user,
  List<String> selected,
) async {
  var values = List<String>.of(selected);
  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setState) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit pinned shortcuts',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              ..._catalog.entries
                  .where((entry) => _allowed(entry.value, user))
                  .map(
                    (entry) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: _ink(context),
                      value: values.contains(entry.key),
                      title: Text(entry.value.label),
                      onChanged: (checked) => setState(() {
                        if (checked == true && values.length < 4) {
                          values.add(entry.key);
                        }
                        if (checked == false) {
                          values.remove(entry.key);
                        }
                      }),
                    ),
                  ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.id)
                        .collection('dashboard_preferences')
                        .doc(user.schoolId)
                        .set({
                          'schoolId': user.schoolId,
                          'pinned': values,
                          'updatedAt': FieldValue.serverTimestamp(),
                        }, SetOptions(merge: true));
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ink(context),
                    foregroundColor: _paper(context),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showTermPicker(BuildContext context, UserEntity user) {
  final bloc = context.read<AdminDashboardBloc>();
  showModalBottomSheet<void>(
    context: context,
    builder: (_) => SafeArea(
      child: StreamBuilder<List<AcademicTerm>>(
        stream: di.sl<StructureRepository>().watchAcademicTerms(user.schoolId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: 160,
              child: Center(
                child: CircularProgressIndicator(color: _ink(context)),
              ),
            );
          }
          final terms =
              snapshot.data!.where((term) => !term.isArchived).toList()
                ..sort((a, b) => b.startDate.compareTo(a.startDate));
          return ListView(
            shrinkWrap: true,
            children: terms
                .map(
                  (term) => ListTile(
                    title: Text('${term.name} · ${term.startDate.year}'),
                    trailing: term.isCurrent ? const Icon(Icons.check) : null,
                    onTap: () {
                      Navigator.pop(context);
                      bloc.add(
                        LoadAdminDashboardStats(
                          forTerm: term.isCurrent ? null : term,
                        ),
                      );
                    },
                  ),
                )
                .toList(),
          );
        },
      ),
    ),
  );
}

Stream<List<_WorkItem>> _watchWork(UserEntity user) {
  final school = FirebaseFirestore.instance
      .collection('schools')
      .doc(user.schoolId);
  final streams = [
    school
        .collection('expenditures')
        .where('status', isEqualTo: 'pending')
        .snapshots(),
    school
        .collection('reportCards')
        .where('academicStatus', isEqualTo: 'pendingHeadteacher')
        .snapshots(),
  ];
  return _streamZip(streams).map((data) {
    final work = <_WorkItem>[];
    if (_canSeeFinance(user) && data[0].docs.isNotEmpty) {
      work.add(
        _WorkItem(
          data[0].docs.length,
          'fees exceptions',
          Icons.account_balance_wallet_outlined,
          '/staff/bursar',
        ),
      );
    }
    if (_canApproveReports(user) && data[1].docs.isNotEmpty) {
      work.add(
        _WorkItem(
          data[1].docs.length,
          'report cards awaiting approval',
          Icons.description_outlined,
          '/staff/headteacher/report-approvals',
        ),
      );
    }
    return work;
  });
}

Stream<List<QuerySnapshot<Map<String, dynamic>>>> _streamZip(
  List<Stream<QuerySnapshot<Map<String, dynamic>>>> streams,
) => Stream.multi((controller) {
  final latest = List<QuerySnapshot<Map<String, dynamic>>?>.filled(
    streams.length,
    null,
  );
  final subscriptions =
      <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];
  for (var index = 0; index < streams.length; index++) {
    final current = index;
    subscriptions.add(
      streams[index].listen((value) {
        latest[current] = value;
        if (latest.every((item) => item != null)) {
          controller.add(latest.cast<QuerySnapshot<Map<String, dynamic>>>());
        }
      }, onError: controller.addError),
    );
  }
  controller.onCancel = () async {
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
  };
});

class _WorkItem {
  const _WorkItem(this.count, this.label, this.icon, this.route);
  final int count;
  final String label;
  final IconData icon;
  final String route;
}

class _Shortcut {
  const _Shortcut(this.id, this.label, this.description, this.icon, this.route);
  final String id, label, description, route;
  final IconData icon;
}

const _catalog = <String, _Shortcut>{
  'learners': _Shortcut(
    'learners',
    'Learners',
    'Manage learners and admissions',
    Icons.people_outline,
    '/staff/admin/students',
  ),
  'staff': _Shortcut(
    'staff',
    'Staff',
    'Manage staff',
    Icons.badge_outlined,
    '/staff/admin/users',
  ),
  'attendance': _Shortcut(
    'attendance',
    'Take attendance',
    'Open an attendance session',
    Icons.check_circle_outline,
    '/staff/attendance',
  ),
  'finance': _Shortcut(
    'finance',
    'Finance',
    'Fees and collections',
    Icons.account_balance_wallet_outlined,
    '/staff/bursar',
  ),
  'school': _Shortcut(
    'school',
    'Finish school setup',
    'Complete recommended setup tasks',
    Icons.school_outlined,
    '/staff/admin/structure',
  ),
};
List<String> _defaults(UserEntity user) =>
    _catalog.keys.where((id) => _allowed(_catalog[id]!, user)).take(4).toList();
bool _allowed(_Shortcut shortcut, UserEntity user) =>
    shortcut.id != 'finance' || _canSeeFinance(user);
bool _canSeeFinance(UserEntity user) => user.roles.any(
  (role) =>
      role == UserRole.schoolAdmin ||
      role == UserRole.director ||
      role == UserRole.headTeacher ||
      role == UserRole.bursar,
);
bool _canTakeAttendance(UserEntity user) => user.roles.any(
  (role) =>
      role == UserRole.schoolAdmin ||
      role == UserRole.director ||
      role == UserRole.headTeacher ||
      role == UserRole.classTeacher ||
      role == UserRole.subjectTeacher,
);
bool _canApproveReports(UserEntity user) => user.roles.any(
  (role) =>
      role == UserRole.schoolAdmin ||
      role == UserRole.director ||
      role == UserRole.headTeacher,
);
String _money(double amount) => amount >= 1000000
    ? '${(amount / 1000000).toStringAsFixed(1)}M'
    : NumberFormat.decimalPattern().format(amount);

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 100,
    child: Center(child: CircularProgressIndicator(color: _ink(context))),
  );
}

class _Retry extends StatelessWidget {
  const _Retry({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onRetry,
    style: OutlinedButton.styleFrom(
      foregroundColor: _ink(context),
      side: BorderSide(color: _ink(context)),
    ),
    child: Text('$message Retry'),
  );
}

Color _ink(BuildContext context) => Theme.of(context).colorScheme.onSurface;
Color _paper(BuildContext context) => Theme.of(context).colorScheme.surface;
