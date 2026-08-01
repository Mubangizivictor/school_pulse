import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LessonDetailsScreen extends StatelessWidget {
  final String lessonId;
  const LessonDetailsScreen({super.key, required this.lessonId});

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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF312E81),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.book, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Linear Equations',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Grade 10A (Science) • Section A',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Completed',
                            style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(Icons.calendar_today_outlined, 'Date', 'Mon, 20 May 2025'),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.access_time, 'Time', '10:00 AM - 10:45 AM'),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.location_on_outlined, 'Room', 'Room 12'),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.people_outline, 'Students', '28 Enrolled'),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.assignment_outlined, 'Related Assessment', 'Mid Term Test - Test 1'),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.note_alt_outlined, 'Notes', '1 Note'),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.folder_open, 'Resources', '2 Files'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Actions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildActionButton(context, 'Take\nAttendance', Icons.how_to_reg, Colors.greenAccent, surfaceColor,
                    () => context.push('/staff/lessons/attendance/123')),
                const SizedBox(width: 12),
                _buildActionButton(context, 'Lesson\nNotes', Icons.description_outlined, Colors.orangeAccent,
                    surfaceColor, () => context.push('/staff/lessons/notes/123')),
                const SizedBox(width: 12),
                _buildActionButton(context, 'Edit\nLesson', Icons.edit_outlined, Colors.blueAccent, surfaceColor, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 18),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, IconData icon, Color color, Color surfaceColor, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 12),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
