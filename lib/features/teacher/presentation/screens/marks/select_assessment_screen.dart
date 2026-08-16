import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/teacher/domain/entities/subject_assessment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/marks/marks_bloc.dart';

class SelectAssessmentScreen extends StatefulWidget {
  const SelectAssessmentScreen({super.key});

  @override
  State<SelectAssessmentScreen> createState() =>
      _SelectAssessmentScreenState();
}

class _SelectAssessmentScreenState extends State<SelectAssessmentScreen> {
  String _typeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = theme.scaffoldBackgroundColor;
    final surface = isDark
        ? const Color(0xFF1E293B)
        : theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Select Assessment',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<MarksBloc, MarksState>(
        builder: (context, state) {
          final types = <String>{
            'All',
            for (final a in state.assessments) a.assessmentTypeName,
          }.where((t) => t.isNotEmpty).toList();

          final visible = state.assessments
              .where(
                (a) =>
                    _typeFilter == 'All' ||
                    a.assessmentTypeName == _typeFilter,
              )
              .toList();

          return Column(
            children: [
              _buildTabs(context, types, surface),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : visible.isEmpty
                    ? Center(
                        child: Text(
                          'No assessments are open for entry right now.',
                          style: TextStyle(color: theme.hintColor),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          for (final assessment in visible)
                            _buildAssessmentCard(
                              context,
                              assessment,
                              surface,
                              theme,
                            ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabs(BuildContext context, List<String> types, Color surface) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          for (final type in types)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildTab(context, type, type == _typeFilter),
            ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, bool isSelected) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => setState(() => _typeFilter = label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: theme.dividerColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.hintColor,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentCard(
    BuildContext context,
    SubjectAssessment assessment,
    Color surfaceColor,
    ThemeData theme,
  ) {
    final statusColor = switch (assessment.status) {
      AssessmentAvailability.approved ||
      AssessmentAvailability.published ||
      AssessmentAvailability.submitted => Colors.green,
      AssessmentAvailability.locked ||
      AssessmentAvailability.archived => Colors.grey,
      _ => Colors.blue,
    };

    return InkWell(
      onTap: () {
        context.read<MarksBloc>().add(MarksAssessmentSelected(assessment));
        context.push('/staff/marks/select-component');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assessment.title.isEmpty
                        ? assessment.assessmentTypeName
                        : assessment.title,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${assessment.assessmentTypeName} • '
                    '${assessment.maximumMark.toStringAsFixed(0)} Marks',
                    style: TextStyle(color: theme.hintColor, fontSize: 12),
                  ),
                  if (assessment.assessmentDate != null)
                    Text(
                      _formatDate(assessment.assessmentDate!),
                      style: TextStyle(
                        color: theme.hintColor.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      assessment.status.label,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: theme.hintColor, size: 16),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
