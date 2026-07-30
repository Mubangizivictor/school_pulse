import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'package:school_pulse/features/security/domain/usecases/security_usecases.dart';
import 'package:school_pulse/features/verification/domain/entities/resolved_identity.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_decision.dart';
import 'package:school_pulse/features/verification/domain/repositories/identity_resolver.dart';
import 'package:school_pulse/features/verification/domain/repositories/verification_event_recorder.dart';
import 'package:school_pulse/features/verification/domain/repositories/verification_policy_evaluator.dart';
import 'package:school_pulse/features/verification/domain/services/verification_feedback_service.dart';
import 'package:school_pulse/features/verification/presentation/bloc/credential_scan_bloc.dart';
import 'package:school_pulse/features/verification/presentation/bloc/verification_session_bloc.dart';
import 'package:school_pulse/features/verification/presentation/widgets/verification_scan_screen.dart';
import 'package:school_pulse/injection_container.dart' as di;

class MockIdentityResolver extends Mock implements IdentityResolver {}

class MockVerificationPolicyEvaluator extends Mock implements VerificationPolicyEvaluator {}

class MockVerificationEventRecorder extends Mock implements VerificationEventRecorder {}

class MockVerificationFeedbackService extends Mock implements VerificationFeedbackService {}

class MockRecordStudentMovement extends Mock implements RecordStudentMovement {}

class MockRecordStaffMovement extends Mock implements RecordStaffMovement {}

void main() {
  late MockIdentityResolver identityResolver;
  late MockVerificationPolicyEvaluator policyEvaluator;
  late MockVerificationEventRecorder eventRecorder;
  late MockVerificationFeedbackService feedbackService;
  late MockRecordStudentMovement recordStudentMovement;
  late MockRecordStaffMovement recordStaffMovement;

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

  final credential = QrScanCredential(rawPayload: 'SP-0001', scannedAt: DateTime.now());

  const student = StudentResolvedIdentity(
    id: 'student-1',
    name: 'Jane Student',
    studentCode: 'SP-0001',
    classId: 'class-1',
  );

  setUpAll(() {
    registerFallbackValue(credential);
    registerFallbackValue(verificationContext);
    registerFallbackValue(student);
    registerFallbackValue(
      const VerificationDecision(outcome: VerificationOutcome.allowed, identity: student, message: ''),
    );
    registerFallbackValue(StudentMovement(
      id: 'fallback',
      studentId: 'fallback',
      studentName: 'fallback',
      className: 'fallback',
      timestamp: DateTime.now(),
      gateId: 'fallback',
      direction: 'In',
      movementType: 'Arrival',
      verificationMethod: 'fallback',
      officerId: 'fallback',
      deviceId: 'fallback',
      schoolId: 'fallback',
    ));
  });

  setUp(() {
    identityResolver = MockIdentityResolver();
    policyEvaluator = MockVerificationPolicyEvaluator();
    eventRecorder = MockVerificationEventRecorder();
    feedbackService = MockVerificationFeedbackService();
    recordStudentMovement = MockRecordStudentMovement();
    recordStaffMovement = MockRecordStaffMovement();

    when(() => feedbackService.playApproved()).thenAnswer((_) async {});
    when(() => feedbackService.playDenied()).thenAnswer((_) async {});
    when(() => feedbackService.playDuplicate()).thenAnswer((_) async {});
    when(() => feedbackService.playError()).thenAnswer((_) async {});
    when(() => recordStudentMovement(any())).thenAnswer((_) async => const Right(null));
    when(() => eventRecorder.record(
          decision: any(named: 'decision'),
          context: any(named: 'context'),
          credential: any(named: 'credential'),
          direction: any(named: 'direction'),
        )).thenAnswer((_) async => const Right(null));

    di.sl.registerFactory(
      () => VerificationSessionBloc(
        identityResolver: identityResolver,
        policyEvaluator: policyEvaluator,
        eventRecorder: eventRecorder,
        feedbackService: feedbackService,
        recordStudentMovement: recordStudentMovement,
        recordStaffMovement: recordStaffMovement,
      ),
    );
    di.sl.registerFactory(() => CredentialScanBloc(adapters: const {}));
  });

  tearDown(() async {
    await di.sl.reset();
  });

  testWidgets('shows the green VERIFIED screen with direction buttons on an allowed outcome', (tester) async {
    when(() => identityResolver.resolve(any(), any())).thenAnswer((_) async => const Right(student));
    when(() => policyEvaluator.evaluate(identity: any(named: 'identity'), context: any(named: 'context')))
        .thenAnswer((_) async => const Right(VerificationDecision(
              outcome: VerificationOutcome.allowed,
              identity: student,
              message: 'Identity verified.',
              suggestedDirection: 'In',
            )));

    await tester.pumpWidget(MaterialApp(
      home: VerificationScanScreen(context: verificationContext, initialCredential: credential),
    ));
    await tester.pumpAndSettle();

    expect(find.text('VERIFIED'), findsOneWidget);
    expect(find.textContaining('Jane Student'), findsOneWidget);
    expect(find.text('Confirm In (suggested)'), findsOneWidget);
    expect(find.text('Confirm Out'), findsOneWidget);
  });

  testWidgets('shows the red DENIED screen with a Done button on a denied outcome', (tester) async {
    when(() => identityResolver.resolve(any(), any())).thenAnswer((_) async => const Right(student));
    when(() => policyEvaluator.evaluate(identity: any(named: 'identity'), context: any(named: 'context')))
        .thenAnswer((_) async => const Right(VerificationDecision(
              outcome: VerificationOutcome.denied,
              identity: student,
              message: 'You are not authorized to verify identities at this gate.',
              reasonCode: 'NOT_AUTHORIZED',
            )));

    await tester.pumpWidget(MaterialApp(
      home: VerificationScanScreen(context: verificationContext, initialCredential: credential),
    ));
    await tester.pumpAndSettle();

    expect(find.text('DENIED'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Confirm In'), findsNothing);
  });

  testWidgets('confirming a direction on an allowed outcome records the movement and shows ENTRY RECORDED', (tester) async {
    when(() => identityResolver.resolve(any(), any())).thenAnswer((_) async => const Right(student));
    when(() => policyEvaluator.evaluate(identity: any(named: 'identity'), context: any(named: 'context')))
        .thenAnswer((_) async => const Right(VerificationDecision(
              outcome: VerificationOutcome.allowed,
              identity: student,
              message: 'Identity verified.',
              suggestedDirection: 'In',
            )));

    await tester.pumpWidget(MaterialApp(
      home: VerificationScanScreen(context: verificationContext, initialCredential: credential),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm In (suggested)'));
    await tester.pumpAndSettle();

    expect(find.text('ENTRY RECORDED'), findsOneWidget);
    verify(() => recordStudentMovement(any(that: isA<StudentMovement>()))).called(1);
  });

  testWidgets('shows a generic error screen with a Done button when resolution fails', (tester) async {
    when(() => identityResolver.resolve(any(), any())).thenAnswer(
      (_) async => const Left(CacheFailure('offline, no cached data')),
    );

    await tester.pumpWidget(MaterialApp(
      home: VerificationScanScreen(context: verificationContext, initialCredential: credential),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });
}
