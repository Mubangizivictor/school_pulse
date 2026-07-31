import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';

/// Manages the NFC card lifecycle backing `CachedCredentialIsar` /
/// `RevokedCredentialIsar` - the tables `IdentityResolver` reads at scan
/// time. Nothing wrote to either table before this (see the doc comment on
/// `CachedCredentialIsar`); this is that missing write path.
///
/// Deliberately local/offline-first, matching this device's own gate - it
/// does not sync a card assignment to other devices. Multi-device
/// propagation would need a Firestore-backed source of truth plus a pull
/// sync, mirroring `VerificationEventRecorderImpl`; that's follow-up work,
/// not implemented here.
abstract class NfcCredentialRepository {
  /// Binds a physical card UID to an identity. Succeeds as a no-op if the
  /// card is already actively assigned to the same identity. Fails if the
  /// card is actively assigned to a *different* identity - use [replace]
  /// or [revoke] first. Reassigning a previously-revoked card ("reuse
  /// after secure deactivation") is allowed and clears the old denylist
  /// entry so the card resolves again.
  Future<Either<Failure, void>> assign({
    required String credentialValue,
    required String identityId,
    required String identityType,
    required String schoolId,
  });

  /// Revokes [oldCredentialValue] and assigns [newCredentialValue] to the
  /// same identity in one step - the "lost/stolen/damaged card" flow.
  Future<Either<Failure, void>> replace({
    required String oldCredentialValue,
    required String newCredentialValue,
    required String identityId,
    required String identityType,
    required String schoolId,
    required String reason,
  });

  /// Adds the card to the denylist and marks the cached mapping revoked.
  /// [reason] is freeform ('lost', 'stolen', 'expired', 'deactivated', ...).
  Future<Either<Failure, void>> revoke({
    required String credentialValue,
    required String schoolId,
    required String reason,
  });

  /// Clears a revocation and restores the card to active for its existing
  /// identity mapping - for reversing an accidental/investigative
  /// deactivation. Fails if the card has no prior mapping to reactivate.
  Future<Either<Failure, void>> reactivate({
    required String credentialValue,
    required String schoolId,
  });

  /// The most recent card bound to [identityId] regardless of status
  /// (active or revoked), or null if none was ever assigned. Lets a caller
  /// revoke a lost/stolen card without the physical card being available
  /// to scan.
  Future<Either<Failure, String?>> findAssignedCredential({
    required String identityId,
    required String schoolId,
  });
}
