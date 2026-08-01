import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';

class CompetencyEntryScreen extends StatelessWidget {
  const CompetencyEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> students = [
      {'name': 'Abiola Peter', 'level': 3},
      {'name': 'Adong Grace', 'level': 3},
      {'name': 'Aguil Brian', 'level': 4},
      {'name': 'Ampiire Doris', 'level': 2},
      {'name': 'Atim Charles', 'level': 3},
      {'name': 'Namatuga Grace', 'level': 3},
      {'name': 'Tumusiime David', 'level': 2},
      {'name': 'Mugisha Samuel', 'level': 3},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Competency Development'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Communication Skills', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Level Key:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    _LevelBadge(level: 4, label: 'Exceeding'),
                    const SizedBox(width: 4),
                    _LevelBadge(level: 3, label: 'Achieved'),
                    const SizedBox(width: 4),
                    _LevelBadge(level: 2, label: 'Developing'),
                    const SizedBox(width: 4),
                    _LevelBadge(level: 1, label: 'Emerging'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final student = students[index];
                return AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      Row(
                        children: List.generate(4, (i) {
                          final level = i + 1;
                          final isSelected = student['level'] == level;
                          return GestureDetector(
                            onTap: () {},
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isSelected ? _getLevelColor(level) : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: _getLevelColor(level)),
                              ),
                              child: Center(
                                child: Text(
                                  '$level',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : _getLevelColor(level),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
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
              label: 'Save & Next',
              onPressed: () => context.push('/teacher/reports/attendance-summary'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 4: return Colors.blue;
      case 3: return Colors.green;
      case 2: return Colors.orange;
      case 1: return Colors.red;
      default: return Colors.grey;
    }
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  final String label;

  const _LevelBadge({required this.level, required this.label});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (level) {
      case 4: color = Colors.blue; break;
      case 3: color = Colors.green; break;
      case 2: color = Colors.orange; break;
      case 1: color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
