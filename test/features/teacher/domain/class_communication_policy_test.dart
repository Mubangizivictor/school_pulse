import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_announcement.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_student_summary.dart';
import 'package:school_pulse/features/teacher/domain/policies/class_communication_policy.dart';

final _now = DateTime(2026, 6, 15, 10, 0);

ClassAnnouncement _announcement({
  ClassAnnouncementStatus status = ClassAnnouncementStatus.draft,
  ClassAnnouncementAudience audience = ClassAnnouncementAudience.both,
  DateTime? scheduledFor,
  DateTime? expiresAt,
}) {
  return ClassAnnouncement(
    id: 'a1',
    schoolId: 'school1',
    classId: 'p7',
    academicYearId: '2026',
    title: "Parents' meeting",
    body: 'There will be a parents meeting on Friday.',
    status: status,
    audience: audience,
    scheduledFor: scheduledFor,
    expiresAt: expiresAt,
    createdAt: _now,
  );
}

ClassStudentSummary _student(String id, {bool active = true}) {
  return ClassStudentSummary(
    studentId: id,
    schoolId: 'school1',
    name: 'Student $id',
    classId: 'p7',
    academicYearId: '2026',
    status: active ? ClassStudentStatus.active : ClassStudentStatus.transferred,
  );
}

void main() {
  final roster = [_student('s1'), _student('s2'), _student('s3')];

  group('saving an announcement', () {
    test('needs a title and a body', () {
      expect(
        ClassCommunicationPolicy.canSaveAnnouncement(
          title: 'x',
          body: 'There will be a meeting.',
          existing: null,
          scheduledFor: null,
          expiresAt: null,
          now: _now,
        ).refusal,
        CommunicationRefusal.titleRequired,
      );

      expect(
        ClassCommunicationPolicy.canSaveAnnouncement(
          title: "Parents' meeting",
          body: '  ',
          existing: null,
          scheduledFor: null,
          expiresAt: null,
          now: _now,
        ).refusal,
        CommunicationRefusal.bodyRequired,
      );
    });

    test('refuses a send time already past', () {
      expect(
        ClassCommunicationPolicy.canSaveAnnouncement(
          title: "Parents' meeting",
          body: 'There will be a meeting.',
          existing: null,
          scheduledFor: _now.subtract(const Duration(hours: 2)),
          expiresAt: null,
          now: _now,
        ).refusal,
        CommunicationRefusal.scheduleInPast,
      );
    });

    test('refuses an expiry before the send time', () {
      expect(
        ClassCommunicationPolicy.canSaveAnnouncement(
          title: "Parents' meeting",
          body: 'There will be a meeting.',
          existing: null,
          scheduledFor: _now.add(const Duration(days: 3)),
          expiresAt: _now.add(const Duration(days: 1)),
          now: _now,
        ).refusal,
        CommunicationRefusal.expiryBeforePublish,
      );
    });

    test('allows editing the expiry of something already sent', () {
      expect(
        ClassCommunicationPolicy.canSaveAnnouncement(
          title: "Parents' meeting",
          body: 'There will be a meeting.',
          existing: _announcement(status: ClassAnnouncementStatus.published),
          scheduledFor: _now.subtract(const Duration(days: 1)),
          expiresAt: _now.add(const Duration(days: 5)),
          now: _now,
        ).isAllowed,
        isTrue,
      );
    });
  });

  group('publishing', () {
    test('is refused without the publish permission', () {
      expect(
        ClassCommunicationPolicy.canPublishAnnouncement(
          announcement: _announcement(),
          hasPublishPermission: false,
          recipientCount: 3,
        ).refusal,
        CommunicationRefusal.publishNotPermitted,
      );
    });

    test('is refused when it would reach nobody', () {
      // An empty roster, or guardians-only where none are linked yet.
      expect(
        ClassCommunicationPolicy.canPublishAnnouncement(
          announcement: _announcement(),
          hasPublishPermission: true,
          recipientCount: 0,
        ).refusal,
        CommunicationRefusal.noRecipients,
      );
    });

    test('is refused for something already sent', () {
      expect(
        ClassCommunicationPolicy.canPublishAnnouncement(
          announcement: _announcement(
            status: ClassAnnouncementStatus.published,
          ),
          hasPublishPermission: true,
          recipientCount: 3,
        ).refusal,
        CommunicationRefusal.alreadyPublished,
      );
    });
  });

  group('recipients', () {
    test('are resolved from the live roster, not stored on the draft', () {
      final recipients = ClassCommunicationPolicy.recipientsFor(
        announcement: _announcement(),
        roster: roster,
      );

      expect(recipients.reach, 3);
    });

    test('exclude students who have left', () {
      // A student who transferred out between drafting and sending must not
      // receive it.
      final recipients = ClassCommunicationPolicy.recipientsFor(
        announcement: _announcement(),
        roster: [...roster, _student('gone', active: false)],
      );

      expect(recipients.reach, 3);
    });

    test('honour a students-only audience', () {
      final recipients = ClassCommunicationPolicy.recipientsFor(
        announcement: _announcement(
          audience: ClassAnnouncementAudience.students,
        ),
        roster: roster,
      );

      expect(recipients.studentIds, hasLength(3));
      expect(recipients.guardiansOf, isEmpty);
    });

    test('honour a guardians-only audience', () {
      final recipients = ClassCommunicationPolicy.recipientsFor(
        announcement: _announcement(
          audience: ClassAnnouncementAudience.guardians,
        ),
        roster: roster,
      );

      expect(recipients.studentIds, isEmpty);
      expect(recipients.guardiansOf, hasLength(3));
    });

    test('do not double-count when the audience is both', () {
      final recipients = ClassCommunicationPolicy.recipientsFor(
        announcement: _announcement(audience: ClassAnnouncementAudience.both),
        roster: roster,
      );

      expect(recipients.reach, 3);
    });
  });

  group('messaging about a student', () {
    test('is refused for a student outside the class', () {
      // A student id is guessable; the roster is the authority.
      expect(
        ClassCommunicationPolicy.canMessageAbout(
          studentId: 'someone-elses-child',
          roster: roster,
        ).refusal,
        CommunicationRefusal.studentNotInClass,
      );
    });

    test('is refused for a student who has left the class', () {
      expect(
        ClassCommunicationPolicy.canMessageAbout(
          studentId: 'gone',
          roster: [...roster, _student('gone', active: false)],
        ).refusal,
        CommunicationRefusal.studentNotInClass,
      );
    });

    test('is allowed for an active student on the roster', () {
      expect(
        ClassCommunicationPolicy.canMessageAbout(
          studentId: 's2',
          roster: roster,
        ).isAllowed,
        isTrue,
      );
    });
  });

  group('effective status', () {
    test('a published notice past its expiry reads as expired', () {
      expect(
        _announcement(
          status: ClassAnnouncementStatus.published,
          expiresAt: _now.subtract(const Duration(days: 1)),
        ).effectiveStatus(asOf: _now),
        ClassAnnouncementStatus.expired,
      );
    });

    test('a scheduled notice past its send time reads as published', () {
      expect(
        _announcement(
          status: ClassAnnouncementStatus.scheduled,
          scheduledFor: _now.subtract(const Duration(hours: 1)),
        ).effectiveStatus(asOf: _now),
        ClassAnnouncementStatus.published,
      );
    });

    test('a draft is never re-derived from the clock', () {
      expect(
        _announcement(
          expiresAt: _now.subtract(const Duration(days: 3)),
        ).effectiveStatus(asOf: _now),
        ClassAnnouncementStatus.draft,
      );
    });
  });
}
