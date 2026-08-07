import 'package:equatable/equatable.dart';

/// Relocated unchanged from the deleted `security/domain/entities/
/// security_entities.dart`'s `PickupAuthorization` class.
class PickupAuthorization extends Equatable {
  final String id;
  final String studentId;
  final String parentId;
  final String authorizedPersonName;
  final String phone;
  final String relationship;
  final String? photoUrl;
  final String? idDocumentUrl;
  final DateTime? expiryDate;
  final String schoolId;

  const PickupAuthorization({
    required this.id,
    required this.studentId,
    required this.parentId,
    required this.authorizedPersonName,
    required this.phone,
    required this.relationship,
    this.photoUrl,
    this.idDocumentUrl,
    this.expiryDate,
    required this.schoolId,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    parentId,
    authorizedPersonName,
    phone,
    relationship,
    photoUrl,
    idDocumentUrl,
    expiryDate,
    schoolId,
  ];
}
