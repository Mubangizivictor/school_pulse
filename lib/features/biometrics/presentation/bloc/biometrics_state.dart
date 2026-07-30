import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/biometrics/domain/entities/biometric_audit_log.dart';
import 'package:school_pulse/features/biometrics/domain/entities/biometric_settings.dart';

abstract class BiometricsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BiometricsInitial extends BiometricsState {}

class BiometricsLoading extends BiometricsState {}

class BiometricsSettingsLoaded extends BiometricsState {
  final BiometricSettings settings;
  BiometricsSettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class BiometricsAuditLogsLoaded extends BiometricsState {
  final List<BiometricAuditLog> logs;
  BiometricsAuditLogsLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

class BiometricOperationSuccess extends BiometricsState {
  final String message;
  BiometricOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class BiometricOperationFailure extends BiometricsState {
  final String message;
  BiometricOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class BiometricEnrollmentInProgress extends BiometricsState {
  final String step; // e.g., "Place finger on scanner", "Capture 2/3"
  BiometricEnrollmentInProgress(this.step);

  @override
  List<Object?> get props => [step];
}
