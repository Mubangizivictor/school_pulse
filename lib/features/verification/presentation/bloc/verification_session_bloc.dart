import 'dart:io' show Platform;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/movement_event.dart';
import 'package:school_pulse/features/gate_ops/domain/policies/movement_direction_heuristics.dart';
import 'package:school_pulse/features/gate_ops/domain/usecases/record_movement_event.dart';
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
/// confirms a direction for, this also calls [RecordMovementEvent] so
/// gate movement-log behavior (dashboard stats, reports, everything
/// downstream) stays consistent regardless of person type - this bloc
/// adds an audit trail and permission/duplicate policy on top, it
/// doesn't replace movement recording.
class VerificationSessionBloc
    extends Bloc<VerificationSessionEvent, VerificationSessionState> {
  final IdentityResolver identityResolver;
  final VerificationPolicyEvaluator policyEvaluator;
  final VerificationEventRecorder eventRecorder;
  final VerificationFeedbackService feedbackService;
  final RecordMovementEvent recordMovementEvent;

  VerificationSessionBloc({
    required this.identityResolver,
    required this.policyEvaluator,
    required this.eventRecorder,
    required this.feedbackService,
    required this.recordMovementEvent,
  }) : super(const VerificationIdle()) {
    on<VerificationCredentialCaptured>(_onCredentialCaptured);
    on<VerificationDirectionConfirmed>(_onDirectionConfirmed);
    on<VerificationSessionReset>(
      (event, emit) => emit(const VerificationIdle()),
    );
  }

  Future<void> _onCredentialCaptured(
    VerificationCredentialCaptured event,
    Emitter<VerificationSessionState> emit,
  ) async {
    emit(const VerificationResolving());

    final identityResult = await identityResolver.resolve(
      event.credential,
      event.context,
    );
    final identity = identityResult.fold(
      (failure) => null,
      (identity) => identity,
    );
    if (identity == null) {
      await feedbackService.playError();
      emit(
        VerificationSessionError(
          identityResult.fold((f) => f.message, (_) => 'Unknown error'),
        ),
      );
      return;
    }

    final decisionResult = await policyEvaluator.evaluate(
      identity: identity,
      context: event.context,
    );
    final decision = decisionResult.fold(
      (failure) => null,
      (decision) => decision,
    );
    if (decision == null) {
      await feedbackService.playError();
      emit(
        VerificationSessionError(
          decisionResult.fold((f) => f.message, (_) => 'Unknown error'),
        ),
      );
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

    emit(
      VerificationDecided(
        decision: decision,
        credential: event.credential,
        context: event.context,
      ),
    );
  }

  Future<void> _onDirectionConfirmed(
    VerificationDirectionConfirmed event,
    Emitter<VerificationSessionState> emit,
  ) async {
    final current = state;
    if (current is! VerificationDecided ||
        current.decision.outcome != VerificationOutcome.allowed) {
      return;
    }

    emit(const VerificationRecording());

    final gate = current.context.gate;
    final movementType = computeMovementType(gate, event.direction);
    final operatorId = current.context.operatorUser.id;
    final operatorRole = current.context.operatorUser.role.name;
    final deviceId = current.context.deviceId;
    final schoolId = gate.schoolId;
    final identity = current.decision.identity;
    final direction = event.direction == 'Out'
        ? MovementDirection.out
        : MovementDirection.in_;
    final verificationMethod = _verificationMethod(current.credential);
    final now = DateTime.now();
    final platform = Platform.isIOS ? 'ios' : 'android';

    final movementEvent = switch (identity) {
      StaffResolvedIdentity() => MovementEvent(
        id: const Uuid().v4(),
        schoolId: schoolId,
        gateId: gate.id,
        personType: PersonType.staff,
        personId: identity.id,
        personName: identity.name,
        direction: direction,
        movementType: movementType,
        verificationMethod: verificationMethod,
        officerId: operatorId,
        officerRole: operatorRole,
        deviceId: deviceId,
        platform: platform,
        appVersion: '',
        actionTimestamp: now,
        syncStatus: SyncStatus.pending,
      ),
      StudentResolvedIdentity() => MovementEvent(
        id: const Uuid().v4(),
        schoolId: schoolId,
        gateId: gate.id,
        personType: PersonType.student,
        personId: identity.id,
        personName: identity.name,
        direction: direction,
        movementType: movementType,
        verificationMethod: verificationMethod,
        officerId: operatorId,
        officerRole: operatorRole,
        deviceId: deviceId,
        platform: platform,
        appVersion: '',
        actionTimestamp: now,
        syncStatus: SyncStatus.pending,
      ),
      ParentPickupResolvedIdentity() => MovementEvent(
        id: const Uuid().v4(),
        schoolId: schoolId,
        gateId: gate.id,
        personType: PersonType.pickup,
        personId: identity.childId,
        personName: identity.childName,
        direction: direction,
        movementType: event.direction == 'Out'
            ? 'Authorized Pickup'
            : movementType,
        verificationMethod: VerificationMethod.parentCode,
        officerId: operatorId,
        officerRole: operatorRole,
        deviceId: deviceId,
        platform: platform,
        appVersion: '',
        actionTimestamp: now,
        syncStatus: SyncStatus.pending,
        pickupParentCode: identity.parentCode,
        pickupParentName: identity.parentName,
        pickupPhoneNumber: identity.phoneNumber,
      ),
      UnresolvedResolvedIdentity() => throw StateError(
        'unreachable: allowed outcome implies a resolved identity',
      ),
    };

    final movementResult = await recordMovementEvent(movementEvent);

    if (movementResult.isLeft()) {
      await feedbackService.playError();
      final message = movementResult
          .swap()
          .getOrElse(() => const ServerFailure())
          .message;
      emit(VerificationSessionError('Could not record movement: $message'));
      return;
    }

    // The movement is the record of truth and already succeeded above; the
    // audit trail is best-effort on top of it (VerificationEventRecorder
    // already retries via its own offline queue), so its result doesn't
    // gate the success state the operator sees.
    await eventRecorder.record(
      decision: current.decision,
      context: current.context,
      credential: current.credential,
      direction: event.direction,
    );

    emit(
      VerificationRecorded(
        decision: current.decision,
        direction: event.direction,
      ),
    );
  }

  VerificationMethod _verificationMethod(ScanCredential credential) =>
      switch (credential) {
        QrScanCredential() => VerificationMethod.qr,
        NfcScanCredential() => VerificationMethod.nfc,
        ManualCodeScanCredential() => VerificationMethod.manualCode,
        StaffLookupScanCredential() => VerificationMethod.staffLookup,
        ParentCodeScanCredential() => VerificationMethod.parentCode,
        FingerprintScanCredential() => VerificationMethod.fingerprint,
      };
}
