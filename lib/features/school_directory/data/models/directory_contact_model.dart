import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/school_directory/domain/entities/directory_contact_entity.dart';

class DirectoryContactModel extends DirectoryContactEntity {
  const DirectoryContactModel({
    required super.uid,
    required super.name,
    required super.role,
    super.roles,
    required super.schoolId,
    super.isActive,
    super.phone,
  });

  factory DirectoryContactModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DirectoryContactModel(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      role: data['role'] as String? ?? '',
      roles: List<String>.from(data['roles'] ?? const []),
      schoolId: data['schoolId'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      phone: data['phone'] as String?,
    );
  }
}
