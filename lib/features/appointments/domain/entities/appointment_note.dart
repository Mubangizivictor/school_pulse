import 'package:equatable/equatable.dart';

/// A staff-only record of what happened in a meeting - stored in the
/// `private_notes` subcollection of a `meeting_appointments` doc, which
/// Firestore rules restrict to staff reads only. Parents never see this.
class AppointmentNote extends Equatable {
  final String id;
  final String appointmentId;
  final String authorId;
  final String authorName;
  final String summary;
  final String? actionItems;
  final bool followUpRequired;
  final String? nextAppointmentSuggested;
  final String? privateRemarks;
  final DateTime createdAt;

  const AppointmentNote({
    required this.id,
    required this.appointmentId,
    required this.authorId,
    required this.authorName,
    required this.summary,
    this.actionItems,
    this.followUpRequired = false,
    this.nextAppointmentSuggested,
    this.privateRemarks,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        appointmentId,
        authorId,
        authorName,
        summary,
        actionItems,
        followUpRequired,
        nextAppointmentSuggested,
        privateRemarks,
        createdAt,
      ];
}
