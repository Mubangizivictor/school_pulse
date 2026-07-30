import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../../../domain/entities/curriculum.dart';
import 'syllabus_coverage_screen.dart';

class SubjectListScreen extends StatelessWidget {
  final Curriculum curriculum;

  const SubjectListScreen({super.key, required this.curriculum});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${curriculum.name} - Subjects'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: curriculum.subjects.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final subject = curriculum.subjects[index];
          return AppCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SyllabusCoverageScreen(subject: subject),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            subject.code,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    _CoverageIndicator(coverage: subject.currentCoverage),
                  ],
                ),
                if (subject.department != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Dept: ${subject.department}',
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: subject.currentCoverage / 100,
                  backgroundColor: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${subject.topics.length} Topics',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      '${subject.currentCoverage.toStringAsFixed(1)}% Covered',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CoverageIndicator extends StatelessWidget {
  final double coverage;

  const _CoverageIndicator({required this.coverage});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (coverage >= 80) {
      color = Colors.green;
    } else if (coverage >= 50) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        coverage >= 80 ? 'On Track' : coverage >= 50 ? 'Progressing' : 'Behind',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
