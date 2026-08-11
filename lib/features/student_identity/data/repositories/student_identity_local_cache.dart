import '../../../student/domain/entities/student.dart';
import '../models/student_identity_model.dart';

/// No Isar/isar-model import here on purpose - see
/// student_identity_local_cache_mobile.dart for why. Mobile and web/stub
/// implementations are selected at compile time via
/// student_identity_local_cache_factory.dart's conditional import.
///
/// Both methods are best-effort local caching for offline QR/NFC
/// verification lookups - not a source of truth. On web there is no local
/// database, so `save` is a no-op and `findByUniqueSystemId` always misses,
/// leaving `StudentIdentityRepositoryImpl` to fall through to its existing
/// Firestore lookup.
abstract class StudentIdentityLocalCache {
  Future<void> save({
    required Student student,
    required StudentIdentityModel identity,
  });

  Future<Student?> findByUniqueSystemId(String uniqueSystemId);
}
