import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../datasources/announcement_remote_data_source.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementRemoteDataSource remoteDataSource;

  AnnouncementRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncements(
    String schoolId,
  ) async {
    try {
      final announcements = await remoteDataSource.getAnnouncements(schoolId);
      return Right(announcements);
    } catch (e, st) {
      debugPrint('AnnouncementRepositoryImpl error: $e\n$st');
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> upsertAnnouncement(
    AnnouncementEntity announcement,
  ) async {
    try {
      await remoteDataSource.upsertAnnouncement(
        AnnouncementModel.fromEntity(announcement),
      );
      return const Right(null);
    } catch (e, st) {
      debugPrint('AnnouncementRepositoryImpl error: $e\n$st');
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAnnouncement(
    String schoolId,
    String announcementId,
  ) async {
    try {
      await remoteDataSource.deleteAnnouncement(schoolId, announcementId);
      return const Right(null);
    } catch (e, st) {
      debugPrint('AnnouncementRepositoryImpl error: $e\n$st');
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, void>> publishAnnouncement(
    String schoolId,
    String announcementId,
  ) async {
    try {
      await remoteDataSource.publishAnnouncement(schoolId, announcementId);
      return const Right(null);
    } catch (e, st) {
      debugPrint('AnnouncementRepositoryImpl error: $e\n$st');
      return Left(ServerFailure('$e'));
    }
  }
}
