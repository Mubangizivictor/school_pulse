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

const List<String> _kStepLabels = [
  'Basic Info',
  'Periods',
  'Schedule',
  'Review',
];

/// Structure -> Timetables -> Create Timetable: a 4-step wizard that
/// produces one draft [Timetable] envelope. Lesson assignment itself
/// happens afterwards in the Timetable Builder, not in this flow.
class CreateTimetableScreen extends StatefulWidget {
  const CreateTimetableScreen({super.key});

  @override
  State<CreateTimetableScreen> createState() => _CreateTimetableScreenState();
}

class _CreateTimetableScreenState extends State<CreateTimetableScreen> {
  int _step = 0;
  final _draft = CreateTimetableDraft();

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
          previous.current?.id != current.current?.id &&
          current.current != null,
      listener: (context, state) {
        Navigator.of(context).pop(state.current!.id);
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
      child: Row(
        children: List.generate(_kStepLabels.length * 2 - 1, (i) {
          if (i.isOdd) {
            final leftStepDone = (i - 1) ~/ 2 < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: leftStepDone
                    ? colors.primary
                    : colors.outline.withValues(alpha: .3),
              ),
            );
          }
          final index = i ~/ 2;
          final isDone = index < currentStep;
          final isCurrent = index == currentStep;
          return Column(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone || isCurrent
                      ? colors.primary
                      : colors.surfaceContainer,
                  border: Border.all(
                    color: isDone || isCurrent
                        ? colors.primary
                        : colors.outline.withValues(alpha: .3),
                  ),
                ),
                child: isDone
                    ? Icon(Icons.check, size: 15, color: colors.onPrimary)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isCurrent
                              ? colors.onPrimary
                              : colors.onSurfaceVariant,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                _kStepLabels[index],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
