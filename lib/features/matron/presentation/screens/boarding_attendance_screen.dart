import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/matron/domain/entities/matron_entities.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_bloc.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_event.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_state.dart';

const _kAttendanceTypes = ['Morning', 'Evening', 'Weekend', 'Holiday', 'Study', 'Activity'];
const _kAttendanceStatuses = ['Present', 'Absent', 'Late', 'Sick'];

class BoardingAttendanceScreen extends StatefulWidget {
  const BoardingAttendanceScreen({super.key});

  @override
  State<BoardingAttendanceScreen> createState() => _BoardingAttendanceScreenState();
}

class _BoardingAttendanceScreenState extends State<BoardingAttendanceScreen> {
  String? selectedDormId;
  String? selectedDormName;
  String selectedType = 'Evening';
  DateTime selectedDate = DateTime.now();
  Map<String, String> attendanceMap = {};

  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(WatchDormitories());
    _loadAttendance();
  }

  void _loadAttendance() {
    context.read<MatronBloc>().add(WatchAttendance(
          date: selectedDate,
          dormitoryId: selectedDormId,
          type: selectedType,
        ));
    if (selectedDormId != null) {
      context.read<MatronBloc>().add(WatchBoardingStudents(dormitoryId: selectedDormId));
    }
  }

  String _currentUserName(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.name : 'Matron';
  }

  @override
  Widget build(BuildContext context) {
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.success(context),
                  ));
                }
              },
              buildWhen: (previous, current) =>
                  current is BoardingStudentsLoaded || current is AttendanceLoaded || current is MatronLoading,
              builder: (context, state) {
                List<BoardingStudent> students = [];
                if (state is BoardingStudentsLoaded) {
                  students = state.students;
                }
                if (state is AttendanceLoaded) {
                  for (var record in state.attendance) {
                    attendanceMap[record.studentId] = record.status;
                  }
                }

                if (selectedDormId == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.how_to_reg_outlined, size: 64, color: AppColors.textMuted(context)),
                        const SizedBox(height: AppSpacing.m),
                        const Text(
                          'Select a Dormitory',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Choose a dormitory above to begin roll call.',
                          style: TextStyle(color: AppColors.textMuted(context)),
                        ),
                      ],
                    ),
                  );
                }

                if (state is MatronLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: AppColors.textMuted(context)),
                        const SizedBox(height: AppSpacing.m),
                        const Text(
                          'No Boarders Found',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'This dormitory has no allocated students.',
                          style: TextStyle(color: AppColors.textMuted(context)),
                        ),
                      ],
                    ),
                  );
                }

                final missingCount = students.where((s) => (attendanceMap[s.id] ?? 'Present') == 'Absent').length;

                return Column(
                  children: [
                    if (missingCount > 0)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
                        padding: const EdgeInsets.all(AppSpacing.m),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.errorRed, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$missingCount marked absent — will alert parents on save.',
                                style: const TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final status = attendanceMap[student.id] ?? 'Present';
                          return AppCard(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: student.photoUrl != null ? NetworkImage(student.photoUrl!) : null,
                                  child: student.photoUrl == null ? const Icon(Icons.person) : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(student.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text('Bed: ${student.bedNumber ?? 'N/A'}', style: TextStyle(color: AppColors.textMuted(context), fontSize: 12)),
                                    ],
                                  ),
                                ),
                                DropdownButton<String>(
                                  value: status,
                                  underline: const SizedBox(),
                                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                                  items: _kAttendanceStatuses
                                      .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val == null) return;
                                    setState(() => attendanceMap[student.id] = val);
                                  },
                                ),
                              ],
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
                    const Text('Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 90)),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                          _loadAttendance();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated(context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border(context)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: AppColors.royalBlue),
                            const SizedBox(width: 8),
                            Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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

  Widget _buildDropdown(BuildContext context, String label, String value, {required VoidCallback onTap}) {
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
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: dorms.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(dorms[index].name, style: const TextStyle(color: Colors.white)),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: _kAttendanceTypes.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(_kAttendanceTypes[index], style: const TextStyle(color: Colors.white)),
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
      child: PrimaryButton(
        label: 'Save Attendance',
        onPressed: selectedDormId == null ? null : () => _saveAttendance(context),
      ),
    );
  }

  void _saveAttendance(BuildContext context) {
    final state = context.read<MatronBloc>().state;
    if (state is BoardingStudentsLoaded) {
      final recordedBy = _currentUserName(context);
      final records = state.students.map((s) {
        return BoardingAttendance(
          id: '',
          studentId: s.id,
          studentName: s.name,
          dormitoryId: selectedDormId!,
          date: selectedDate,
          type: selectedType,
          status: attendanceMap[s.id] ?? 'Present',
          recordedBy: recordedBy,
        );
      }).toList();

      context.read<MatronBloc>().add(BulkRecordAttendanceEvent(records));
    }
  }
}

