import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/biometrics/domain/usecases/biometric_usecases.dart';
import 'biometrics_event.dart';
import 'biometrics_state.dart';

class BiometricsBloc extends Bloc<BiometricsEvent, BiometricsState> {
  final GetBiometricSettings getBiometricSettings;
  final UpdateBiometricSettings updateBiometricSettings;
  final EnrollFingerprint enrollFingerprint;
  final VerifyFingerprint verifyFingerprint;
  final GetAuditLogs getAuditLogs;
  final SyncBiometrics syncBiometrics;

  BiometricsBloc({
    required this.getBiometricSettings,
    required this.updateBiometricSettings,
    required this.enrollFingerprint,
    required this.verifyFingerprint,
    required this.getAuditLogs,
    required this.syncBiometrics,
  }) : super(BiometricsInitial()) {
    on<LoadBiometricSettings>((event, emit) async {
      emit(BiometricsLoading());
      try {
        final settings = await getBiometricSettings(event.schoolId);
        emit(BiometricsSettingsLoaded(settings));
      } catch (e) {
        emit(BiometricOperationFailure(e.toString()));
      }
    });

    on<UpdateBiometricSettingsEvent>((event, emit) async {
      emit(BiometricsLoading());
      try {
        await updateBiometricSettings(event.schoolId, event.settings);
        emit(BiometricOperationSuccess('Settings updated successfully'));
        add(LoadBiometricSettings(event.schoolId));
      } catch (e) {
        emit(BiometricOperationFailure(e.toString()));
      }
    });

    on<EnrollStudentFingerprint>((event, emit) async {
      emit(BiometricEnrollmentInProgress('Starting enrollment...'));
      try {
        await enrollFingerprint(
          schoolId: event.schoolId,
          personId: event.studentId,
          personType: 'student',
          deviceId: event.deviceId,
          operatorId: event.operatorId,
        );
        emit(BiometricOperationSuccess('Fingerprint enrolled successfully'));
      } catch (e) {
        emit(BiometricOperationFailure(e.toString()));
      }
    });

    on<VerifyStudentFingerprint>((event, emit) async {
      emit(BiometricsLoading());
      try {
        final success = await verifyFingerprint(
          schoolId: event.schoolId,
          personId: event.studentId,
          deviceId: event.deviceId,
          location: event.location,
        );
        if (success) {
          emit(BiometricOperationSuccess('Verification successful'));
        } else {
          emit(BiometricOperationFailure('Verification failed'));
        }
      } catch (e) {
        emit(BiometricOperationFailure(e.toString()));
      }
    });

    on<LoadBiometricAuditLogs>((event, emit) async {
      emit(BiometricsLoading());
      await emit.forEach(
        getAuditLogs(event.schoolId, personId: event.personId),
        onData: (logs) => BiometricsAuditLogsLoaded(logs),
        onError: (error, stackTrace) =>
            BiometricOperationFailure(error.toString()),
      );
    });
  }
}
