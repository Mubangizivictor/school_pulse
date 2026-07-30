import 'package:isar/isar.dart';
import '../../domain/entities/scheduled_visit.dart';

part 'scheduled_visit_isar.g.dart';

@collection
class ScheduledVisitIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String scheduledVisitId;

  late String schoolId;
  late String fullName;
  late String phone;
  late String host;
  late String hostId;
  late String purpose;
  late DateTime scheduledTime;
  late bool isApproved;
  bool isRejected = false;
  late bool isCheckedIn;

  ScheduledVisitIsar();

  factory ScheduledVisitIsar.fromEntity(ScheduledVisit entity) {
    return ScheduledVisitIsar()
      ..scheduledVisitId = entity.id
      ..schoolId = entity.schoolId
      ..fullName = entity.fullName
      ..phone = entity.phone
      ..host = entity.host
      ..hostId = entity.hostId
      ..purpose = entity.purpose
      ..scheduledTime = entity.scheduledTime
      ..isApproved = entity.isApproved
      ..isRejected = entity.isRejected
      ..isCheckedIn = entity.isCheckedIn;
  }

  ScheduledVisit toEntity() {
    return ScheduledVisit(
      id: scheduledVisitId,
      schoolId: schoolId,
      fullName: fullName,
      phone: phone,
      host: host,
      hostId: hostId,
      purpose: purpose,
      scheduledTime: scheduledTime,
      isApproved: isApproved,
      isRejected: isRejected,
      isCheckedIn: isCheckedIn,
    );
  }
}
