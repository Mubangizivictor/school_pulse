import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
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
import 'package:school_pulse/features/verification/presentation/bloc/verification_session_bloc.dart';
import 'package:school_pulse/features/verification/presentation/bloc/verification_session_event.dart';
import 'package:school_pulse/features/verification/presentation/bloc/verification_session_state.dart';

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

  final context = VerificationContext(
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

  VerificationSessionBloc buildBloc() => VerificationSessionBloc(
        identityResolver: identityResolver,
        policyEvaluator: policyEvaluator,
        eventRecorder: eventRecorder,
        feedbackService: feedbackService,
        recordStudentMovement: recordStudentMovement,
        recordStaffMovement: recordStaffMovement,
      );

  setUpAll(() {
    registerFallbackValue(credential);
    registerFallbackValue(context);
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
  });

  blocTest<VerificationSessionBloc, VerificationSessionState>(
    'emits Resolving then Decided(allowed) on a successful, permitted scan',
    build: () {
      when(() => identityResolver.resolve(any(), any())).thenAnswer((_) async => const Right(student));
      when(() => policyEvaluator.evaluate(identity: any(named: 'identity'), context: any(named: 'context')))
          .thenAnswer((_) async => const Right(VerificationDecision(
                outcome: VerificationOutcome.allowed,
                identity: student,
                message: 'Identity verified.',
                suggestedDirection: 'In',
              )));
      return buildBloc();
    },
    act: (bloc) => bloc.add(VerificationCredentialCaptured(credential: credential, context: context)),
    expect: () => [
      const VerificationResolving(),
      isA<VerificationDecided>().having((s) => s.decision.outcome, 'outcome', VerificationOutcome.allowed),
    ],
    verify: (_) {
      verify(() => feedbackService.playApproved()).called(1);
    },
  );

  blocTest<VerificationSessionBloc, VerificationSessionState>(
    'emits Decided(denied) and plays the denied sound when policy rejects the identity',
    build: () {
      when(() => identityResolver.resolve(any(), any())).thenAnswer((_) async => const Right(student));
      when(() => policyEvaluator.evaluate(identity: any(named: 'identity'), context: any(named: 'context')))
          .thenAnswer((_) async => const Right(VerificationDecision(
                outcome: VerificationOutcome.denied,
                identity: student,
                message: 'Not authorized.',
                reasonCode: 'NOT_AUTHORIZED',
              )));
      return buildBloc();
    },
    act: (bloc) => bloc.add(VerificationCredentialCaptured(credential: credential, context: context)),
    expect: () => [
      const VerificationResolving(),
      isA<VerificationDecided>().having((s) => s.decision.outcome, 'outcome', VerificationOutcome.denied),
    ],
    verify: (_) {
      verify(() => feedbackService.playDenied()).called(1);
      verifyNever(() => recordStudentMovement(any()));
    },
  );

  blocTest<VerificationSessionBloc, VerificationSessionState>(
    'records the student movement and the audit event once the operator confirms a direction',
    build: () {
      when(() => identityResolver.resolve(any(), any())).thenAnswer((_) async => const Right(student));
      when(() => policyEvaluator.evaluate(identity: any(named: 'identity'), context: any(named: 'context')))
          .thenAnswer((_) async => const Right(VerificationDecision(
                outcome: VerificationOutcome.allowed,
                identity: student,
                message: 'Identity verified.',
                suggestedDirection: 'In',
              )));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(VerificationCredentialCaptured(credential: credential, context: context));
      await Future.delayed(Duration.zero);
      bloc.add(const VerificationDirectionConfirmed('In'));
    },
    skip: 2,
    expect: () => [
      const VerificationRecording(),
      isA<VerificationRecorded>().having((s) => s.direction, 'direction', 'In'),
    ],
    verify: (_) {
      verify(() => recordStudentMovement(any(that: isA<StudentMovement>()))).called(1);
      verify(() => eventRecorder.record(
            decision: any(named: 'decision'),
            context: any(named: 'context'),
            credential: any(named: 'credential'),
            direction: 'In',
          )).called(1);
    },
  );

  blocTest<VerificationSessionBloc, VerificationSessionState>(
    'surfaces an error instead of a false "recorded" success when the movement write itself fails',
    build: () {
      when(() => identityResolver.resolve(any(), any())).thenAnswer((_) async => const Right(student));
      when(() => policyEvaluator.evaluate(identity: any(named: 'identity'), context: any(named: 'context')))
          .thenAnswer((_) async => const Right(VerificationDecision(
                outcome: VerificationOutcome.allowed,
                identity: student,
                message: 'Identity verified.',
                suggestedDirection: 'In',
              )));
      when(() => recordStudentMovement(any())).thenAnswer((_) async => const Left(ServerFailure('write failed')));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(VerificationCredentialCaptured(credential: credential, context: context));
      await Future.delayed(Duration.zero);
      bloc.add(const VerificationDirectionConfirmed('In'));
    },
    skip: 2,
    expect: () => [
      const VerificationRecording(),
      isA<VerificationSessionError>(),
    ],
    verify: (_) {
      verifyNever(() => eventRecorder.record(
            decision: any(named: 'decision'),
            context: any(named: 'context'),
            credential: any(named: 'credential'),
            direction: any(named: 'direction'),
          ));
    },
  );

  blocTest<VerificationSessionBloc, VerificationSessionState>(
    'emits an error state and plays the error sound when the resolver fails',
    build: () {
      when(() => identityResolver.resolve(any(), any()))
          .thenAnswer((_) async => const Left(CacheFailure('offline')));
      return buildBloc();
    },
    act: (bloc) => bloc.add(VerificationCredentialCaptured(credential: credential, context: context)),
    expect: () => [
      const VerificationResolving(),
      isA<VerificationSessionError>(),
    ],
    verify: (_) {
      verify(() => feedbackService.playError()).called(1);
    },
  );
}
