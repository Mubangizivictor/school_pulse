import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';

class SelectStudentsScreen extends StatefulWidget {
  const SelectStudentsScreen({super.key});

  @override
  State<SelectStudentsScreen> createState() => _SelectStudentsScreenState();
}

class _SelectStudentsScreenState extends State<SelectStudentsScreen> {
  final List<Map<String, dynamic>> students = [
    {'name': 'Abiola Peter', 'selected': true},
    {'name': 'Adong Grace', 'selected': true},
    {'name': 'Aguil Brian', 'selected': true},
    {'name': 'Ampiire Doris', 'selected': true},
    {'name': 'Atim Charles', 'selected': true},
    {'name': 'Namatuga Grace', 'selected': true},
    {'name': 'Tumusiime David', 'selected': true},
    {'name': 'Mugisha Samuel', 'selected': true},
  ];

  bool allSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students (32)'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppSearchField(hintText: 'Search students...'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Select All', style: TextStyle(fontWeight: FontWeight.bold)),
              value: allSelected,
              onChanged: (val) {
                setState(() {
                  allSelected = val ?? false;
                  for (var s in students) {
                    s['selected'] = allSelected;
                  }
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final student = students[index];
                return AppCard(
                  padding: EdgeInsets.zero,
                  child: CheckboxListTile(
                    title: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    secondary: const CircleAvatar(
                      radius: 18,
                      child: Icon(Icons.person, size: 20),
                    ),
                    value: student['selected'],
                    onChanged: (val) {
                      setState(() {
                        student['selected'] = val;
                        allSelected = students.every((s) => s['selected']);
                      });
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              label: 'Continue',
              onPressed: () => context.push('/teacher/reports/subject-progress'),
            ),
          ),
        ],
      ),
    );
  }
}
