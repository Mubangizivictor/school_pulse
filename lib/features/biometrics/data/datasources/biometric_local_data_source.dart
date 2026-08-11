import '../../domain/entities/biometric_template.dart';

/// No Isar/isar-model import here on purpose - see
/// biometric_local_data_source_mobile.dart for why. Mobile and web
/// implementations are selected at compile time via
/// biometric_local_data_source_factory.dart's conditional import.
///
/// Templates are stored locally for offline enrollment/verification
/// continuity on mobile, with a sync queue to BiometricRemoteDataSource.
/// Web has no fingerprint sensor and no offline queue - reads/writes go
/// straight to BiometricRemoteDataSource, and getPendingSyncTemplates
/// always returns empty since nothing is ever queued.
abstract class BiometricLocalDataSource {
  Future<void> saveTemplate(BiometricTemplate template);
  Future<BiometricTemplate?> getTemplate(String personId);
  Future<List<BiometricTemplate>> getPendingSyncTemplates();
  Future<void> markTemplateAsSynced(String personId);
  Future<void> clearAllTemplates();
}
