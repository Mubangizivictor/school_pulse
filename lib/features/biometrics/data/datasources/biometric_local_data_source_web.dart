import '../../domain/entities/biometric_template.dart';
import 'biometric_local_data_source.dart';

BiometricLocalDataSource create({dynamic isar, dynamic remote}) =>
    const BiometricLocalDataSourceWeb();

/// No local database and no fingerprint sensor on web - always misses so
/// BiometricRepositoryImpl falls through to its existing
/// BiometricRemoteDataSource fallback, and every write there is
/// immediately durable, so nothing is ever "pending".
class BiometricLocalDataSourceWeb implements BiometricLocalDataSource {
  const BiometricLocalDataSourceWeb();

  @override
  Future<void> saveTemplate(BiometricTemplate template) async {}

  @override
  Future<BiometricTemplate?> getTemplate(String personId) async => null;

  @override
  Future<List<BiometricTemplate>> getPendingSyncTemplates() async => [];

  @override
  Future<void> markTemplateAsSynced(String personId) async {}

  @override
  Future<void> clearAllTemplates() async {}
}
