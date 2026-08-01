import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClassLessonsScreen extends StatelessWidget {
  final String classId;
  const ClassLessonsScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF0F172A);
    final surfaceColor = const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          children: [
            Text('Grade 10A (Science)',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Mathematics • Section A', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildTab('Lessons', true),
                const SizedBox(width: 12),
                _buildTab('Notes', false),
                const SizedBox(width: 12),
                _buildTab('Resources', false),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Text('This Week',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTimelineItem(
                  'Mon, 20 May 2025',
                  '10:00 AM - 10:45 AM',
                  'Linear Equations',
                  'Completed',
                  Colors.greenAccent,
                  surfaceColor,
                ),
                _buildTimelineItem(
                  'Tue, 21 May 2025',
                  '10:00 AM - 10:45 AM',
                  'Quadratic Equations',
                  'Scheduled',
                  Colors.blueAccent,
                  surfaceColor,
                ),
                _buildTimelineItem(
                  'Wed, 22 May 2025',
                  '10:00 AM - 10:45 AM',
                  'Inequalities',
                  'Scheduled',
                  Colors.blueAccent,
                  surfaceColor,
                ),
                const SizedBox(height: 24),
                const Text('Next Week',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTimelineItem(
                  'Mon, 27 May 2025',
                  '10:00 AM - 10:45 AM',
                  'Functions',
                  'Scheduled',
                  Colors.blueAccent,
                  surfaceColor,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF4338CA),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4338CA) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? null : Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: TextStyle(color: isActive ? Colors.white : Colors.white60, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTimelineItem(
      String date, String time, String title, String status, Color statusColor, Color surfaceColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => {},
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(time, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(title,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
