import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';

class ReportSectionsScreen extends StatefulWidget {
  const ReportSectionsScreen({super.key});

  @override
  State<ReportSectionsScreen> createState() => _ReportSectionsScreenState();
}

class _ReportSectionsScreenState extends State<ReportSectionsScreen> {
  final List<Map<String, dynamic>> sections = [
    {'title': 'Academic Performance', 'subtitle': '(Subjects & Scores)', 'enabled': true},
    {'title': 'Competency Development', 'subtitle': '(Competency Ratings)', 'enabled': true},
    {'title': 'Attendance & Punctuality', 'enabled': true},
    {'title': 'Behaviour & Conduct', 'enabled': true},
    {'title': 'Teacher\'s Comment', 'enabled': true},
    {'title': 'Next Steps / Recommendations', 'enabled': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Sections'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'This report will include the following sections:',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ...sections.map((section) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(section['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: section['subtitle'] != null ? Text(section['subtitle']) : null,
                          value: section['enabled'],
                          onChanged: (val) {
                            setState(() {
                              section['enabled'] = val;
                            });
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              label: 'Continue',
              onPressed: () => context.push('/teacher/reports/select-students'),
            ),
          ),
        ],
      ),
    );
  }
}
