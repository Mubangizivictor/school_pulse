import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/biometrics/domain/entities/biometric_settings.dart';

abstract class BiometricsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBiometricSettings extends BiometricsEvent {
  final String schoolId;
  LoadBiometricSettings(this.schoolId);

  @override
  List<Object?> get props => [schoolId];
}

class UpdateBiometricSettingsEvent extends BiometricsEvent {
  final String schoolId;
  final BiometricSettings settings;
  UpdateBiometricSettingsEvent(this.schoolId, this.settings);

  @override
  List<Object?> get props => [schoolId, settings];
}

class EnrollStudentFingerprint extends BiometricsEvent {
  final String schoolId;
  final String studentId;
  final String deviceId;
  final String operatorId;

  EnrollStudentFingerprint({
    required this.schoolId,
    required this.studentId,
    required this.deviceId,
    required this.operatorId,
  });

  @override
  List<Object?> get props => [schoolId, studentId, deviceId, operatorId];
}

class VerifyStudentFingerprint extends BiometricsEvent {
  final String schoolId;
  final String studentId;
  final String deviceId;
  final String? location;

  VerifyStudentFingerprint({
    required this.schoolId,
    required this.studentId,
    required this.deviceId,
    this.location,
  });

  @override
  List<Object?> get props => [schoolId, studentId, deviceId, location];
}

class LoadBiometricAuditLogs extends BiometricsEvent {
  final String schoolId;
  final String? personId;

  LoadBiometricAuditLogs(this.schoolId, {this.personId});

  @override
  List<Object?> get props => [schoolId, personId];
}
