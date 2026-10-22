import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import '../../../domain/entities/exam_factory_entities.dart';
import '../../bloc/exam_factory_cubit.dart';
import '../../widgets/exam_factory_shell.dart';

String attendanceStatusLabel(ExamAttendanceStatus status) => switch (status) {
  ExamAttendanceStatus.present => 'Present',
  ExamAttendanceStatus.absent => 'Absent',
  ExamAttendanceStatus.late => 'Late',
  ExamAttendanceStatus.extraTime => 'Extra time',
};

Color attendanceStatusColor(
  BuildContext context,
  ExamAttendanceStatus status,
) => switch (status) {
  ExamAttendanceStatus.present => AppColors.success(context),
  ExamAttendanceStatus.absent => AppColors.danger(context),
  ExamAttendanceStatus.late => AppColors.warning(context),
  ExamAttendanceStatus.extraTime => AppColors.information(context),
};

class ExamAttendanceScreen extends StatefulWidget {
  final String sittingId;
  const ExamAttendanceScreen({super.key, required this.sittingId});

  @override
  State<ExamAttendanceScreen> createState() => _ExamAttendanceScreenState();
}

class _ExamAttendanceScreenState extends State<ExamAttendanceScreen> {
  final _studentIdController = TextEditingController();
  final _studentNameController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _studentIdController.dispose();
    _studentNameController.dispose();
    super.dispose();
  }

  Future<void> _record(
    ExamFactoryCubit cubit,
    ExamAttendanceStatus status,
  ) async {
    if (_studentIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the candidate\'s ID.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await cubit.recordAttendance(
        sittingId: widget.sittingId,
        studentId: _studentIdController.text.trim(),
        studentName: _studentNameController.text.trim(),
        status: status,
        operationId: '${widget.sittingId}_${_studentIdController.text.trim()}',
      );
      if (!mounted) return;
      _studentIdController.clear();
      _studentNameController.clear();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cubit.state.error ?? 'Could not record attendance.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Exam attendance',
      backFallback:
          '/staff/dean/exam-factory/exam-day?sittingId=${widget.sittingId}',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          100,
        ),
        children: [
          TextField(
            controller: _studentIdController,
            decoration: const InputDecoration(labelText: 'Candidate ID'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _studentNameController,
            decoration: const InputDecoration(labelText: 'Candidate name'),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExamAttendanceStatus.values
                .map(
                  (status) => FilledButton.tonalIcon(
                    onPressed: _saving ? null : () => _record(cubit, status),
                    icon: Icon(switch (status) {
                      ExamAttendanceStatus.present => Icons.check,
                      ExamAttendanceStatus.absent => Icons.close,
                      ExamAttendanceStatus.late => Icons.schedule,
                      ExamAttendanceStatus.extraTime => Icons.timer_outlined,
                    }),
                    label: Text(attendanceStatusLabel(status)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Text('Recorded', style: AppTypography.titleSmall),
          const SizedBox(height: 8),
          StreamBuilder<List<ExamAttendanceRecord>>(
            stream: cubit.watchAttendance(sittingId: widget.sittingId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final records = snap.data ?? const <ExamAttendanceRecord>[];
              if (records.isEmpty) {
                return const Text('No attendance recorded yet.');
              }
              return Column(
                children: records
                    .map(
                      (r) => Card(
                        child: ListTile(
                          title: Text(
                            r.studentName.isEmpty ? r.studentId : r.studentName,
                          ),
                          subtitle: r.note.isNotEmpty ? Text(r.note) : null,
                          trailing: Text(
                            attendanceStatusLabel(r.status),
                            style: TextStyle(
                              color: attendanceStatusColor(context, r.status),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
