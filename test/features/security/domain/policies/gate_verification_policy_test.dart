import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'package:school_pulse/features/security/domain/policies/gate_verification_policy.dart';
import 'package:school_pulse/features/security/domain/repositories/security_repository.dart';
import 'package:school_pulse/features/verification/domain/entities/resolved_identity.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_decision.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';

class MockPermissionEvaluator extends Mock implements PermissionEvaluator {}

class MockSecurityRepository extends Mock implements SecurityRepository {}

void main() {
  late GateVerificationPolicy policy;
  late MockPermissionEvaluator permissionEvaluator;
  late MockSecurityRepository securityRepository;

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
    securityRepository = MockSecurityRepository();
    policy = GateVerificationPolicy(
      permissionEvaluator: permissionEvaluator,
      securityRepository: securityRepository,
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
        () => securityRepository.watchStudentMovements(
          'school-1',
          date: any(named: 'date'),
          gateId: 'gate-1',
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
        () => securityRepository.watchStudentMovements(
          'school-1',
          date: any(named: 'date'),
          gateId: 'gate-1',
        ),
      ).thenAnswer(
        (_) => Stream.value([
          StudentMovement(
            id: 'm1',
            studentId: 'student-1',
            studentName: 'Jane Student',
            className: 'class-1',
            timestamp: DateTime(2026, 1, 1, 7),
            gateId: 'gate-1',
            direction: 'In',
            movementType: 'Arrival',
            verificationMethod: 'QR Student ID',
            officerId: 'op-1',
            deviceId: 'device-1',
            schoolId: 'school-1',
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
