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

const _kAttendanceTypes = [
  'Morning',
  'Evening',
  'Weekend',
  'Holiday',
  'Study',
  'Activity',
];

class BoardingAttendanceScreen extends StatefulWidget {
  const BoardingAttendanceScreen({super.key});

  @override
  State<BoardingAttendanceScreen> createState() =>
      _BoardingAttendanceScreenState();
}

class _BoardingAttendanceScreenState extends State<BoardingAttendanceScreen> {
  String? selectedDormId;
  String? selectedDormName;
  String selectedType = 'Evening';
  DateTime selectedDate = DateTime.now();
  Map<String, StudentStatus> attendanceMap = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(WatchDormitories());
    _loadAttendance();
  }

  void _loadAttendance() {
    context.read<MatronBloc>().add(
      WatchAttendance(
        schoolId: _currentSchoolId(context),
        date: selectedDate,
        dormitoryId: selectedDormId,
        type: selectedType,
      ),
    );
    if (selectedDormId != null) {
      context.read<MatronBloc>().add(
        WatchBoardingStudents(dormitoryId: selectedDormId),
      );
    }
  }

  String _currentUserName(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.name : 'Matron';
  }

  String _currentSchoolId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : '';
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Boarding Attendance'),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: BlocConsumer<MatronBloc, MatronState>(
              listener: (context, state) {
                if (state is MatronActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.success(context),
                    ),
                  );
                }
              },
              buildWhen: (previous, current) =>
                  current is BoardingStudentsLoaded ||
                  current is AttendanceLoaded ||
                  current is MatronLoading,
              builder: (context, state) {
                List<BoardingStudent> students = [];
                if (state is BoardingStudentsLoaded) {
                  students = state.students;
                }
                if (state is AttendanceLoaded) {
                  for (var record in state.attendance) {
                    attendanceMap[record.studentId] = StudentStatus.values
                        .firstWhere(
                          (e) =>
                              e.name.toLowerCase() ==
                              record.status.toLowerCase(),
                          orElse: () => StudentStatus.present,
                        );
                  }
                }

                if (selectedDormId == null) {
                  return const EmptyState(
                    icon: Icons.how_to_reg_outlined,
                    title: 'Select a Dormitory',
                    message: 'Choose a dormitory above to begin roll call.',
                  );
                }

                if (state is MatronLoading && students.isEmpty) {
                  return const _AttendanceSkeleton();
                }

                if (students.isEmpty) {
                  return const EmptyState(
                    icon: Icons.people_outline,
                    title: 'No Boarders Found',
                    message: 'This dormitory has no allocated students.',
                  );
                }

                final filteredStudents = students
                    .where(
                      (s) =>
                          s.name.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ) ||
                          (s.id).toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                    )
                    .toList();

                final missingCount = students
                    .where(
                      (s) =>
                          (attendanceMap[s.id] ?? StudentStatus.present) ==
                          StudentStatus.absent,
                    )
                    .length;

                return Column(
                  children: [
                    if (missingCount > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.l,
                          vertical: AppSpacing.s,
                        ),
                        child: AlertBanner(
                          title: 'Absentees Detected',
                          message:
                              '$missingCount marked absent — will alert parents on save.',
                          color: semanticColors.error,
                          icon: Icons.warning_amber_rounded,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.l,
                        vertical: AppSpacing.s,
                      ),
                      child: AppSearchField(
                        hintText: 'Search boarders...',
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.l,
                        vertical: AppSpacing.s,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${filteredStudents.length} Students',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                for (var s in filteredStudents) {
                                  attendanceMap[s.id] = StudentStatus.present;
                                }
                              });
                            },
                            icon: const Icon(Icons.done_all, size: 18),
                            label: const Text('Mark all present'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.l,
                        ),
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          final status =
                              attendanceMap[student.id] ??
                              StudentStatus.present;
                          return FadeInSlide(
                            delay: Duration(milliseconds: index * 30),
                            child: AppCard(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  AvatarInitials(name: student.name, size: 40),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Bed: ${student.bedNumber ?? 'N/A'}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildStatusToggle(
                                    student.id,
                                    status,
                                    semanticColors,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(
    String studentId,
    StudentStatus currentStatus,
    SemanticColors colors,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusButton(
          icon: Icons.check,
          color: colors.success,
          isSelected: currentStatus == StudentStatus.present,
          onTap: () =>
              setState(() => attendanceMap[studentId] = StudentStatus.present),
        ),
        const SizedBox(width: 4),
        _StatusButton(
          icon: Icons.access_time,
          color: colors.warning,
          isSelected: currentStatus == StudentStatus.late,
          onTap: () =>
              setState(() => attendanceMap[studentId] = StudentStatus.late),
        ),
        const SizedBox(width: 4),
        _StatusButton(
          icon: Icons.close,
          color: colors.error,
          isSelected: currentStatus == StudentStatus.absent,
          onTap: () =>
              setState(() => attendanceMap[studentId] = StudentStatus.absent),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        children: [
          BlocBuilder<MatronBloc, MatronState>(
            buildWhen: (p, c) => c is DormitoriesLoaded,
            builder: (context, state) {
              List<Dormitory> dorms = [];
              if (state is DormitoriesLoaded) {
                dorms = state.dormitories;
              }
              return _buildDropdown(
                context,
                'Dormitory',
                selectedDormName ?? 'Select Dormitory',
                onTap: () => _showDormPicker(context, dorms),
              );
            },
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  context,
                  'Session',
                  selectedType,
                  onTap: () => _showSessionPicker(context),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 90),
                          ),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                          _loadAttendance();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated(context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border(context)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppColors.royalBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    String label,
    String value, {
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDormPicker(BuildContext context, List<Dormitory> dorms) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: dorms.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            dorms[index].name,
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () {
            setState(() {
              selectedDormId = dorms[index].id;
              selectedDormName = dorms[index].name;
              attendanceMap.clear();
            });
            _loadAttendance();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showSessionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: _kAttendanceTypes.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            _kAttendanceTypes[index],
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () {
            setState(() => selectedType = _kAttendanceTypes[index]);
            _loadAttendance();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        border: Border(top: BorderSide(color: AppColors.border(context))),
      ),
      child: SafeArea(
        top: false,
        child: PrimaryButton(
          label: 'Save Attendance',
          onPressed: selectedDormId == null
              ? null
              : () => _saveAttendance(context),
        ),
      ),
    );
  }

  void _saveAttendance(BuildContext context) {
    final state = context.read<MatronBloc>().state;
    if (state is BoardingStudentsLoaded) {
      final recordedBy = _currentUserName(context);
      final schoolId = _currentSchoolId(context);
      final records = state.students.map((s) {
        return BoardingAttendance(
          id: '',
          schoolId: schoolId,
          studentId: s.id,
          studentName: s.name,
          dormitoryId: selectedDormId!,
          date: selectedDate,
          type: selectedType,
          status: (attendanceMap[s.id] ?? StudentStatus.present).name,
          recordedBy: recordedBy,
        );
      }).toList();

      context.read<MatronBloc>().add(BulkRecordAttendanceEvent(records));
    }
  }
}

class _AttendanceSkeleton extends StatelessWidget {
  const _AttendanceSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.s,
          ),
          child: Skeleton(height: 50, borderRadius: 12),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.s,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Skeleton(width: 100, height: 20),
              const Skeleton(width: 120, height: 20),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            itemCount: 10,
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Skeleton(height: 60, borderRadius: 12),
            ),
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
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: isSelected ? Colors.white : color),
      ),
    );
  }
}
