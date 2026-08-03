import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/admin/domain/entities/role_permission_override.dart';
import 'package:school_pulse/features/admin/domain/repositories/role_permission_override_repository.dart';

class RolePermissionOverrideRepositoryImpl implements RolePermissionOverrideRepository {
  final FirebaseFirestore firestore;

  RolePermissionOverrideRepositoryImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> _collection(String schoolId) =>
      firestore.collection('schools').doc(schoolId).collection('role_permission_overrides');

  @override
  Future<Either<Failure, Map<UserRole, RolePermissionOverride>>> getOverrides(String schoolId) async {
    try {
      final snap = await _collection(schoolId).get();
      final result = <UserRole, RolePermissionOverride>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        final role = UserRole.values.where((r) => r.name == data['role']).firstOrNull;
        if (role == null) continue;
        result[role] = RolePermissionOverride(
          role: role,
          permissions: Set<String>.from(data['permissions'] as List? ?? const []),
          updatedBy: data['updatedBy'] as String? ?? '',
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveOverride({
    required String schoolId,
    required UserRole role,
    required Set<String> permissions,
    required String updatedBy,
  }) async {
    try {
      await _collection(schoolId).doc(role.name).set({
        'role': role.name,
        'permissions': permissions.toList(),
        'updatedBy': updatedBy,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
