import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentMarksDetailScreen extends StatelessWidget {
  const StudentMarksDetailScreen({super.key});

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
        title: const Text('Student Marks Detail', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage('https://placeholder.com/150'),
            ),
            const SizedBox(height: 12),
            const Text('Akena Brian', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('ADM/2022/001', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            const Text('Grade 10A', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            const SizedBox(height: 32),
            _buildAssessmentSummary(surfaceColor),
            const SizedBox(height: 24),
            _buildComponentBreakdown(surfaceColor),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentSummary(Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          const Text('Mid Term Test', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: 16 / 40,
                      strokeWidth: 8,
                      backgroundColor: Colors.white10,
                      color: Colors.greenAccent,
                    ),
                  ),
                  Column(
                    children: [
                      const Text('16', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const Text('/ 40', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatItem('Percentage', '40%', Colors.greenAccent),
                  const SizedBox(height: 12),
                  _buildStatItem('Grade', 'C', Colors.orangeAccent),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildComponentBreakdown(Color surfaceColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Component Breakdown', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildComponentItem('Section A', '16 / 20', Colors.greenAccent, surfaceColor),
        _buildComponentItem('Section B', '-- / 10', Colors.white30, surfaceColor),
        _buildComponentItem('Section C', '-- / 10', Colors.white30, surfaceColor),
      ],
    );
  }

  Widget _buildComponentItem(String name, String score, Color scoreColor, Color surfaceColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
          Text(score, style: TextStyle(color: scoreColor, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
