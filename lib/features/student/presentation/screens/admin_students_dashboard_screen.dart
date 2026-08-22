import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/components/pulse_table.dart';
import '../../../../design_system/responsive/responsive_builder.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_radius.dart';
import '../../../../design_system/theme/app_spacing.dart';
import '../../../../design_system/theme/app_typography.dart';
import '../../../shared/staff_dashboard/staff_dashboard_widgets.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../structure/domain/entities/structure_entities.dart';
import '../../../structure/presentation/bloc/structure_bloc.dart';
import '../../../structure/presentation/bloc/structure_state.dart';
import '../../domain/entities/admission_application.dart';
import '../../domain/entities/student.dart';
import '../../domain/entities/student_enums.dart';
import '../bloc/admission_bloc.dart';
import '../bloc/admission_event.dart';
import '../bloc/admission_state.dart';
import '../bloc/students_bloc.dart';
import '../bloc/students_event.dart';
import '../bloc/students_state.dart';
import 'admissions_list_screen.dart' show admissionStatusLabel;

/// Admin Students Dashboard + List, merged onto one screen: a search bar
/// (name/class/code/admission no./parent name - all matched client-side
/// against the already school-scoped roster StudentsBloc loads), a compact
/// stat row, and the full filterable student list below it. No separate
/// List screen is needed - AdminStudentsListScreen still exists for direct
/// deep-linking but this is the primary entry point.
class AdminStudentsDashboardScreen extends StatelessWidget {
  const AdminStudentsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';

    // StructureBloc is already provided app-wide (see main.dart) and loaded
    // at sign-in - creating a second instance here would duplicate its
    // listeners and re-fetch data that's already loading/loaded.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              di.sl<StudentsBloc>()..add(LoadSchoolStudents(schoolId)),
        ),
        BlocProvider(
          create: (_) =>
              di.sl<AdmissionBloc>()..add(LoadApplicationsRequested(schoolId)),
        ),
      ],
      child: _AdminStudentsView(schoolId: schoolId),
    );
  }
}

class _AdminStudentsView extends StatefulWidget {
  final String schoolId;
  const _AdminStudentsView({required this.schoolId});

  @override
  State<_AdminStudentsView> createState() => _AdminStudentsViewState();
}

class _AdminStudentsViewState extends State<_AdminStudentsView> {
  String _query = '';
  StudentStatus? _statusFilter;
  String? _classFilter;
  Gender? _genderFilter;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// [classLabel] resolves a classId to its display name so "search by
  /// class" can match the name shown on-screen, not just the raw id -
  /// same class-name resolution the dashboard already uses for display,
  /// not a new lookup path.
  List<Student> _applyFilters(
    List<Student> students, {
    required String Function(String classId) classLabel,
  }) {
    final q = _query.trim().toLowerCase();
    return students.where((s) {
      if (q.isNotEmpty) {
        // Parent name/phone visibility here matches what this screen
        // already surfaces via emergencyContacts elsewhere on the card -
        // no new permission gate invented just for search.
        final matchesParent = s.emergencyContacts.any(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.phoneNumber.toLowerCase().contains(q),
        );
        final matchesClass = classLabel(s.classId).toLowerCase().contains(q);
        final matches =
            s.name.toLowerCase().contains(q) ||
            s.studentCode.toLowerCase().contains(q) ||
            s.admissionNumber.toLowerCase().contains(q) ||
            matchesClass ||
            matchesParent;
        if (!matches) return false;
      }
      if (_statusFilter != null && s.status != _statusFilter) return false;
      if (_classFilter != null && s.classId != _classFilter) return false;
      if (_genderFilter != null && s.gender != _genderFilter) return false;
      return true;
    }).toList();
  }

  // Applicant/Pending Admission are Student.status values that no Student
  // document ever actually carries - admitStudent() only creates the
  // Student record once an application is approved and admitted, so a
  // person still at those two stages exists solely as an
  // AdmissionApplication. Filtering the (always-empty-for-these-statuses)
  // Student list therefore showed "No students match" even when
  // applications were genuinely pending - this reads from the same
  // AdmissionBloc the "New Admissions" counter already uses instead, so
  // the chip and the counter agree.
  bool get _showsApplications =>
      _statusFilter == StudentStatus.applicant ||
      _statusFilter == StudentStatus.pendingAdmission;

  List<AdmissionApplication> _applyApplicationFilters(
    List<AdmissionApplication> applications,
  ) {
    final q = _query.trim().toLowerCase();
    final wantsReview = _statusFilter == StudentStatus.pendingAdmission;
    return applications.where((a) {
      final isReviewStage =
          a.status == AdmissionStatus.review ||
          a.status == AdmissionStatus.approved;
      final isApplicantStage = a.status == AdmissionStatus.application;
      if (wantsReview ? !isReviewStage : !isApplicantStage) return false;
      if (q.isEmpty) return true;
      return a.studentName.toLowerCase().contains(q) ||
          a.applicantParentName.toLowerCase().contains(q) ||
          a.applicantParentPhone.toLowerCase().contains(q);
    }).toList();
  }

  void _openFilterSheet(List<SchoolClass> classes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.xl,
                bottom:
                    MediaQuery.of(sheetContext).viewInsets.bottom +
                    AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Students',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Class',
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Wrap(
                    spacing: AppSpacing.m,
                    runSpacing: AppSpacing.m,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _classFilter == null,
                        onSelected: (_) =>
                            setSheetState(() => _classFilter = null),
                      ),
                      for (final c in classes)
                        ChoiceChip(
                          label: Text(c.name),
                          selected: _classFilter == c.id,
                          onSelected: (_) =>
                              setSheetState(() => _classFilter = c.id),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Gender',
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Wrap(
                    spacing: AppSpacing.m,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _genderFilter == null,
                        onSelected: (_) =>
                            setSheetState(() => _genderFilter = null),
                      ),
                      for (final g in Gender.values)
                        ChoiceChip(
                          label: Text(_genderLabel(g)),
                          selected: _genderFilter == g,
                          onSelected: (_) =>
                              setSheetState(() => _genderFilter = g),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x3l),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.of(sheetContext).pop();
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _genderLabel(Gender g) {
    switch (g) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }

  String _statusLabel(StudentStatus s) {
    final name = s.name;
    if (name.isEmpty) return name;
    final spaced = name.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m.group(1)} ${m.group(2)}',
    );
    return '${spaced[0].toUpperCase()}${spaced.substring(1)}';
  }

  Color _statusColor(BuildContext context, StudentStatus s) {
    switch (s) {
      case StudentStatus.active:
      case StudentStatus.enrolled:
        return AppColors.success(context);
      case StudentStatus.suspended:
      case StudentStatus.expelled:
      case StudentStatus.deceased:
        return AppColors.danger(context);
      case StudentStatus.withdrawn:
      case StudentStatus.transferredIn:
      case StudentStatus.transferredOut:
      case StudentStatus.onLeave:
      case StudentStatus.deferred:
        return AppColors.warning(context);
      case StudentStatus.graduated:
      case StudentStatus.completed:
        return AppColors.information(context);
      case StudentStatus.alumni:
      case StudentStatus.applicant:
      case StudentStatus.pendingAdmission:
      case StudentStatus.admitted:
      case StudentStatus.enrollmentInProgress:
      case StudentStatus.archived:
        return AppColors.primary(context);
    }
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: staffDashboardAppBar(
        context,
        roleLabel: 'Students',
        showHeaderActions: false,
      ),
      // Add Student registers directly (no application/review step) - that
      // flow is reserved for applicants coming through the public website,
      // reachable from AdmissionsListScreen's own "New Application" action.
      // An admin using this button knows the student already, so they go
      // straight through DirectStudentRegistrationScreen into the
      // Enrollment Setup Wizard in one continuous action.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final admissionBloc = context.read<AdmissionBloc>();
          final registered = await context.push<bool>(
            '/staff/admin/admissions/register',
            extra: widget.schoolId,
          );
          if (registered == true) {
            admissionBloc.add(LoadApplicationsRequested(widget.schoolId));
          }
        },
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Student'),
      ),
      body: SafeArea(
        child: BlocBuilder<StructureBloc, StructureState>(
          builder: (context, structureState) {
            final classes = structureState.classes;

            String classLabel(String classId) {
              final match = classes.where((c) => c.id == classId);
              if (match.isEmpty) {
                return classId.isEmpty ? 'Unassigned' : classId;
              }
              return match.first.name;
            }

            return BlocBuilder<StudentsBloc, StudentsState>(
              builder: (context, studentsState) {
                final isLoading =
                    studentsState is StudentsLoading ||
                    studentsState is StudentsInitial;
                final allStudents = studentsState is StudentsLoaded
                    ? studentsState.students
                    : <Student>[];
                final filtered = _applyFilters(
                  allStudents,
                  classLabel: classLabel,
                );

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.l,
                        AppSpacing.xl,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _query = v),
                            style: AppTypography.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Search name, class, code, admission no. or parent',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.surfaceLight,
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.medium,
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          BlocBuilder<AdmissionBloc, AdmissionState>(
                            builder: (context, admissionState) {
                              final pendingAdmissions =
                                  admissionState is AdmissionApplicationsLoaded
                                  ? admissionState.applications
                                        .where(
                                          (a) =>
                                              a.status !=
                                              AdmissionStatus.rejected,
                                        )
                                        .length
                                  : 0;
                              final total = allStudents.length;
                              final active = allStudents
                                  .where(
                                    (s) => s.status == StudentStatus.active,
                                  )
                                  .length;
                              final suspended = allStudents
                                  .where(
                                    (s) => s.status == StudentStatus.suspended,
                                  )
                                  .length;
                              return StaffHeroSummaryCard(
                                greetingNameFallback: 'there',
                                kpis: isLoading
                                    ? null
                                    : [
                                        StaffKpiData(
                                          title: 'Total Students',
                                          valueText: '$total',
                                          subtitle: 'Enrolled',
                                          icon: Icons.groups_rounded,
                                          color: AppColors.information(context),
                                        ),
                                        StaffKpiData(
                                          title: 'Active',
                                          valueText: '$active',
                                          subtitle: 'In good standing',
                                          icon: Icons.verified_rounded,
                                          color: AppColors.success(context),
                                        ),
                                        StaffKpiData(
                                          title: 'Suspended',
                                          valueText: '$suspended',
                                          subtitle: 'Needs review',
                                          icon: Icons.block_rounded,
                                          color: AppColors.danger(context),
                                        ),
                                        StaffKpiData(
                                          title: 'New Admissions',
                                          valueText: '$pendingAdmissions',
                                          subtitle: 'Pending',
                                          icon: Icons.how_to_reg_rounded,
                                          color: AppColors.warning(context),
                                        ),
                                      ],
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.l),
                          Row(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _StatusChip(
                                        label: 'All',
                                        selected: _statusFilter == null,
                                        onTap: () => setState(
                                          () => _statusFilter = null,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.m),
                                      for (final s in StudentStatus.values) ...[
                                        _StatusChip(
                                          label: _statusLabel(s),
                                          selected: _statusFilter == s,
                                          onTap: () => setState(
                                            () => _statusFilter =
                                                _statusFilter == s ? null : s,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.m),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.filter_list,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                                onPressed: () => _openFilterSheet(classes),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.l),
                          BlocBuilder<AdmissionBloc, AdmissionState>(
                            builder: (context, admissionState) {
                              final count = _showsApplications
                                  ? _applyApplicationFilters(
                                      admissionState
                                              is AdmissionApplicationsLoaded
                                          ? admissionState.applications
                                          : const <AdmissionApplication>[],
                                    ).length
                                  : filtered.length;
                              final label = _showsApplications
                                  ? '$count Applications'
                                  : '$count Students';
                              return Text(
                                label,
                                style: AppTypography.labelLarge.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.l),
                        ],
                      ),
                    ),
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : BlocBuilder<AdmissionBloc, AdmissionState>(
                              builder: (context, admissionState) {
                                final applications = _showsApplications
                                    ? _applyApplicationFilters(
                                        admissionState
                                                is AdmissionApplicationsLoaded
                                            ? admissionState.applications
                                            : const <AdmissionApplication>[],
                                      )
                                    : const <AdmissionApplication>[];

                                if (_showsApplications) {
                                  if (applications.isEmpty) {
                                    return Center(
                                      child: Text(
                                        _statusFilter ==
                                                StudentStatus.pendingAdmission
                                            ? 'No pending admissions'
                                            : 'No applicants match the current filters',
                                        style: AppTypography.bodyMedium
                                            .copyWith(
                                              color: isDark
                                                  ? AppColors.textMutedDark
                                                  : AppColors.textMutedLight,
                                            ),
                                      ),
                                    );
                                  }
                                  return ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(
                                      AppSpacing.xl,
                                      0,
                                      AppSpacing.xl,
                                      AppSpacing.x6l,
                                    ),
                                    itemCount: applications.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(height: AppSpacing.m),
                                    itemBuilder: (context, index) {
                                      final a = applications[index];
                                      return _ApplicationRow(
                                        application: a,
                                        initials: _initials(a.studentName),
                                        onTap: () => context.push(
                                          '/staff/admin/admissions/review',
                                          extra: a,
                                        ),
                                      );
                                    },
                                  );
                                }

                                return ResponsiveBuilder(
                                  builder: (context, layout) {
                                    if (layout == ResponsiveLayout.desktop) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.xl,
                                        ),
                                        child: SingleChildScrollView(
                                          child: PulseTable<Student>(
                                            items: filtered,
                                            emptyMessage:
                                                'No students match the current filters',
                                            columns: [
                                              PulseTableColumn<Student>(
                                                title: 'Name',
                                                cellBuilder: (s) => InkWell(
                                                  onTap: () => context.push(
                                                    '/staff/admin/students/${s.id}',
                                                  ),
                                                  child: Text(
                                                    s.name,
                                                    style: AppTypography
                                                        .bodyMedium
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              AppColors.primary(
                                                                context,
                                                              ),
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              PulseTableColumn<Student>(
                                                title: 'Class',
                                                cellBuilder: (s) =>
                                                    Text(classLabel(s.classId)),
                                              ),
                                              PulseTableColumn<Student>(
                                                title: 'Status',
                                                cellBuilder: (s) => _StatusPill(
                                                  label: _statusLabel(s.status),
                                                  color: _statusColor(
                                                    context,
                                                    s.status,
                                                  ),
                                                ),
                                              ),
                                              PulseTableColumn<Student>(
                                                title: 'Admission No.',
                                                cellBuilder: (s) =>
                                                    Text(s.admissionNumber),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    if (filtered.isEmpty) {
                                      return Center(
                                        child: Text(
                                          'No students match the current filters',
                                          style: AppTypography.bodyMedium
                                              .copyWith(
                                                color: isDark
                                                    ? AppColors.textMutedDark
                                                    : AppColors.textMutedLight,
                                              ),
                                        ),
                                      );
                                    }

                                    return ListView.separated(
                                      padding: const EdgeInsets.fromLTRB(
                                        AppSpacing.xl,
                                        0,
                                        AppSpacing.xl,
                                        AppSpacing.x6l,
                                      ),
                                      itemCount: filtered.length,
                                      separatorBuilder: (_, _) =>
                                          const SizedBox(height: AppSpacing.m),
                                      itemBuilder: (context, index) {
                                        final s = filtered[index];
                                        return _StudentRow(
                                          student: s,
                                          classLabel: classLabel(s.classId),
                                          statusLabel: _statusLabel(s.status),
                                          statusColor: _statusColor(
                                            context,
                                            s.status,
                                          ),
                                          initials: _initials(s.name),
                                          onTap: () => context.push(
                                            '/staff/admin/students/${s.id}',
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primarySoft(context),
      labelStyle: AppTypography.labelMedium.copyWith(
        color: selected
            ? AppColors.primary(context)
            : AppColors.textSecondary(context),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.full,
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final Student student;
  final String classLabel;
  final String statusLabel;
  final Color statusColor;
  final String initials;
  final VoidCallback onTap;

  const _StudentRow({
    required this.student,
    required this.classLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.initials,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPhoto = student.photoUrl != null && student.photoUrl!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.medium,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppRadius.medium,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primarySoft(context),
              backgroundImage: hasPhoto
                  ? NetworkImage(student.photoUrl!)
                  : null,
              child: hasPhoto
                  ? null
                  : Text(
                      initials,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary(context),
                      ),
                    ),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    '$classLabel · ${student.admissionNumber}',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
            _StatusPill(label: statusLabel, color: statusColor),
          ],
        ),
      ),
    );
  }
}

// Same card layout as _StudentRow so an Applicant/Pending Admission chip
// doesn't look like a different feature - it's the same list, just backed
// by AdmissionApplication instead of Student for these two statuses.
class _ApplicationRow extends StatelessWidget {
  final AdmissionApplication application;
  final String initials;
  final VoidCallback onTap;

  const _ApplicationRow({
    required this.application,
    required this.initials,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.medium,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppRadius.medium,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primarySoft(context),
              child: Text(
                initials,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary(context),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.studentName,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    application.applicantParentName.isNotEmpty
                        ? application.applicantParentName
                        : 'No parent/guardian on file',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
            _StatusPill(
              label: admissionStatusLabel(application.status),
              color: AppColors.warning(context),
            ),
          ],
        ),
      ),
    );
  }
}
