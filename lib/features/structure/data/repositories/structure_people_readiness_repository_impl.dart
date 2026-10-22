import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/auth/data/models/user_model.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import '../../domain/repositories/structure_people_readiness_repository.dart';

class StructurePeopleReadinessRepositoryImpl
    implements StructurePeopleReadinessRepository {
  final FirebaseFirestore firestore;

  StructurePeopleReadinessRepositoryImpl({required this.firestore});

  @override
  Stream<List<UserEntity>> watchSchoolStaff(String schoolId) {
    if (schoolId.trim().isEmpty) return Stream.value(const <UserEntity>[]);
    return firestore
        .collection('users')
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map((snapshot) {
          final staff = snapshot.docs
              .map((doc) => UserModel.fromJson({...doc.data(), 'id': doc.id}))
              .where(
                (user) =>
                    !user.roles.contains(UserRole.parent) &&
                    !user.roles.contains(UserRole.student),
              )
              .toList(growable: false);
          staff.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
          return staff;
        });
  }
}
