import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';

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
    required List<LearnerLinkRequest> learners,
  }) async {
    try {
      final data = await remoteDataSource.createParentAccessCode(
        parentName: parentName,
        phoneNumber: phoneNumber,
        learners: learners
            .map((l) => {'studentId': l.studentId, 'relationship': l.relationship})
            .toList(),
      );
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
      return const Left(ServerFailure('Could not create the parent access code.'));
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
      if (data['removed'] == true || data['code'] == null) return const Right(null);
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

  Failure _mapException(FirebaseFunctionsException error) {
    switch (error.code) {
      case 'failed-precondition':
        return ServerFailure(
          error.message ?? 'A learner can have a maximum of two parents.',
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
        return ServerFailure(error.message ?? 'Check the details and try again.');
      case 'not-found':
        return ServerFailure(error.message ?? 'That parent link no longer exists.');
      default:
        return ServerFailure(
          error.message ?? 'Something went wrong. Please try again.',
        );
    }
  }
}
