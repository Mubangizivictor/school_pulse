import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';

import '../../domain/entities/parent_access_invite.dart';
import '../../domain/entities/parent_access_record.dart';
import '../../domain/repositories/parent_access_repository.dart';
import '../datasources/parent_access_remote_data_source.dart';
import '../models/parent_access_invite_model.dart';

class ParentAccessRepositoryImpl implements ParentAccessRepository {
  final ParentAccessRemoteDataSource remoteDataSource;

  ParentAccessRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, IssuedParentAccessCode>> issueParentAccessCode({
    required String parentName,
    required String phoneNumber,
    String? email,
    required List<LearnerLinkRequest> learners,
  }) async {
    try {
      final data = await remoteDataSource.createParentAccessCode(
        parentName: parentName,
        phoneNumber: phoneNumber,
        email: email,
        learners: learners
            .map(
              (l) => {
                'studentId': l.studentId,
                'relationship': l.relationship,
                'isPrimaryContact': l.isPrimaryContact,
              },
            )
            .toList(),
      );
      final invitation = data['invitation'] is Map
          ? Map<String, dynamic>.from(data['invitation'] as Map)
          : const <String, dynamic>{};
      return Right(
        IssuedParentAccessCode(
          inviteId: data['inviteId'] as String,
          code: data['code'] as String,
          expiresAt: DateTime.fromMillisecondsSinceEpoch(
            (data['expiresAt'] as num).toInt(),
          ),
          invitationStatus: invitation['status'] as String? ?? 'pending_manual',
          invitationDelivered: invitation['delivered'] as bool? ?? false,
        ),
      );
    } on SocketException {
      return const Left(NetworkFailure('No internet connection.'));
    } on FirebaseFunctionsException catch (e) {
      return Left(_mapException(e));
    } catch (_) {
      return const Left(
        ServerFailure('Could not create the parent access code.'),
      );
    }
  }

  @override
  Future<Either<Failure, IssuedParentAccessCode?>> reallocateParentLink({
    required String linkId,
    String? parentName,
    String? phoneNumber,
    required String reason,
  }) async {
    try {
      final data = await remoteDataSource.reallocateParentLink(
        linkId: linkId,
        parentName: parentName,
        phoneNumber: phoneNumber,
        reason: reason,
      );
      if (data['removed'] == true || data['code'] == null) {
        return const Right(null);
      }
      return Right(
        IssuedParentAccessCode(
          inviteId: data['inviteId'] as String,
          code: data['code'] as String,
          expiresAt: DateTime.fromMillisecondsSinceEpoch(
            (data['expiresAt'] as num).toInt(),
          ),
        ),
      );
    } on SocketException {
      return const Left(NetworkFailure('No internet connection.'));
    } on FirebaseFunctionsException catch (e) {
      return Left(_mapException(e));
    } catch (_) {
      return const Left(ServerFailure('Could not reallocate the parent link.'));
    }
  }

  @override
  Future<Either<Failure, void>> revokeParentAccessCode({
    required String inviteId,
  }) async {
    try {
      await remoteDataSource.revokeParentAccessCode(inviteId: inviteId);
      return const Right(null);
    } on SocketException {
      return const Left(NetworkFailure('No internet connection.'));
    } on FirebaseFunctionsException catch (e) {
      return Left(_mapException(e));
    } catch (_) {
      return const Left(ServerFailure('Could not revoke the access code.'));
    }
  }

  @override
  Future<Either<Failure, ParentAccessInvitesPage>> listParentAccessInvites({
    int pageSize = 25,
    String? cursor,
  }) async {
    try {
      final page = await remoteDataSource.listParentAccessInvites(
        pageSize: pageSize,
        cursor: cursor,
      );
      return Right(page);
    } on SocketException {
      return const Left(NetworkFailure('No internet connection.'));
    } on FirebaseFunctionsException catch (e) {
      return Left(_mapException(e));
    } catch (_) {
      return const Left(ServerFailure('Could not load parent access codes.'));
    }
  }

  @override
  Future<Either<Failure, void>> resendParentInvitation({
    required String inviteId,
    String? rawCode,
  }) async {
    try {
      await remoteDataSource.createParentInvitation(
        inviteId: inviteId,
        rawCode: rawCode,
      );
      return const Right(null);
    } on SocketException {
      return const Left(NetworkFailure('No internet connection.'));
    } on FirebaseFunctionsException catch (e) {
      return Left(_mapException(e));
    } catch (_) {
      return const Left(ServerFailure('Could not send the invitation.'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelParentInvitation({
    required String inviteId,
  }) async {
    try {
      await remoteDataSource.cancelParentInvitation(inviteId: inviteId);
      return const Right(null);
    } on SocketException {
      return const Left(NetworkFailure('No internet connection.'));
    } on FirebaseFunctionsException catch (e) {
      return Left(_mapException(e));
    } catch (_) {
      return const Left(ServerFailure('Could not cancel the invitation.'));
    }
  }

  @override
  Future<Either<Failure, ParentAccessRecord>> getParentAccessRecord({
    required String inviteId,
  }) async {
    try {
      final data = await remoteDataSource.getParentAccessRecord(
        inviteId: inviteId,
      );
      return Right(_recordFromData(data));
    } on SocketException {
      return const Left(NetworkFailure('No internet connection.'));
    } on FirebaseFunctionsException catch (e) {
      return Left(_mapException(e));
    } catch (_) {
      return const Left(ServerFailure('Could not load the parent record.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateParentDetails({
    required String inviteId,
    String? parentName,
    String? phoneNumber,
    String? email,
  }) async {
    try {
      await remoteDataSource.updateParentInvitationDetails(
        inviteId: inviteId,
        parentName: parentName,
        phoneNumber: phoneNumber,
        email: email,
      );
      return const Right(null);
    } on SocketException {
      return const Left(NetworkFailure('No internet connection.'));
    } on FirebaseFunctionsException catch (e) {
      return Left(_mapException(e));
    } catch (_) {
      return const Left(ServerFailure('Could not update the parent details.'));
    }
  }

  @override
  Future<Either<Failure, void>> linkLearnersToExistingParent({
    required String inviteId,
    required List<LearnerLinkRequest> learners,
  }) async {
    try {
      await remoteDataSource.linkLearnersToExistingParent(
        inviteId: inviteId,
        learners: learners
            .map(
              (l) => {
                'studentId': l.studentId,
                'relationship': l.relationship,
                'isPrimaryContact': l.isPrimaryContact,
              },
            )
            .toList(),
      );
      return const Right(null);
    } on SocketException {
      return const Left(NetworkFailure('No internet connection.'));
    } on FirebaseFunctionsException catch (e) {
      return Left(_mapException(e));
    } catch (_) {
      return const Left(ServerFailure('Could not link the learners.'));
    }
  }

  @override
  Future<Either<Failure, List<ParentLinkAuditEntry>>> listParentLinkAudit({
    String? inviteId,
    String? studentId,
  }) async {
    try {
      final entries = await remoteDataSource.listParentLinkAudit(
        inviteId: inviteId,
        studentId: studentId,
      );
      return Right(entries.map(_auditFromMap).toList());
    } on SocketException {
      return const Left(NetworkFailure('No internet connection.'));
    } on FirebaseFunctionsException catch (e) {
      return Left(_mapException(e));
    } catch (_) {
      return const Left(ServerFailure('Could not load the audit history.'));
    }
  }

  static DateTime? _ms(dynamic v) =>
      v is num ? DateTime.fromMillisecondsSinceEpoch(v.toInt()) : null;

  ParentAccessRecord _recordFromData(Map<String, dynamic> data) {
    ParentInviteStatus status;
    switch (data['status']) {
      case 'revoked':
        status = ParentInviteStatus.revoked;
        break;
      case 'expired':
        status = ParentInviteStatus.expired;
        break;
      default:
        status = ParentInviteStatus.active;
    }
    final rawLearners = (data['learners'] as List?) ?? const [];
    return ParentAccessRecord(
      inviteId: data['inviteId'] as String? ?? '',
      parentName: data['parentName'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      email: data['email'] as String? ?? '',
      status: status,
      invitationStatus: parentInvitationDeliveryFromString(
        data['invitationStatus'] as String?,
      ),
      invitationSentAt: _ms(data['invitationSentAt']),
      canResendAt: _ms(data['canResendAt']),
      createdAt: _ms(data['createdAt']),
      expiresAt: _ms(data['expiresAt']),
      revokedAt: _ms(data['revokedAt']),
      maxGuardians: (data['maxGuardians'] as num?)?.toInt() ?? 2,
      learners: rawLearners.map((raw) {
        final l = Map<String, dynamic>.from(raw as Map);
        return ParentLinkedLearner(
          linkId: l['linkId'] as String? ?? '',
          studentId: l['studentId'] as String? ?? '',
          studentName: l['studentName'] as String? ?? '',
          className: l['className'] as String? ?? '',
          relationship: l['relationship'] as String? ?? 'Guardian',
          isPrimaryContact: l['isPrimaryContact'] as bool? ?? false,
          linkStatus: l['linkStatus'] as String? ?? 'pending',
          linkType: l['linkType'] as String? ?? 'initial',
        );
      }).toList(),
    );
  }

  ParentLinkAuditEntry _auditFromMap(Map<String, dynamic> e) {
    return ParentLinkAuditEntry(
      id: e['id'] as String? ?? '',
      action: e['action'] as String? ?? '',
      actorRole: e['actorRole'] as String? ?? '',
      studentId: e['studentId'] as String? ?? '',
      reason: e['reason'] as String? ?? '',
      createdAt: _ms(e['createdAt']),
    );
  }

  Failure _mapException(FirebaseFunctionsException error) {
    switch (error.code) {
      case 'failed-precondition':
        return ServerFailure(
          error.message ??
              'This learner already has the maximum number of '
                  'linked parents.',
        );
      case 'resource-exhausted':
        return ServerFailure(
          error.message ?? 'Please wait before resending this invitation.',
        );
      case 'already-exists':
        return ServerFailure(
          error.message ?? 'This parent is already linked to the learner.',
        );
      case 'permission-denied':
        return PermissionDeniedFailure(
          error.message ?? 'You do not have permission to perform this action.',
        );
      case 'unauthenticated':
        return const AuthFailure('Sign in to manage parent access codes.');
      case 'unavailable':
      case 'deadline-exceeded':
        return const NetworkFailure('No internet connection.');
      case 'invalid-argument':
        return ServerFailure(
          error.message ?? 'Check the details and try again.',
        );
      case 'not-found':
        return ServerFailure(
          error.message ?? 'That parent link no longer exists.',
        );
      default:
        return ServerFailure(
          error.message ?? 'Something went wrong. Please try again.',
        );
    }
  }
}
