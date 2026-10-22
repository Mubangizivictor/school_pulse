import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/injection_container.dart';
import '../../../domain/entities/curriculum.dart';
import '../../bloc/dean_bloc.dart';
import '../../bloc/dean_event.dart';
import '../../bloc/dean_state.dart';
import 'syllabus_coverage_screen.dart';

class CurriculumCoverageListScreen extends StatefulWidget {
  const CurriculumCoverageListScreen({super.key});

  @override
  State<CurriculumCoverageListScreen> createState() =>
      _CurriculumCoverageListScreenState();
}

class _CurriculumCoverageListScreenState
    extends State<CurriculumCoverageListScreen> {
  String? _selectedSubjectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(CurriculaRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          title: Text('Curriculum Coverage', style: AppTypography.titleLarge),
        ),
        body: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is CurriculaLoaded) {
              final subjects = state.curricula
                  .expand((curriculum) => curriculum.subjects)
                  .toList();
              if (subjects.isEmpty) {
                return const EmptyState(
                  icon: Icons.menu_book_outlined,
                  title: 'No curriculum configured',
                  message: 'No subjects have been set up yet.',
                );
              }
              final filtered = _selectedSubjectId == null
                  ? subjects
                  : subjects.where((s) => s.id == _selectedSubjectId).toList();
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: _buildSubjectFilter(context, subjects),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.l),
                      itemBuilder: (context, index) =>
                          _SubjectCoverageRow(subject: filtered[index]),
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

  Widget _buildSubjectFilter(BuildContext context, List<Subject> subjects) {
    return DropdownButtonFormField<String?>(
      initialValue: _selectedSubjectId,
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
        ...subjects.map(
          (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
        ),
      ],
      onChanged: (value) => setState(() => _selectedSubjectId = value),
    );
  }
}

class _SubjectCoverageRow extends StatelessWidget {
  final Subject subject;

  const _SubjectCoverageRow({required this.subject});

  @override
  Widget build(BuildContext context) {
    final coverage = subject.currentCoverage.clamp(0.0, 100.0);
    final status = _statusFor(coverage);
    return AppCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SyllabusCoverageScreen(subject: subject),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subject.name,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${coverage.toStringAsFixed(0)}%',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  Text(
                    status.label,
                    style: AppTypography.labelMedium.copyWith(
                      color: status.color(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          ClipRRect(
            borderRadius: AppRadius.small,
            child: LinearProgressIndicator(
              value: coverage / 100,
              minHeight: 8,
              backgroundColor: AppColors.border(context),
              color: status.color(context),
            ),
          ),
        ],
      ),
    );
  }

  _CoverageStatus _statusFor(double coverage) {
    if (coverage >= 90) return _CoverageStatus.onTrack;
    if (coverage >= 70) return _CoverageStatus.slightlyBehind;
    if (coverage >= 50) return _CoverageStatus.behind;
    return _CoverageStatus.critical;
  }
}

enum _CoverageStatus {
  onTrack('On Track'),
  slightlyBehind('Slightly Behind'),
  behind('Behind'),
  critical('Critical');

  final String label;
  const _CoverageStatus(this.label);

  Color color(BuildContext context) {
    switch (this) {
      case _CoverageStatus.onTrack:
        return AppColors.success(context);
      case _CoverageStatus.slightlyBehind:
        return AppColors.warning(context);
      case _CoverageStatus.behind:
        return AppColors.warning(context);
      case _CoverageStatus.critical:
        return AppColors.danger(context);
    }
  }
}
