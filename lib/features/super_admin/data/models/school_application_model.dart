import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/school_application.dart';

class SchoolApplicationModel extends SchoolApplication {
  const SchoolApplicationModel({
    required super.id,
    required super.authUid,
    required super.status,
    required super.schoolName,
    required super.shortName,
    required super.schoolEmail,
    required super.schoolPhone,
    required super.category,
    required super.prefix,
    required super.motto,
    required super.region,
    required super.district,
    required super.address,
    required super.website,
    required super.plan,
    required super.selectedModules,
    required super.administratorName,
    required super.administratorEmail,
    required super.administratorPhone,
    required super.administratorEmailVerified,
    required super.termsAccepted,
    super.createdAt,
    super.updatedAt,
    super.reviewedAt,
    super.reviewedBy,
    super.rejectionReason,
    super.schoolId,
    super.appReady,
  });

  factory SchoolApplicationModel.fromFirestore(
    String documentId,
    Map<String, dynamic> json,
  ) {
    final school = Map<String, dynamic>.from(json['school'] as Map? ?? const {});
    final location = Map<String, dynamic>.from(json['location'] as Map? ?? const {});
    final administrator = Map<String, dynamic>.from(
      json['administrator'] as Map? ?? const {},
    );

    final firstName = (administrator['firstName'] ?? '').toString().trim();
    final lastName = (administrator['lastName'] ?? '').toString().trim();

    return SchoolApplicationModel(
      id: (json['id'] ?? documentId).toString(),
      authUid: (json['authUid'] ?? documentId).toString(),
      status: SchoolApplicationStatusX.fromWire(json['status']?.toString()),
      schoolName: (school['name'] ?? '').toString(),
      shortName: (school['shortName'] ?? '').toString(),
      schoolEmail: (school['email'] ?? '').toString(),
      schoolPhone: (school['phone'] ?? '').toString(),
      category: (school['category'] ?? '').toString(),
      prefix: (school['prefix'] ?? '').toString(),
      motto: (school['motto'] ?? '').toString(),
      region: (location['region'] ?? '').toString(),
      district: (location['district'] ?? '').toString(),
      address: (location['address'] ?? '').toString(),
      website: (location['website'] ?? '').toString(),
      plan: (json['plan'] ?? '').toString(),
      selectedModules: List<String>.from(json['selectedModules'] as List? ?? const []),
      administratorName: '$firstName $lastName'.trim(),
      administratorEmail: (administrator['email'] ?? '').toString(),
      administratorPhone: (administrator['phone'] ?? '').toString(),
      administratorEmailVerified: administrator['emailVerified'] == true,
      termsAccepted: json['termsAccepted'] == true,
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
      reviewedAt: _date(json['reviewedAt']),
      reviewedBy: json['reviewedBy']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),
      schoolId: json['schoolId']?.toString(),
      appReady: json['appReady'] == true,
    );
  }

  static DateTime? _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
