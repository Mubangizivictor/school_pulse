import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/enums/student_status.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class ManualAttendanceScreen extends StatefulWidget {
  const ManualAttendanceScreen({super.key});

  @override
  State<ManualAttendanceScreen> createState() => _ManualAttendanceScreenState();
}

class _ManualAttendanceScreenState extends State<ManualAttendanceScreen> {
  final List<Map<String, dynamic>> _students = [
    {'name': 'Akera Brian', 'id': 'SH-2026-0481', 'status': StudentStatus.present},
    {'name': 'Kato Mercy', 'id': 'SH-2026-0482', 'status': StudentStatus.present},
    {'name': 'Nansubuga Grace', 'id': 'SH-2026-0483', 'status': StudentStatus.absent},
    {'name': 'Tumusiime David', 'id': 'SH-2026-0484', 'status': StudentStatus.absent},
    {'name': 'Mugisha Samuel', 'id': 'SH-2026-0485', 'status': StudentStatus.absent},
  ];

  String _searchQuery = '';

  void _markAllPresent() {
    setState(() {
      for (var student in _students) {
        student['status'] = StudentStatus.present;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    final filteredStudents = _students.where((s) => 
      s['name'].toLowerCase().contains(_searchQuery.toLowerCase()) || 
      s['id'].toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Manual Attendance'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              children: [
                _buildDropdown(context, 'Dormitory', 'Sunset House'),
                const SizedBox(height: AppSpacing.m),
                Row(
                  children: [
                    Expanded(child: _buildDropdown(context, 'Session', 'Evening')),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated(context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border(context)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            const Text('1/6/2026', style: TextStyle(fontSize: 14)),
                          ],
                        ),
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
              hintText: 'Search students...',
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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _markAllPresent,
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('Mark all present'),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredStudents.isEmpty 
              ? const EmptyState(
                  icon: Icons.search_off, 
                  title: 'No results', 
                  message: 'No students found matching your search query.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    return FadeInSlide(
                      delay: Duration(milliseconds: index * 30),
                      child: AppCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            AvatarInitials(name: student['name'], size: 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(student['id'], style: Theme.of(context).textTheme.labelSmall),
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
              border: Border(top: BorderSide(color: AppColors.border(context))),
            ),
            child: SafeArea(
              top: false,
              child: PrimaryButton(
                label: 'Save Attendance',
                onPressed: () => context.push('/staff/attendance/summary'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(Map<String, dynamic> student, SemanticColors colors) {
    final currentStatus = student['status'] as StudentStatus;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusButton(
          icon: Icons.check,
          color: colors.success,
          isSelected: currentStatus == StudentStatus.present,
          onTap: () => setState(() => student['status'] = StudentStatus.present),
        ),
        const SizedBox(width: 4),
        _StatusButton(
          icon: Icons.access_time,
          color: colors.warning,
          isSelected: currentStatus == StudentStatus.late,
          onTap: () => setState(() => student['status'] = StudentStatus.late),
        ),
        const SizedBox(width: 4),
        _StatusButton(
          icon: Icons.close,
          color: colors.error,
          isSelected: currentStatus == StudentStatus.absent,
          onTap: () => setState(() => student['status'] = StudentStatus.absent),
        ),
      ],
    );
  }

  Widget _buildDropdown(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
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
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : color,
        ),
      ),
    );
  }
}
