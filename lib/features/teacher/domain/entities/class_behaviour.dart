import 'package:equatable/equatable.dart';

/// What a behaviour category means for the class record.
///
/// The school names its own categories; this is the part the app needs in
/// order to total them and colour them, which a name and a colour cannot
/// express on their own.
enum BehaviourValence {
  /// Something the school wants more of - merit, helpfulness, leadership.
  positive,

  /// A formal achievement, reported separately from day-to-day good conduct
  /// because it can feed a report comment.
  achievement,

  /// Something the school wants less of.
  concern;

  static BehaviourValence fromId(String? id) {
    if (id == null) return BehaviourValence.concern;
    for (final v in BehaviourValence.values) {
      if (v.name == id) return v;
    }
    return BehaviourValence.concern;
  }
}

/// One behaviour or achievement category, as the school defined it.
class BehaviourCategory extends Equatable {
  final String code;
  final String label;
  final BehaviourValence valence;
  final String colorHex;

  /// Whether recording this category should raise a follow-up by default.
  /// Serious concerns default to needing one; a merit does not.
  final bool defaultsToFollowUp;

  const BehaviourCategory({
    required this.code,
    required this.label,
    required this.valence,
    this.colorHex = '',
    this.defaultsToFollowUp = false,
  });

  bool get isPositive =>
      valence == BehaviourValence.positive ||
      valence == BehaviourValence.achievement;

  @override
  List<Object?> get props => [
    code,
    label,
    valence,
    colorHex,
    defaultsToFollowUp,
  ];
}

/// Resolves the school's configured behaviour categories, with a default set
/// for schools that have configured none.
///
/// The defaults are deliberately not the "Merit / Demerit" pair the old screen
/// hardcoded: that pair cannot express an achievement worth a report comment,
/// and a school using a different vocabulary had no way to say so.
class BehaviourCategoryResolver {
  const BehaviourCategoryResolver._();

  static const List<BehaviourCategory> defaults = [
    BehaviourCategory(
      code: 'merit',
      label: 'Merit',
      valence: BehaviourValence.positive,
    ),
    BehaviourCategory(
      code: 'helpfulness',
      label: 'Helpfulness',
      valence: BehaviourValence.positive,
    ),
    BehaviourCategory(
      code: 'leadership',
      label: 'Leadership',
      valence: BehaviourValence.achievement,
    ),
    BehaviourCategory(
      code: 'academic_achievement',
      label: 'Academic achievement',
      valence: BehaviourValence.achievement,
    ),
    BehaviourCategory(
      code: 'sports_achievement',
      label: 'Sports achievement',
      valence: BehaviourValence.achievement,
    ),
    BehaviourCategory(
      code: 'lateness',
      label: 'Lateness',
      valence: BehaviourValence.concern,
    ),
    BehaviourCategory(
      code: 'disruption',
      label: 'Disruption',
      valence: BehaviourValence.concern,
      defaultsToFollowUp: true,
    ),
    BehaviourCategory(
      code: 'incomplete_work',
      label: 'Incomplete work',
      valence: BehaviourValence.concern,
    ),
  ];

  /// Classifies a category the school added that the app does not recognise.
  ///
  /// Falls to [BehaviourValence.concern] rather than positive: recording an
  /// unclassified category as a merit would let an unrecognised code quietly
  /// improve a student's conduct record.
  static BehaviourValence classify(String code, String label) {
    final text = '${label.toLowerCase()} ${code.toLowerCase()}';
    if (text.contains('achiev') ||
        text.contains('award') ||
        text.contains('prize') ||
        text.contains('leader')) {
      return BehaviourValence.achievement;
    }
    if (text.contains('merit') ||
        text.contains('good') ||
        text.contains('positive') ||
        text.contains('help') ||
        text.contains('improv')) {
      return BehaviourValence.positive;
    }
    return BehaviourValence.concern;
  }

  static List<BehaviourCategory> from(
    List<({String id, String name, String colorHex, bool isActive})> configured,
  ) {
    final active = configured.where((c) => c.isActive).toList();
    if (active.isEmpty) return defaults;

    return active.map((c) {
      final known = defaults.where((d) => d.code == c.id).firstOrNull;
      return BehaviourCategory(
        code: c.id,
        label: c.name,
        valence: known?.valence ?? classify(c.id, c.name),
        colorHex: c.colorHex,
        defaultsToFollowUp: known?.defaultsToFollowUp ?? false,
      );
    }).toList();
  }
}

/// One behaviour or achievement entry against a student in this class.
///
/// A class-level record, not a discipline case: the Class Teacher observes,
/// notes and may recommend, but the outcome of a formal case is the Discipline
/// Office's. That is why there is no `decision` or `sanction` field here.
class ClassBehaviourRecord extends Equatable {
  final String id;
  final String schoolId;
  final String campusId;
  final String classId;
  final String? streamId;
  final String academicYearId;
  final String termId;

  final String studentId;
  final String studentName;
  final String categoryCode;
  final String note;

  /// What the teacher suggests happens next. A recommendation, never a
  /// decision - the Discipline Office reads it and decides.
  final String? recommendation;

  final bool followUpRequired;
  final bool followUpClosed;
  final String? followUpNote;

  /// Set when this was escalated into a formal discipline case, so the
  /// teacher can see the status without being able to change it.
  final String? disciplineCaseId;
  final String? disciplineStatus;

  final String recordedBy;
  final DateTime recordedAt;
  final String? updatedBy;
  final DateTime? updatedAt;
  final String roleAssignmentId;

  const ClassBehaviourRecord({
    required this.id,
    required this.schoolId,
    this.campusId = '',
    required this.classId,
    this.streamId,
    required this.academicYearId,
    this.termId = '',
    required this.studentId,
    this.studentName = '',
    required this.categoryCode,
    this.note = '',
    this.recommendation,
    this.followUpRequired = false,
    this.followUpClosed = false,
    this.followUpNote,
    this.disciplineCaseId,
    this.disciplineStatus,
    this.recordedBy = '',
    required this.recordedAt,
    this.updatedBy,
    this.updatedAt,
    this.roleAssignmentId = '',
  });

  bool get isOpenFollowUp => followUpRequired && !followUpClosed;

  /// Whether this has left the class teacher's hands. Escalated records are
  /// read-only here - the Discipline Office owns the outcome.
  bool get isEscalated => disciplineCaseId != null;

  ClassBehaviourRecord copyWith({
    String? note,
    String? recommendation,
    bool? followUpRequired,
    bool? followUpClosed,
    String? followUpNote,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return ClassBehaviourRecord(
      id: id,
      schoolId: schoolId,
      campusId: campusId,
      classId: classId,
      streamId: streamId,
      academicYearId: academicYearId,
      termId: termId,
      studentId: studentId,
      studentName: studentName,
      categoryCode: categoryCode,
      note: note ?? this.note,
      recommendation: recommendation ?? this.recommendation,
      followUpRequired: followUpRequired ?? this.followUpRequired,
      followUpClosed: followUpClosed ?? this.followUpClosed,
      followUpNote: followUpNote ?? this.followUpNote,
      disciplineCaseId: disciplineCaseId,
      disciplineStatus: disciplineStatus,
      recordedBy: recordedBy,
      recordedAt: recordedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      roleAssignmentId: roleAssignmentId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    campusId,
    classId,
    streamId,
    academicYearId,
    termId,
    studentId,
    studentName,
    categoryCode,
    note,
    recommendation,
    followUpRequired,
    followUpClosed,
    followUpNote,
    disciplineCaseId,
    disciplineStatus,
    recordedBy,
    recordedAt,
    updatedBy,
    updatedAt,
    roleAssignmentId,
  ];
}
