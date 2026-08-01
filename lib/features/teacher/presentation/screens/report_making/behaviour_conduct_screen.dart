import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';

class BehaviourConductScreen extends StatelessWidget {
  const BehaviourConductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> criteria = [
      {'label': 'Respect for Others', 'rating': 5},
      {'label': 'Responsibility', 'rating': 4},
      {'label': 'Self-Discipline', 'rating': 4},
      {'label': 'Cooperation', 'rating': 5},
      {'label': 'Honesty & Integrity', 'rating': 4},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Behaviour & Conduct'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SectionHeader(title: 'Rate each area (1 - 5 Stars)'),
                const SizedBox(height: 12),
                ...criteria.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['label'], style: const TextStyle(fontWeight: FontWeight.w500)),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < item['rating'] ? Icons.star : Icons.star_border,
                                color: Colors.green,
                                size: 24,
                              );
                            }),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Overall Conduct'),
                const SizedBox(height: 12),
                AppCard(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderColor: Colors.green.withValues(alpha: 0.3),
                  child: const Center(
                    child: Text(
                      'Very Good',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Teacher\'s Remarks (Optional)'),
                const SizedBox(height: 12),
                TextFormField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Add a remark about behaviour...',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              label: 'Save & Next',
              onPressed: () => context.push('/teacher/reports/teacher-comment'),
            ),
          ),
        ],
      ),
    );
  }
}
