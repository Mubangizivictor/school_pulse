import 'package:school_pulse/features/biometrics/domain/entities/biometric_audit_log.dart';
import 'package:school_pulse/features/biometrics/domain/entities/biometric_settings.dart';
import 'package:school_pulse/features/biometrics/domain/repositories/biometric_repository.dart';
import 'package:school_pulse/features/biometrics/domain/repositories/biometric_device_service.dart';

class GetBiometricSettings {
  final BiometricRepository repository;
  GetBiometricSettings(this.repository);

  Future<BiometricSettings> call(String schoolId) async {
    return await repository.getSettings(schoolId);
  }
}

class UpdateBiometricSettings {
  final BiometricRepository repository;
  UpdateBiometricSettings(this.repository);

  Future<void> call(String schoolId, BiometricSettings settings) async {
    await repository.updateSettings(schoolId, settings);
  }
}

class EnrollFingerprint {
  final BiometricRepository repository;
  final BiometricDeviceService deviceService;

  EnrollFingerprint(this.repository, this.deviceService);

  Future<void> call({
    required String schoolId,
    required String personId,
    required String personType,
    required String deviceId,
    required String operatorId,
  }) async {
    final template = await deviceService.captureTemplate();
    if (template != null) {
      await repository.saveBiometricTemplate(
        schoolId: schoolId,
        personId: personId,
        personType: personType,
        template: template,
        deviceId: deviceId,
        operatorId: operatorId,
      );
    } else {
      throw Exception('Failed to capture fingerprint template');
    }
  }
}

class VerifyFingerprint {
  final BiometricRepository repository;
  final BiometricDeviceService deviceService;

  VerifyFingerprint(this.repository, this.deviceService);

  Future<bool> call({
    required String schoolId,
    required String personId,
    required String deviceId,
    String? operatorId,
    String? location,
  }) async {
    final storedTemplate = await repository.getBiometricTemplate(schoolId, personId);
    if (storedTemplate == null) {
      return false;
    }

    final isValid = await deviceService.verify(storedTemplate);
    
    await repository.logEvent(BiometricAuditLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      schoolId: schoolId,
      personId: personId,
      deviceId: deviceId,
      operatorId: operatorId,
      eventType: isValid ? BiometricEventType.verificationSuccess : BiometricEventType.verificationFailed,
      timestamp: DateTime.now(),
      location: location,
    ));

    return isValid;
  }
}

class GetAuditLogs {
  final BiometricRepository repository;
  GetAuditLogs(this.repository);

  Stream<List<BiometricAuditLog>> call(String schoolId, {String? personId}) {
    return repository.getAuditLogs(schoolId, personId: personId);
  }
}

class SyncBiometrics {
  final BiometricRepository repository;
  SyncBiometrics(this.repository);

  Future<void> call() async {
    await repository.syncOfflineData();
  }
}
