import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EnterMarksScreen extends StatelessWidget {
  const EnterMarksScreen({super.key});

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
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            const Text('Enter Marks', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Mid Term Test • Section A', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('8 / 28 Entered', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey, size: 14),
                      SizedBox(width: 4),
                      Text('Search students...', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Text('#', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                const SizedBox(width: 12),
                const Expanded(child: Text('Student Name', style: TextStyle(color: Color(0xFF64748B), fontSize: 12))),
                const Text('/ 20', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                const SizedBox(width: 24),
                const Text('Mark', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 8,
              itemBuilder: (context, index) {
                final studentNames = ['Akena Brian', 'Nanyonga Faith', 'Odhiambo James', 'Tusiime Kevin', 'Nabirye Amanda', 'Kamya Sharon', 'Mugisha Ethan', 'Ssekidde Daniel'];
                final marks = ['16', '14', '9', '18', '', '', '', ''];
                return _buildStudentMarkRow(index + 1, studentNames[index], marks[index], surfaceColor);
              },
            ),
          ),
          _buildBottomActions(context, surfaceColor),
        ],
      ),
    );
  }

  Widget _buildStudentMarkRow(int rank, String name, String mark, Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Text(rank.toString(), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(width: 12),
          const CircleAvatar(radius: 14, backgroundColor: Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 14))),
          Container(
            width: 60,
            height: 36,
            decoration: BoxDecoration(
              color: mark.isEmpty ? Colors.transparent : Colors.white10,
              border: Border.all(color: mark.isEmpty ? Colors.white24 : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(mark, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Draft', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => context.push('/staff/marks/review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4338CA),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Review & Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
