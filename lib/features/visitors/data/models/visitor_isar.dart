import 'package:isar/isar.dart';
import '../../domain/entities/visitor.dart';

part 'visitor_isar.g.dart';

@collection
class VisitorIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String visitorId;

  late String schoolId;
  late String fullName;
  late String phone;
  String? nationalId;
  String? gender;
  String? vehicleNumber;
  String? parkingSlot;
  String? company;
  late String host;
  String? hostId;
  late String department;
  late String purpose;
  
  @enumerated
  late VisitorCategory category;
  
  String? expectedDuration;
  DateTime? expectedDepartureTime;
  String? itemsCarried;
  String? notes;
  late DateTime arrivalTime;
  DateTime? departureTime;
  
  @enumerated
  late VisitorStatus status;
  
  @enumerated
  late ApprovalStatus approvalStatus;
  
  late String deviceId;
  String? gateId;
  String? photoLocalPath;
  String? photoUrl;
  String? idImageLocalPath;
  String? idImageUrl;
  String? signatureLocalPath;
  String? signatureUrl;
  String? studentId;
  String? scheduledVisitId;
  late bool isSynced;
  late bool isBlacklisted;
  String badgeNumber = '';
  int badgeReplacementCount = 0;
  bool agreementAccepted = false;

  VisitorIsar();

  factory VisitorIsar.fromEntity(Visitor entity) {
    return VisitorIsar()
      ..visitorId = entity.id
      ..schoolId = entity.schoolId
      ..fullName = entity.fullName
      ..phone = entity.phone
      ..nationalId = entity.nationalId
      ..gender = entity.gender
      ..vehicleNumber = entity.vehicleNumber
      ..parkingSlot = entity.parkingSlot
      ..company = entity.company
      ..host = entity.host
      ..hostId = entity.hostId
      ..department = entity.department
      ..purpose = entity.purpose
      ..category = entity.category
      ..expectedDuration = entity.expectedDuration
      ..expectedDepartureTime = entity.expectedDepartureTime
      ..itemsCarried = entity.itemsCarried
      ..notes = entity.notes
      ..arrivalTime = entity.arrivalTime
      ..departureTime = entity.departureTime
      ..status = entity.status
      ..approvalStatus = entity.approvalStatus
      ..deviceId = entity.deviceId
      ..gateId = entity.gateId
      ..photoLocalPath = entity.photoLocalPath
      ..photoUrl = entity.photoUrl
      ..idImageLocalPath = entity.idImageLocalPath
      ..idImageUrl = entity.idImageUrl
      ..signatureLocalPath = entity.signatureLocalPath
      ..signatureUrl = entity.signatureUrl
      ..studentId = entity.studentId
      ..scheduledVisitId = entity.scheduledVisitId
      ..isSynced = entity.isSynced
      ..isBlacklisted = entity.isBlacklisted
      ..badgeNumber = entity.badgeNumber
      ..badgeReplacementCount = entity.badgeReplacementCount
      ..agreementAccepted = entity.agreementAccepted;
  }

  Visitor toEntity() {
    return Visitor(
      id: visitorId,
      schoolId: schoolId,
      fullName: fullName,
      phone: phone,
      nationalId: nationalId,
      gender: gender,
      vehicleNumber: vehicleNumber,
      parkingSlot: parkingSlot,
      company: company,
      host: host,
      hostId: hostId,
      department: department,
      purpose: purpose,
      category: category,
      expectedDuration: expectedDuration,
      expectedDepartureTime: expectedDepartureTime,
      itemsCarried: itemsCarried,
      notes: notes,
      arrivalTime: arrivalTime,
      departureTime: departureTime,
      status: status,
      approvalStatus: approvalStatus,
      deviceId: deviceId,
      gateId: gateId,
      photoLocalPath: photoLocalPath,
      photoUrl: photoUrl,
      idImageLocalPath: idImageLocalPath,
      idImageUrl: idImageUrl,
      signatureLocalPath: signatureLocalPath,
      signatureUrl: signatureUrl,
      studentId: studentId,
      scheduledVisitId: scheduledVisitId,
      isSynced: isSynced,
      isBlacklisted: isBlacklisted,
      badgeNumber: badgeNumber,
      badgeReplacementCount: badgeReplacementCount,
      agreementAccepted: agreementAccepted,
    );
  }
}
