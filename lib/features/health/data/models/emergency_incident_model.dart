import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/emergency_incident.dart';

DateTime _readEmergencyDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

class EmergencyIncidentModel extends EmergencyIncident {
  const EmergencyIncidentModel({
    required super.id,
    required super.studentId,
    super.staffId,
    required super.dateTime,
    required super.incidentDetails,
    required super.firstAidGiven,
    required super.ambulanceRequired,
    super.hospitalReferral,
    required super.parentNotified,
    required super.staffInvolved,
    super.witnesses,
    required super.outcome,
    required super.recordedBy,
    super.schoolId,
  });

  factory EmergencyIncidentModel.fromJson(Map<String, dynamic> json) {
    return EmergencyIncidentModel(
      id: json['id'] as String? ?? '',
      studentId: json['studentId'] as String,
      staffId: json['staffId'] as String?,
      dateTime: _readEmergencyDateTime(json['dateTime']),
      incidentDetails: json['incidentDetails'] as String,
      firstAidGiven: json['firstAidGiven'] as String,
      ambulanceRequired: json['ambulanceRequired'] as bool? ?? false,
      hospitalReferral: json['hospitalReferral'] as String?,
      parentNotified: json['parentNotified'] as bool? ?? false,
      staffInvolved: List<String>.from(json['staffInvolved'] ?? []),
      witnesses: json['witnesses'] != null
          ? List<String>.from(json['witnesses'])
          : null,
      outcome: json['outcome'] as String,
      recordedBy: json['recordedBy'] as String? ?? '',
      schoolId: json['schoolId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'staffId': staffId,
      'dateTime': Timestamp.fromDate(dateTime),
      'incidentDetails': incidentDetails,
      'firstAidGiven': firstAidGiven,
      'ambulanceRequired': ambulanceRequired,
      'hospitalReferral': hospitalReferral,
      'parentNotified': parentNotified,
      'staffInvolved': staffInvolved,
      'witnesses': witnesses,
      'outcome': outcome,
      'recordedBy': recordedBy,
      'schoolId': schoolId,
    };
  }
}
