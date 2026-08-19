import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dartz/dartz.dart' hide State;

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

import 'admin_student_documents_screen.dart';
import 'student_portal_codes_screen.dart';
import 'package:school_pulse/features/student_identity/presentation/screens/identity_and_cards_screen.dart';

/// Admin-facing student profile screen.
///
/// Loads a single [Student] by id directly from the [StudentRepository]
/// (mirrors the lightweight FutureBuilder-based loading approach used by
/// the student-portal detail screens rather than pulling in a new bloc).
class AdminStudentProfileScreen extends StatefulWidget {
  final String studentId;

  const AdminStudentProfileScreen({super.key, required this.studentId});

  @override
  State<AdminStudentProfileScreen> createState() =>
      _AdminStudentProfileScreenState();
}

class _AdminStudentProfileScreenState extends State<AdminStudentProfileScreen> {
  late Future<Either<Failure, Student>> _future;
  final StudentRepository _repository = di.sl<StudentRepository>();

  @override
  void initState() {
    super.initState();
    _future = _repository.getStudentById(widget.studentId);
  }

  void _reload() {
    setState(() {
      _future = _repository.getStudentById(widget.studentId);
    });
  }

  bool _canMutate(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return false;
    final roleName = authState.user.role.name.toLowerCase();
    // Light-touch check: hide mutation affordances for portal/student-only
    // roles. Real enforcement lives in firestore.rules.
    if (roleName.contains('parent') || roleName.contains('student')) {
      return false;
    }
    return true;
  }

  void _todoSnackBar(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('TODO: $action is not wired up yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        actions: [
          FutureBuilder<Either<Failure, Student>>(
            future: _future,
            builder: (context, snapshot) {
              final student = snapshot.data?.fold((_) => null, (s) => s);
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'deactivate':
                      _todoSnackBar(context, 'Deactivate student');
                      break;
                    case 'move_class':
                      _todoSnackBar(context, 'Move to another class');
                      break;
                    case 'export':
                      _todoSnackBar(context, 'Export record');
                      break;
                    case 'documents':
                      if (student != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AdminStudentDocumentsScreen(
                              student: student,
                              canMutate: _canMutate(context),
                              onDocumentsChanged: _reload,
                            ),
                          ),
                        );
                      }
                      break;
                    case 'identity':
                      if (student != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                IdentityAndCardsScreen(student: student),
                          ),
                        );
                      }
                      break;
                    case 'portal':
                      if (student != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                StudentPortalCodesScreen(student: student),
                          ),
                        );
                      }
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'documents',
                    child: ListTile(
                      leading: Icon(Icons.folder_outlined),
                      title: Text('Documents'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'identity',
                    child: ListTile(
                      leading: Icon(Icons.badge_outlined),
                      title: Text('Identity & Cards'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'portal',
                    child: ListTile(
                      leading: Icon(Icons.lock_outline),
                      title: Text('Portal Access'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'deactivate',
                    child: ListTile(
                      leading: Icon(Icons.block_outlined),
                      title: Text('Deactivate'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'move_class',
                    child: ListTile(
                      leading: Icon(Icons.swap_horiz),
                      title: Text('Move to Another Class'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'export',
                    child: ListTile(
                      leading: Icon(Icons.ios_share_outlined),
                      title: Text('Export Record'),
                    ),
                  ),
                ],
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
            (student) => _ProfileBody(
              student: student,
              canMutate: _canMutate(context),
              onDocumentsChanged: _reload,
            ),
          );
        },
      ),
    );
  }
}

class _ProfileBody extends StatefulWidget {
  final Student student;
  final bool canMutate;
  final VoidCallback onDocumentsChanged;

  const _ProfileBody({
    required this.student,
    required this.canMutate,
    required this.onDocumentsChanged,
  });

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['Overview', 'Guardian', 'Academic', 'More'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, layout) {
        final isDesktop = layout == ResponsiveLayout.desktop;
        final header = _ProfileHeader(student: widget.student);
        final tabContent = _TabContent(
          student: widget.student,
          canMutate: widget.canMutate,
          onDocumentsChanged: widget.onDocumentsChanged,
        );

        if (!isDesktop) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: header,
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _OverviewTab(student: widget.student),
                    _GuardianTab(student: widget.student),
                    _AcademicTab(student: widget.student),
                    _MoreTab(
                      student: widget.student,
                      canMutate: widget.canMutate,
                      onDocumentsChanged: widget.onDocumentsChanged,
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // Desktop: wide two-column layout, vertical side nav instead of a
        // top TabBar.
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 340,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: header,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 180,
                      child: NavigationRail(
                        selectedIndex: _tabController.index,
                        onDestinationSelected: (index) {
                          setState(() => _tabController.index = index);
                        },
                        labelType: NavigationRailLabelType.all,
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.person_outline),
                            label: Text('Overview'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.family_restroom_outlined),
                            label: Text('Guardian'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.school_outlined),
                            label: Text('Academic'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.more_horiz),
                            label: Text('More'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _tabController,
                        builder: (context, _) {
                          return tabContent._forIndex(_tabController.index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TabContent {
  final Student student;
  final bool canMutate;
  final VoidCallback onDocumentsChanged;

  const _TabContent({
    required this.student,
    required this.canMutate,
    required this.onDocumentsChanged,
  });

  Widget _forIndex(int index) {
    switch (index) {
      case 0:
        return _OverviewTab(student: student);
      case 1:
        return _GuardianTab(student: student);
      case 2:
        return _AcademicTab(student: student);
      default:
        return _MoreTab(
          student: student,
          canMutate: canMutate,
          onDocumentsChanged: onDocumentsChanged,
        );
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final Student student;

  const _ProfileHeader({required this.student});

  Color _statusColor(SemanticColors colors, StudentStatus status) {
    switch (status) {
      case StudentStatus.active:
      case StudentStatus.enrolled:
        return colors.success;
      case StudentStatus.suspended:
      case StudentStatus.expelled:
      case StudentStatus.deceased:
        return colors.error;
      case StudentStatus.withdrawn:
      case StudentStatus.transferredIn:
      case StudentStatus.transferredOut:
      case StudentStatus.onLeave:
      case StudentStatus.deferred:
        return colors.warning;
      case StudentStatus.graduated:
      case StudentStatus.alumni:
      case StudentStatus.completed:
      case StudentStatus.applicant:
      case StudentStatus.pendingAdmission:
      case StudentStatus.admitted:
      case StudentStatus.archived:
        return colors.info;
    }
  }

  String _statusLabel(StudentStatus status) {
    final name = status.name;
    if (name.isEmpty) return name;
    // Splits camelCase enum names into a readable label, e.g.
    // "transferredOut" -> "Transferred Out", "onLeave" -> "On Leave".
    final spaced = name.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m.group(1)} ${m.group(2)}',
    );
    return '${spaced[0].toUpperCase()}${spaced.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<SemanticColors>()!;
    final theme = Theme.of(context);

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: theme.colorScheme.primaryContainer,
            backgroundImage: (student.photoUrl != null && student.photoUrl!.isNotEmpty)
                ? NetworkImage(student.photoUrl!)
                : null,
            child: (student.photoUrl == null || student.photoUrl!.isEmpty)
                ? Text(
                    _initials(student.name),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        student.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: _statusLabel(student.status),
                      color: _statusColor(colors, student.status),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  student.studentCode,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                BlocBuilder<StructureBloc, StructureState>(
                  builder: (context, structure) {
                    final className = structure.classes
                        .where((c) => c.id == student.classId)
                        .firstOrNull
                        ?.name;
                    final streamName = structure.streams
                        .where((s) => s.id == student.streamId)
                        .firstOrNull
                        ?.name;
                    final label = [
                      ?className,
                      ?streamName,
                    ].join(' • ');
                    if (label.isEmpty) return const SizedBox.shrink();
                    return Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Student student;

  const _OverviewTab({required this.student});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      _InfoRow(
        label: 'Date of Birth',
        value: DateFormat('dd MMM yyyy').format(student.dateOfBirth),
      ),
      _InfoRow(label: 'Gender', value: _genderLabel(student.gender)),
      if (student.medicalInfo?.bloodGroup != null &&
          student.medicalInfo!.bloodGroup!.isNotEmpty)
        _InfoRow(label: 'Blood Group', value: student.medicalInfo!.bloodGroup!),
      if (student.previousSchool != null && student.previousSchool!.isNotEmpty)
        _InfoRow(label: 'Previous School', value: student.previousSchool!),
      _InfoRow(label: 'Admission No.', value: student.admissionNumber),
      _InfoRow(label: 'Education Level', value: _levelLabel(student.level)),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(child: Column(children: rows)),
      ],
    );
  }

  String _genderLabel(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }

  String _levelLabel(EducationLevel level) {
    switch (level) {
      case EducationLevel.kindergarten:
        return 'Kindergarten';
      case EducationLevel.primary:
        return 'Primary';
      case EducationLevel.secondary:
        return 'Secondary';
      case EducationLevel.vocational:
        return 'Vocational';
      case EducationLevel.university:
        return 'University';
      case EducationLevel.international:
        return 'International';
    }
  }
}

class _GuardianTab extends StatelessWidget {
  final Student student;

  const _GuardianTab({required this.student});

  @override
  Widget build(BuildContext context) {
    if (student.emergencyContacts.isEmpty) {
      return const EmptyState(
        icon: Icons.family_restroom_outlined,
        title: 'No guardians on file',
        message: 'Emergency contacts for this student will appear here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: student.emergencyContacts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final contact = student.emergencyContacts[index];
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contact.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(contact.relationship, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text(contact.phoneNumber),
                ],
              ),
              if (contact.email != null && contact.email!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 16),
                    const SizedBox(width: 6),
                    Text(contact.email!),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AcademicTab extends StatelessWidget {
  final Student student;

  const _AcademicTab({required this.student});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, structure) {
        final className = structure.classes
            .where((c) => c.id == student.classId)
            .firstOrNull
            ?.name ??
            'Unknown class';
        final streamName = structure.streams
            .where((s) => s.id == student.streamId)
            .firstOrNull
            ?.name;
        final year = structure.academicYears
            .where((y) => y.id == student.academicYearId)
            .firstOrNull
            ?.name ??
            'Unknown year';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                children: [
                  _InfoRow(label: 'Class', value: className),
                  if (streamName != null) _InfoRow(label: 'Stream', value: streamName),
                  _InfoRow(label: 'Academic Year', value: year),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Deep academic performance data (grades/scores) is served by
            // AcademicBloc, which is scoped to the currently selected
            // student in the student portal (see StudentAcademicsScreen).
            // Reusing it here read-only would require re-keying that
            // global selection, which is out of scope for this admin
            // view — so we link out instead of duplicating aggregation
            // logic.
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'TODO: link to full academic record view for this student.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.bar_chart_outlined),
              label: const Text('View full academic record'),
            ),
          ],
        );
      },
    );
  }
}

class _MoreTab extends StatelessWidget {
  final Student student;
  final bool canMutate;
  final VoidCallback onDocumentsChanged;

  const _MoreTab({
    required this.student,
    required this.canMutate,
    required this.onDocumentsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Documents'),
            subtitle: const Text('ID card, certificates, forms and letters'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AdminStudentDocumentsScreen(
                    student: student,
                    canMutate: canMutate,
                    onDocumentsChanged: onDocumentsChanged,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (student.qrReference != null && student.qrReference!.isNotEmpty)
          AppCard(
            child: Column(
              children: [
                _InfoRow(label: 'QR Reference', value: student.qrReference!),
              ],
            ),
          ),
      ],
    );
  }
}
