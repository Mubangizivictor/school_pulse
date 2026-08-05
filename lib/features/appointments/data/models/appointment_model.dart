import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/core/user_roles.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_status.dart';
import '../../domain/entities/appointment_type.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.schoolId,
    required super.appointmentTypeId,
    required super.appointmentTypeName,
    required super.department,
    super.category,
    required super.requesterId,
    required super.requesterName,
    required super.requesterRole,
    super.studentId,
    super.studentName,
    required super.staffId,
    required super.staffName,
    required super.scheduledStart,
    required super.scheduledEnd,
    required super.reason,
    super.location,
    super.campus,
    super.notes,
    super.priority,
    super.recurrence,
    super.reminderMinutes,
    super.attachmentUrls,
    super.visitorId,
    super.requiresApproval,
    super.attachmentUrl,
    super.status,
    required super.createdAt,
    required super.updatedAt,
    super.respondedBy,
    super.responseNote,
    super.proposedStart,
    super.checkInTime,
    super.checkInBy,
    super.checkInPhotoUrl,
    super.checkOutTime,
  });

  factory AppointmentModel.fromEntity(Appointment a) {
    return AppointmentModel(
      id: a.id,
      schoolId: a.schoolId,
      appointmentTypeId: a.appointmentTypeId,
      appointmentTypeName: a.appointmentTypeName,
      department: a.department,
      category: a.category,
      requesterId: a.requesterId,
      requesterName: a.requesterName,
      requesterRole: a.requesterRole,
      studentId: a.studentId,
      studentName: a.studentName,
      staffId: a.staffId,
      staffName: a.staffName,
      scheduledStart: a.scheduledStart,
      scheduledEnd: a.scheduledEnd,
      reason: a.reason,
      location: a.location,
      campus: a.campus,
      notes: a.notes,
      priority: a.priority,
      recurrence: a.recurrence,
      reminderMinutes: a.reminderMinutes,
      attachmentUrls: a.attachmentUrls,
      visitorId: a.visitorId,
      requiresApproval: a.requiresApproval,
      attachmentUrl: a.attachmentUrl,
      status: a.status,
      createdAt: a.createdAt,
      updatedAt: a.updatedAt,
      respondedBy: a.respondedBy,
      responseNote: a.responseNote,
      proposedStart: a.proposedStart,
      checkInTime: a.checkInTime,
      checkInBy: a.checkInBy,
      checkInPhotoUrl: a.checkInPhotoUrl,
      checkOutTime: a.checkOutTime,
    );
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? toDate(dynamic v) => v == null ? null : (v as Timestamp).toDate();

    return AppointmentModel(
      id: id,
      schoolId: map['schoolId'] ?? '',
      appointmentTypeId: map['appointmentTypeId'] ?? '',
      appointmentTypeName: map['appointmentTypeName'] ?? '',
      department: map['department'] ?? '',
      category: AppointmentCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => AppointmentCategory.parentStaff,
      ),
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      requesterRole: UserRole.values.firstWhere(
        (r) => r.name == map['requesterRole'],
        orElse: () => UserRole.parent,
      ),
      studentId: map['studentId'],
      studentName: map['studentName'],
      staffId: map['staffId'] ?? '',
      staffName: map['staffName'] ?? '',
      scheduledStart: toDate(map['scheduledStart'])!,
      scheduledEnd: toDate(map['scheduledEnd'])!,
      reason: map['reason'] ?? '',
      location: map['location'],
      campus: map['campus'],
      notes: map['notes'],
      priority: map['priority'] ?? 'normal',
      recurrence: map['recurrence'] ?? 'doesNotRepeat',
      reminderMinutes: ((map['reminderMinutes'] as List?) ?? const [15])
          .map((v) => v as int)
          .toList(),
      attachmentUrls: ((map['attachmentUrls'] as List?) ?? const [])
          .map((v) => v.toString())
          .toList(),
      visitorId: map['visitorId'],
      requiresApproval: map['requiresApproval'] ?? false,
      attachmentUrl: map['attachmentUrl'],
      status: AppointmentStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      createdAt: toDate(map['createdAt']) ?? DateTime.now(),
      updatedAt: toDate(map['updatedAt']) ?? DateTime.now(),
      respondedBy: map['respondedBy'],
      responseNote: map['responseNote'],
      proposedStart: toDate(map['proposedStart']),
      checkInTime: toDate(map['checkInTime']),
      checkInBy: map['checkInBy'],
      checkInPhotoUrl: map['checkInPhotoUrl'],
      checkOutTime: toDate(map['checkOutTime']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'appointmentTypeId': appointmentTypeId,
      'appointmentTypeName': appointmentTypeName,
      'department': department,
      'category': category.name,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterRole': requesterRole.name,
      'studentId': studentId,
      'studentName': studentName,
      'staffId': staffId,
      'staffName': staffName,
      'scheduledStart': Timestamp.fromDate(scheduledStart),
      'scheduledEnd': Timestamp.fromDate(scheduledEnd),
      'reason': reason,
      'location': location,
      'campus': campus,
      'notes': notes,
      'priority': priority,
      'recurrence': recurrence,
      'reminderMinutes': reminderMinutes,
      'attachmentUrls': attachmentUrls,
      'visitorId': visitorId,
      'requiresApproval': requiresApproval,
      'attachmentUrl': attachmentUrl,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'respondedBy': respondedBy,
      'responseNote': responseNote,
      'proposedStart': proposedStart != null
          ? Timestamp.fromDate(proposedStart!)
          : null,
      'checkInTime': checkInTime != null
          ? Timestamp.fromDate(checkInTime!)
          : null,
      'checkInBy': checkInBy,
      'checkInPhotoUrl': checkInPhotoUrl,
      'checkOutTime': checkOutTime != null
          ? Timestamp.fromDate(checkOutTime!)
          : null,
    };
  }
}
