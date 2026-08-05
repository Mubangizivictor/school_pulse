import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_state.dart';

class ReportPreviewScreen extends StatelessWidget {
  const ReportPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportWizardBloc, ReportWizardState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Report Card Preview'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.file_download_outlined),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _ReportCardPreviewHeader(
                        year: state.selectedYear,
                        term: state.selectedTerm,
                      ),
                      const SizedBox(height: 16),
                      _buildPreviewSection(
                        context,
                        title: 'Student Information',
                        content: _StudentInfoTable(
                          className: state.selectedClassName,
                        ),
                      ),
                      if (state.enabledSections.contains(
                        'Academic Performance',
                      )) ...[
                        const SizedBox(height: 16),
                        _buildPreviewSection(
                          context,
                          title: 'Academic Performance',
                          content: const _AcademicPerformanceTable(),
                        ),
                      ],
                      if (state.enabledSections.contains(
                        'Competency Development',
                      )) ...[
                        const SizedBox(height: 16),
                        _buildPreviewSection(
                          context,
                          title: 'Competencies & Skills',
                          content: const _SkillsGrid(),
                        ),
                      ],
                      if (state.enabledSections.contains(
                            'Attendance & Punctuality',
                          ) ||
                          state.enabledSections.contains(
                            'Behaviour & Conduct',
                          )) ...[
                        const SizedBox(height: 16),
                        _buildPreviewSection(
                          context,
                          title: 'Attendance & Conduct',
                          content: const _AttendanceConductSummary(),
                        ),
                      ],
                      if (state.enabledSections.contains(
                        'Teacher\'s Comment',
                      )) ...[
                        const SizedBox(height: 16),
                        _buildPreviewSection(
                          context,
                          title: 'Teacher\'s Remarks',
                          content: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'Amara is a bright and enthusiastic learner. She participates actively in class discussions and shows strong potential. She should continue to work on her problem-solving skills in Mathematics.',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: PrimaryButton(
                  label:
                      'Proceed to Generate (${state.selectedStudentIds.length} Students)',
                  onPressed: () => context.push('/staff/reports/generate'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewSection(
    BuildContext context, {
    required String title,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
        AppCard(padding: EdgeInsets.zero, child: content),
      ],
    );
  }
}

class _ReportCardPreviewHeader extends StatelessWidget {
  final String? year;
  final String? term;

  const _ReportCardPreviewHeader({this.year, this.term});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primary(context).withOpacity(0.1),
          child: Icon(
            Icons.school,
            color: AppColors.primary(context),
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LITTLE SAINTS INTERNATIONAL SCHOOL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                '${year ?? '2023/2024'} Academic Session - ${term ?? 'First Term'}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StudentInfoTable extends StatelessWidget {
  final String? className;

  const _StudentInfoTable({this.className});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _infoRow(context, 'Name:', 'Amara Okoro'),
          Divider(color: AppColors.border(context)),
          _infoRow(context, 'Class:', className ?? 'Primary 2 Gold'),
          Divider(color: AppColors.border(context)),
          _infoRow(context, 'Admission No:', 'LSIS/2021/042'),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _AcademicPerformanceTable extends StatelessWidget {
  const _AcademicPerformanceTable();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.surfaceContainer(context),
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Subject',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'CA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Exam',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Total',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Grade',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        _subjectRow(context, 'Mathematics', '35', '55', '90', 'A+'),
        _subjectRow(context, 'English Language', '30', '52', '82', 'A'),
        _subjectRow(context, 'Science', '28', '48', '76', 'B+'),
        _subjectRow(context, 'Social Studies', '32', '50', '82', 'A'),
      ],
    );
  }

  Widget _subjectRow(
    BuildContext context,
    String name,
    String ca,
    String exam,
    String total,
    String grade,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border(context))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: TextStyle(color: AppColors.textPrimary(context)),
            ),
          ),
          Expanded(
            child: Text(
              ca,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textPrimary(context)),
            ),
          ),
          Expanded(
            child: Text(
              exam,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textPrimary(context)),
            ),
          ),
          Expanded(
            child: Text(
              total,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textPrimary(context)),
            ),
          ),
          Expanded(
            child: Text(
              grade,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillsGrid extends StatelessWidget {
  const _SkillsGrid();

  Widget _skillRow(BuildContext context, String name, int rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(color: AppColors.textPrimary(context))),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star : Icons.star_border,
                size: 16,
                color: AppColors.warning(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _skillRow(context, 'Punctuality', 5),
          _skillRow(context, 'Creativity', 4),
          _skillRow(context, 'Neatness', 5),
          _skillRow(context, 'Self-Confidence', 4),
        ],
      ),
    );
  }
}

class _AttendanceConductSummary extends StatelessWidget {
  const _AttendanceConductSummary();

  Widget _summaryItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem(context, 'Attendance', '95%'),
          _summaryItem(context, 'Conduct', 'Excellent'),
        ],
      ),
    );
  }
}
