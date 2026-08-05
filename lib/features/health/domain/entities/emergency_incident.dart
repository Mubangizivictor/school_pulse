import 'package:equatable/equatable.dart';

class EmergencyIncident extends Equatable {
  final String id;
  final String studentId;
  final String? staffId;
  final DateTime dateTime;
  final String incidentDetails;
  final String firstAidGiven;
  final bool ambulanceRequired;
  final String? hospitalReferral;
  final bool parentNotified;
  final List<String> staffInvolved;
  final List<String>? witnesses;
  final String outcome;
  final String recordedBy;
  final String? schoolId;

  const EmergencyIncident({
    required this.id,
    required this.studentId,
    this.staffId,
    required this.dateTime,
    required this.incidentDetails,
    required this.firstAidGiven,
    required this.ambulanceRequired,
    this.hospitalReferral,
    required this.parentNotified,
    required this.staffInvolved,
    this.witnesses,
    required this.outcome,
    required this.recordedBy,
    this.schoolId,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    staffId,
    dateTime,
    incidentDetails,
    firstAidGiven,
    ambulanceRequired,
    hospitalReferral,
    parentNotified,
    staffInvolved,
    witnesses,
    outcome,
    recordedBy,
    schoolId,
  ];
}
