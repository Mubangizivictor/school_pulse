import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../../../domain/entities/timetable.dart';
import '../../../bloc/timetable_bloc.dart';
import '../../../bloc/timetable_event.dart';
import '../../../bloc/timetable_state.dart';
import 'create_timetable_draft.dart';
import 'step_1_basic_info.dart';
import 'step_2_periods.dart';
import 'step_3_schedule.dart';
import 'step_4_review.dart';

const List<String> _kStepLabels = ['Details', 'Periods', 'Schedule', 'Review'];

/// Structure -> Timetables -> Create Timetable: a 4-step wizard that
/// produces one draft [Timetable] envelope. Lesson assignment itself
/// happens afterwards in the Timetable Builder, not in this flow.
class CreateTimetableScreen extends StatefulWidget {
  const CreateTimetableScreen({super.key, this.initialClassId});

  final String? initialClassId;

  @override
  State<CreateTimetableScreen> createState() => _CreateTimetableScreenState();
}

class _CreateTimetableScreenState extends State<CreateTimetableScreen> {
  int _step = 0;
  late final _draft = CreateTimetableDraft()
    ..classId = widget.initialClassId ?? '';

  void _next() {
    if (_step < 3) setState(() => _step++);
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _create() {
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    final userId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.id;
    final draft = Timetable(
      id: '',
      schoolId: schoolId,
      academicYearId: _draft.academicYearId,
      termId: _draft.termId,
      classId: _draft.classId,
      streamId: _draft.streamId,
      name: _draft.name,
      description: _draft.description,
      status: TimetableStatus.draft,
      createdAt: DateTime.now(),
      createdBy: userId,
    );
    context.read<TimetableBloc>().add(TimetableCreateRequested(draft));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TimetableBloc, TimetableState>(
      listenWhen: (previous, current) =>
          (previous.current?.id != current.current?.id &&
              current.current != null) ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          return;
        }
        if (state.current != null) {
          Navigator.of(context).pop(state.current!.id);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AdminAppBar(
          title: 'Create Timetable',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _back,
          ),
        ),
        body: Column(
          children: [
            _StepIndicator(currentStep: _step),
            Expanded(
              child: switch (_step) {
                0 => Step1BasicInfo(draft: _draft, onNext: _next),
                1 => Step2Periods(onNext: _next),
                2 => Step3Schedule(onNext: _next),
                _ => Step4Review(draft: _draft, onCreate: _create),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${currentStep + 1} of ${_kStepLabels.length}',
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (currentStep + 1) / _kStepLabels.length,
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < _kStepLabels.length; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                Text(
                  _kStepLabels[i],
                  style: TextStyle(
                    fontWeight: i == currentStep
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: i == currentStep
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
