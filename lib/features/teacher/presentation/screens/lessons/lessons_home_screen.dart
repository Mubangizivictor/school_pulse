import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LessonsHomeScreen extends StatelessWidget {
  const LessonsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF0F172A);
    final surfaceColor = const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lessons',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: Colors.white),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Text(
                'Manage your lessons and teaching',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              ),
              const SizedBox(height: 24),
              _buildSummaryCard(context, surfaceColor),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Lessons",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View Timetable', style: TextStyle(color: Color(0xFF818CF8))),
                  ),
                ],
              ),
              _buildLessonItem(
                context,
                time: '10:00 AM - 10:45 AM',
                subject: 'Mathematics',
                grade: 'Grade 10A (Science) • Section A',
                room: 'Room 12',
                status: 'ONGOING',
                statusColor: Colors.indigoAccent,
                surfaceColor: surfaceColor,
              ),
              const SizedBox(height: 12),
              _buildLessonItem(
                context,
                time: '01:00 PM - 01:45 PM',
                subject: 'Mathematics',
                grade: 'Grade 10B (Science) • Section B',
                room: 'Room 15',
                status: 'UPCOMING',
                statusColor: Colors.blueAccent,
                surfaceColor: surfaceColor,
              ),
              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildQuickAction(context, 'Take Attendance', Icons.how_to_reg, Colors.greenAccent, surfaceColor),
                  const SizedBox(width: 12),
                  _buildQuickAction(context, 'Lesson Notes', Icons.description_outlined, Colors.orangeAccent, surfaceColor),
                  const SizedBox(width: 12),
                  _buildQuickAction(context, 'View Resources', Icons.folder_open, Colors.purpleAccent, surfaceColor),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, Color surfaceColor) {
    return Column(
      children: [
        InkWell(
          onTap: () => context.push('/staff/lessons/my-classes'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.book_outlined, color: Colors.indigoAccent),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Classes (Subject)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('3 Classes', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white54),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard('8', 'Lessons Today', surfaceColor),
            const SizedBox(width: 12),
            _buildStatCard('2', 'Upcoming Lessons', surfaceColor),
            const SizedBox(width: 12),
            _buildStatCard('0', 'Cancelled Lessons', surfaceColor),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color surfaceColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonItem(BuildContext context,
      {required String time,
      required String subject,
      required String grade,
      required String room,
      required String status,
      required Color statusColor,
      required Color surfaceColor}) {
    return InkWell(
      onTap: () => context.push('/staff/lessons/details/123'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(subject, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(grade, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Color(0xFF94A3B8), size: 14),
                const SizedBox(width: 4),
                Text(room, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.white54),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, Color color, Color surfaceColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
