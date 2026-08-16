import 'package:equatable/equatable.dart';

/// Lifecycle states deliberately model approval/closure separately from date
/// ranges. A calendar is never inferred from a hard-coded term count or a
/// particular country's school year.
enum AcademicCalendarStatus {
  draft,
  upcoming,
  active,
  closing,
  closed,
  reopened,
  archived,
}

enum AcademicPeriodKind {
  term,
  semester,
  quarter,
  trimester,
  block,
  session,
  rotation,
  modulePeriod,
  custom,
}

enum CalendarClosureKind {
  publicHoliday,
  institutionHoliday,
  midTermBreak,
  vacation,
  examinationBreak,
  staffDevelopment,
  sportsDay,
  religiousEvent,
  maintenance,
  emergency,
  custom,
}

enum CalendarDeadlineKind {
  marksEntry,
  reportReview,
  hodModeration,
  reportApproval,
  reportPublication,
  parentRelease,
  finance,
  admissions,
  custom,
}

class CalendarScope extends Equatable {
  final String campusId;
  final String divisionId;
  final String programmeId;

  const CalendarScope({
    this.campusId = '',
    this.divisionId = '',
    this.programmeId = '',
  });

  bool overlaps(CalendarScope other) =>
      (campusId.isEmpty ||
          other.campusId.isEmpty ||
          campusId == other.campusId) &&
      (divisionId.isEmpty ||
          other.divisionId.isEmpty ||
          divisionId == other.divisionId) &&
      (programmeId.isEmpty ||
          other.programmeId.isEmpty ||
          programmeId == other.programmeId);

  @override
  List<Object?> get props => [campusId, divisionId, programmeId];
}

class AcademicCalendarYear extends Equatable {
  final String id;
  final String institutionId;
  final String name;
  final String code;
  final DateTime startDate;
  final DateTime endDate;
  final CalendarScope scope;
  final AcademicCalendarStatus status;
  final bool isCurrent;
  final int order;
  final int version;

  const AcademicCalendarYear({
    required this.id,
    required this.institutionId,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.code = '',
    this.scope = const CalendarScope(),
    this.status = AcademicCalendarStatus.draft,
    this.isCurrent = false,
    this.order = 0,
    this.version = 1,
  });

  @override
  List<Object?> get props => [
    id,
    institutionId,
    name,
    code,
    startDate,
    endDate,
    scope,
    status,
    isCurrent,
    order,
    version,
  ];
}

class AcademicCalendarPeriod extends Equatable {
  final String id;
  final String institutionId;
  final String academicYearId;
  final String name;
  final String code;
  final AcademicPeriodKind kind;
  final int order;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? teachingStartDate;
  final DateTime? teachingEndDate;
  final CalendarScope scope;
  final AcademicCalendarStatus status;
  final bool isCurrent;

  const AcademicCalendarPeriod({
    required this.id,
    required this.institutionId,
    required this.academicYearId,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.code = '',
    this.kind = AcademicPeriodKind.term,
    this.order = 0,
    this.teachingStartDate,
    this.teachingEndDate,
    this.scope = const CalendarScope(),
    this.status = AcademicCalendarStatus.draft,
    this.isCurrent = false,
  });

  @override
  List<Object?> get props => [
    id,
    institutionId,
    academicYearId,
    name,
    code,
    kind,
    order,
    startDate,
    endDate,
    teachingStartDate,
    teachingEndDate,
    scope,
    status,
    isCurrent,
  ];
}

class TeachingDay extends Equatable {
  final int weekday; // DateTime.monday through DateTime.sunday.
  final bool enabled;
  final String defaultStartTime;
  final String defaultEndTime;
  final CalendarScope scope;

  const TeachingDay({
    required this.weekday,
    required this.enabled,
    this.defaultStartTime = '',
    this.defaultEndTime = '',
    this.scope = const CalendarScope(),
  });

  @override
  List<Object?> get props => [
    weekday,
    enabled,
    defaultStartTime,
    defaultEndTime,
    scope,
  ];
}

class CalendarClosure extends Equatable {
  final String id;
  final String institutionId;
  final String title;
  final CalendarClosureKind kind;
  final DateTime startDate;
  final DateTime endDate;
  final CalendarScope scope;
  final bool teachingSuspended;
  final bool attendanceAffected;

  const CalendarClosure({
    required this.id,
    required this.institutionId,
    required this.title,
    required this.kind,
    required this.startDate,
    required this.endDate,
    this.scope = const CalendarScope(),
    this.teachingSuspended = true,
    this.attendanceAffected = true,
  });

  @override
  List<Object?> get props => [
    id,
    institutionId,
    title,
    kind,
    startDate,
    endDate,
    scope,
    teachingSuspended,
    attendanceAffected,
  ];
}

class CalendarDeadline extends Equatable {
  final String id;
  final String institutionId;
  final String academicYearId;
  final String academicPeriodId;
  final CalendarDeadlineKind kind;
  final String title;
  final DateTime dueAt;
  final DateTime? opensAt;
  final DateTime? lockAt;
  final CalendarScope scope;

  const CalendarDeadline({
    required this.id,
    required this.institutionId,
    required this.academicYearId,
    required this.academicPeriodId,
    required this.kind,
    required this.title,
    required this.dueAt,
    this.opensAt,
    this.lockAt,
    this.scope = const CalendarScope(),
  });

  @override
  List<Object?> get props => [
    id,
    institutionId,
    academicYearId,
    academicPeriodId,
    kind,
    title,
    dueAt,
    opensAt,
    lockAt,
    scope,
  ];
}
