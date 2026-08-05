import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';

class PerformanceAnalyticsScreen extends StatelessWidget {
  const PerformanceAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<DeanBloc>()
            ..add(const PerformanceAnalyticsRequested(type: 'school')),
      child: Scaffold(
        appBar: AppBar(title: const Text('Academic Performance')),
        body: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is DeanLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PerformanceAnalyticsLoaded) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildGradeDistribution(
                    context,
                    state.analytics['gradeDistribution'] ?? {},
                  ),
                  const SizedBox(height: 24),
                  _buildSubjectPerformance(
                    context,
                    state.analytics['subjectPassRates'] ?? [],
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Top Performing Students'),
                  const SizedBox(height: 12),
                  _buildTopStudents(
                    context,
                    state.analytics['topStudents'] ?? [],
                  ),
                ],
              );
            } else if (state is DeanError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Initializing analytics...'));
          },
        ),
      ),
    );
  }

  Widget _buildGradeDistribution(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final grades = ['D1', 'D2', 'C3', 'C4', 'C5', 'C6', 'P7', 'P8', 'F9'];
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grade Distribution',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
                        if (value.toInt() >= grades.length)
                          return const SizedBox.shrink();
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            grades[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(grades.length, (index) {
                  final grade = grades[index];
                  final value = (data[grade] ?? 0).toDouble();
                  return _makeGroupData(index, value, _getColorForGrade(grade));
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForGrade(String grade) {
    if (grade.startsWith('D')) return Colors.blue;
    if (grade.startsWith('C')) return Colors.green;
    if (grade.startsWith('P')) return Colors.orange;
    return Colors.red;
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

  Widget _buildSubjectPerformance(
    BuildContext context,
    List<dynamic> subjects,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subject Pass Rates',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...subjects.map(
            (s) => _SubjectRow(
              subject: s['subject'] ?? '',
              rate: (s['rate'] ?? 0).toDouble(),
              color: (s['rate'] ?? 0) > 0.8 ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStudents(BuildContext context, List<dynamic> students) {
    return Column(
      children: students.asMap().entries.map((entry) {
        final idx = entry.key;
        final s = entry.value;
        return AppCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                '${idx + 1}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              s['name'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(s['class'] ?? ''),
            trailing: Text(
              '${(s['score'] * 100).toInt()}%',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  final String subject;
  final double rate;
  final Color color;

  const _SubjectRow({
    required this.subject,
    required this.rate,
    required this.color,
  });

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
              Text(
                '${(rate * 100).toInt()}%',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
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
