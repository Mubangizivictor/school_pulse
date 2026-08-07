import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/gate.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/movement_event.dart';
import 'package:school_pulse/features/gate_ops/domain/policies/movement_verification_policy.dart';
import 'package:school_pulse/features/gate_ops/domain/repositories/gate_ops_repository.dart';
import 'package:school_pulse/features/verification/domain/entities/resolved_identity.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_decision.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';

class MockPermissionEvaluator extends Mock implements PermissionEvaluator {}

class MockGateOpsRepository extends Mock implements GateOpsRepository {}

void main() {
  late MovementVerificationPolicy policy;
  late MockPermissionEvaluator permissionEvaluator;
  late MockGateOpsRepository gateOpsRepository;

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
    requestedAt: DateTime(2026, 1, 1, 8),
  );

  const student = StudentResolvedIdentity(
    id: 'student-1',
    name: 'Jane Student',
    studentCode: 'SP-0001',
    classId: 'class-1',
  );

  setUpAll(() {
    registerFallbackValue(operatorUser);
    registerFallbackValue(gate);
  });

  setUp(() {
    permissionEvaluator = MockPermissionEvaluator();
    gateOpsRepository = MockGateOpsRepository();
    policy = MovementVerificationPolicy(
      permissionEvaluator: permissionEvaluator,
      gateOpsRepository: gateOpsRepository,
    );
  });

  test(
    'checks permission even for an unresolved identity, then denies with the unresolved reason',
    () async {
      const unresolved = UnresolvedResolvedIdentity(
        reason: 'unknown_credential',
      );
      when(
        () => permissionEvaluator.can(
          Permission.securityIdentityVerify,
          operatorUser,
          gate: gate,
        ),
      ).thenAnswer((_) async => const Right(true));

      final result = await policy.evaluate(
        identity: unresolved,
        context: context,
      );

      expect(result.isRight(), isTrue);
      final decision = result.getOrElse(() => throw Exception());
      expect(decision.outcome, VerificationOutcome.denied);
      expect(decision.reasonCode, 'unknown_credential');
      verify(
        () => permissionEvaluator.can(
          Permission.securityIdentityVerify,
          operatorUser,
          gate: gate,
        ),
      ).called(1);
    },
  );

  test(
    'denies an unauthorized operator with NOT_AUTHORIZED even for an unresolved identity, never leaking the reason',
    () async {
      const unresolved = UnresolvedResolvedIdentity(
        reason: 'unknown_credential',
      );
      when(
        () => permissionEvaluator.can(
          Permission.securityIdentityVerify,
          operatorUser,
          gate: gate,
        ),
      ).thenAnswer((_) async => const Right(false));

      final result = await policy.evaluate(
        identity: unresolved,
        context: context,
      );

      final decision = result.getOrElse(() => throw Exception());
      expect(decision.outcome, VerificationOutcome.denied);
      expect(decision.reasonCode, 'NOT_AUTHORIZED');
    },
  );

  test(
    'denies when the operator lacks the security.identity.verify permission',
    () async {
      when(
        () => permissionEvaluator.can(
          Permission.securityIdentityVerify,
          operatorUser,
          gate: gate,
        ),
      ).thenAnswer((_) async => const Right(false));

      final result = await policy.evaluate(identity: student, context: context);

      final decision = result.getOrElse(() => throw Exception());
      expect(decision.outcome, VerificationOutcome.denied);
      expect(decision.reasonCode, 'NOT_AUTHORIZED');
    },
  );

  test(
    'allows and suggests "In" when the student has no movements recorded today',
    () async {
      when(
        () => permissionEvaluator.can(
          Permission.securityIdentityVerify,
          operatorUser,
          gate: gate,
        ),
      ).thenAnswer((_) async => const Right(true));
      when(
        () => gateOpsRepository.watchMovementEvents(
          'school-1',
          personType: PersonType.student,
          gateId: 'gate-1',
          date: any(named: 'date'),
        ),
      ).thenAnswer((_) => Stream.value(const []));

      final result = await policy.evaluate(identity: student, context: context);

      final decision = result.getOrElse(() => throw Exception());
      expect(decision.outcome, VerificationOutcome.allowed);
      expect(decision.suggestedDirection, 'In');
    },
  );

  test(
    'suggests "Out" when the student\'s last movement today was "In"',
    () async {
      when(
        () => permissionEvaluator.can(
          Permission.securityIdentityVerify,
          operatorUser,
          gate: gate,
        ),
      ).thenAnswer((_) async => const Right(true));
      when(
        () => gateOpsRepository.watchMovementEvents(
          'school-1',
          personType: PersonType.student,
          gateId: 'gate-1',
          date: any(named: 'date'),
        ),
      ).thenAnswer(
        (_) => Stream.value([
          MovementEvent(
            id: 'm1',
            schoolId: 'school-1',
            gateId: 'gate-1',
            personType: PersonType.student,
            personId: 'student-1',
            personName: 'Jane Student',
            direction: MovementDirection.in_,
            movementType: 'Arrival',
            verificationMethod: VerificationMethod.qr,
            officerId: 'op-1',
            officerRole: 'gatekeeper',
            deviceId: 'device-1',
            platform: 'ios',
            appVersion: '',
            actionTimestamp: DateTime(2026, 1, 1, 7),
            syncStatus: SyncStatus.pending,
          ),
        ]),
      );

      final result = await policy.evaluate(identity: student, context: context);

      final decision = result.getOrElse(() => throw Exception());
      expect(decision.outcome, VerificationOutcome.allowed);
      expect(decision.suggestedDirection, 'Out');
    },
  );
}
