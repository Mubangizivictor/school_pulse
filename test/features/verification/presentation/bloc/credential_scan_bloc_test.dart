import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/gate.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/repositories/credential_reader_adapter.dart';
import 'package:school_pulse/features/verification/presentation/bloc/credential_scan_bloc.dart';
import 'package:school_pulse/features/verification/presentation/bloc/credential_scan_event.dart';
import 'package:school_pulse/features/verification/presentation/bloc/credential_scan_state.dart';

class MockCredentialReaderAdapter extends Mock
    implements CredentialReaderAdapter {}

void main() {
  late MockCredentialReaderAdapter nfcAdapter;
  late MockCredentialReaderAdapter qrAdapter;
  late StreamController<ScanCredential> nfcController;

  const gate = Gate(
    id: 'gate-1',
    name: 'Main Gate',
    type: 'Main Entrance',
    location: 'Front',
    assignedOfficerIds: [],
    operatingHours: {},
    allowedUserRoles: [],
    requiredVerificationMethods: [],
    schoolId: 'school-1',
  );

  const operatorUser = UserEntity(
    id: 'op-1',
    name: 'Gate Officer',
    email: 'officer@example.com',
    schoolId: 'school-1',
    roles: [UserRole.gatekeeper],
  );

  final verificationContext = VerificationContext(
    gate: gate,
    operatorUser: operatorUser,
    purpose: 'security.identity.verify',
    deviceId: 'device-1',
    requestedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(verificationContext);
  });

  setUp(() {
    nfcController = StreamController<ScanCredential>.broadcast();
    nfcAdapter = MockCredentialReaderAdapter();
    qrAdapter = MockCredentialReaderAdapter();

    when(() => nfcAdapter.kind).thenReturn(ScanCredentialKind.nfc);
    when(() => nfcAdapter.credentials).thenAnswer((_) => nfcController.stream);
    when(() => nfcAdapter.start(any())).thenAnswer((_) async {});
    when(() => nfcAdapter.stop()).thenAnswer((_) async {});

    when(() => qrAdapter.kind).thenReturn(ScanCredentialKind.qr);
    when(() => qrAdapter.credentials).thenAnswer((_) => const Stream.empty());
    when(() => qrAdapter.start(any())).thenAnswer((_) async {});
    when(() => qrAdapter.stop()).thenAnswer((_) async {});
  });

  tearDown(() => nfcController.close());

  blocTest<CredentialScanBloc, CredentialScanState>(
    'starts the matching adapter and marks isScanning true',
    build: () => CredentialScanBloc(
      adapters: {
        ScanCredentialKind.nfc: nfcAdapter,
        ScanCredentialKind.qr: qrAdapter,
      },
    ),
    act: (bloc) => bloc.add(
      StartCredentialScan(
        kind: ScanCredentialKind.nfc,
        context: verificationContext,
      ),
    ),
    expect: () => [
      isA<CredentialScanState>().having(
        (s) => s.isScanning,
        'isScanning',
        true,
      ),
    ],
    verify: (_) {
      verify(() => nfcAdapter.start(verificationContext)).called(1);
      verifyNever(() => qrAdapter.start(any()));
    },
  );

  blocTest<CredentialScanBloc, CredentialScanState>(
    'forwards a credential emitted by the active adapter into state.lastCredential',
    build: () =>
        CredentialScanBloc(adapters: {ScanCredentialKind.nfc: nfcAdapter}),
    act: (bloc) async {
      bloc.add(
        StartCredentialScan(
          kind: ScanCredentialKind.nfc,
          context: verificationContext,
        ),
      );
      await Future.delayed(Duration.zero);
      nfcController.add(
        NfcScanCredential(cardUid: 'UID123', scannedAt: DateTime.now()),
      );
    },
    skip: 1,
    expect: () => [
      isA<CredentialScanState>().having(
        (s) => s.lastCredential,
        'lastCredential',
        isA<NfcScanCredential>(),
      ),
    ],
  );

  blocTest<CredentialScanBloc, CredentialScanState>(
    'stopping fully resets state - isScanning, activeKind, and lastCredential all clear',
    build: () =>
        CredentialScanBloc(adapters: {ScanCredentialKind.nfc: nfcAdapter}),
    act: (bloc) async {
      bloc.add(
        StartCredentialScan(
          kind: ScanCredentialKind.nfc,
          context: verificationContext,
        ),
      );
      await Future.delayed(Duration.zero);
      nfcController.add(
        NfcScanCredential(cardUid: 'UID123', scannedAt: DateTime.now()),
      );
      await Future.delayed(Duration.zero);
      bloc.add(const StopCredentialScan());
    },
    skip: 2,
    expect: () => [const CredentialScanState.initial()],
    verify: (_) {
      verify(() => nfcAdapter.stop()).called(1);
    },
  );
}
