import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';

class EnterScoresScreen extends StatelessWidget {
  const EnterScoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> scores = [
      {'name': 'Abiola Peter', 'ca': '32', 'ea': '48', 'total': 80},
      {'name': 'Adong Grace', 'ca': '28', 'ea': '42', 'total': 70},
      {'name': 'Aguil Brian', 'ca': '30', 'ea': '45', 'total': 75},
      {'name': 'Ampiire Doris', 'ca': '26', 'ea': '39', 'total': 65},
      {'name': 'Atim Charles', 'ca': '36', 'ea': '54', 'total': 90},
      {'name': 'Namatuga Grace', 'ca': '34', 'ea': '51', 'total': 85},
      {'name': 'Tumusiime David', 'ca': '33', 'ea': '50', 'total': 83},
      {'name': 'Mugisha Samuel', 'ca': '38', 'ea': '57', 'total': 95},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Scores'),
        actions: [
          TextButton(
            onPressed: () => context.push('/teacher/reports/ca-ea-breakdown'),
            child: const Text('CA/EA Breakdown'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mathematics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Total: 100 Points', style: TextStyle(color: Theme.of(context).hintColor)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Student', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(child: Text('CA (40)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(child: Text('EA (60)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(child: Text('Total', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: scores.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final score = scores[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(score['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: TextFormField(
                            initialValue: score['ca'],
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: TextFormField(
                            initialValue: score['ea'],
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${score['total']}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Previous',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    label: 'Save & Next',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
