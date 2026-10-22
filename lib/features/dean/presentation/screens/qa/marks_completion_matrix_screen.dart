import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart';
import '../../../domain/entities/assessment_moderation.dart';
import '../../bloc/dean_bloc.dart';
import '../../bloc/dean_event.dart';
import '../../bloc/dean_state.dart';

class MarksCompletionMatrixScreen extends StatefulWidget {
  const MarksCompletionMatrixScreen({super.key});

  @override
  State<MarksCompletionMatrixScreen> createState() =>
      _MarksCompletionMatrixScreenState();
}

class _MarksCompletionMatrixScreenState
    extends State<MarksCompletionMatrixScreen> {
  String? _selectedSubject;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';
    return BlocProvider(
      create: (context) =>
          sl<DeanBloc>()..add(AssessmentsOverviewRequested(schoolId: schoolId)),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          title: Text('Marks Completion', style: AppTypography.titleLarge),
        ),
        body: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is AssessmentsOverviewLoaded) {
              final subjects =
                  state.assessments.map((a) => a.subjectName).toSet().toList()
                    ..sort();
              final filtered = _selectedSubject == null
                  ? state.assessments
                  : state.assessments
                        .where((a) => a.subjectName == _selectedSubject)
                        .toList();
              if (filtered.isEmpty) {
                return const EmptyState(
                  icon: Icons.fact_check_outlined,
                  title: 'No assessments found',
                  message: 'No marks completion data for this filter.',
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: _buildSubjectFilter(context, subjects),
                  ),
                  const _MatrixHeaderRow(),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: AppColors.border(context)),
                      itemBuilder: (context, index) =>
                          _MatrixRow(assessment: filtered[index]),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              );
            }
            if (state is DeanError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildSubjectFilter(BuildContext context, List<String> subjects) {
    return DropdownButtonFormField<String?>(
      initialValue: _selectedSubject,
      decoration: InputDecoration(
        labelText: 'Subject',
        filled: true,
        fillColor: AppColors.surfaceContainer(context),
        border: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide.none,
        ),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('All Subjects')),
        ...subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))),
      ],
      onChanged: (value) => setState(() => _selectedSubject = value),
    );
  }
}

class _MatrixHeaderRow extends StatelessWidget {
  const _MatrixHeaderRow();

  @override
  Widget build(BuildContext context) {
    final headerStyle = AppTypography.labelSmall.copyWith(
      color: AppColors.textMuted(context),
      fontWeight: FontWeight.w700,
    );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.m,
      ),
      color: AppColors.surfaceContainer(context),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Class', style: headerStyle)),
          Expanded(
            flex: 2,
            child: Text(
              'Comp %',
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Missing',
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('Status', style: headerStyle, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _MatrixRow extends StatelessWidget {
  final AssessmentModeration assessment;

  const _MatrixRow({required this.assessment});

  @override
  Widget build(BuildContext context) {
    final total = assessment.totalStudents;
    final entered = assessment.submissionCount;
    final missing = (total - entered).clamp(0, total);
    final completionPct = total == 0 ? 0.0 : (entered / total * 100);
    final status = _statusFor(completionPct);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              assessment.className,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${completionPct.toStringAsFixed(0)}%',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$missing',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: StatusBadge(
                label: status.label,
                color: status.color(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _MatrixStatus _statusFor(double completionPct) {
    if (completionPct >= 90) return _MatrixStatus.good;
    if (completionPct >= 60) return _MatrixStatus.attention;
    return _MatrixStatus.atRisk;
  }
}

enum _MatrixStatus {
  good('Good'),
  attention('Attention'),
  atRisk('At Risk');

  final String label;
  const _MatrixStatus(this.label);

  Color color(BuildContext context) {
    switch (this) {
      case _MatrixStatus.good:
        return AppColors.success(context);
      case _MatrixStatus.attention:
        return AppColors.warning(context);
      case _MatrixStatus.atRisk:
        return AppColors.danger(context);
    }
  }
}
