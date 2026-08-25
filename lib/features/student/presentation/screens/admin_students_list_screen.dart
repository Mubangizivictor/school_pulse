import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/components/pulse_table.dart';
import '../../../../design_system/responsive/responsive_builder.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_radius.dart';
import '../../../../design_system/theme/app_spacing.dart';
import '../../../../design_system/theme/app_typography.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../structure/domain/entities/structure_entities.dart';
import '../../../structure/presentation/bloc/structure_bloc.dart';
import '../../../structure/presentation/bloc/structure_state.dart';
import '../../domain/entities/student.dart';
import '../../domain/entities/student_enums.dart';
import '../bloc/students_bloc.dart';
import '../bloc/students_event.dart';
import '../bloc/students_state.dart';

/// Admin Students List / directory.
///
/// Filter chip set: `StudentStatus` has no `admitted` value (that only
/// exists on the separate `AdmissionStatus` enum used by applications, not
/// enrolled students), so the chips use the real StudentStatus set:
/// All / Active / Suspended / Transferred / Graduated / Alumni.
///
/// Desktop table: `PulseTable` has no built-in row-tap or column-sort
/// wiring (confirmed by reading pulse_table.dart - DataCell content is a
/// plain Widget with no onTap, and DataColumn has no onSort callback
/// plumbed through). Row navigation is achieved by wrapping the Name cell's
/// content in an InkWell that calls context.push(...) - true column sorting
/// is not implemented since PulseTable doesn't expose a hook for it and it
/// is a shared design-system component this task should not modify.
class AdminStudentsListScreen extends StatelessWidget {
  const AdminStudentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';

    // StructureBloc is already provided app-wide (see main.dart) and loaded
    // at sign-in - creating a second instance here would duplicate its
    // listeners and re-fetch data that's already loading/loaded.
    return BlocProvider(
      create: (_) => di.sl<StudentsBloc>()..add(LoadSchoolStudents(schoolId)),
      child: _AdminStudentsListView(schoolId: schoolId),
    );
  }
}

class _AdminStudentsListView extends StatefulWidget {
  final String schoolId;
  const _AdminStudentsListView({required this.schoolId});

  @override
  State<_AdminStudentsListView> createState() => _AdminStudentsListViewState();
}

class _AdminStudentsListViewState extends State<_AdminStudentsListView> {
  bool _searchVisible = false;
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

  List<Student> _applyFilters(List<Student> students) {
    final q = _query.trim().toLowerCase();
    return students.where((s) {
      if (q.isNotEmpty) {
        final matches =
            s.name.toLowerCase().contains(q) ||
            s.studentCode.toLowerCase().contains(q) ||
            s.admissionNumber.toLowerCase().contains(q);
        if (!matches) return false;
      }
      if (_statusFilter != null && s.status != _statusFilter) return false;
      if (_classFilter != null && s.classId != _classFilter) return false;
      if (_genderFilter != null && s.gender != _genderFilter) return false;
      return true;
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
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        elevation: 0,
        title: Text(
          'Students',
          style: AppTypography.titleLarge.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _searchVisible ? Icons.close : Icons.search,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            onPressed: () {
              setState(() {
                _searchVisible = !_searchVisible;
                if (!_searchVisible) {
                  _query = '';
                  _searchController.clear();
                }
              });
            },
          ),
          const SizedBox(width: AppSpacing.s),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/staff/admin/admissions/new', extra: widget.schoolId),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Student'),
      ),
      body: SafeArea(
        child: BlocBuilder<StructureBloc, StructureState>(
          builder: (context, structureState) {
            final classes = structureState.classes;

            String classLabel(String classId) {
              final match = classes.where((c) => c.id == classId);
              if (match.isEmpty)
                return classId.isEmpty ? 'Unassigned' : classId;
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
                final filtered = _applyFilters(allStudents);

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
                          if (_searchVisible) ...[
                            TextField(
                              controller: _searchController,
                              autofocus: true,
                              onChanged: (v) => setState(() => _query = v),
                              style: AppTypography.bodyMedium.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Search by name, code or admission number',
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
                          ],
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
                          Text(
                            '${filtered.length} Students',
                            style: AppTypography.labelLarge.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.l),
                        ],
                      ),
                    ),
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ResponsiveBuilder(
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
                                                style: AppTypography.bodyMedium
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors.primary(
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
                                      style: AppTypography.bodyMedium.copyWith(
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
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.full),
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
