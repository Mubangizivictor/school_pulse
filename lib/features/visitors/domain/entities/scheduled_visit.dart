import 'package:equatable/equatable.dart';

class ScheduledVisit extends Equatable {
  final String id;
  final String schoolId;
  final String fullName;
  final String phone;
  final String host;
  final String hostId;
  final String purpose;
  final DateTime scheduledTime;
  final bool isApproved;
  final bool isRejected;
  final bool isCheckedIn;

  const ScheduledVisit({
    required this.id,
    required this.schoolId,
    required this.fullName,
    required this.phone,
    required this.host,
    required this.hostId,
    required this.purpose,
    required this.scheduledTime,
    this.isApproved = false,
    this.isRejected = false,
    this.isCheckedIn = false,
  });

  @override
  List<Object?> get props => [id, schoolId, fullName, phone, host, hostId, purpose, scheduledTime, isApproved, isRejected, isCheckedIn];
}
