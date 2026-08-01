import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LessonNotesScreen extends StatelessWidget {
  final String lessonId;
  const LessonNotesScreen({super.key, required this.lessonId});

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
        title: const Text('Lesson Notes',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => context.push('/staff/lessons/add-note/123'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildLessonHeader(surfaceColor),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildNoteItem(
                  'Introduction to Linear Equations',
                  'Key concepts and definitions',
                  'By you • 20 May 2025',
                  surfaceColor,
                ),
                _buildNoteItem(
                  'Solving Linear Equations',
                  'Examples and class practice',
                  'By you • 20 May 2025',
                  surfaceColor,
                ),
                _buildNoteItem(
                  'Homework',
                  'Exercise 1 - 10 page 45',
                  'By you • 20 May 2025',
                  surfaceColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonHeader(Color surfaceColor) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
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
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Grade 10A (Science) • Section A', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                Text('Mon, 20 May 2025 • 10:00 AM - 10:45 AM', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(String title, String subtitle, String author, Color surfaceColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description_outlined, color: Colors.blueAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                const SizedBox(height: 8),
                Text(author, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8), size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
