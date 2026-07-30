import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_note.dart';
import '../../domain/entities/appointment_status.dart';

abstract class AppointmentActionEvent extends Equatable {
  const AppointmentActionEvent();

  @override
  List<Object?> get props => [];
}

class SubmitAppointmentRequestAction extends AppointmentActionEvent {
  final Appointment appointment;
  const SubmitAppointmentRequestAction(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

class RespondToAppointmentAction extends AppointmentActionEvent {
  final Appointment appointment;
  final AppointmentStatus status;
  final String respondedBy;
  final String? responseNote;
  final DateTime? proposedStart;
  final DateTime? proposedEnd;

  const RespondToAppointmentAction({
    required this.appointment,
    required this.status,
    required this.respondedBy,
    this.responseNote,
    this.proposedStart,
    this.proposedEnd,
  });

  @override
  List<Object?> get props => [appointment, status, respondedBy, responseNote, proposedStart, proposedEnd];
}

class CancelAppointmentAction extends AppointmentActionEvent {
  final Appointment appointment;
  final String cancelledBy;
  final String? reason;

  const CancelAppointmentAction({required this.appointment, required this.cancelledBy, this.reason});

  @override
  List<Object?> get props => [appointment, cancelledBy, reason];
}

class CheckInAppointmentAction extends AppointmentActionEvent {
  final Appointment appointment;
  final String checkedInBy;
  final String? photoUrl;

  const CheckInAppointmentAction({required this.appointment, required this.checkedInBy, this.photoUrl});

  @override
  List<Object?> get props => [appointment, checkedInBy, photoUrl];
}

class CheckOutAppointmentAction extends AppointmentActionEvent {
  final Appointment appointment;
  const CheckOutAppointmentAction(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

class AddAppointmentNoteAction extends AppointmentActionEvent {
  final AppointmentNote note;
  const AddAppointmentNoteAction(this.note);

  @override
  List<Object?> get props => [note];
}

class ResetAppointmentActionState extends AppointmentActionEvent {
  const ResetAppointmentActionState();
}
