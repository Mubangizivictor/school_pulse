import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class AttendanceListScreen extends StatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.pop(),
          ),
          title: const Text('Attendance Report'),
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildFilter(context, 'Dormitory', 'Sunset House')),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(child: _buildFilter(context, 'Session', 'Evening')),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  AppSearchField(
                    hintText: 'Search students...',
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildList(context, _mockStudents, semanticColors),
                  _buildList(context, _mockStudents.where((s) => s['isPresent']).toList(), semanticColors),
                  _buildList(context, _mockStudents.where((s) => !s['isPresent']).toList(), semanticColors),
                ],
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
                  label: 'Export Detailed Report',
                  icon: Icons.ios_share,
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, List<Map<String, dynamic>> students, SemanticColors colors) {
    final filtered = students.where((s) => 
      s['name'].toLowerCase().contains(_searchQuery.toLowerCase()) || 
      s['id'].toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No results found',
        message: 'Try adjusting your search or filters.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final student = filtered[index];
        final bool isPresent = student['isPresent'];
        
        return FadeInSlide(
          delay: Duration(milliseconds: index * 30),
          child: AppCard(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                AvatarInitials(name: student['name'], size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name'], 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                      ),
                      Text(
                        student['id'], 
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge(
                      label: isPresent ? 'Present' : 'Absent',
                      color: isPresent ? colors.success : colors.error,
                      icon: isPresent ? Icons.check_circle : Icons.cancel,
                    ),
                    if (isPresent && student['time'].isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        student['time'],
                        style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
              ],
            ),
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
    {'name': 'Auma Esther', 'id': 'SH-2026-0423', 'time': '', 'isPresent': false},
  ];
}
