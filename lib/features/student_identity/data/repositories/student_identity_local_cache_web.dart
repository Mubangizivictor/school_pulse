import '../../../student/domain/entities/student.dart';
import '../models/student_identity_model.dart';
import 'student_identity_local_cache.dart';

StudentIdentityLocalCache create({dynamic isar}) =>
    const StudentIdentityLocalCacheWeb();

/// No local database on web - save is a no-op, lookups always miss so
/// StudentIdentityRepositoryImpl falls through to its Firestore lookup.
class StudentIdentityLocalCacheWeb implements StudentIdentityLocalCache {
  const StudentIdentityLocalCacheWeb();

  @override
  Future<void> save({
    required Student student,
    required StudentIdentityModel identity,
  }) async {}

  @override
  Future<Student?> findByUniqueSystemId(String uniqueSystemId) async => null;
}
