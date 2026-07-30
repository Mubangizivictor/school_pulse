import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'package:school_pulse/features/security/domain/usecases/security_usecases.dart';
import 'package:school_pulse/features/security/presentation/gatekeeper/gatekeeper_shared.dart';
import 'package:school_pulse/features/verification/domain/entities/resolved_identity.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_decision.dart';
import 'package:school_pulse/features/verification/domain/repositories/identity_resolver.dart';
import 'package:school_pulse/features/verification/domain/repositories/verification_event_recorder.dart';
import 'package:school_pulse/features/verification/domain/repositories/verification_policy_evaluator.dart';
import 'package:school_pulse/features/verification/domain/services/verification_feedback_service.dart';
import 'package:school_pulse/features/verification/presentation/bloc/verification_session_event.dart';
import 'package:school_pulse/features/verification/presentation/bloc/verification_session_state.dart';

/// Owns scan -> resolve -> decide -> record -> feedback for one
/// verification attempt. On an `allowed` outcome that the operator
/// confirms a direction for, this also calls the EXISTING
/// `RecordStudentMovement`/`RecordStaffMovement` usecases so gate
/// movement-log behavior (dashboard stats, reports, everything
/// downstream) stays exactly as it is today - this bloc adds an audit
/// trail and permission/duplicate policy on top, it doesn't replace
/// movement recording.
class VerificationSessionBloc extends Bloc<VerificationSessionEvent, VerificationSessionState> {
  final IdentityResolver identityResolver;
  final VerificationPolicyEvaluator policyEvaluator;
  final VerificationEventRecorder eventRecorder;
  final VerificationFeedbackService feedbackService;
  final RecordStudentMovement recordStudentMovement;
  final RecordStaffMovement recordStaffMovement;

  VerificationSessionBloc({
    required this.identityResolver,
    required this.policyEvaluator,
    required this.eventRecorder,
    required this.feedbackService,
    required this.recordStudentMovement,
    required this.recordStaffMovement,
  }) : super(const VerificationIdle()) {
    on<VerificationCredentialCaptured>(_onCredentialCaptured);
    on<VerificationDirectionConfirmed>(_onDirectionConfirmed);
    on<VerificationSessionReset>((event, emit) => emit(const VerificationIdle()));
  }

  Future<void> _onCredentialCaptured(
    VerificationCredentialCaptured event,
    Emitter<VerificationSessionState> emit,
  ) async {
    emit(const VerificationResolving());

    final identityResult = await identityResolver.resolve(event.credential, event.context);
    final identity = identityResult.fold((failure) => null, (identity) => identity);
    if (identity == null) {
      await feedbackService.playError();
      emit(VerificationSessionError(identityResult.fold((f) => f.message, (_) => 'Unknown error')));
      return;
    }

    final decisionResult = await policyEvaluator.evaluate(identity: identity, context: event.context);
    final decision = decisionResult.fold((failure) => null, (decision) => decision);
    if (decision == null) {
      await feedbackService.playError();
      emit(VerificationSessionError(decisionResult.fold((f) => f.message, (_) => 'Unknown error')));
      return;
    }

    switch (decision.outcome) {
      case VerificationOutcome.allowed:
        await feedbackService.playApproved();
        break;
      case VerificationOutcome.denied:
        await feedbackService.playDenied();
        break;
      case VerificationOutcome.alreadyRecorded:
        await feedbackService.playDuplicate();
        break;
      case VerificationOutcome.requiresOverride:
        await feedbackService.playDuplicate();
        break;
    }

    emit(VerificationDecided(decision: decision, credential: event.credential, context: event.context));
  }

  Future<void> _onDirectionConfirmed(
    VerificationDirectionConfirmed event,
    Emitter<VerificationSessionState> emit,
  ) async {
    final current = state;
    if (current is! VerificationDecided || current.decision.outcome != VerificationOutcome.allowed) {
      return;
    }

    emit(const VerificationRecording());

    final gate = current.context.gate;
    final movementType = computeMovementType(gate, event.direction);
    final operatorId = current.context.operatorUser.id;
    final deviceId = current.context.deviceId;
    final schoolId = gate.schoolId;
    final identity = current.decision.identity;

    if (identity is StaffResolvedIdentity) {
      await recordStaffMovement(StaffMovement(
        id: const Uuid().v4(),
        staffId: identity.id,
        staffName: identity.name,
        timestamp: DateTime.now(),
        gateId: gate.id,
        direction: event.direction,
        verificationMethod: _verificationMethodLabel(current.credential),
        officerId: operatorId,
        schoolId: schoolId,
      ));
    } else if (identity is StudentResolvedIdentity) {
      await recordStudentMovement(StudentMovement(
        id: const Uuid().v4(),
        studentId: identity.id,
        studentName: identity.name,
        className: identity.classId,
        timestamp: DateTime.now(),
        gateId: gate.id,
        direction: event.direction,
        movementType: movementType,
        verificationMethod: _verificationMethodLabel(current.credential),
        officerId: operatorId,
        deviceId: deviceId,
        schoolId: schoolId,
      ));
    } else if (identity is ParentPickupResolvedIdentity) {
      await recordStudentMovement(StudentMovement(
        id: const Uuid().v4(),
        studentId: identity.childId,
        studentName: identity.childName,
        className: '',
        timestamp: DateTime.now(),
        gateId: gate.id,
        direction: event.direction,
        movementType: event.direction == 'Out' ? 'Authorized Pickup' : movementType,
        verificationMethod: 'Parent Code Verification',
        officerId: operatorId,
        deviceId: deviceId,
        schoolId: schoolId,
        pickupDetails: {
          'parentCode': identity.parentCode,
          if (identity.parentName != null) 'parentName': identity.parentName,
          if (identity.phoneNumber != null) 'phoneNumber': identity.phoneNumber,
        },
      ));
    }

    await eventRecorder.record(
      decision: current.decision,
      context: current.context,
      credential: current.credential,
      direction: event.direction,
    );

    emit(VerificationRecorded(decision: current.decision, direction: event.direction));
  }

  String _verificationMethodLabel(ScanCredential credential) => switch (credential) {
        QrScanCredential() => 'QR Student ID',
        NfcScanCredential() => 'NFC Card',
        ManualCodeScanCredential() => 'Manual Search',
        StaffLookupScanCredential() => 'Staff ID',
        ParentCodeScanCredential() => 'Parent Code Verification',
        FingerprintScanCredential() => 'Fingerprint',
      };
}
