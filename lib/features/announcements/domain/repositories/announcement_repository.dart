import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/announcement_entity.dart';

abstract class AnnouncementRepository {
  Future<Either<Failure, List<AnnouncementEntity>>> getAnnouncements(
    String schoolId, {
    bool publishedOnly = false,
  });

  Future<Either<Failure, void>> upsertAnnouncement(
    AnnouncementEntity announcement,
  );

  Future<Either<Failure, void>> deleteAnnouncement(
    String schoolId,
    String announcementId,
  );

  Future<Either<Failure, void>> publishAnnouncement(
    String schoolId,
    String announcementId,
  );
}
