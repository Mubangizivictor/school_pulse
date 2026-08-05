import 'package:equatable/equatable.dart';

enum ClassAnnouncementStatus {
  draft,
  scheduled,
  published,
  expired,
  archived;

  static ClassAnnouncementStatus fromId(String? id) {
    if (id == null) return ClassAnnouncementStatus.draft;
    for (final s in ClassAnnouncementStatus.values) {
      if (s.name == id) return s;
    }
    return ClassAnnouncementStatus.draft;
  }
}

extension ClassAnnouncementStatusDisplay on ClassAnnouncementStatus {
  String get label => switch (this) {
    ClassAnnouncementStatus.draft => 'Draft',
    ClassAnnouncementStatus.scheduled => 'Scheduled',
    ClassAnnouncementStatus.published => 'Published',
    ClassAnnouncementStatus.expired => 'Expired',
    ClassAnnouncementStatus.archived => 'Archived',
  };
}

/// Who an announcement reaches.
///
/// Both audiences are bounded by the class either way - this decides whether
/// the students see it, the guardians see it, or both. It can never widen
/// beyond the roster.
enum ClassAnnouncementAudience {
  students,
  guardians,
  both;

  static ClassAnnouncementAudience fromId(String? id) {
    if (id == null) return ClassAnnouncementAudience.both;
    for (final a in ClassAnnouncementAudience.values) {
      if (a.name == id) return a;
    }
    return ClassAnnouncementAudience.both;
  }

  bool get includesGuardians => this != ClassAnnouncementAudience.students;
  bool get includesStudents => this != ClassAnnouncementAudience.guardians;
}

/// One notice posted to the teacher's own class.
///
/// There is no "all classes" option and no recipient list on this entity: the
/// audience is derived from the class roster at send time, which is what keeps
/// a class notice from becoming school-wide messaging.
class ClassAnnouncement extends Equatable {
  final String id;
  final String schoolId;
  final String campusId;
  final String classId;
  final String className;
  final String? streamId;
  final String academicYearId;
  final String termId;

  final String title;
  final String body;
  final ClassAnnouncementStatus status;
  final ClassAnnouncementAudience audience;
  final List<String> attachments;

  /// When set and in the future, the notice goes out then rather than now.
  final DateTime? scheduledFor;

  /// After this, the notice stops showing. Null means it stands until
  /// archived.
  final DateTime? expiresAt;

  final DateTime? publishedAt;
  final String createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;
  final String roleAssignmentId;

  /// How many recipients it actually reached, stamped at send time. Held so
  /// the teacher can see delivery rather than assume it.
  final int recipientCount;

  const ClassAnnouncement({
    required this.id,
    required this.schoolId,
    this.campusId = '',
    required this.classId,
    this.className = '',
    this.streamId,
    required this.academicYearId,
    this.termId = '',
    required this.title,
    this.body = '',
    this.status = ClassAnnouncementStatus.draft,
    this.audience = ClassAnnouncementAudience.both,
    this.attachments = const [],
    this.scheduledFor,
    this.expiresAt,
    this.publishedAt,
    this.createdBy = '',
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.roleAssignmentId = '',
    this.recipientCount = 0,
  });

  bool get isDraft => status == ClassAnnouncementStatus.draft;

  /// The status with the clock applied - a published notice past its expiry
  /// reads as expired without anything having to sweep it overnight.
  ClassAnnouncementStatus effectiveStatus({DateTime? asOf}) {
    final now = asOf ?? DateTime.now();
    if (status == ClassAnnouncementStatus.published) {
      final expiry = expiresAt;
      if (expiry != null && now.isAfter(expiry)) {
        return ClassAnnouncementStatus.expired;
      }
    }
    if (status == ClassAnnouncementStatus.scheduled) {
      final due = scheduledFor;
      if (due != null && now.isAfter(due)) {
        return ClassAnnouncementStatus.published;
      }
    }
    return status;
  }

  ClassAnnouncement copyWith({
    String? title,
    String? body,
    ClassAnnouncementStatus? status,
    ClassAnnouncementAudience? audience,
    List<String>? attachments,
    DateTime? scheduledFor,
    DateTime? expiresAt,
    DateTime? publishedAt,
    String? updatedBy,
    DateTime? updatedAt,
    String? roleAssignmentId,
    int? recipientCount,
  }) {
    return ClassAnnouncement(
      id: id,
      schoolId: schoolId,
      campusId: campusId,
      classId: classId,
      className: className,
      streamId: streamId,
      academicYearId: academicYearId,
      termId: termId,
      title: title ?? this.title,
      body: body ?? this.body,
      status: status ?? this.status,
      audience: audience ?? this.audience,
      attachments: attachments ?? this.attachments,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      expiresAt: expiresAt ?? this.expiresAt,
      publishedAt: publishedAt ?? this.publishedAt,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      roleAssignmentId: roleAssignmentId ?? this.roleAssignmentId,
      recipientCount: recipientCount ?? this.recipientCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    campusId,
    classId,
    className,
    streamId,
    academicYearId,
    termId,
    title,
    body,
    status,
    audience,
    attachments,
    scheduledFor,
    expiresAt,
    publishedAt,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    roleAssignmentId,
    recipientCount,
  ];
}
