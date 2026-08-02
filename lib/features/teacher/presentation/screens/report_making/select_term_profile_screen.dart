import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_event.dart';

class SelectTermProfileScreen extends StatefulWidget {
  const SelectTermProfileScreen({super.key});

  @override
  State<SelectTermProfileScreen> createState() => _SelectTermProfileScreenState();
}

class _SelectTermProfileScreenState extends State<SelectTermProfileScreen> {
  String selectedYear = '2024/2025';
  String selectedTerm = 'Term 2 (Jan - Apr 2025)';
  String selectedProfile = 'Primary Competency & Percentage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Term & Profile'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Academic Year',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedYear,
                  decoration: const InputDecoration(hintText: 'Select Year'),
                  items: ['2024/2025', '2023/2024'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedYear = v);
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Term',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedTerm,
                  decoration: const InputDecoration(hintText: 'Select Term'),
                  items: ['Term 1 (Sep - Dec 2024)', 'Term 2 (Jan - Apr 2025)', 'Term 3 (May - Aug 2025)']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedTerm = v);
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Assessment Profile',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedProfile,
                  decoration: const InputDecoration(hintText: 'Select Profile'),
                  items: ['Primary Competency & Percentage', 'Secondary Standard', 'Early Years Foundation']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedProfile = v);
                  },
                ),
                const SizedBox(height: 16),
                AppCard(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('About this profile', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              'Continuous Assessment (40%)\nEnd of Term Assessment (60%)\nGrading Scale: A - F',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              label: 'Continue',
              onPressed: () {
                context.read<ReportWizardBloc>().add(
                      ReportWizardTermProfileSelected(
                        year: selectedYear,
                        term: selectedTerm,
                        profile: selectedProfile,
                      ),
                    );
                context.push('/staff/reports/sections');
              },
            ),
          ),
        ],
      ),
    );
  }
}
