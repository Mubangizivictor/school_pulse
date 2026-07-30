import 'package:flutter/material.dart';

class StudentTimetableScreen extends StatelessWidget {
  const StudentTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Timetable'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_view_week, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Timetable feature is currently being updated by the school.'),
            SizedBox(height: 8),
            Text(
              'Please check back later.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
