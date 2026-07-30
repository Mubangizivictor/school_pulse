import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/verification/domain/entities/resolved_identity.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';

/// Resolves any [ScanCredential] to a [ResolvedIdentity]. Every credential
/// kind - NFC, QR, fingerprint, manual code, parent code, staff lookup -
/// goes through this single resolver. There is no per-module identity
/// resolution logic; modules only supply the [VerificationContext].
abstract class IdentityResolver {
  Future<Either<Failure, ResolvedIdentity>> resolve(
    ScanCredential credential,
    VerificationContext context,
  );
}
