import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_event.dart';

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
                Text(
                  'This report will include the following sections:',
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
                const SizedBox(height: 16),
                ...sections.map((section) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            section['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          subtitle: section['subtitle'] != null
                              ? Text(
                                  section['subtitle'],
                                  style: TextStyle(color: AppColors.textSecondary(context)),
                                )
                              : null,
                          value: section['enabled'],
                          onChanged: (val) {
                            setState(() {
                              section['enabled'] = val;
                            });
                          },
                          activeColor: AppColors.primary(context),
                          checkColor: AppColors.white,
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
              onPressed: () {
                final enabledTitles = sections
                    .where((s) => s['enabled'] == true)
                    .map((s) => s['title'] as String)
                    .toList();
                context.read<ReportWizardBloc>().add(ReportWizardSectionsUpdated(enabledTitles));
                context.push('/staff/reports/select-students');
              },
            ),
          ),
        ],
      ),
    );
  }
}
