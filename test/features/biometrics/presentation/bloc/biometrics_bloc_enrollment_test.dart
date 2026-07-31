import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/biometrics/domain/repositories/biometric_device_service.dart';
import 'package:school_pulse/features/biometrics/domain/repositories/biometric_repository.dart';
import 'package:school_pulse/features/biometrics/domain/usecases/biometric_usecases.dart';
import 'package:school_pulse/features/biometrics/presentation/bloc/biometrics_bloc.dart';
import 'package:school_pulse/features/biometrics/presentation/bloc/biometrics_event.dart';
import 'package:school_pulse/features/biometrics/presentation/bloc/biometrics_state.dart';

class MockBiometricRepository extends Mock implements BiometricRepository {}

class MockBiometricDeviceService extends Mock implements BiometricDeviceService {}

void main() {
  late BiometricsBloc bloc;
  late MockBiometricRepository repository;
  late MockBiometricDeviceService deviceService;

  const schoolId = 'school-1';
  const studentId = 'student-1';
  const deviceId = 'device-1';
  const operatorId = 'staff-1';

  setUp(() {
    repository = MockBiometricRepository();
    deviceService = MockBiometricDeviceService();
    bloc = BiometricsBloc(
      getBiometricSettings: GetBiometricSettings(repository),
      updateBiometricSettings: UpdateBiometricSettings(repository),
      enrollFingerprint: EnrollFingerprint(repository, deviceService),
      verifyFingerprint: VerifyFingerprint(repository, deviceService),
      getAuditLogs: GetAuditLogs(repository),
      syncBiometrics: SyncBiometrics(repository),
    );
  });

  tearDown(() => bloc.close());

  blocTest<BiometricsBloc, BiometricsState>(
    'captures a template via the connected device and saves it, emitting success',
    build: () {
      when(() => deviceService.captureTemplate()).thenAnswer((_) async => 'encrypted-template');
      when(() => repository.saveBiometricTemplate(
            schoolId: schoolId,
            personId: studentId,
            personType: 'student',
            template: 'encrypted-template',
            deviceId: deviceId,
            operatorId: operatorId,
          )).thenAnswer((_) async {});
      return bloc;
    },
    act: (bloc) => bloc.add(EnrollStudentFingerprint(
      schoolId: schoolId,
      studentId: studentId,
      deviceId: deviceId,
      operatorId: operatorId,
    )),
    expect: () => [
      isA<BiometricEnrollmentInProgress>(),
      isA<BiometricOperationSuccess>(),
    ],
    verify: (_) {
      verify(() => repository.saveBiometricTemplate(
            schoolId: schoolId,
            personId: studentId,
            personType: 'student',
            template: 'encrypted-template',
            deviceId: deviceId,
            operatorId: operatorId,
          )).called(1);
    },
  );

  blocTest<BiometricsBloc, BiometricsState>(
    'emits failure and never saves anything when the device fails to capture a template',
    build: () {
      when(() => deviceService.captureTemplate()).thenAnswer((_) async => null);
      return bloc;
    },
    act: (bloc) => bloc.add(EnrollStudentFingerprint(
      schoolId: schoolId,
      studentId: studentId,
      deviceId: deviceId,
      operatorId: operatorId,
    )),
    expect: () => [
      isA<BiometricEnrollmentInProgress>(),
      isA<BiometricOperationFailure>(),
    ],
    verify: (_) {
      verifyNever(() => repository.saveBiometricTemplate(
            schoolId: any(named: 'schoolId'),
            personId: any(named: 'personId'),
            personType: any(named: 'personType'),
            template: any(named: 'template'),
            deviceId: any(named: 'deviceId'),
            operatorId: any(named: 'operatorId'),
          ));
    },
  );
}
