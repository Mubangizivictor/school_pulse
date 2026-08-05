import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/enums/student_status.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/matron/domain/entities/matron_entities.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_bloc.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_event.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_state.dart';

/// This screen's own copy ("Dormitory", "Session") already identifies it as
/// boarding manual attendance, even though the shared /staff/attendance
/// route it sits under is reachable by other staff roles too - scoped to
/// boarding rosters only for this pass, matching what's actually on screen.
/// Class/subject/staff manual entry is a known gap for a future phase; the
/// real Class Teacher panel already has its own correct flow elsewhere.
class ManualAttendanceScreen extends StatefulWidget {
  const ManualAttendanceScreen({super.key});

  @override
  State<ManualAttendanceScreen> createState() => _ManualAttendanceScreenState();
}

class _ManualAttendanceScreenState extends State<ManualAttendanceScreen> {
  String? _selectedDormId;
  final String _selectedSession = 'Evening';
  final DateTime _selectedDate = DateTime.now();
  final Map<String, StudentStatus> _statusOverrides = {};
  String _searchQuery = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(WatchDormitories());
  }

  String _currentSchoolId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : '';
  }

  String _currentUserName(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.name : 'Staff';
  }

  StudentStatus _statusFor(BoardingStudent student) {
    return _statusOverrides[student.id] ??
        (student.status == 'Absent'
            ? StudentStatus.absent
            : StudentStatus.present);
  }

  void _markAllPresent(List<BoardingStudent> students) {
    setState(() {
      for (final s in students) {
        _statusOverrides[s.id] = StudentStatus.present;
      }
    });
  }

  void _saveAttendance(List<BoardingStudent> students) {
    setState(() => _saving = true);
    final schoolId = _currentSchoolId(context);
    final recordedBy = _currentUserName(context);
    final records = students.map((s) {
      final status = _statusFor(s);
      return BoardingAttendance(
        id: '',
        schoolId: schoolId,
        studentId: s.id,
        studentName: s.name,
        dormitoryId: _selectedDormId!,
        date: _selectedDate,
        type: _selectedSession,
        status: status == StudentStatus.absent ? 'Absent' : 'Present',
        recordedBy: recordedBy,
      );
    }).toList();

    context.read<MatronBloc>().add(BulkRecordAttendanceEvent(records));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticColors = theme.extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Manual Attendance'),
      ),
      body: BlocConsumer<MatronBloc, MatronState>(
        listener: (context, state) {
          if (state is MatronActionSuccess) {
            setState(() => _saving = false);
            context.push('/staff/attendance/summary');
          } else if (state is MatronError) {
            setState(() => _saving = false);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final dormitories = state is DormitoriesLoaded
              ? state.dormitories
              : (state is MatronDashboardLoaded
                    ? state.dormitories
                    : const <Dormitory>[]);
          final students = state is BoardingStudentsLoaded
              ? state.students
              : const <BoardingStudent>[];
          final filteredStudents = students
              .where(
                (s) =>
                    s.name.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  children: [
                    _buildDormDropdown(context, dormitories),
                    const SizedBox(height: AppSpacing.m),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStaticField(
                            context,
                            'Session',
                            _selectedSession,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: _buildStaticField(
                            context,
                            'Date',
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: AppSearchField(
                  hintText: 'Search students by name...',
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: Row(
                  children: [
                    Text(
                      '${filteredStudents.length} Students',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: filteredStudents.isEmpty
                          ? null
                          : () => _markAllPresent(filteredStudents),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      icon: const Icon(Icons.done_all, size: 18),
                      label: const Text('Mark all present'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _selectedDormId == null
                    ? const EmptyState(
                        icon: Icons.night_shelter_outlined,
                        title: 'Select a dormitory',
                        message:
                            'Choose a dormitory above to load its residents.',
                      )
                    : filteredStudents.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off,
                        title: 'No results',
                        message:
                            'No students found matching your search query.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.l,
                        ),
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          return FadeInSlide(
                            delay: Duration(milliseconds: index * 30),
                            child: AppCard(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  AvatarInitials(name: student.name, size: 44),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          student.studentClass,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.outline,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildStatusToggle(student, semanticColors),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated(context),
                  border: Border(
                    top: BorderSide(color: AppColors.border(context)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: PrimaryButton(
                    label: 'Save Attendance',
                    onPressed:
                        (_selectedDormId == null || students.isEmpty || _saving)
                        ? null
                        : () => _saveAttendance(students),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusToggle(BoardingStudent student, SemanticColors colors) {
    final currentStatus = _statusFor(student);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusButton(
            icon: Icons.check,
            color: colors.success,
            isSelected: currentStatus == StudentStatus.present,
            onTap: () => setState(
              () => _statusOverrides[student.id] = StudentStatus.present,
            ),
          ),
          const SizedBox(width: 4),
          _StatusButton(
            icon: Icons.access_time,
            color: colors.warning,
            isSelected: currentStatus == StudentStatus.late,
            onTap: () => setState(
              () => _statusOverrides[student.id] = StudentStatus.late,
            ),
          ),
          const SizedBox(width: 4),
          _StatusButton(
            icon: Icons.close,
            color: colors.error,
            isSelected: currentStatus == StudentStatus.absent,
            onTap: () => setState(
              () => _statusOverrides[student.id] = StudentStatus.absent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDormDropdown(BuildContext context, List<Dormitory> dormitories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dormitory',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedDormId,
              hint: const Text(
                'Select dormitory',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              items: dormitories
                  .map(
                    (d) => DropdownMenuItem(value: d.id, child: Text(d.name)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDormId = value;
                  _statusOverrides.clear();
                });
                if (value != null) {
                  context.read<MatronBloc>().add(
                    WatchBoardingStudents(dormitoryId: value),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaticField(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusButton({
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : color.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
