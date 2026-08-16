import 'package:equatable/equatable.dart';
import '../../domain/entities/homework.dart';
import '../../domain/entities/report_comment.dart';
import '../../domain/entities/competency_rating.dart';

abstract class TeacherEvent extends Equatable {
  const TeacherEvent();

  @override
  List<Object?> get props => [];
}

class TeacherDashboardRequested extends TeacherEvent {
  final String teacherId;

  const TeacherDashboardRequested(this.teacherId);

  @override
  List<Object?> get props => [teacherId];
}

class TeacherAttendanceHistoryRequested extends TeacherEvent {
  final String teacherId;

  const TeacherAttendanceHistoryRequested(this.teacherId);

  @override
  List<Object?> get props => [teacherId];
}

class TeacherAttendanceRequested extends TeacherEvent {
  final String className;

  const TeacherAttendanceRequested(this.className);

  @override
  List<Object?> get props => [className];
}

class TeacherMarksEntryRequested extends TeacherEvent {
  final String className;
  final String subject;
  final String assessment;

  const TeacherMarksEntryRequested({
    required this.className,
    required this.subject,
    required this.assessment,
  });

  @override
  List<Object?> get props => [className, subject, assessment];
}

class TeacherMarksSubmitted extends TeacherEvent {
  final String schoolId;
  final String className;
  final String subject;
  final String assessment;
  final String term;
  final String year;

  /// studentId -> score (0-100)
  final Map<String, double> marks;

  const TeacherMarksSubmitted({
    required this.schoolId,
    required this.className,
    required this.subject,
    required this.assessment,
    required this.term,
    required this.year,
    required this.marks,
  });

  @override
  List<Object?> get props => [
    schoolId,
    className,
    subject,
    assessment,
    term,
    year,
    marks,
  ];
}

class TeacherAttendanceSubmitted extends TeacherEvent {
  final String schoolId;
  final String className;
  final Map<String, String> attendance; // studentId -> status

  const TeacherAttendanceSubmitted({
    required this.schoolId,
    required this.className,
    required this.attendance,
  });

  @override
  List<Object?> get props => [schoolId, className, attendance];
}

// Homework Events
class TeacherHomeworkRequested extends TeacherEvent {
  final String schoolId;
  final String teacherId;
  const TeacherHomeworkRequested(this.schoolId, this.teacherId);
  @override
  List<Object?> get props => [schoolId, teacherId];
}

class TeacherHomeworkCreated extends TeacherEvent {
  final Homework homework;
  const TeacherHomeworkCreated(this.homework);
  @override
  List<Object?> get props => [homework];
}

class TeacherHomeworkUpdated extends TeacherEvent {
  final Homework homework;
  const TeacherHomeworkUpdated(this.homework);
  @override
  List<Object?> get props => [homework];
}

class TeacherHomeworkDeleted extends TeacherEvent {
  final String homeworkId;
  const TeacherHomeworkDeleted(this.homeworkId);
  @override
  List<Object?> get props => [homeworkId];
}

// Report Comment Events
class TeacherReportCommentsRequested extends TeacherEvent {
  final String className;
  final String term;
  final String year;

  const TeacherReportCommentsRequested({
    required this.className,
    required this.term,
    required this.year,
  });

  @override
  List<Object?> get props => [className, term, year];
}

class TeacherReportCommentSaved extends TeacherEvent {
  final ReportComment comment;
  const TeacherReportCommentSaved(this.comment);
  @override
  List<Object?> get props => [comment];
}

// Competency Rating Events
class TeacherCompetencyRatingsRequested extends TeacherEvent {
  final String className;
  final String term;
  final String year;
  final String competency;

  const TeacherCompetencyRatingsRequested({
    required this.className,
    required this.term,
    required this.year,
    required this.competency,
  });

  @override
  List<Object?> get props => [className, term, year, competency];
}

class TeacherCompetencyRatingSaved extends TeacherEvent {
  final CompetencyRating rating;
  const TeacherCompetencyRatingSaved(this.rating);
  @override
  List<Object?> get props => [rating];
}
