import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_state.dart';

class SelectClassScreen extends StatelessWidget {
  const SelectClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Select Class'),
        backgroundColor: AppColors.surfaceElevated(context),
        foregroundColor: AppColors.textPrimary(context),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.border(context).withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      body: BlocBuilder<ReportWizardBloc, ReportWizardState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AppSearchField(hintText: 'Search class...'),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _ClassItem(
                      className: 'Primary 4 - Emerald',
                      studentCount: 32,
                      isSelected: state.selectedClassId == 'p4e',
                      onTap: () {
                        context.read<ReportWizardBloc>().add(
                              const ReportWizardClassSelected(
                                classId: 'p4e',
                                className: 'Primary 4 - Emerald',
                              ),
                            );
                      },
                    ),
                    const SizedBox(height: 12),
                    _ClassItem(
                      className: 'Primary 4 - Sapphire',
                      studentCount: 33,
                      isSelected: state.selectedClassId == 'p4s',
                      onTap: () {
                        context.read<ReportWizardBloc>().add(
                              const ReportWizardClassSelected(
                                classId: 'p4s',
                                className: 'Primary 4 - Sapphire',
                              ),
                            );
                      },
                    ),
                    const SizedBox(height: 12),
                    _ClassItem(
                      className: 'Primary 5 - Emerald',
                      studentCount: 28,
                      isSelected: state.selectedClassId == 'p5e',
                      onTap: () {
                        context.read<ReportWizardBloc>().add(
                              const ReportWizardClassSelected(
                                classId: 'p5e',
                                className: 'Primary 5 - Emerald',
                              ),
                            );
                      },
                    ),
                    const SizedBox(height: 12),
                    _ClassItem(
                      className: 'Primary 5 - Sapphire',
                      studentCount: 29,
                      isSelected: state.selectedClassId == 'p5s',
                      onTap: () {
                        context.read<ReportWizardBloc>().add(
                              const ReportWizardClassSelected(
                                classId: 'p5s',
                                className: 'Primary 5 - Sapphire',
                              ),
                            );
                      },
                    ),
                    const SizedBox(height: 12),
                    _ClassItem(
                      className: 'Primary 6 - Emerald',
                      studentCount: 31,
                      isSelected: state.selectedClassId == 'p6e',
                      onTap: () {
                        context.read<ReportWizardBloc>().add(
                              const ReportWizardClassSelected(
                                classId: 'p6e',
                                className: 'Primary 6 - Emerald',
                              ),
                            );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: PrimaryButton(
                  label: 'Continue',
                  onPressed: state.selectedClassId == null
                      ? null
                      : () => context.push('/staff/reports/select-term'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ClassItem extends StatelessWidget {
  final String className;
  final int studentCount;
  final bool isSelected;
  final VoidCallback onTap;

  const _ClassItem({
    required this.className,
    required this.studentCount,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: isSelected ? AppColors.primary(context) : null,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary(context).withValues(alpha: isSelected ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isSelected ? Icons.check_circle : Icons.class_outlined,
              color: AppColors.primary(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(className,
                    style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text('$studentCount Students',
                    style: TextStyle(color: AppColors.textSecondary(context))),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
        ],
      ),
    );
  }
}

