import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';

class SyllabusCoverageScreen extends StatefulWidget {
  const SyllabusCoverageScreen({super.key});

  @override
  State<SyllabusCoverageScreen> createState() => _SyllabusCoverageScreenState();
}

class _SyllabusCoverageScreenState extends State<SyllabusCoverageScreen> {
  String _selectedClass = 'Primary 4';
  
  final List<Map<String, dynamic>> _subjects = [
    {'name': 'Mathematics', 'coverage': 0.75, 'topics': 12, 'completed': 9, 'teacher': 'Robert Mugabe'},
    {'name': 'English', 'coverage': 0.60, 'topics': 10, 'completed': 6, 'teacher': 'Sarah Namusoke'},
    {'name': 'Science', 'coverage': 0.85, 'topics': 8, 'completed': 7, 'teacher': 'John Musisi'},
    {'name': 'Social Studies', 'coverage': 0.40, 'topics': 10, 'completed': 4, 'teacher': 'Peter Kaguta'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syllabus Coverage'),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                final subject = _subjects[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ProgressCard(
                    title: subject['name'],
                    progress: subject['coverage'],
                    subtitle: '${subject['completed']}/${subject['topics']} topics completed • ${subject['teacher']}',
                    color: _getColorForCoverage(subject['coverage']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 20),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: _selectedClass,
            underline: const SizedBox(),
            onChanged: (val) => setState(() => _selectedClass = val!),
            items: ['Primary 4', 'Primary 5', 'Primary 6', 'Primary 7']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Color _getColorForCoverage(double coverage) {
    if (coverage > 0.8) return Colors.green;
    if (coverage > 0.5) return Colors.orange;
    return Colors.red;
  }
}
