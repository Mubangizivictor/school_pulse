import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Attendance History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search records...',
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              itemCount: _mockHistory.length,
              itemBuilder: (context, index) {
                final item = _mockHistory[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _HistoryCard(item: item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static const List<Map<String, dynamic>> _mockHistory = [
    {
      'title': 'Sunset House — Evening',
      'date': '1/6/2026',
      'time': '08:46 PM',
      'present': 23,
      'total': 25,
      'status': 'Completed'
    },
    {
      'title': 'Sunrise House — Morning',
      'date': '1/6/2026',
      'time': '07:15 AM',
      'present': 48,
      'total': 50,
      'status': 'Completed'
    },
    {
      'title': 'Dining Hall — Lunch',
      'date': '1/6/2026',
      'time': '12:30 PM',
      'present': 450,
      'total': 480,
      'status': 'Completed'
    },
    {
      'title': 'Sunset House — Evening',
      'date': '31/5/2026',
      'time': '08:45 PM',
      'present': 25,
      'total': 25,
      'status': 'Completed'
    },
  ];
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final double percentage = item['present'] / item['total'];

    return AppCard(
      onTap: () => context.push('/staff/attendance/summary'),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['title'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              StatusBadge(
                label: item['status'],
                color: AppColors.success(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${item['date']} — ${item['time']}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary(context)),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${item['present']}/${item['total']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
