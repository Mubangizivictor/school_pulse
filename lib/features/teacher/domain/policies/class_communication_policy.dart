import '../entities/class_announcement.dart';
import '../entities/class_student_summary.dart';

enum CommunicationRefusal {
  titleRequired,
  bodyRequired,
  publishNotPermitted,
  alreadyPublished,
  scheduleInPast,
  expiryBeforePublish,
  noRecipients,
  studentNotInClass,
  guardianNotLinked,
}

class CommunicationDecision {
  final bool isAllowed;
  final CommunicationRefusal? refusal;
  final String? message;

  const CommunicationDecision.allowed()
      : isAllowed = true,
        refusal = null,
        message = null;

  const CommunicationDecision.refused(this.refusal, this.message)
      : isAllowed = false;
}

/// Who a class teacher may talk to, and what they may post.
///
/// The scoping rule is the whole point of this file: a Class Teacher's reach
/// is the guardians of active students on their own roster, resolved from that
/// roster every time. Not a contact list, not a saved recipient set, and never
/// the school directory — those would all drift from the class as students
/// join and leave.
class ClassCommunicationPolicy {
  const ClassCommunicationPolicy._();

  static CommunicationDecision canSaveAnnouncement({
    required String title,
    required String body,
    required ClassAnnouncement? existing,
    required DateTime? scheduledFor,
    required DateTime? expiresAt,
    required DateTime now,
  }) {
    if (title.trim().length < 3) {
      return const CommunicationDecision.refused(
        CommunicationRefusal.titleRequired,
        'Give the announcement a title.',
      );
    }

    if (body.trim().length < 5) {
      return const CommunicationDecision.refused(
        CommunicationRefusal.bodyRequired,
        'Write the announcement before sending it.',
      );
    }

    // Only for work not yet out: rescheduling something already published is
    // meaningless, and this check would otherwise block editing its expiry.
    if (existing == null || existing.isDraft) {
      if (scheduledFor != null && scheduledFor.isBefore(now)) {
        return const CommunicationDecision.refused(
          CommunicationRefusal.scheduleInPast,
          'That send time has already passed.',
        );
      }
    }

    if (expiresAt != null) {
      final from = scheduledFor ?? now;
      if (expiresAt.isBefore(from)) {
        return const CommunicationDecision.refused(
          CommunicationRefusal.expiryBeforePublish,
          'The announcement would expire before it is sent.',
        );
      }
    }

    return const CommunicationDecision.allowed();
  }

  static CommunicationDecision canPublishAnnouncement({
    required ClassAnnouncement announcement,
    required bool hasPublishPermission,
    required int recipientCount,
  }) {
    if (!hasPublishPermission) {
      return const CommunicationDecision.refused(
        CommunicationRefusal.publishNotPermitted,
        'You do not have permission to send announcements to your class.',
      );
    }

    if (announcement.status == ClassAnnouncementStatus.published) {
      return const CommunicationDecision.refused(
        CommunicationRefusal.alreadyPublished,
        'This announcement has already been sent.',
      );
    }

    // Sending to nobody is almost always a mistake — an empty roster, or an
    // audience of guardians when none are linked yet.
    if (recipientCount == 0) {
      return const CommunicationDecision.refused(
        CommunicationRefusal.noRecipients,
        'There is nobody in your class to send this to yet.',
      );
    }

    return const CommunicationDecision.allowed();
  }

  /// Whether the teacher may open a conversation about [studentId].
  ///
  /// Membership is checked against the roster passed in, which the caller
  /// resolved from the active assignment — so a student id from a deep link or
  /// a stale screen cannot open a conversation the teacher is not entitled to.
  static CommunicationDecision canMessageAbout({
    required String studentId,
    required List<ClassStudentSummary> roster,
  }) {
    final student =
        roster.where((s) => s.studentId == studentId).firstOrNull;

    if (student == null) {
      return const CommunicationDecision.refused(
        CommunicationRefusal.studentNotInClass,
        'That student is not in your class.',
      );
    }

    // A student who has left keeps their record but is no longer this
    // teacher's to contact home about.
    if (!student.isActive) {
      return const CommunicationDecision.refused(
        CommunicationRefusal.studentNotInClass,
        'That student is no longer active in your class.',
      );
    }

    return const CommunicationDecision.allowed();
  }

  /// Who an announcement should reach, resolved from the roster at send time.
  ///
  /// Derived rather than stored on the announcement, so a notice cannot reach
  /// a student who transferred out between drafting and sending. The delivery
  /// layer fans [guardiansOf] out to each student's linked guardians; this
  /// keeps the *scope* decision here rather than in the messaging feature.
  static ClassAnnouncementRecipients recipientsFor({
    required ClassAnnouncement announcement,
    required List<ClassStudentSummary> roster,
  }) {
    final active = roster.where((s) => s.isActive).map((s) => s.studentId).toList();

    return ClassAnnouncementRecipients(
      studentIds: announcement.audience.includesStudents ? active : const [],
      guardiansOf: announcement.audience.includesGuardians ? active : const [],
    );
  }
}

/// The resolved audience of one announcement.
class ClassAnnouncementRecipients {
  /// Students who receive it directly.
  final List<String> studentIds;

  /// Students whose linked guardians receive it. Expressed as student ids
  /// rather than guardian ids because the guardian link is the Student
  /// Information System's to resolve, not this panel's.
  final List<String> guardiansOf;

  const ClassAnnouncementRecipients({
    this.studentIds = const [],
    this.guardiansOf = const [],
  });

  /// The number the publish guard checks. Counted as distinct students so an
  /// audience of "both" does not read as twice the class.
  int get reach => {...studentIds, ...guardiansOf}.length;
}
