import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/app_components.dart';
import '../bloc/assessment_bloc.dart';
import '../bloc/assessment_event.dart';
import '../bloc/assessment_state.dart';
import '../../domain/entities/assessment_mark.dart';

class ModerationApprovalScreen extends StatefulWidget {
  final String schoolId;
  const ModerationApprovalScreen({super.key, required this.schoolId});

  @override
  State<ModerationApprovalScreen> createState() => _ModerationApprovalScreenState();
}

class _ModerationApprovalScreenState extends State<ModerationApprovalScreen> {
  final List<String> _selectedMarkIds = [];

  @override
  void initState() {
    super.initState();
    // Load marks that are in 'submitted' or 'moderated' status
    context.read<AssessmentBloc>().add(LoadMarksForEntry(
      schoolId: widget.schoolId,
      assessmentTypeId: '', // Should probably load all pending ones or filter
      subjectId: '',
      classId: '',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderation & Approval'),
        actions: [
          if (_selectedMarkIds.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'moderate') {
                  context.read<AssessmentBloc>().add(ModerateMarks(_selectedMarkIds, 'current_user_id'));
                } else if (value == 'approve') {
                  context.read<AssessmentBloc>().add(ApproveMarks(_selectedMarkIds, 'current_user_id'));
                }
                setState(() => _selectedMarkIds.clear());
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'moderate', child: Text('Moderate Selected')),
                const PopupMenuItem(value: 'approve', child: Text('Approve Selected')),
              ],
            ),
        ],
      ),
      body: BlocBuilder<AssessmentBloc, AssessmentState>(
        builder: (context, state) {
          if (state.status == AssessmentStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final pendingMarks = state.marks.where((m) => 
            m.status == MarkStatus.submitted || m.status == MarkStatus.moderated
          ).toList();

          if (pendingMarks.isEmpty) {
            return const EmptyState(
              icon: Icons.fact_check,
              title: 'All Caught Up',
              message: 'There are no marks awaiting moderation or approval.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingMarks.length,
            itemBuilder: (context, index) {
              final mark = pendingMarks[index];
              final isSelected = _selectedMarkIds.contains(mark.id);

              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedMarkIds.add(mark.id);
                      } else {
                        _selectedMarkIds.remove(mark.id);
                      }
                    });
                  },
                  title: Text('Student: ${mark.studentId}'),
                  subtitle: Text('Subject: ${mark.subjectId} | Score: ${mark.score}'),
                  secondary: StatusBadge(label: mark.status.name, color: _markStatusColor(mark.status)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Color _markStatusColor(MarkStatus status) => switch (status) {
      MarkStatus.submitted => Colors.orange,
      MarkStatus.moderated => Colors.blue,
      MarkStatus.approved => Colors.green,
      _ => Colors.grey,
    };
