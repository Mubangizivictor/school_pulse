import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/student_identity/presentation/bloc/student_identity_bloc.dart';
import 'package:school_pulse/features/student_identity/presentation/screens/identity_and_cards_screen.dart';
import 'package:school_pulse/features/student_identity/presentation/screens/student_id_card_screen.dart';
import 'package:school_pulse/injection_container.dart' as di;

import 'admin_student_documents_screen.dart';
import 'student_portal_codes_screen.dart';

class AdminStudentProfileScreen extends StatefulWidget {
  final String studentId;
  const AdminStudentProfileScreen({super.key, required this.studentId});
  @override
  State<AdminStudentProfileScreen> createState() =>
      _AdminStudentProfileScreenState();
}

class _AdminStudentProfileScreenState extends State<AdminStudentProfileScreen> {
  late Future<Either<Failure, Student>> _future;
  final _repository = di.sl<StudentRepository>();
  @override
  void initState() {
    super.initState();
    _future = _repository.getStudentById(widget.studentId);
  }

  void _reload() =>
      setState(() => _future = _repository.getStudentById(widget.studentId));
  bool _canMutate(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return false;
    final role = auth.user.role.name.toLowerCase();
    return !role.contains('parent') && !role.contains('student');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Student Profile'),
      actions: [
        FutureBuilder<Either<Failure, Student>>(
          future: _future,
          builder: (context, snapshot) {
            final student = snapshot.data?.fold((_) => null, (value) => value);
            return IconButton(
              tooltip: 'View student ID card',
              icon: const Icon(Icons.badge_outlined),
              onPressed: student == null
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => di.sl<StudentIdentityBloc>(),
                          child: StudentIdCardScreen(student: student),
                        ),
                      ),
                    ),
            );
          },
        ),
      ],
    ),
    body: FutureBuilder<Either<Failure, Student>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final result = snapshot.data;
        if (result == null) {
          return const Center(child: Text('Could not load student'));
        }
        return result.fold(
          (failure) => Center(child: Text(failure.message)),
          (student) => _Profile(
            student: student,
            canMutate: _canMutate(context),
            onChanged: _reload,
          ),
        );
      },
    ),
  );
}

class _Profile extends StatefulWidget {
  final Student student;
  final bool canMutate;
  final VoidCallback onChanged;
  const _Profile({
    required this.student,
    required this.canMutate,
    required this.onChanged,
  });
  @override
  State<_Profile> createState() => _ProfileState();
}

class _ProfileState extends State<_Profile>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: _Header(widget.student),
      ),
      DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: TabBar(
          controller: _tabs,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(icon: Icon(Icons.home_rounded), text: 'Overview'),
            Tab(icon: Icon(Icons.groups_2_outlined), text: 'Guardian'),
            Tab(icon: Icon(Icons.menu_book_outlined), text: 'Academic'),
            Tab(icon: Icon(Icons.grid_view_rounded), text: 'More'),
          ],
        ),
      ),
      Expanded(
        child: TabBarView(
          controller: _tabs,
          children: [
            _Overview(student: widget.student),
            _Guardians(student: widget.student),
            _Academic(student: widget.student),
            _More(
              student: widget.student,
              canMutate: widget.canMutate,
              onChanged: widget.onChanged,
            ),
          ],
        ),
      ),
    ],
  );
}

class _Scroll extends StatelessWidget {
  final List<Widget> children;
  const _Scroll(this.children);
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  final Student student;
  const _Header(this.student);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.extension<SemanticColors>()!;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: theme.colorScheme.primaryContainer,
            backgroundImage: student.photoUrl?.isNotEmpty == true
                ? NetworkImage(student.photoUrl!)
                : null,
            child: student.photoUrl?.isNotEmpty == true
                ? null
                : Text(
                    _initials(student.name),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                StatusBadge(
                  label: _status(student.status),
                  color: _statusColor(semantic, student.status),
                ),
                const SizedBox(height: 10),
                _HeaderLine(Icons.badge_outlined, student.studentCode),
                const SizedBox(height: 6),
                BlocBuilder<StructureBloc, StructureState>(
                  builder: (context, s) {
                    final c = s.classes
                        .where((x) => x.id == student.classId)
                        .firstOrNull
                        ?.name;
                    final stream = s.streams
                        .where((x) => x.id == student.streamId)
                        .firstOrNull
                        ?.name;
                    final label = [c, stream].whereType<String>().join(' • ');
                    return _HeaderLine(
                      Icons.school_outlined,
                      label.isEmpty ? _level(student.level) : label,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HeaderLine(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        icon,
        size: 17,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ],
  );
}

class _Overview extends StatelessWidget {
  final Student student;
  const _Overview({required this.student});
  @override
  Widget build(BuildContext context) => _Scroll([_InfoCard(student)]);
}

class _InfoCard extends StatelessWidget {
  final Student student;
  const _InfoCard(this.student);
  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    final rows = <Widget>[
      _InfoRow(
        Icons.cake_outlined,
        'Date of Birth',
        DateFormat('dd MMM yyyy').format(student.dateOfBirth),
      ),
      _InfoRow(Icons.person_outline_rounded, 'Gender', _gender(student.gender)),
      if (student.previousSchool?.isNotEmpty == true)
        _InfoRow(
          Icons.account_balance_outlined,
          'Previous School',
          student.previousSchool!,
        ),
      _InfoRow(Icons.badge_outlined, 'Admission No.', student.admissionNumber),
      _InfoRow(Icons.school_outlined, 'Education Level', _level(student.level)),
      _InfoRow(
        Icons.verified_outlined,
        'Status',
        _status(student.status),
        badge: _statusColor(semantic, student.status),
      ),
      BlocBuilder<StructureBloc, StructureState>(
        builder: (context, s) => _InfoRow(
          Icons.calendar_month_outlined,
          'Academic Year',
          s.academicYears
                  .where((x) => x.id == student.academicYearId)
                  .firstOrNull
                  ?.name ??
              '—',
        ),
      ),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Student Information',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? badge;
  const _InfoRow(this.icon, this.label, this.value, {this.badge});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
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
          child: badge == null
              ? Text(
                  value,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                )
              : StatusBadge(label: value, color: badge!),
        ),
      ],
    ),
  );
}

class _Guardians extends StatelessWidget {
  final Student student;
  const _Guardians({required this.student});
  @override
  Widget build(BuildContext context) => _Scroll([
    if (student.emergencyContacts.isEmpty)
      const Padding(
        padding: EdgeInsets.only(top: 64),
        child: EmptyState(
          icon: Icons.groups_2_outlined,
          title: 'No guardians on file',
          message: 'Emergency contacts for this student will appear here.',
        ),
      )
    else
      ...student.emergencyContacts.map(
        (x) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(x.name),
              subtitle: Text(
                '${x.relationship}\n${x.phoneNumber}${x.email?.isNotEmpty == true ? '\n${x.email}' : ''}',
              ),
              isThreeLine: x.email?.isNotEmpty == true,
            ),
          ),
        ),
      ),
  ]);
}

class _Academic extends StatelessWidget {
  final Student student;
  const _Academic({required this.student});
  @override
  Widget build(BuildContext context) => _Scroll([
    BlocBuilder<StructureBloc, StructureState>(
      builder: (context, s) {
        final c =
            s.classes.where((x) => x.id == student.classId).firstOrNull?.name ??
            '—';
        final stream = s.streams
            .where((x) => x.id == student.streamId)
            .firstOrNull
            ?.name;
        final y =
            s.academicYears
                .where((x) => x.id == student.academicYearId)
                .firstOrNull
                ?.name ??
            '—';
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Academic Placement',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              _InfoRow(Icons.class_outlined, 'Class', c),
              const Divider(height: 1),
              if (stream != null) ...[
                _InfoRow(Icons.account_tree_outlined, 'Stream', stream),
                const Divider(height: 1),
              ],
              _InfoRow(Icons.calendar_month_outlined, 'Academic Year', y),
            ],
          ),
        );
      },
    ),
  ]);
}

class _More extends StatelessWidget {
  final Student student;
  final bool canMutate;
  final VoidCallback onChanged;
  const _More({
    required this.student,
    required this.canMutate,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => _Scroll([
    AppCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Icons.folder_outlined),
        title: const Text('Documents'),
        subtitle: const Text('View student documents'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AdminStudentDocumentsScreen(
              student: student,
              canMutate: canMutate,
              onDocumentsChanged: onChanged,
            ),
          ),
        ),
      ),
    ),
  ]);
}

class ActionsSheet extends StatelessWidget {
  final Student student;
  final bool canMutate;
  final VoidCallback onChanged;
  const ActionsSheet({
    super.key,
    required this.student,
    required this.canMutate,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        decoration: BoxDecoration(
          color: t.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: t.colorScheme.outline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'More Options',
                style: t.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              _SheetItem(
                Icons.folder_outlined,
                'Documents',
                'View and manage student documents',
                () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AdminStudentDocumentsScreen(
                        student: student,
                        canMutate: canMutate,
                        onDocumentsChanged: onChanged,
                      ),
                    ),
                  );
                },
              ),
              _SheetItem(
                Icons.badge_outlined,
                'Identity & Cards',
                'Manage ID, QR code and NFC card',
                () {
                  Navigator.pop(context);
                  _identity(context, student);
                },
              ),
              _SheetItem(
                Icons.lock_outline_rounded,
                'Portal Access',
                'Manage student portal credentials',
                canMutate
                    ? () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                StudentPortalCodesScreen(student: student),
                          ),
                        );
                      }
                    : null,
              ),
              _SheetItem(
                Icons.block_outlined,
                'Deactivate',
                'Deactivate or suspend this student',
                canMutate ? () => _deactivate(context) : null,
                destructive: true,
              ),
              _SheetItem(
                Icons.swap_horiz_rounded,
                'Move to Another Class',
                'Transfer student to another class',
                canMutate ? () => _move(context) : null,
              ),
              _SheetItem(
                Icons.ios_share_outlined,
                'Export Record',
                'Export this student record',
                () => _export(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deactivate(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Deactivate student?'),
        content: Text('${student.name} will be suspended.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(d, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final result = await di.sl<StudentRepository>().updateStudentStatus(
      student.id,
      StudentStatus.suspended,
    );
    if (!context.mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(f.message))),
      (_) {
        Navigator.pop(context);
        onChanged();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Student deactivated.')));
      },
    );
  }

  Future<void> _move(BuildContext context) async {
    final s = context.read<StructureBloc>().state;
    String? selected = student.classId;
    final choice = await showDialog<String>(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Move to another class'),
          content: DropdownButtonFormField<String>(
            initialValue: selected,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Class'),
            items: s.classes
                .where((x) => x.isActive)
                .map(
                  (x) => DropdownMenuItem(
                    value: x.id,
                    child: Text(x.name, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (x) => setState(() => selected = x),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selected == null
                  ? null
                  : () => Navigator.pop(d, selected),
              child: const Text('Move student'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;
    final auth = context.read<AuthBloc>().state as AuthAuthenticated;
    final result = await di.sl<StudentRepository>().updateStudent(
      student.copyWith(classId: choice, streamId: null),
      recordedBy: auth.user.id,
    );
    if (!context.mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(f.message))),
      (_) {
        Navigator.pop(context);
        onChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student moved successfully.')),
        );
      },
    );
  }

  Future<void> _export() => Share.share(
    'Student record\n\nName: ${student.name}\nStudent code: ${student.studentCode}\nAdmission number: ${student.admissionNumber}\nDate of birth: ${DateFormat('dd MMM yyyy').format(student.dateOfBirth)}\nStatus: ${_status(student.status)}',
  );
}

class _SheetItem extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback? onTap;
  final bool destructive;
  const _SheetItem(
    this.icon,
    this.title,
    this.subtitle,
    this.onTap, {
    this.destructive = false,
  });
  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final color = destructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        ListTile(
          enabled: !disabled,
          contentPadding: const EdgeInsets.symmetric(vertical: 7),
          onTap: onTap,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(title),
          subtitle: Text(
            disabled ? 'You do not have permission for this action' : subtitle,
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

void _identity(BuildContext context, Student s) => Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => di.sl<StudentIdentityBloc>(),
      child: IdentityAndCardsScreen(student: s),
    ),
  ),
);
String _initials(String value) {
  final p = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((x) => x.isNotEmpty)
      .toList();
  return p.isEmpty
      ? '?'
      : (p.length == 1 ? p.first[0] : '${p.first[0]}${p.last[0]}')
            .toUpperCase();
}

String _gender(Gender value) => switch (value) {
  Gender.male => 'Male',
  Gender.female => 'Female',
  Gender.other => 'Other',
};
String _level(EducationLevel value) => switch (value) {
  EducationLevel.kindergarten => 'Kindergarten',
  EducationLevel.primary => 'Primary',
  EducationLevel.secondary => 'Secondary',
  EducationLevel.vocational => 'Vocational',
  EducationLevel.university => 'University',
  EducationLevel.international => 'International',
};
String _status(StudentStatus value) {
  final v = value.name.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
    (m) => '${m.group(1)} ${m.group(2)}',
  );
  return '${v[0].toUpperCase()}${v.substring(1)}';
}

Color _statusColor(SemanticColors c, StudentStatus s) => switch (s) {
  StudentStatus.active || StudentStatus.enrolled => c.success,
  StudentStatus.suspended ||
  StudentStatus.expelled ||
  StudentStatus.deceased => c.error,
  StudentStatus.withdrawn ||
  StudentStatus.transferredIn ||
  StudentStatus.transferredOut ||
  StudentStatus.onLeave ||
  StudentStatus.deferred => c.warning,
  _ => c.info,
};
