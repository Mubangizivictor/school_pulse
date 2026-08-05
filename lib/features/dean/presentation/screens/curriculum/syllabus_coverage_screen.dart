import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../../../domain/entities/curriculum.dart';

class SyllabusCoverageScreen extends StatelessWidget {
  final Subject subject;

  const SyllabusCoverageScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 24),
            const Text(
              'Topics & Subtopics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...subject.topics.map((topic) => _TopicExpansionTile(topic: topic)),
            const SizedBox(height: 24),
            const Text(
              'Learning Objectives',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...subject.objectives.map((obj) => _ObjectiveTile(objective: obj)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return AppCard(
      child: Column(
        children: [
          const Text(
            'Overall Syllabus Coverage',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  value: subject.currentCoverage / 100,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey[200],
                ),
              ),
              Text(
                '${subject.currentCoverage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                label: 'Topics',
                value: subject.topics.length.toString(),
              ),
              _SummaryItem(
                label: 'Subtopics',
                value: subject.topics
                    .fold(0, (sum, t) => sum + t.subTopics.length)
                    .toString(),
              ),
              _SummaryItem(
                label: 'Core Objectives',
                value: subject.objectives
                    .where((o) => o.isCore)
                    .length
                    .toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _TopicExpansionTile extends StatelessWidget {
  final Topic topic;

  const _TopicExpansionTile({required this.topic});

  @override
  Widget build(BuildContext context) {
    final completedCount = topic.subTopics.where((st) => st.isCompleted).length;
    final totalCount = topic.subTopics.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        title: Text(
          topic.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$completedCount/$totalCount subtopics completed'),
        leading: CircularProgressIndicator(
          value: progress,
          strokeWidth: 3,
          backgroundColor: Colors.grey[200],
        ),
        children: topic.subTopics
            .map(
              (st) => ListTile(
                dense: true,
                title: Text(st.title),
                trailing: Icon(
                  st.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: st.isCompleted ? Colors.green : Colors.grey,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ObjectiveTile extends StatelessWidget {
  final LearningObjective objective;

  const _ObjectiveTile({required this.objective});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.track_changes,
          color: objective.isCore ? Colors.blue : Colors.grey,
        ),
        title: Text(objective.description),
        trailing: objective.isCore
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CORE',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
