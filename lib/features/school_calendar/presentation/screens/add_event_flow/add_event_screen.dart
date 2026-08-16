import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';
import 'package:school_pulse/injection_container.dart';
import '../../../data/calendar_attachments_uploader.dart';
import '../../../domain/entities/calendar_event.dart';
import '../../../domain/entities/calendar_event_type.dart';
import '../../bloc/school_calendar_bloc.dart';
import '../../bloc/school_calendar_event.dart';
import '../../bloc/school_calendar_state.dart';
import 'add_event_draft.dart';
import 'step_1_event_details.dart';
import 'step_2_recurrence.dart';
import 'step_3_review.dart';

class AddEventScreen extends StatefulWidget {
  final DateTime? initialDate;
  final CalendarEvent? editing;
  const AddEventScreen({super.key, this.initialDate, this.editing});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _draft = AddEventDraft();
  int _step = 1;
  bool _submitting = false;

  static const _titles = {1: 'Add Event', 2: 'Add Event', 3: 'Add Event'};

  @override
  void initState() {
    super.initState();
    final event = widget.editing;
    if (event != null) {
      _draft
        ..type = event.type
        ..title = event.title
        ..description = event.description
        ..startDate = event.startDate
        ..endDate = event.endDate
        ..allDay = event.allDay
        ..colorHex = event.colorHex
        ..category = event.category
        ..location = event.location
        ..organizer = event.organizer
        ..audienceKind = event.audience.kind
        ..audienceRoles = List.of(event.audience.roles)
        ..reminder = event.reminder
        ..notes = event.notes
        ..existingAttachments = List.of(event.attachments)
        ..repeats = event.recurrence != null;
      final recurrence = event.recurrence;
      if (recurrence != null) {
        _draft
          ..frequency = recurrence.frequency
          ..repeatsOn = List.of(recurrence.repeatsOn)
          ..endType = recurrence.endType
          ..recurrenceEndDate = recurrence.endDate
          ..occurrences = recurrence.occurrences ?? 0;
      }
    } else if (widget.initialDate != null) {
      _draft.startDate = widget.initialDate;
      _draft.endDate = widget.initialDate;
    }
  }

  void _goTo(int step) => setState(() => _step = step);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SchoolCalendarBloc, SchoolCalendarState>(
      listener: (context, state) async {
        if (state is SchoolCalendarActionSuccess) {
          if (state.savedEventId != null) {
            await _afterSave(context, state.savedEventId!);
          }
          if (!context.mounted) return;
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
        return Step1EventDetails(draft: _draft, onNext: () => _goTo(2));
      case 2:
        return Step2Recurrence(
          draft: _draft,
          onBack: () => _goTo(1),
          onNext: () => _goTo(3),
        );
      case 3:
        return BlocBuilder<SchoolCalendarBloc, SchoolCalendarState>(
          builder: (context, state) {
            final saving = state is SchoolCalendarLoading || _submitting;
            return Step3Review(
              draft: _draft,
              onBack: () => _goTo(2),
              saving: saving,
              onSave: saving ? () {} : () => _save(context),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _save(BuildContext context) {
    if (_submitting) return; // idempotent guard against double-tap
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final user = authState.user;
    setState(() => _submitting = true);

    final event = CalendarEvent(
      id: widget.editing?.id ?? '',
      schoolId: user.schoolId,
      title: _draft.title,
      description: _draft.description,
      type: _draft.type,
      startDate: _draft.startDate!,
      endDate: _draft.endDate!,
      allDay: _draft.allDay,
      colorHex: _draft.colorHex,
      category: _draft.category,
      location: _draft.location,
      organizer: _draft.organizer,
      audience: _draft.buildAudience(),
      reminder: _draft.reminder,
      notes: _draft.notes,
      attachments: _draft.existingAttachments,
      recurrence: _draft.buildRecurrence(),
      createdBy: widget.editing?.createdBy ?? user.id,
      createdAt: widget.editing?.createdAt ?? DateTime.now(),
    );

    context.read<SchoolCalendarBloc>().add(
      SaveCalendarEventRequested(event: event, operatorUser: user),
    );
  }

  /// Runs after the event document is confirmed saved: uploads any newly
  /// staged attachments (tenant-scoped Storage path requires the event id),
  /// notifies the chosen audience via the existing notification pipeline,
  /// and writes an audit log entry.
  Future<void> _afterSave(BuildContext context, String eventId) async {
    if (!context.mounted) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final user = authState.user;
    final isEdit = widget.editing != null;

    if (_draft.stagedAttachments.isNotEmpty) {
      final uploader = CalendarAttachmentsUploader();
      final result = await uploader.uploadAll(
        schoolId: user.schoolId,
        eventId: eventId,
        staged: _draft.stagedAttachments,
      );
      if (result.uploaded.isNotEmpty && context.mounted) {
        final merged = [..._draft.existingAttachments, ...result.uploaded];
        context.read<SchoolCalendarBloc>().add(
          SaveCalendarEventRequested(
            event: CalendarEvent(
              id: eventId,
              schoolId: user.schoolId,
              title: _draft.title,
              description: _draft.description,
              type: _draft.type,
              startDate: _draft.startDate!,
              endDate: _draft.endDate!,
              allDay: _draft.allDay,
              colorHex: _draft.colorHex,
              category: _draft.category,
              location: _draft.location,
              organizer: _draft.organizer,
              audience: _draft.buildAudience(),
              reminder: _draft.reminder,
              notes: _draft.notes,
              attachments: merged,
              recurrence: _draft.buildRecurrence(),
              createdBy: widget.editing?.createdBy ?? user.id,
              createdAt: widget.editing?.createdAt ?? DateTime.now(),
            ),
            operatorUser: user,
          ),
        );
      }
      if (result.failed.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Some attachments failed to upload: ${result.failed.join(', ')}',
            ),
          ),
        );
      }
    }

    // Notify the chosen audience about a newly created event. Edits are not
    // re-notified to avoid duplicate sends on every minor change.
    if (!isEdit) {
      await sl<NotificationSendService>().send(
        sender: user,
        audience: _draft.buildAudience(),
        category: NotificationCategory.others,
        type: NotificationType.eventNotice,
        title: 'New calendar event: ${_draft.title}',
        body: _eventSummary(),
        sourceModule: 'school_calendar',
        sourceEntityId: eventId,
      );
    }

    await sl<AuditRepository>().logAction(
      schoolId: user.schoolId,
      title: isEdit ? 'Calendar event updated' : 'Calendar event created',
      description: _draft.title,
      iconName: 'calendar_month',
      colorHex: _draft.colorHex,
      userId: user.id,
    );
  }

  String _eventSummary() {
    final start = _draft.startDate;
    if (start == null) return _draft.title;
    return '${_draft.type.label} on ${start.day}/${start.month}/${start.year}';
  }
}
