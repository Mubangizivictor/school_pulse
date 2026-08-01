import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';

class SubjectProgressScreen extends StatelessWidget {
  const SubjectProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> subjects = [
      {'name': 'English Language', 'entered': 8, 'total': 32, 'icon': Icons.book, 'color': Colors.blue},
      {'name': 'Mathematics', 'entered': 8, 'total': 32, 'icon': Icons.calculate, 'color': Colors.purple},
      {'name': 'Integrated Science', 'entered': 8, 'total': 32, 'icon': Icons.science, 'color': Colors.green},
      {'name': 'Social Studies', 'entered': 0, 'total': 32, 'icon': Icons.public, 'color': Colors.orange},
      {'name': 'Religious & Moral Educ.', 'entered': 0, 'total': 32, 'icon': Icons.mosque, 'color': Colors.red},
      {'name': 'ICT', 'entered': 0, 'total': 32, 'icon': Icons.computer, 'color': Colors.cyan},
      {'name': 'Creative Arts', 'entered': 0, 'total': 32, 'icon': Icons.palette, 'color': Colors.pink},
      {'name': 'Physical Education', 'entered': 0, 'total': 32, 'icon': Icons.sports_soccer, 'color': Colors.brown},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppSearchField(hintText: 'Search subjects...'),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final isPending = subject['entered'] == 0;
                return AppCard(
                  onTap: () => context.push('/teacher/reports/enter-scores'),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: subject['color'].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(subject['icon'], color: subject['color'], size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(subject['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('${subject['entered']}/${subject['total']} Entered',
                                style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
                          ],
                        ),
                      ),
                      StatusBadge(
                        label: isPending ? 'Pending' : 'Entered',
                        color: isPending ? Colors.orange : Colors.green,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              label: 'Next: Competency',
              onPressed: () => context.push('/teacher/reports/competency-entry'),
            ),
          ),
        ],
      ),
    );
  }
}
