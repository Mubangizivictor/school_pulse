import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:school_pulse/design_system/app_components.dart';

class PerformanceAnalyticsScreen extends StatelessWidget {
  const PerformanceAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academic Performance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGradeDistribution(context),
          const SizedBox(height: 24),
          _buildSubjectPerformance(context),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Top Performing Students'),
          const SizedBox(height: 12),
          _buildTopStudents(context),
        ],
      ),
    );
  }

  Widget _buildGradeDistribution(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Grade Distribution (Term 3)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = ['D1', 'D2', 'C3', 'C4', 'C5', 'C6', 'P7', 'P8', 'F9'];
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(titles[value.toInt()], style: const TextStyle(fontSize: 10)),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroupData(0, 15, Colors.blue),
                  _makeGroupData(1, 25, Colors.blue),
                  _makeGroupData(2, 45, Colors.blue),
                  _makeGroupData(3, 60, Colors.blue),
                  _makeGroupData(4, 30, Colors.blue),
                  _makeGroupData(5, 20, Colors.blue),
                  _makeGroupData(6, 10, Colors.orange),
                  _makeGroupData(7, 5, Colors.orange),
                  _makeGroupData(8, 2, Colors.red),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildSubjectPerformance(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Subject Pass Rates', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _SubjectRow(subject: 'Mathematics', rate: 0.88, color: Colors.green),
          _SubjectRow(subject: 'English', rate: 0.92, color: Colors.green),
          _SubjectRow(subject: 'Science', rate: 0.74, color: Colors.orange),
          _SubjectRow(subject: 'Social Studies', rate: 0.95, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildTopStudents(BuildContext context) {
    final students = [
      {'name': 'Namono Grace', 'class': 'P.7 Blue', 'score': '92%', 'rank': '1'},
      {'name': 'Okello David', 'class': 'P.7 Red', 'score': '90%', 'rank': '2'},
      {'name': 'Mugabe Robert', 'class': 'P.6 White', 'score': '89%', 'rank': '3'},
    ];

    return Column(
      children: students.map((s) => AppCard(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(s['rank']!, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          title: Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(s['class']!),
          trailing: Text(s['score']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      )).toList(),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  final String subject;
  final double rate;
  final Color color;

  const _SubjectRow({required this.subject, required this.rate, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject, style: const TextStyle(fontSize: 13)),
              Text('${(rate * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: rate,
            backgroundColor: color.withValues(alpha: 0.1),
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}
