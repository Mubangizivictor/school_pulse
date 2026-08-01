import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class ManualAttendanceScreen extends StatefulWidget {
  const ManualAttendanceScreen({super.key});

  @override
  State<ManualAttendanceScreen> createState() => _ManualAttendanceScreenState();
}

class _ManualAttendanceScreenState extends State<ManualAttendanceScreen> {
  final List<Map<String, dynamic>> _students = [
    {'name': 'Akera Brian', 'id': 'SH-2026-0481', 'selected': true},
    {'name': 'Kato Mercy', 'id': 'SH-2026-0482', 'selected': true},
    {'name': 'Nansubuga Grace', 'id': 'SH-2026-0483', 'selected': false},
    {'name': 'Tumusiime David', 'id': 'SH-2026-0484', 'selected': false},
    {'name': 'Mugisha Samuel', 'id': 'SH-2026-0485', 'selected': false},
  ];

  bool _selectAll = false;

  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      for (var student in _students) {
        student['selected'] = _selectAll;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int selectedCount = _students.where((s) => s['selected'] == true).length;

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
                        child: const Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16),
                            SizedBox(width: 8),
                            Text('1/6/2026', style: TextStyle(fontSize: 14)),
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
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.filter_list),
                filled: true,
                fillColor: AppColors.surfaceElevated(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            child: Row(
              children: [
                Checkbox(
                  value: _selectAll,
                  onChanged: _toggleSelectAll,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                const Text('Select All', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${_students.length} students', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(student['id'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: student['selected'],
                        onChanged: (value) {
                          setState(() {
                            student['selected'] = value ?? false;
                            _selectAll = _students.every((s) => s['selected'] == true);
                          });
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ],
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
            child: Row(
              children: [
                Text(
                  '$selectedCount Selected',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                SizedBox(
                  width: 160,
                  child: PrimaryButton(
                    label: 'Save Attendance',
                    onPressed: () => context.push('/staff/attendance/summary'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: null,
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
              const Icon(Icons.keyboard_arrow_down, size: 20),
            ],
          ),
        ),
      ],
    );
  }
}
