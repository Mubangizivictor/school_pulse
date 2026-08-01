import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    
    final filteredHistory = _mockHistory.where((item) => 
      item['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
      item['date'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Attendance History'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildFilter(context, 'Date Range', 'Last 7 Days')),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(child: _buildFilter(context, 'Category', 'Boarding')),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                AppSearchField(
                  hintText: 'Search history...',
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredHistory.isEmpty 
              ? const EmptyState(
                  icon: Icons.history, 
                  title: 'No history found', 
                  message: 'Try adjusting your search or filters.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                  itemCount: filteredHistory.length,
                  itemBuilder: (context, index) {
                    final item = filteredHistory[index];
                    return FadeInSlide(
                      delay: Duration(milliseconds: index * 50),
                      child: _HistoryCard(item: item, colors: semanticColors),
                    );
                  },
                ),
          ),
        ],
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
  final SemanticColors colors;

  const _HistoryCard({required this.item, required this.colors});

  @override
  Widget build(BuildContext context) {
    final double percentage = item['present'] / item['total'];
    final bool isPerfect = percentage == 1.0;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => context.push('/staff/attendance/summary'),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isPerfect ? colors.success : colors.warning).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isPerfect ? Icons.verified_user : Icons.pending_actions,
                  color: isPerfect ? colors.success : colors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      '${item['date']} • ${item['time']}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Attendance Rate',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${(percentage * 100).round()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isPerfect ? colors.success : colors.warning,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: AppColors.surfaceElevated(context),
                        valueColor: AlwaysStoppedAnimation<Color>(isPerfect ? colors.success : colors.warning),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  Text(
                    '${item['present']}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  Text(
                    'of ${item['total']}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
