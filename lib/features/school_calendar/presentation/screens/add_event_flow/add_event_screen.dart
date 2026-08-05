import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../bloc/school_calendar_bloc.dart';
import '../../bloc/school_calendar_event.dart';
import '../../bloc/school_calendar_state.dart';
import '../../../domain/entities/calendar_event.dart';
import 'add_event_draft.dart';
import 'step_1_event_details.dart';
import 'step_2_recurrence.dart';
import 'step_3_review.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _draft = AddEventDraft();
  int _step = 1;

  static const _titles = {
    1: 'Add Event',
    2: 'Add Event',
    3: 'Add Event',
  };

  void _goTo(int step) => setState(() => _step = step);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SchoolCalendarBloc, SchoolCalendarState>(
      listener: (context, state) {
        if (state is SchoolCalendarActionSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is SchoolCalendarActionDenied) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: WizardScaffold(
        title: _titles[_step]!,
        currentStep: _step,
        totalSteps: 3,
        onBack: () {
          if (_step > 1) {
            _goTo(_step - 1);
          } else {
            Navigator.of(context).pop();
          }
        },
        child: _buildStep(context),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case 1:
        return Step1EventDetails(
          draft: _draft,
          onNext: () => _goTo(2),
        );
      case 2:
        return Step2Recurrence(
          draft: _draft,
          onBack: () => _goTo(1),
          onNext: () => _goTo(3),
        );
      case 3:
        return BlocBuilder<SchoolCalendarBloc, SchoolCalendarState>(
          builder: (context, state) {
            final saving = state is SchoolCalendarLoading;
            return Step3Review(
              draft: _draft,
              onBack: () => _goTo(2),
              saving: saving,
              onSave: () => _save(context),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _save(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final user = authState.user;

    final event = CalendarEvent(
      id: '',
      schoolId: user.schoolId,
      title: _draft.title,
      description: _draft.description,
      type: _draft.type,
      startDate: _draft.startDate!,
      endDate: _draft.endDate!,
      allDay: _draft.allDay,
      colorHex: _draft.colorHex,
      recurrence: _draft.buildRecurrence(),
      createdBy: user.id,
      createdAt: DateTime.now(),
    );

    context.read<SchoolCalendarBloc>().add(
      SaveCalendarEventRequested(event: event, operatorUser: user),
    );
  }
}
