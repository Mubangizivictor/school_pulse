import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/notification/notification_service.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import '../../domain/entities/appointment_status.dart';
import '../../domain/usecases/appointment_usecases.dart';
import 'appointment_action_event.dart';
import 'appointment_action_state.dart';

/// Drives every appointment *mutation* (request, approve/reject/reschedule,
/// cancel, check-in/out, confidential notes) from one place, so the
/// notification + audit-log side effects that must accompany each action
/// live in a single spot instead of being duplicated across the parent,
/// staff, and admin screens that all trigger them.
class AppointmentActionBloc
    extends Bloc<AppointmentActionEvent, AppointmentActionState> {
  final RequestAppointment requestAppointment;
  final RespondToAppointment respondToAppointment;
  final CancelAppointment cancelAppointment;
  final CheckInAppointment checkInAppointment;
  final CheckOutAppointment checkOutAppointment;
  final AddAppointmentNote addAppointmentNote;
  final NotificationService notificationService = NotificationService();
  final AuditRepository auditRepository = AuditRepository();

  AppointmentActionBloc({
    required this.requestAppointment,
    required this.respondToAppointment,
    required this.cancelAppointment,
    required this.checkInAppointment,
    required this.checkOutAppointment,
    required this.addAppointmentNote,
  }) : super(AppointmentActionIdle()) {
    on<SubmitAppointmentRequestAction>(_onSubmitRequest);
    on<RespondToAppointmentAction>(_onRespond);
    on<CancelAppointmentAction>(_onCancel);
    on<CheckInAppointmentAction>(_onCheckIn);
    on<CheckOutAppointmentAction>(_onCheckOut);
    on<AddAppointmentNoteAction>(_onAddNote);
    on<ResetAppointmentActionState>(
      (event, emit) => emit(AppointmentActionIdle()),
    );
  }

  Future<void> _onSubmitRequest(
    SubmitAppointmentRequestAction event,
    Emitter<AppointmentActionState> emit,
  ) async {
    emit(AppointmentActionInProgress());
    final result = await requestAppointment(event.appointment);
    result.fold((failure) => emit(AppointmentActionFailure(failure.message)), (
      appointment,
    ) {
      notificationService.sendDirectNotification(
        userId: appointment.staffId,
        title: 'New Appointment Request',
        body:
            '${appointment.requesterName} requested a ${appointment.appointmentTypeName} meeting.',
      );
      auditRepository.logAction(
        title: 'Appointment Requested',
        description:
            '${appointment.requesterName} requested a meeting with ${appointment.staffName}.',
        iconName: 'event_note',
        colorHex: 'FF1976D2',
        userId: appointment.requesterId,
      );
      emit(
        AppointmentActionSuccess(
          'Appointment request sent',
          appointment: appointment,
        ),
      );
    });
  }

  Future<void> _onRespond(
    RespondToAppointmentAction event,
    Emitter<AppointmentActionState> emit,
  ) async {
    emit(AppointmentActionInProgress());
    final result = await respondToAppointment(
      id: event.appointment.id,
      status: event.status,
      respondedBy: event.respondedBy,
      responseNote: event.responseNote,
      proposedStart: event.proposedStart,
      proposedEnd: event.proposedEnd,
    );
    result.fold((failure) => emit(AppointmentActionFailure(failure.message)), (
      _,
    ) {
      final (title, body) = switch (event.status) {
        AppointmentStatus.approved => (
          'Appointment Approved',
          '${event.appointment.staffName} approved your ${event.appointment.appointmentTypeName} meeting.',
        ),
        AppointmentStatus.rejected => (
          'Appointment Declined',
          '${event.appointment.staffName} declined your appointment request.',
        ),
        AppointmentStatus.rescheduleProposed => (
          'New Time Proposed',
          '${event.appointment.staffName} proposed a new time for your meeting.',
        ),
        _ => ('Appointment Updated', 'Your appointment status changed.'),
      };
      notificationService.sendDirectNotification(
        userId: event.appointment.requesterId,
        title: title,
        body: body,
      );
      auditRepository.logAction(
        title: title,
        description:
            '${event.respondedBy} ${event.status.label.toLowerCase()} an appointment for '
            '${event.appointment.requesterName}.',
        iconName: 'event_available',
        colorHex: 'FF2E7D32',
        userId: event.respondedBy,
      );
      emit(AppointmentActionSuccess(title));
    });
  }

  Future<void> _onCancel(
    CancelAppointmentAction event,
    Emitter<AppointmentActionState> emit,
  ) async {
    emit(AppointmentActionInProgress());
    final result = await cancelAppointment(
      id: event.appointment.id,
      cancelledBy: event.cancelledBy,
      reason: event.reason,
    );
    result.fold((failure) => emit(AppointmentActionFailure(failure.message)), (
      _,
    ) {
      final notifyUserId = event.cancelledBy == event.appointment.requesterId
          ? event.appointment.staffId
          : event.appointment.requesterId;
      notificationService.sendDirectNotification(
        userId: notifyUserId,
        title: 'Appointment Cancelled',
        body:
            '${event.appointment.appointmentTypeName} meeting on '
            '${event.appointment.scheduledStart.toLocal()} was cancelled.',
      );
      auditRepository.logAction(
        title: 'Appointment Cancelled',
        description:
            'Appointment for ${event.appointment.requesterName} with '
            '${event.appointment.staffName} was cancelled.',
        iconName: 'event_busy',
        colorHex: 'FFC62828',
        userId: event.cancelledBy,
      );
      emit(const AppointmentActionSuccess('Appointment cancelled'));
    });
  }

  Future<void> _onCheckIn(
    CheckInAppointmentAction event,
    Emitter<AppointmentActionState> emit,
  ) async {
    emit(AppointmentActionInProgress());
    final result = await checkInAppointment(
      id: event.appointment.id,
      checkedInBy: event.checkedInBy,
      photoUrl: event.photoUrl,
    );
    result.fold((failure) => emit(AppointmentActionFailure(failure.message)), (
      _,
    ) {
      notificationService.sendDirectNotification(
        userId: event.appointment.staffId,
        title: 'Visitor Arrived',
        body:
            '${event.appointment.requesterName} has checked in for your '
            '${event.appointment.appointmentTypeName} meeting.',
      );
      auditRepository.logAction(
        title: 'Appointment Checked In',
        description:
            '${event.appointment.requesterName} checked in for their appointment.',
        iconName: 'login',
        colorHex: 'FF1976D2',
        userId: event.checkedInBy,
      );
      emit(const AppointmentActionSuccess('Checked in'));
    });
  }

  Future<void> _onCheckOut(
    CheckOutAppointmentAction event,
    Emitter<AppointmentActionState> emit,
  ) async {
    emit(AppointmentActionInProgress());
    final result = await checkOutAppointment(event.appointment.id);
    result.fold((failure) => emit(AppointmentActionFailure(failure.message)), (
      _,
    ) {
      auditRepository.logAction(
        title: 'Appointment Completed',
        description:
            'Meeting between ${event.appointment.requesterName} and '
            '${event.appointment.staffName} was completed.',
        iconName: 'task_alt',
        colorHex: 'FF2E7D32',
        userId: event.appointment.staffId,
      );
      emit(const AppointmentActionSuccess('Checked out - meeting completed'));
    });
  }

  Future<void> _onAddNote(
    AddAppointmentNoteAction event,
    Emitter<AppointmentActionState> emit,
  ) async {
    emit(AppointmentActionInProgress());
    final result = await addAppointmentNote(event.note);
    result.fold((failure) => emit(AppointmentActionFailure(failure.message)), (
      _,
    ) {
      auditRepository.logAction(
        title: 'Appointment Note Added',
        description: '${event.note.authorName} recorded meeting notes.',
        iconName: 'note_add',
        colorHex: 'FF1976D2',
        userId: event.note.authorId,
      );
      emit(const AppointmentActionSuccess('Notes saved'));
    });
  }
}
