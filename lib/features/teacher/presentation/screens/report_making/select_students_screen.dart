import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_state.dart';

class SelectStudentsScreen extends StatefulWidget {
  const SelectStudentsScreen({super.key});

  @override
  State<SelectStudentsScreen> createState() => _SelectStudentsScreenState();
}

class _SelectStudentsScreenState extends State<SelectStudentsScreen> {
  final List<Map<String, dynamic>> students = [
    {'id': 's1', 'name': 'Abiola Peter', 'selected': true},
    {'id': 's2', 'name': 'Adong Grace', 'selected': true},
    {'id': 's3', 'name': 'Aguil Brian', 'selected': true},
    {'id': 's4', 'name': 'Ampiire Doris', 'selected': true},
    {'id': 's5', 'name': 'Atim Charles', 'selected': true},
    {'id': 's6', 'name': 'Namatuga Grace', 'selected': true},
    {'id': 's7', 'name': 'Tumusiime David', 'selected': true},
    {'id': 's8', 'name': 'Mugisha Samuel', 'selected': true},
  ];

  bool allSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Students (32)')),
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
              title: Text(
                'Select All',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              value: allSelected,
              onChanged: (val) {
                setState(() {
                  allSelected = val ?? false;
                  for (var s in students) {
                    s['selected'] = allSelected;
                  }
                });
              },
              activeColor: AppColors.primary(context),
              checkColor: AppColors.white,
            ),
          ),
          Divider(color: AppColors.border(context)),
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
                    title: Text(
                      student['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    secondary: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primarySoft(context),
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: AppColors.primary(context),
                      ),
                    ),
                    value: student['selected'],
                    onChanged: (val) {
                      setState(() {
                        student['selected'] = val;
                        allSelected = students.every((s) => s['selected']);
                      });
                    },
                    activeColor: AppColors.primary(context),
                    checkColor: AppColors.white,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<ReportWizardBloc, ReportWizardState>(
              builder: (context, state) {
                final selectedCount = students
                    .where((s) => s['selected'] == true)
                    .length;
                return PrimaryButton(
                  label:
                      'Continue${selectedCount > 0 ? ' ($selectedCount)' : ''}',
                  onPressed: selectedCount == 0
                      ? null
                      : () {
                          final selectedIds = students
                              .where((s) => s['selected'] == true)
                              .map((s) => s['id'] as String)
                              .toList();
                          context.read<ReportWizardBloc>().add(
                            ReportWizardStudentsSelected(selectedIds),
                          );
                          context.push('/staff/reports/subject-progress');
                        },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
