import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/appointment_note.dart';

class AppointmentNoteModel extends AppointmentNote {
  const AppointmentNoteModel({
    required super.id,
    required super.appointmentId,
    required super.authorId,
    required super.authorName,
    required super.summary,
    super.actionItems,
    super.followUpRequired,
    super.nextAppointmentSuggested,
    super.privateRemarks,
    required super.createdAt,
  });

  factory AppointmentNoteModel.fromEntity(AppointmentNote n) {
    return AppointmentNoteModel(
      id: n.id,
      appointmentId: n.appointmentId,
      authorId: n.authorId,
      authorName: n.authorName,
      summary: n.summary,
      actionItems: n.actionItems,
      followUpRequired: n.followUpRequired,
      nextAppointmentSuggested: n.nextAppointmentSuggested,
      privateRemarks: n.privateRemarks,
      createdAt: n.createdAt,
    );
  }

  factory AppointmentNoteModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentNoteModel(
      id: id,
      appointmentId: map['appointmentId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      summary: map['summary'] ?? '',
      actionItems: map['actionItems'],
      followUpRequired: map['followUpRequired'] ?? false,
      nextAppointmentSuggested: map['nextAppointmentSuggested'],
      privateRemarks: map['privateRemarks'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'authorId': authorId,
      'authorName': authorName,
      'summary': summary,
      'actionItems': actionItems,
      'followUpRequired': followUpRequired,
      'nextAppointmentSuggested': nextAppointmentSuggested,
      'privateRemarks': privateRemarks,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
