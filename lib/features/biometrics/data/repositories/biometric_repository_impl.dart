import 'package:school_pulse/features/biometrics/data/datasources/biometric_local_data_source.dart';
import 'package:school_pulse/features/biometrics/data/datasources/biometric_remote_data_source.dart';
import 'package:school_pulse/features/biometrics/data/models/biometric_audit_log_model.dart';
import 'package:school_pulse/features/biometrics/data/models/biometric_settings_model.dart';
import 'package:school_pulse/features/biometrics/data/models/biometric_template_isar.dart';
import 'package:school_pulse/features/biometrics/domain/entities/biometric_audit_log.dart';
import 'package:school_pulse/features/biometrics/domain/entities/biometric_device.dart';
import 'package:school_pulse/features/biometrics/domain/entities/biometric_settings.dart';
import 'package:school_pulse/features/biometrics/domain/repositories/biometric_repository.dart';

class BiometricRepositoryImpl implements BiometricRepository {
  final BiometricRemoteDataSource remoteDataSource;
  final BiometricLocalDataSource localDataSource;

  BiometricRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<BiometricSettings> getSettings(String schoolId) async {
    try {
      return await remoteDataSource.getSettings(schoolId);
    } catch (e) {
      // In a real app, we might want to cache settings locally too
      return BiometricSettings();
    }
  }

  @override
  Future<void> updateSettings(
    String schoolId,
    BiometricSettings settings,
  ) async {
    await remoteDataSource.updateSettings(
      schoolId,
      BiometricSettingsModel.fromEntity(settings),
    );
  }

  @override
  Future<void> saveBiometricTemplate({
    required String schoolId,
    required String personId,
    required String personType,
    required String template,
    required String deviceId,
    required String operatorId,
  }) async {
    // 1. Save to local storage for offline use
    final isarTemplate = BiometricTemplateIsar()
      ..personId = personId
      ..schoolId = schoolId
      ..personType = personType
      ..encryptedTemplate = template
      ..updatedAt = DateTime.now()
      ..isSynced = false;

    await localDataSource.saveTemplate(isarTemplate);

    // 2. Try to save to remote
    try {
      await remoteDataSource.saveTemplate(
        schoolId,
        personId,
        personType,
        template,
      );
      await localDataSource.markTemplateAsSynced(personId);
    } catch (e) {
      // Stay as isSynced = false
    }

    // 3. Log the enrollment event
    await logEvent(
      BiometricAuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        schoolId: schoolId,
        personId: personId,
        personType: personType,
        deviceId: deviceId,
        operatorId: operatorId,
        eventType: BiometricEventType.enrollment,
        timestamp: DateTime.now(),
        result: 'Success',
      ),
    );
  }

  @override
  Future<String?> getBiometricTemplate(String schoolId, String personId) async {
    // Check local first for speed and offline capability
    final local = await localDataSource.getTemplate(personId);
    if (local != null) return local.encryptedTemplate;

    // Fallback to remote
    try {
      final remote = await remoteDataSource.getTemplate(schoolId, personId);
      if (remote != null) {
        // Cache it locally
        await localDataSource.saveTemplate(
          BiometricTemplateIsar()
            ..personId = personId
            ..schoolId = schoolId
            ..personType =
                'unknown' // Would be better to know this
            ..encryptedTemplate = remote
            ..updatedAt = DateTime.now()
            ..isSynced = true,
        );
      }
      return remote;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logEvent(BiometricAuditLog log) async {
    try {
      await remoteDataSource.logEvent(BiometricAuditLogModel.fromEntity(log));
    } catch (e) {
      // In a production app, we should also store logs locally if offline
    }
  }

  @override
  Stream<List<BiometricAuditLog>> getAuditLogs(
    String schoolId, {
    String? personId,
  }) {
    return remoteDataSource.getAuditLogs(schoolId, personId: personId);
  }

  @override
  Future<List<BiometricDevice>> getRegisteredDevices(String schoolId) async {
    // Implement device storage in remote data source if needed,
    // for now using settings or a separate collection
    return [];
  }

  @override
  Future<void> registerDevice(String schoolId, BiometricDevice device) async {
    // Implementation for device registration
  }

  @override
  Future<void> updateDeviceStatus(
    String schoolId,
    String deviceId,
    bool isActive,
  ) async {
    // Implementation
  }

  @override
  Future<void> deleteDevice(String schoolId, String deviceId) async {
    // Implementation
  }

  @override
  Future<void> syncOfflineData() async {
    final pending = await localDataSource.getPendingSyncTemplates();
    for (var template in pending) {
      try {
        await remoteDataSource.saveTemplate(
          template.schoolId,
          template.personId,
          template.personType,
          template.encryptedTemplate,
        );
        await localDataSource.markTemplateAsSynced(template.personId);
      } catch (e) {
        // Silent fail, try next time
      }
    }
  }

  @override
  Future<int> getPendingSyncCount() async {
    final pending = await localDataSource.getPendingSyncTemplates();
    return pending.length;
  }
}
