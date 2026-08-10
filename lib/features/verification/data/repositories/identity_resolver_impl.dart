import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/biometrics/domain/usecases/biometric_usecases.dart';
import 'package:school_pulse/features/student/domain/usecases/resolve_parent_access_code.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/features/verification/data/datasources/verification_local_data_source.dart';
import 'package:school_pulse/features/verification/data/models/verification_isar_models.dart';
import 'package:school_pulse/features/verification/domain/entities/resolved_identity.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/repositories/identity_resolver.dart';

/// Resolves every credential kind through the same lookups the app already
/// uses elsewhere (`StudentIdentityRepository`, `GetStaffMembers`,
/// `ResolveParentAccessCode`), adding only the one thing that never
/// existed before: an offline card-UID -> person mapping for NFC via
/// `CachedCredentialIsar`.
class IdentityResolverImpl implements IdentityResolver {
  final StudentIdentityRepository studentIdentityRepository;
  final GetStaffMembers getStaffMembers;
  final ResolveParentAccessCode resolveParentAccessCode;
  final VerifyFingerprint verifyFingerprint;
  final VerificationLocalDataSource localDataSource;
  final FirebaseFirestore firestore;

  IdentityResolverImpl({
    required this.studentIdentityRepository,
    required this.getStaffMembers,
    required this.resolveParentAccessCode,
    required this.verifyFingerprint,
    required this.localDataSource,
    required this.firestore,
  });

  @override
  Future<Either<Failure, ResolvedIdentity>> resolve(
    ScanCredential credential,
    VerificationContext context,
  ) {
    return switch (credential) {
      QrScanCredential(:final rawPayload) => _resolveStudentCode(rawPayload),
      ManualCodeScanCredential(:final code) => _resolveManualCode(code),
      StaffLookupScanCredential(:final staffId) => _resolveStaffId(
        staffId,
        context,
      ),
      NfcScanCredential(:final cardUid) => _resolveNfc(cardUid, context),
      ParentCodeScanCredential(
        :final code,
        :final preSelectedChildId,
        :final preSelectedChildName,
      ) =>
        _resolveParentCode(code, preSelectedChildId, preSelectedChildName),
      FingerprintScanCredential() => _resolveFingerprint(credential, context),
    };
  }

  Future<Either<Failure, ResolvedIdentity>> _resolveStudentCode(
    String code,
  ) async {
    final result = await studentIdentityRepository.getStudentByUniqueId(code);
    return result.fold(
      Left.new,
      (student) => Right(
        student == null
            ? const UnresolvedResolvedIdentity(reason: 'unknown_credential')
            : StudentResolvedIdentity(
                id: student.id,
                name: student.name,
                studentCode: student.studentCode,
                classId: student.classId,
                photoUrl: student.photoUrl,
              ),
      ),
    );
  }

  Future<Either<Failure, ResolvedIdentity>> _resolveManualCode(
    String code,
  ) async {
    // A manual code may be a student code, or (rarely) a staff code typed
    // in by hand - try student first since it's the overwhelmingly common
    // case for this method in the gate workflow.
    final studentResult = await _resolveStudentCode(code);
    if (studentResult.isLeft()) return studentResult;

    final resolved = studentResult.getOrElse(
      () => const UnresolvedResolvedIdentity(reason: 'unknown_credential'),
    );
    if (resolved is StudentResolvedIdentity) return Right(resolved);

    final staffResult = await getStaffMembers(NoParams());
    return staffResult.fold(Left.new, (staff) {
      final match = staff.where((s) => s.staffCode == code).toList();
      if (match.isEmpty) {
        return const Right(
          UnresolvedResolvedIdentity(reason: 'unknown_credential'),
        );
      }
      return Right(
        StaffResolvedIdentity(
          id: match.first.id,
          name: match.first.name,
          staffCode: match.first.staffCode,
          roles: match.first.roles,
        ),
      );
    });
  }

  Future<Either<Failure, ResolvedIdentity>> _resolveStaffId(
    String staffId,
    VerificationContext context,
  ) async {
    final result = await getStaffMembers(NoParams());
    return result.fold(Left.new, (staff) {
      final match = staff
          .where((s) => s.id == staffId && s.schoolId == context.gate.schoolId)
          .toList();
      if (match.isEmpty) {
        return const Right(
          UnresolvedResolvedIdentity(reason: 'unknown_credential'),
        );
      }
      return Right(
        StaffResolvedIdentity(
          id: match.first.id,
          name: match.first.name,
          staffCode: match.first.staffCode,
          roles: match.first.roles,
        ),
      );
    });
  }

  Future<Either<Failure, ResolvedIdentity>> _resolveNfc(
    String cardUid,
    VerificationContext context,
  ) async {
    final schoolId = context.gate.schoolId;

    final revoked = await localDataSource.findRevocation(cardUid, schoolId);
    if (revoked != null) {
      return const Right(
        UnresolvedResolvedIdentity(reason: 'revoked_credential'),
      );
    }

    var cached = await localDataSource.findCredential(cardUid, schoolId);

    // Never seen on this device - it may have been assigned/revoked on a
    // different one (NfcCredentialRepositoryImpl pushes every change to
    // Firestore for exactly this). Fall back once, mirroring
    // StudentIdentityRepositoryImpl.getStudentByUniqueId's cache-then-
    // remote pattern, and cache whatever's found so the next scan on this
    // device resolves offline.
    if (cached == null) {
      final remote = await _fetchRemoteCredentialState(cardUid, schoolId);
      if (remote.isRevoked) {
        return const Right(
          UnresolvedResolvedIdentity(reason: 'revoked_credential'),
        );
      }
      cached = remote.credential;
    }

    if (cached == null || cached.status != 'active') {
      return const Right(
        UnresolvedResolvedIdentity(reason: 'unknown_credential'),
      );
    }

    if (cached.identityType == 'student') {
      return _resolveStudentCode(cached.identityId);
    }
    return _resolveStaffId(cached.identityId, context);
  }

  Future<({CachedCredentialIsar? credential, bool isRevoked})>
  _fetchRemoteCredentialState(String cardUid, String schoolId) async {
    try {
      final revokedDoc = await firestore
          .collection('schools')
          .doc(schoolId)
          .collection('revoked_credentials')
          .doc(cardUid)
          .get();
      if (revokedDoc.exists) {
        final data = revokedDoc.data()!;
        await localDataSource.saveRevocation(
          RevokedCredentialIsar()
            ..credentialValue = cardUid
            ..schoolId = schoolId
            ..revokedAt =
                DateTime.tryParse(data['revokedAt'] as String? ?? '') ??
                DateTime.now()
            ..reason = data['reason'] as String? ?? 'revoked',
        );
        return (credential: null, isRevoked: true);
      }

      final credentialDoc = await firestore
          .collection('schools')
          .doc(schoolId)
          .collection('credentials')
          .doc(cardUid)
          .get();
      if (!credentialDoc.exists) return (credential: null, isRevoked: false);

      final data = credentialDoc.data()!;
      final credential = CachedCredentialIsar()
        ..credentialValue = cardUid
        ..credentialType = data['credentialType'] as String? ?? 'nfc'
        ..identityId = data['identityId'] as String
        ..identityType = data['identityType'] as String
        ..schoolId = schoolId
        ..status = data['status'] as String? ?? 'active'
        ..updatedAt =
            DateTime.tryParse(data['updatedAt'] as String? ?? '') ??
            DateTime.now();

      await localDataSource.cacheCredential(credential);
      return (credential: credential, isRevoked: false);
    } catch (_) {
      // Offline, or no Firestore doc reachable - fall through to
      // "unknown", exactly the behavior before this fallback existed.
      return (credential: null, isRevoked: false);
    }
  }

  Future<Either<Failure, ResolvedIdentity>> _resolveParentCode(
    String code,
    String? preSelectedChildId,
    String? preSelectedChildName,
  ) async {
    final result = await resolveParentAccessCode(code);
    return result.fold(Left.new, (accessCode) {
      if (!accessCode.isActive) {
        return const Right(
          UnresolvedResolvedIdentity(reason: 'revoked_credential'),
        );
      }

      if (preSelectedChildId != null) {
        return Right(
          ParentPickupResolvedIdentity(
            parentCode: accessCode.parentCode,
            childId: preSelectedChildId,
            childName: preSelectedChildName ?? 'Student',
            parentName: accessCode.parentName,
            phoneNumber: accessCode.phoneNumber,
          ),
        );
      }

      if (accessCode.studentIds.length != 1) {
        // Multiple linked children and none pre-selected - the calling
        // screen falls back to its existing child-picker UI rather than
        // the engine guessing.
        return const Right(
          UnresolvedResolvedIdentity(reason: 'multiple_children'),
        );
      }
      return Right(
        ParentPickupResolvedIdentity(
          parentCode: accessCode.parentCode,
          childId: accessCode.studentIds.first,
          childName: accessCode.studentNames.isNotEmpty
              ? accessCode.studentNames.first
              : 'Student',
          parentName: accessCode.parentName,
          phoneNumber: accessCode.phoneNumber,
        ),
      );
    });
  }

  Future<Either<Failure, ResolvedIdentity>> _resolveFingerprint(
    FingerprintScanCredential credential,
    VerificationContext context,
  ) async {
    final isMatch = await verifyFingerprint(
      schoolId: context.gate.schoolId,
      personId: credential.claimedIdentityId,
      deviceId: credential.deviceId,
      operatorId: context.operatorUser.id,
    );
    if (!isMatch) {
      return const Right(
        UnresolvedResolvedIdentity(reason: 'fingerprint_mismatch'),
      );
    }
    return credential.claimedIdentityType == 'student'
        ? _resolveStudentCode(credential.claimedIdentityId)
        : _resolveStaffId(credential.claimedIdentityId, context);
  }
}
