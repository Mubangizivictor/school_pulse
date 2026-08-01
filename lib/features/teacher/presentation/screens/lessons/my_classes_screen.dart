import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyClassesScreen extends StatelessWidget {
  const MyClassesScreen({super.key});

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
        title: const Text('My Classes (Subject)',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _buildTab('Subject Classes', true),
                const SizedBox(width: 12),
                _buildTab('Other Subjects', false),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildClassItem(context, '10A', 'Grade 10A (Science)', 'Section A', 'Mathematics', '28 Students',
                    '10:00 AM', surfaceColor),
                const SizedBox(height: 16),
                _buildClassItem(context, '10B', 'Grade 10B (Science)', 'Section B', 'Mathematics', '25 Students',
                    '01:00 PM', surfaceColor,
                    nextTimeColor: Colors.blueAccent),
                const SizedBox(height: 16),
                _buildClassItem(context, '9A', 'Grade 9A (Science)', 'Section A', 'Mathematics', '27 Students',
                    'Tomorrow\n02:00 PM', surfaceColor,
                    nextTimeColor: Colors.indigoAccent),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4338CA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('View Timetable',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildClassItem(BuildContext context, String code, String name, String section, String subject,
      String students, String nextLesson, Color surfaceColor,
      {Color nextTimeColor = Colors.greenAccent}) {
    return InkWell(
      onTap: () => context.push('/staff/lessons/class/10A'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF312E81),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(code,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(section, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(subject, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.people_outline, color: Color(0xFF94A3B8), size: 14),
                      const SizedBox(width: 4),
                      Text(students, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Next Lesson', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                const SizedBox(height: 4),
                Text(nextLesson,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: nextTimeColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
