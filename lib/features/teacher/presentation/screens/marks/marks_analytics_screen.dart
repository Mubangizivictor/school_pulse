import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MarksAnalyticsScreen extends StatelessWidget {
  const MarksAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF0F172A);
    final surfaceColor = const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Performance Analytics', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCard(surfaceColor),
            const SizedBox(height: 24),
            const Text(
              'Grade Distribution',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildGradeDistribution(surfaceColor),
            const SizedBox(height: 24),
            const Text(
              'Top Performing Students',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTopStudents(surfaceColor),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Avg Score', '78%', Colors.blue),
              _buildStat('Pass Rate', '92%', Colors.green),
              _buildStat('Highest', '98%', Colors.orange),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Performance improved by 4.2% since last term',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
      ],
    );
  }

  Widget _buildGradeDistribution(Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      height: 200,
      child: const Center(
        child: Text('[Chart: Distribution of Grades A-F]', style: TextStyle(color: Color(0xFF94A3B8))),
      ),
    );
  }

  Widget _buildTopStudents(Color surfaceColor) {
    return Column(
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.2),
                child: Text('${index + 1}', style: const TextStyle(color: Colors.blue)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Student Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('Grade 10A', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  ],
                ),
              ),
              Text('${98 - index * 2}%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }),
    );
  }
}
