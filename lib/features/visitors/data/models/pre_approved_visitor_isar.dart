import 'package:isar/isar.dart';
import '../../domain/entities/pre_approved_visitor.dart';

part 'pre_approved_visitor_isar.g.dart';

@collection
class PreApprovedVisitorIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String preApprovedId;

  late String schoolId;
  late String fullName;
  late String phone;
  late String purpose;
  late DateTime expectedDate;
  late String host;
  late bool isUsed;

  PreApprovedVisitorIsar();

  factory PreApprovedVisitorIsar.fromEntity(PreApprovedVisitor entity) {
    return PreApprovedVisitorIsar()
      ..preApprovedId = entity.id
      ..schoolId = entity.schoolId
      ..fullName = entity.fullName
      ..phone = entity.phone
      ..purpose = entity.purpose
      ..expectedDate = entity.expectedDate
      ..host = entity.host
      ..isUsed = entity.isUsed;
  }

  PreApprovedVisitor toEntity() {
    return PreApprovedVisitor(
      id: preApprovedId,
      schoolId: schoolId,
      fullName: fullName,
      phone: phone,
      purpose: purpose,
      expectedDate: expectedDate,
      host: host,
      isUsed: isUsed,
    );
  }
}
