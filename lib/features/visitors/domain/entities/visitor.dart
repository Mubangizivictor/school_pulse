import 'package:equatable/equatable.dart';

enum VisitorStatus { checkedIn, checkedOut }

enum VisitorCategory { 
  parent, 
  vendor, 
  official, 
  contractor, 
  personal, 
  other 
}

enum ApprovalStatus { 
  pending, 
  approved, 
  rejected, 
  notRequired 
}

class Visitor extends Equatable {
  final String id;
  final String schoolId;
  final String fullName;
  final String phone;
  final String? nationalId;
  final String? gender;
  final String? vehicleNumber;
  final String? parkingSlot;
  final String? company;
  final String host;
  final String? hostId; // Link to Employee/User ID
  final String department;
  final String purpose;
  final VisitorCategory category;
  final String? expectedDuration;
  final DateTime? expectedDepartureTime;
  final String? itemsCarried;
  final String? notes;
  final DateTime arrivalTime;
  final DateTime? departureTime;
  final VisitorStatus status;
  final ApprovalStatus approvalStatus;
  final String deviceId;
  final String? gateId;
  final String? photoLocalPath;
  final String? photoUrl;
  final String? idImageLocalPath;
  final String? idImageUrl;
  final String? signatureLocalPath;
  final String? signatureUrl;
  final String? studentId; // For student pickup verification, or the child a parent visitor is linked to
  final String? scheduledVisitId;
  final bool isSynced;
  final bool isBlacklisted;
  final String badgeNumber;
  final int badgeReplacementCount;
  final bool agreementAccepted;

  const Visitor({
    required this.id,
    required this.schoolId,
    required this.fullName,
    required this.phone,
    this.nationalId,
    this.gender,
    this.vehicleNumber,
    this.parkingSlot,
    this.company,
    required this.host,
    this.hostId,
    required this.department,
    required this.purpose,
    this.category = VisitorCategory.other,
    this.expectedDuration,
    this.expectedDepartureTime,
    this.itemsCarried,
    this.notes,
    required this.arrivalTime,
    this.departureTime,
    required this.status,
    this.approvalStatus = ApprovalStatus.notRequired,
    required this.deviceId,
    this.gateId,
    this.photoLocalPath,
    this.photoUrl,
    this.idImageLocalPath,
    this.idImageUrl,
    this.signatureLocalPath,
    this.signatureUrl,
    this.studentId,
    this.scheduledVisitId,
    this.isSynced = false,
    this.isBlacklisted = false,
    this.badgeNumber = '',
    this.badgeReplacementCount = 0,
    this.agreementAccepted = false,
  });

  @override
  List<Object?> get props => [
        id,
        schoolId,
        fullName,
        phone,
        nationalId,
        gender,
        vehicleNumber,
        parkingSlot,
        company,
        host,
        hostId,
        department,
        purpose,
        category,
        expectedDuration,
        expectedDepartureTime,
        itemsCarried,
        notes,
        arrivalTime,
        departureTime,
        status,
        approvalStatus,
        deviceId,
        gateId,
        photoLocalPath,
        photoUrl,
        idImageLocalPath,
        idImageUrl,
        signatureLocalPath,
        signatureUrl,
        studentId,
        scheduledVisitId,
        isSynced,
        isBlacklisted,
        badgeNumber,
        badgeReplacementCount,
        agreementAccepted,
      ];

  Visitor copyWith({
    String? id,
    String? schoolId,
    String? fullName,
    String? phone,
    String? nationalId,
    String? gender,
    String? vehicleNumber,
    String? parkingSlot,
    String? company,
    String? host,
    String? hostId,
    String? department,
    String? purpose,
    VisitorCategory? category,
    String? expectedDuration,
    DateTime? expectedDepartureTime,
    String? itemsCarried,
    String? notes,
    DateTime? arrivalTime,
    DateTime? departureTime,
    VisitorStatus? status,
    ApprovalStatus? approvalStatus,
    String? deviceId,
    String? gateId,
    String? photoLocalPath,
    String? photoUrl,
    String? idImageLocalPath,
    String? idImageUrl,
    String? signatureLocalPath,
    String? signatureUrl,
    String? studentId,
    String? scheduledVisitId,
    bool? isSynced,
    bool? isBlacklisted,
    String? badgeNumber,
    int? badgeReplacementCount,
    bool? agreementAccepted,
  }) {
    return Visitor(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      gender: gender ?? this.gender,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      parkingSlot: parkingSlot ?? this.parkingSlot,
      company: company ?? this.company,
      host: host ?? this.host,
      hostId: hostId ?? this.hostId,
      department: department ?? this.department,
      purpose: purpose ?? this.purpose,
      category: category ?? this.category,
      expectedDuration: expectedDuration ?? this.expectedDuration,
      expectedDepartureTime: expectedDepartureTime ?? this.expectedDepartureTime,
      itemsCarried: itemsCarried ?? this.itemsCarried,
      notes: notes ?? this.notes,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureTime: departureTime ?? this.departureTime,
      status: status ?? this.status,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      deviceId: deviceId ?? this.deviceId,
      gateId: gateId ?? this.gateId,
      photoLocalPath: photoLocalPath ?? this.photoLocalPath,
      photoUrl: photoUrl ?? this.photoUrl,
      idImageLocalPath: idImageLocalPath ?? this.idImageLocalPath,
      idImageUrl: idImageUrl ?? this.idImageUrl,
      signatureLocalPath: signatureLocalPath ?? this.signatureLocalPath,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      studentId: studentId ?? this.studentId,
      scheduledVisitId: scheduledVisitId ?? this.scheduledVisitId,
      isSynced: isSynced ?? this.isSynced,
      isBlacklisted: isBlacklisted ?? this.isBlacklisted,
      badgeNumber: badgeNumber ?? this.badgeNumber,
      badgeReplacementCount: badgeReplacementCount ?? this.badgeReplacementCount,
      agreementAccepted: agreementAccepted ?? this.agreementAccepted,
    );
  }
}
