import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'appointment_status.dart';
import 'appointment_type.dart';

/// A single booked (or requested) meeting. Kept free of confidential
/// content - meeting outcomes and private staff remarks live in
/// [AppointmentNote] instead, in a subcollection parents can never read.
/// See firestore.rules `meeting_appointments/{id}/private_notes`.
class Appointment extends Equatable {
  final String id;
  final String schoolId;
  final String appointmentTypeId;
  final String appointmentTypeName;
  final String department;
  final AppointmentCategory category;
  final String requesterId;
  final String requesterName;
  final UserRole requesterRole;
  final String? studentId;
  final String? studentName;
  final String staffId;
  final String staffName;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final String reason;
  final String? attachmentUrl;
  final AppointmentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? respondedBy;
  final String? responseNote;
  final DateTime? proposedStart;
  final DateTime? checkInTime;
  final String? checkInBy;
  final String? checkInPhotoUrl;
  final DateTime? checkOutTime;

  const Appointment({
    required this.id,
    required this.schoolId,
    required this.appointmentTypeId,
    required this.appointmentTypeName,
    required this.department,
    this.category = AppointmentCategory.parentStaff,
    required this.requesterId,
    required this.requesterName,
    required this.requesterRole,
    this.studentId,
    this.studentName,
    required this.staffId,
    required this.staffName,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.reason,
    this.attachmentUrl,
    this.status = AppointmentStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.respondedBy,
    this.responseNote,
    this.proposedStart,
    this.checkInTime,
    this.checkInBy,
    this.checkInPhotoUrl,
    this.checkOutTime,
  });

  int get durationMinutes => scheduledEnd.difference(scheduledStart).inMinutes;

  Appointment copyWith({
    String? id,
    String? schoolId,
    String? appointmentTypeId,
    String? appointmentTypeName,
    String? department,
    AppointmentCategory? category,
    String? requesterId,
    String? requesterName,
    UserRole? requesterRole,
    String? studentId,
    String? studentName,
    String? staffId,
    String? staffName,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    String? reason,
    String? attachmentUrl,
    AppointmentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? respondedBy,
    String? responseNote,
    DateTime? proposedStart,
    DateTime? checkInTime,
    String? checkInBy,
    String? checkInPhotoUrl,
    DateTime? checkOutTime,
  }) {
    return Appointment(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      appointmentTypeId: appointmentTypeId ?? this.appointmentTypeId,
      appointmentTypeName: appointmentTypeName ?? this.appointmentTypeName,
      department: department ?? this.department,
      category: category ?? this.category,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      requesterRole: requesterRole ?? this.requesterRole,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      reason: reason ?? this.reason,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      respondedBy: respondedBy ?? this.respondedBy,
      responseNote: responseNote ?? this.responseNote,
      proposedStart: proposedStart ?? this.proposedStart,
      checkInTime: checkInTime ?? this.checkInTime,
      checkInBy: checkInBy ?? this.checkInBy,
      checkInPhotoUrl: checkInPhotoUrl ?? this.checkInPhotoUrl,
      checkOutTime: checkOutTime ?? this.checkOutTime,
    );
  }

  @override
  List<Object?> get props => [
        id,
        schoolId,
        appointmentTypeId,
        appointmentTypeName,
        department,
        category,
        requesterId,
        requesterName,
        requesterRole,
        studentId,
        studentName,
        staffId,
        staffName,
        scheduledStart,
        scheduledEnd,
        reason,
        attachmentUrl,
        status,
        createdAt,
        updatedAt,
        respondedBy,
        responseNote,
        proposedStart,
        checkInTime,
        checkInBy,
        checkInPhotoUrl,
        checkOutTime,
      ];
}
