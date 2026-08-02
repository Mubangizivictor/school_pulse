import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/class_announcement.dart';

/// Announcements to the teacher's own class, and the guard on who they may
/// contact about a student.
///
/// The audience is never carried on the request: it is resolved from the class
/// roster at send time, which is what keeps a class notice from widening into
/// school-wide messaging as students join and leave.
abstract class ClassCommunicationRepository {
  Future<Either<Failure, List<ClassAnnouncement>>> getAnnouncements({
    required ActiveResponsibilityContext context,
  });

  Future<Either<Failure, ClassAnnouncement>> saveAnnouncement({
    required ActiveResponsibilityContext context,
    required ClassAnnouncement announcement,
  });

  /// Sends to the class. Resolves recipients from the live roster and refuses
  /// when that comes to nobody, because an announcement to an empty audience
  /// is almost always a mistake rather than an intention.
  Future<Either<Failure, ClassAnnouncement>> publishAnnouncement({
    required ActiveResponsibilityContext context,
    required ClassAnnouncement announcement,
  });

  Future<Either<Failure, ClassAnnouncement>> archiveAnnouncement({
    required ActiveResponsibilityContext context,
    required ClassAnnouncement announcement,
  });

  /// Whether the teacher may open a conversation about this student, checked
  /// against the live roster rather than against whatever the screen holds.
  Future<Either<Failure, void>> assertCanMessageAbout({
    required ActiveResponsibilityContext context,
    required String studentId,
  });
}
