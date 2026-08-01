import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class AttendanceListScreen extends StatelessWidget {
  const AttendanceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.pop(),
          ),
          title: const Text('Attendance List (Summary)'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All (25)'),
              Tab(text: 'Present (23)'),
              Tab(text: 'Absent (2)'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search students...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surfaceElevated(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildList(context, _mockStudents),
                  _buildList(context, _mockStudents.where((s) => s['isPresent']).toList()),
                  _buildList(context, _mockStudents.where((s) => !s['isPresent']).toList()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
                child: const Text('Export Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Map<String, dynamic>> students) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final bool isPresent = student['isPresent'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
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
              if (isPresent) ...[
                Text(
                  student['time'],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Icon(Icons.check_circle, color: AppColors.success(context), size: 20),
              ] else ...[
                Icon(Icons.cancel, color: AppColors.errorRed, size: 20),
              ],
            ],
          ),
        );
      },
    );
  }

  static const List<Map<String, dynamic>> _mockStudents = [
    {'name': 'Akera Brian', 'id': 'SH-2026-0481', 'time': '08:42 PM', 'isPresent': true},
    {'name': 'Kato Mercy', 'id': 'SH-2026-0482', 'time': '08:44 PM', 'isPresent': true},
    {'name': 'Nansubuga Grace', 'id': 'SH-2026-0483', 'time': '08:45 PM', 'isPresent': true},
    {'name': 'Tumusiime David', 'id': 'SH-2026-0484', 'time': '08:45 PM', 'isPresent': true},
    {'name': 'Mugisha Samuel', 'id': 'SH-2026-0485', 'time': '08:47 PM', 'isPresent': true},
    {'name': 'Ochieng Denis', 'id': 'SH-2026-0422', 'time': '', 'isPresent': false},
  ];
}
