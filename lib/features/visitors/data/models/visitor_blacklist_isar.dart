import 'package:isar/isar.dart';
import '../../domain/entities/visitor_blacklist.dart';

part 'visitor_blacklist_isar.g.dart';

@collection
class VisitorBlacklistIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String blacklistId;

  @Index()
  late String schoolId;

  late String visitorId;
  late String fullName;
  late String phone;
  late String reason;
  late DateTime dateAdded;
  late String addedBy;

  VisitorBlacklistIsar();

  factory VisitorBlacklistIsar.fromEntity(VisitorBlacklist entity) {
    return VisitorBlacklistIsar()
      ..blacklistId = entity.id
      ..schoolId = entity.schoolId
      ..visitorId = entity.visitorId
      ..fullName = entity.fullName
      ..phone = entity.phone
      ..reason = entity.reason
      ..dateAdded = entity.dateAdded
      ..addedBy = entity.addedBy;
  }

  VisitorBlacklist toEntity() {
    return VisitorBlacklist(
      id: blacklistId,
      schoolId: schoolId,
      visitorId: visitorId,
      fullName: fullName,
      phone: phone,
      reason: reason,
      dateAdded: dateAdded,
      addedBy: addedBy,
    );
  }
}
