import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/domain/entities/student_financial_account.dart';
import 'package:school_pulse/features/finance/domain/repositories/finance_repository.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/student/data/datasources/student_profile_data_source.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Roles allowed to see a learner's financial detail and payment actions.
/// Mirrors the `permitted = {...}` Set style the router's redirect guards
/// already use, applied at tab-content level instead of route level because
/// the profile route itself is open to the wider student-admin role set.
const Set<UserRole> kFinanceVisibleRoles = {
  UserRole.bursar,
  UserRole.director,
  UserRole.headTeacher,
  UserRole.schoolAdmin,
};

/// Whether the signed-in user holds any of [roles].
bool userHasAnyRole(BuildContext context, Set<UserRole> roles) {
  final auth = context.read<AuthBloc>().state;
  if (auth is! AuthAuthenticated) return false;
  return auth.user.roles.any(roles.contains);
}

/// Scrolling shell shared by the tabs, matching the profile screen's own
/// content width so tabs don't each pick a different max width.
class TabScroll extends StatelessWidget {
  final List<Widget> children;
  const TabScroll(this.children, {super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ),
  );
}

class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? trailing;
  const SectionCard({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}

class KeyValueRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const KeyValueRow(this.icon, this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Guardians
// ---------------------------------------------------------------------------

/// Guardians on file for a learner, read from `student_guardians/{studentId}`
/// - the document `directEnrolLearner` actually writes today.
///
/// Reallocation (moving a guardian to a different learner / replacing one) is
/// deliberately NOT a direct client write: the `student_guardians` rule is
/// `allow write: if false`, server-only via the enrolment callable, and
/// loosening it would be a security regression. This tab therefore collects
/// the reason and confirmation and writes the audit entry immediately, leaving
/// the guardian-list mutation itself to a Cloud Function that does not exist
/// yet (see the TODO in [_reallocate]).
class GuardiansTab extends StatefulWidget {
  final Student student;
  final bool canMutate;
  const GuardiansTab({
    super.key,
    required this.student,
    required this.canMutate,
  });

  @override
  State<GuardiansTab> createState() => _GuardiansTabState();
}

class _GuardiansTabState extends State<GuardiansTab> {
  late Future<List<StudentGuardian>> _future;
  final _dataSource = StudentProfileDataSource();

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<StudentGuardian>> _load() => _dataSource.getGuardians(
    studentId: widget.student.id,
    schoolId: widget.student.schoolId,
  );

  void _reload() => setState(() => _future = _load());

  Future<void> _reallocate(StudentGuardian guardian) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reallocate guardian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reallocating ${guardian.name} detaches them from '
              '${widget.student.name}. This action is audited.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Reason (required)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) return;
              Navigator.pop(dialogContext, reason);
            },
            child: const Text('Reallocate'),
          ),
        ],
      ),
    );
    if (confirmed == null || !mounted) return;

    final auth = context.read<AuthBloc>().state;
    final actorId = auth is AuthAuthenticated ? auth.user.id : null;
    await di.sl<AuditRepository>().logAction(
      schoolId: widget.student.schoolId,
      title: 'Guardian reallocation requested',
      description:
          '${guardian.name} (${guardian.relationship}) on '
          '${widget.student.name} [${widget.student.studentCode}]. '
          'Reason: $confirmed',
      iconName: 'group_off',
      colorHex: '#B3261E',
      userId: actorId,
      relatedEntityId: widget.student.id,
    );
    if (!mounted) return;

    // TODO(guardian-reallocation): the audit entry above is real, but the
    // guardian list itself is NOT mutated here. `student_guardians` is
    // server-only write (firestore.rules: `allow write: if false`), so
    // actually detaching the guardian needs a new callable Cloud Function
    // mirroring `directEnrolLearner`'s role-check pattern. Until that exists
    // this deliberately does not fake the mutation.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Reallocation request logged for audit. The guardian record is '
          'not changed yet - this needs the server-side action.',
        ),
      ),
    );
  }

  void _addGuardianUnavailable(int currentCount) {
    final atCap = currentCount >= kMaxGuardiansPerStudent;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          atCap
              ? 'A learner may have at most $kMaxGuardiansPerStudent '
                    'guardians on file.'
              : 'Guardians are written by the enrolment service. Adding one '
                    'here needs the server-side action.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StudentGuardian>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return TabScroll([
            EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Could not load guardians',
              message: '${snapshot.error}',
              ctaLabel: 'Retry',
              onCtaPressed: _reload,
            ),
          ]);
        }
        final guardians = snapshot.data ?? const <StudentGuardian>[];
        if (guardians.isEmpty) {
          return TabScroll([
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: EmptyState(
                icon: Icons.groups_2_outlined,
                title: 'No guardians on file',
                message:
                    'Guardians captured during enrolment will appear here.',
              ),
            ),
          ]);
        }
        return TabScroll([
          for (final g in guardians) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AvatarInitials(name: g.name, size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              g.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              g.relationship,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (g.isPrimary)
                        StatusBadge(
                          label: 'Primary',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                  const Divider(height: 24),
                  KeyValueRow(Icons.phone_outlined, 'Phone', g.phone),
                  if (g.email.isNotEmpty)
                    KeyValueRow(Icons.mail_outline, 'Email', g.email),
                  KeyValueRow(
                    Icons.directions_walk_outlined,
                    'Authorised pickup',
                    g.pickup ? 'Yes' : 'No',
                  ),
                  KeyValueRow(
                    Icons.health_and_safety_outlined,
                    'Emergency consent',
                    g.emergencyConsent ? 'Yes' : 'No',
                  ),
                  if (widget.canMutate) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _reallocate(g),
                        icon: const Icon(Icons.swap_horiz_rounded),
                        label: const Text('Reallocate'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (widget.canMutate)
            OutlinedButton.icon(
              onPressed: guardians.length >= kMaxGuardiansPerStudent
                  ? null
                  : () => _addGuardianUnavailable(guardians.length),
              icon: const Icon(Icons.person_add_alt_1),
              label: Text(
                guardians.length >= kMaxGuardiansPerStudent
                    ? 'Guardian limit reached ($kMaxGuardiansPerStudent)'
                    : 'Add guardian',
              ),
            ),
        ]);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Academics
// ---------------------------------------------------------------------------

/// Read-only placement. There is deliberately no free-form inline class
/// editor here - changing placement is a transfer, which belongs to the
/// enrolment/transfer flow rather than an unguarded dropdown on the profile.
class AcademicsTab extends StatelessWidget {
  final Student student;
  const AcademicsTab({super.key, required this.student});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<StructureBloc, StructureState>(
        builder: (context, s) {
          final className = s.classes
              .where((x) => x.id == student.classId)
              .firstOrNull
              ?.name;
          final streamName = s.streams
              .where((x) => x.id == student.streamId)
              .firstOrNull
              ?.name;
          final yearName = s.academicYears
              .where((x) => x.id == student.academicYearId)
              .firstOrNull
              ?.name;
          return TabScroll([
            SectionCard(
              title: 'Current placement',
              children: [
                KeyValueRow(
                  Icons.class_outlined,
                  'Class',
                  className ?? 'Unassigned',
                ),
                const Divider(height: 1),
                KeyValueRow(
                  Icons.account_tree_outlined,
                  'Stream',
                  streamName ?? '-',
                ),
                const Divider(height: 1),
                KeyValueRow(
                  Icons.calendar_month_outlined,
                  'Academic year',
                  yearName ?? '-',
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change placement',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // TODO(transfer-flow): DirectStudentRegistrationScreen
                  // handles first enrolment only - it has no
                  // transfer-an-existing-learner entry point on this branch,
                  // and no separate transfer flow exists. Rather than build an
                  // unguarded placement editor here, this stays a signpost
                  // until that flow lands.
                  Text(
                    'Moving a learner between classes is a transfer and is '
                    'handled by the enrolment flow, not edited here. A '
                    'dedicated transfer action is not yet available.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ]);
        },
      );
}

// ---------------------------------------------------------------------------
// Attendance
// ---------------------------------------------------------------------------

/// Read-only attendance for one learner over the last 30 days, queried
/// against `schools/{schoolId}/attendance_records` - the collection the
/// attendance hub's data source actually writes.
class AttendanceTab extends StatefulWidget {
  final Student student;
  const AttendanceTab({super.key, required this.student});

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  late Future<List<StudentAttendanceEvent>> _future;
  final _dataSource = StudentProfileDataSource();
  static const _windowDays = 30;

  @override
  void initState() {
    super.initState();
    _future = _dataSource.getAttendance(
      studentId: widget.student.id,
      schoolId: widget.student.schoolId,
      since: DateTime.now().subtract(const Duration(days: _windowDays)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StudentAttendanceEvent>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return TabScroll([
            EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Could not load attendance',
              message: '${snapshot.error}',
            ),
          ]);
        }
        final events = snapshot.data ?? const <StudentAttendanceEvent>[];
        if (events.isEmpty) {
          return const TabScroll([
            Padding(
              padding: EdgeInsets.only(top: 48),
              child: EmptyState(
                icon: Icons.event_available_outlined,
                title: 'No attendance recorded',
                message: 'Nothing marked for this learner in the last 30 days.',
              ),
            ),
          ]);
        }
        int countOf(String status) =>
            events.where((e) => e.status == status).length;
        return TabScroll([
          SectionCard(
            title: 'Last $_windowDays days',
            children: [
              KeyValueRow(
                Icons.check_circle_outline,
                'Present',
                '${countOf('present')}',
              ),
              const Divider(height: 1),
              KeyValueRow(
                Icons.cancel_outlined,
                'Absent',
                '${countOf('absent')}',
              ),
              const Divider(height: 1),
              KeyValueRow(
                Icons.schedule_outlined,
                'Late',
                '${countOf('late')}',
              ),
              const Divider(height: 1),
              KeyValueRow(
                Icons.event_busy_outlined,
                'Excused',
                '${countOf('excused')}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Recent events',
            children: [
              for (final e in events.take(50))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(_iconFor(e.status)),
                  title: Text(DateFormat('EEE, dd MMM yyyy').format(e.date)),
                  subtitle: Text(
                    [
                      e.status,
                      if (e.sessionType.isNotEmpty) e.sessionType,
                      if (e.scopeName.isNotEmpty) e.scopeName,
                    ].join(' - '),
                  ),
                ),
            ],
          ),
        ]);
      },
    );
  }

  static IconData _iconFor(String status) => switch (status) {
    'present' => Icons.check_circle_outline,
    'absent' => Icons.cancel_outlined,
    'late' => Icons.schedule_outlined,
    'excused' => Icons.event_busy_outlined,
    _ => Icons.help_outline,
  };
}

// ---------------------------------------------------------------------------
// Fees
// ---------------------------------------------------------------------------

/// Financial summary from [StudentFinancialAccount]. Non-finance roles see
/// only a "restricted" notice rather than balances.
class FeesTab extends StatefulWidget {
  final Student student;
  const FeesTab({super.key, required this.student});

  @override
  State<FeesTab> createState() => _FeesTabState();
}

class _FeesTabState extends State<FeesTab> {
  Future<StudentFinancialAccount?>? _future;

  @override
  void initState() {
    super.initState();
    if (userHasAnyRole(context, kFinanceVisibleRoles)) {
      _future = di
          .sl<FinanceRepository>()
          .getStudentFinancialAccount(
            widget.student.id,
            widget.student.academicYearId,
          )
          .then((either) => either.fold((_) => null, (account) => account));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_future == null) {
      return const TabScroll([
        Padding(
          padding: EdgeInsets.only(top: 48),
          child: EmptyState(
            icon: Icons.lock_outline_rounded,
            title: 'Restricted',
            message:
                'Fee balances and payment history are visible to the bursar '
                'and school administrators only.',
          ),
        ),
      ]);
    }
    return FutureBuilder<StudentFinancialAccount?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final account = snapshot.data;
        if (account == null) {
          return const TabScroll([
            Padding(
              padding: EdgeInsets.only(top: 48),
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No fee account',
                message:
                    'This learner has no financial account for the '
                    'current academic year.',
              ),
            ),
          ]);
        }
        final money = NumberFormat.currency(symbol: '', decimalDigits: 0);
        return TabScroll([
          SectionCard(
            title: 'Fee summary',
            children: [
              KeyValueRow(
                Icons.request_quote_outlined,
                'Total billed',
                money.format(account.totalBilled),
              ),
              const Divider(height: 1),
              KeyValueRow(
                Icons.payments_outlined,
                'Total paid',
                money.format(account.totalPaid),
              ),
              const Divider(height: 1),
              KeyValueRow(
                Icons.volunteer_activism_outlined,
                'Scholarship',
                money.format(account.scholarshipAmount),
              ),
              const Divider(height: 1),
              KeyValueRow(
                Icons.discount_outlined,
                'Discount',
                money.format(account.discountAmount),
              ),
              const Divider(height: 1),
              KeyValueRow(
                Icons.account_balance_wallet_outlined,
                'Balance',
                money.format(account.balance),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: 'Payment history',
            children: account.paymentHistory.isEmpty
                ? [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No payments recorded.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ]
                : [
                    for (final p in account.paymentHistory)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: const Icon(Icons.receipt_outlined),
                        title: Text(money.format(p.amount)),
                        subtitle: Text(
                          DateFormat('dd MMM yyyy').format(p.date),
                        ),
                      ),
                  ],
          ),
        ]);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Services
// ---------------------------------------------------------------------------

/// Transport / boarding / house / medical, each row shown only when the
/// school has that module switched on in `FeatureToggles` (Structure module's
/// Feature Toggles tab). Medical detail is role-gated the same way finance is.
class ServicesTab extends StatelessWidget {
  final Student student;
  const ServicesTab({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final canSeeMedical = userHasAnyRole(context, {
      ...kFinanceVisibleRoles,
      UserRole.nurse,
    });
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final toggles = state.featureToggles;
        final rows = <Widget>[
          if (toggles.transport)
            SectionCard(
              title: 'Transport',
              children: [
                KeyValueRow(
                  Icons.directions_bus_outlined,
                  'Route / details',
                  student.transportInfo?.isNotEmpty == true
                      ? student.transportInfo!
                      : 'Not enrolled on transport',
                ),
              ],
            ),
          if (toggles.boarding || toggles.hostel)
            SectionCard(
              title: 'Boarding',
              children: [
                KeyValueRow(
                  Icons.night_shelter_outlined,
                  'Boarding type',
                  student.boardingType?.name ?? 'Day learner',
                ),
                const Divider(height: 1),
                KeyValueRow(
                  Icons.meeting_room_outlined,
                  'Dormitory',
                  student.dormLeadershipDormName ?? '-',
                ),
                const Divider(height: 1),
                KeyValueRow(
                  Icons.workspace_premium_outlined,
                  'Dorm role',
                  student.dormLeadershipRole ?? '-',
                ),
              ],
            ),
          if (toggles.medical)
            SectionCard(
              title: 'Medical',
              children: canSeeMedical
                  ? [
                      KeyValueRow(
                        Icons.bloodtype_outlined,
                        'Blood group',
                        student.medicalInfo?.bloodGroup ?? '-',
                      ),
                      const Divider(height: 1),
                      KeyValueRow(
                        Icons.warning_amber_outlined,
                        'Allergies',
                        student.medicalInfo?.allergies.isNotEmpty == true
                            ? student.medicalInfo!.allergies.join(', ')
                            : 'None recorded',
                      ),
                      const Divider(height: 1),
                      KeyValueRow(
                        Icons.medication_outlined,
                        'Chronic conditions',
                        student.medicalInfo?.chronicConditions.isNotEmpty ==
                                true
                            ? student.medicalInfo!.chronicConditions.join(', ')
                            : 'None recorded',
                      ),
                    ]
                  : [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Medical details are restricted to the school '
                          'nurse and school administrators.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
            ),
        ];
        if (rows.isEmpty) {
          return const TabScroll([
            Padding(
              padding: EdgeInsets.only(top: 48),
              child: EmptyState(
                icon: Icons.tune_rounded,
                title: 'No services enabled',
                message:
                    'Transport, boarding and medical modules are switched '
                    'off for this school.',
              ),
            ),
          ]);
        }
        return TabScroll([
          for (final row in rows) ...[row, const SizedBox(height: 12)],
        ]);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// History
// ---------------------------------------------------------------------------

/// Chronological audit trail for one learner, read from `audit_logs` filtered
/// by `targetId == studentId` - the shape `directEnrolLearner` writes.
class HistoryTab extends StatefulWidget {
  final Student student;
  const HistoryTab({super.key, required this.student});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  late Future<List<StudentHistoryEntry>> _future;
  final _dataSource = StudentProfileDataSource();

  @override
  void initState() {
    super.initState();
    _future = _dataSource.getHistory(
      studentId: widget.student.id,
      schoolId: widget.student.schoolId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StudentHistoryEntry>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return TabScroll([
            EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Could not load history',
              message: '${snapshot.error}',
            ),
          ]);
        }
        final entries = snapshot.data ?? const <StudentHistoryEntry>[];
        if (entries.isEmpty) {
          return const TabScroll([
            Padding(
              padding: EdgeInsets.only(top: 48),
              child: EmptyState(
                icon: Icons.history_rounded,
                title: 'No history yet',
                message: 'Audited events for this learner will appear here.',
              ),
            ),
          ]);
        }
        return TabScroll([
          SectionCard(
            title: 'Timeline',
            children: [
              for (final e in entries)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.circle, size: 12),
                  title: Text(e.title),
                  subtitle: Text(
                    [
                      if (e.description.isNotEmpty) e.description,
                      if (e.timestamp != null)
                        DateFormat('dd MMM yyyy, HH:mm').format(e.timestamp!),
                      if (e.actor.isNotEmpty) 'by ${e.actor}',
                    ].join('\n'),
                  ),
                  isThreeLine: e.description.isNotEmpty,
                ),
            ],
          ),
        ]);
      },
    );
  }
}
