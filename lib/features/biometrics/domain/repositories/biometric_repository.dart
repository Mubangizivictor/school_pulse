import 'package:school_pulse/features/biometrics/domain/entities/biometric_settings.dart';
import 'package:school_pulse/features/biometrics/domain/entities/biometric_device.dart';
import 'package:school_pulse/features/biometrics/domain/entities/biometric_audit_log.dart';

abstract class BiometricRepository {
  // Settings
  Future<BiometricSettings> getSettings(String schoolId);
  Future<void> updateSettings(String schoolId, BiometricSettings settings);

  // Enrollment
  Future<void> saveBiometricTemplate({
    required String schoolId,
    required String personId,
    required String personType,
    required String template,
    required String deviceId,
    required String operatorId,
  });

  Future<String?> getBiometricTemplate(String schoolId, String personId);

  // Verification
  Future<void> logEvent(BiometricAuditLog log);
  Stream<List<BiometricAuditLog>> getAuditLogs(String schoolId, {String? personId});

  // Device Management
  Future<List<BiometricDevice>> getRegisteredDevices(String schoolId);
  Future<void> registerDevice(String schoolId, BiometricDevice device);
  Future<void> updateDeviceStatus(String schoolId, String deviceId, bool isActive);
  Future<void> deleteDevice(String schoolId, String deviceId);

  // Offline Sync
  Future<void> syncOfflineData();
  Future<int> getPendingSyncCount();
}
