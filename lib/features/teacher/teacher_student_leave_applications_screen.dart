import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/injection_container.dart' as di;

import 'domain/entities/student_leave_application.dart';
import 'domain/repositories/class_student_repository.dart';
import 'presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'presentation/widgets/teacher_student_detail_ui.dart';

/// This student's leave applications as the boarding queue holds them.
///
/// The Class Teacher reads the same `boarding_leave_requests` rows the
/// Patron/Matron approves from, so there is one leave record per request
/// rather than a class-teacher copy that could disagree. Approval stays with
/// boarding staff; a class teacher raises and follows, which is why this
/// screen has no approve/reject control.
class TeacherStudentLeaveApplicationsScreen extends StatefulWidget {
  final String studentId;
  const TeacherStudentLeaveApplicationsScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<TeacherStudentLeaveApplicationsScreen> createState() =>
      _TeacherStudentLeaveApplicationsScreenState();
}

class _TeacherStudentLeaveApplicationsScreenState
    extends State<TeacherStudentLeaveApplicationsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<StudentLeaveApplication> _applications = const [];

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  StudentLeaveStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active == null) {
      setState(() {
        _errorMessage =
            'Your class responsibility is still loading. Try again in a moment.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await di
        .sl<ClassStudentRepository>()
        .getStudentLeaveApplications(
          context: active,
          studentId: widget.studentId,
        );

    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _errorMessage = failure.message;
        _isLoading = false;
      }),
      (applications) => setState(() {
        _applications = applications;
        _isLoading = false;
      }),
    );
  }

  /// Search covers reason and destination - what a teacher actually
  /// remembers about a request - plus who raised it.
  List<StudentLeaveApplication> get _visible {
    final query = _query.trim().toLowerCase();
    return _applications.where((application) {
      if (_statusFilter != null && application.status != _statusFilter) {
        return false;
      }
      if (query.isEmpty) return true;
      return application.reason.toLowerCase().contains(query) ||
          (application.destination ?? '').toLowerCase().contains(query) ||
          (application.requestedByName ?? '').toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const TeacherStudentDetailAppBar(title: 'Leave Applications'),
      body: SafeArea(top: false, child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return TeacherStudentDetailErrorState(
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    if (_applications.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
            const TeacherStudentDetailEmptyState(
              icon: Icons.exit_to_app_outlined,
              title: 'No leave applications',
              message:
                  'Leave requests raised for this student - by you, a parent, '
                  'or the boarding patron - will appear here.',
            ),
          ],
        ),
      );
    }

    final visible = _visible;

    return Column(
      children: [
        _LeaveFilters(
          controller: _searchController,
          selected: _statusFilter,
          counts: _statusCounts,
          onQueryChanged: (value) => setState(() => _query = value),
          onStatusChanged: (status) => setState(() => _statusFilter = status),
        ),
        Expanded(
          child: visible.isEmpty
              ? const TeacherStudentDetailEmptyState(
                  icon: Icons.search_off_outlined,
                  title: 'Nothing matches that',
                  message:
                      'No leave application matches your search or filter. '
                      'Try a different word, or clear the filter.',
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      0,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    itemCount: visible.length,
                    itemBuilder: (context, index) => _LeaveCard(
                      application: visible[index],
                      onTap: () => _openDetail(visible[index]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Map<StudentLeaveStatus, int> get _statusCounts {
    final counts = <StudentLeaveStatus, int>{};
    for (final application in _applications) {
      counts[application.status] = (counts[application.status] ?? 0) + 1;
    }
    return counts;
  }

  void _openDetail(StudentLeaveApplication application) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.l)),
      ),
      builder: (_) => _LeaveDetailSheet(application: application),
    );
  }
}

/// Search field plus a status filter row, kept horizontally scrollable so the
/// chips never overflow on a narrow phone.
class _LeaveFilters extends StatelessWidget {
  const _LeaveFilters({
    required this.controller,
    required this.selected,
    required this.counts,
    required this.onQueryChanged,
    required this.onStatusChanged,
  });

  final TextEditingController controller;
  final StudentLeaveStatus? selected;
  final Map<StudentLeaveStatus, int> counts;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<StudentLeaveStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final statuses = StudentLeaveStatus.values
        .where((status) => (counts[status] ?? 0) > 0)
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.s,
        AppSpacing.xl,
        AppSpacing.m,
      ),
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: onQueryChanged,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary(context),
            ),
            decoration: InputDecoration(
              hintText: 'Search reason or destination',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted(context),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.textMuted(context),
              ),
              isDense: true,
              filled: true,
              fillColor: AppColors.surfaceElevated(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.l),
                borderSide: BorderSide(color: AppColors.border(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.l),
                borderSide: BorderSide(color: AppColors.border(context)),
              ),
            ),
          ),
          if (statuses.length > 1) ...[
            const SizedBox(height: AppSpacing.m),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: selected == null,
                    onTap: () => onStatusChanged(null),
                  ),
                  for (final status in statuses) ...[
                    const SizedBox(width: AppSpacing.s),
                    _FilterChip(
                      label: '${status.label} (${counts[status]})',
                      isSelected: selected == status,
                      onTap: () => onStatusChanged(status),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.s,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary(context)
              : AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(AppSpacing.l),
          border: Border.all(
            color: isSelected
                ? AppColors.primary(context)
                : AppColors.border(context),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary(context),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.application, required this.onTap});

  final StudentLeaveApplication application;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(AppSpacing.l),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.l),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        application.reason.isEmpty
                            ? 'Leave request'
                            : application.reason,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    _StatusPill(application: application),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                _IconLine(
                  icon: Icons.event_outlined,
                  text: _dateRange(application),
                ),
                if ((application.destination ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _IconLine(
                    icon: Icons.place_outlined,
                    text: application.destination!,
                  ),
                ],
                if (application.raisedByClassTeacher) ...[
                  const SizedBox(height: 4),
                  _IconLine(
                    icon: Icons.person_outline,
                    text: 'Raised from the Class Teacher panel',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted(context)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
        ),
      ],
    );
  }
}

/// Status colour follows the same meaning the boarding module uses: green for
/// settled, amber for waiting, red for refused or overdue.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.application});

  final StudentLeaveApplication application;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _appearance(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.s),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  (String, Color) _appearance(BuildContext context) {
    if (application.isOverdue) {
      return ('Overdue', AppColors.error);
    }
    return switch (application.status) {
      StudentLeaveStatus.approved => ('Approved', AppColors.success(context)),
      StudentLeaveStatus.returned => ('Returned', AppColors.success(context)),
      StudentLeaveStatus.rejected => ('Rejected', AppColors.error),
      StudentLeaveStatus.out => ('Out', AppColors.primary(context)),
      StudentLeaveStatus.pending => ('Pending', AppColors.warning(context)),
    };
  }
}

/// Read-only detail. Approval belongs to the boarding patron, so this sheet
/// reports the decision rather than offering one.
class _LeaveDetailSheet extends StatelessWidget {
  const _LeaveDetailSheet({required this.application});

  final StudentLeaveApplication application;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Leave application',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusPill(application: application),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            _DetailRow(label: 'Student', value: application.studentName),
            _DetailRow(
              label: 'Reason',
              value: application.reason.isEmpty ? '-' : application.reason,
            ),
            _DetailRow(
              label: 'Destination',
              value: (application.destination ?? '').isEmpty
                  ? '-'
                  : application.destination!,
            ),
            _DetailRow(label: 'Leaves', value: _day(application.departureDate)),
            _DetailRow(
              label: 'Due back',
              value: _day(application.expectedReturnDate),
            ),
            if (application.actualReturnDate != null)
              _DetailRow(
                label: 'Returned',
                value: _day(application.actualReturnDate!),
              )
            else if (application.status == StudentLeaveStatus.out)
              _DetailRow(
                label: 'Returned',
                value: application.isOverdue
                    ? 'Not yet - overdue'
                    : 'Not yet - still out',
              ),
            if ((application.requestedByName ?? '').isNotEmpty)
              _DetailRow(
                label: 'Raised by',
                value: application.requestedByName!,
              ),
            if ((application.approvedByName ?? '').isNotEmpty)
              _DetailRow(
                label: 'Decided by',
                value: application.approvedByName!,
              ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Leave is approved by the boarding patron or matron. Contact '
              'them if this request needs a decision or a change.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _dateRange(StudentLeaveApplication application) {
  final from = _day(application.departureDate);
  final to = _day(application.expectedReturnDate);
  return from == to ? from : '$from to $to';
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _day(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';
