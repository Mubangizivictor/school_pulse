import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/enums/student_status.dart';
import 'package:school_pulse/features/teacher/domain/usecases/get_students_by_class.dart';
import 'package:school_pulse/features/teacher/domain/usecases/submit_attendance.dart';
import 'package:school_pulse/features/teacher/domain/usecases/submit_marks.dart';
import 'package:school_pulse/features/teacher/domain/usecases/get_attendance_history.dart';
import 'package:school_pulse/features/teacher/domain/usecases/get_teacher_dashboard_stats.dart';
import 'package:school_pulse/features/teacher/domain/usecases/manage_homework.dart';
import 'package:school_pulse/features/teacher/domain/usecases/manage_report_comments.dart';
import 'teacher_event.dart';
import 'teacher_state.dart';

class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final GetStudentsByClass getStudentsByClass;
  final SubmitAttendance submitAttendance;
  final SubmitMarks submitMarks;
  final GetAttendanceHistory getAttendanceHistory;
  final GetTeacherDashboardStats getTeacherDashboardStats;
  final GetHomework getHomework;
  final CreateHomework createHomework;
  final UpdateHomework updateHomework;
  final DeleteHomework deleteHomework;
  final GetReportComments getReportComments;
  final SaveReportComment saveReportComment;

  TeacherBloc({
    required this.getStudentsByClass,
    required this.submitAttendance,
    required this.submitMarks,
    required this.getAttendanceHistory,
    required this.getTeacherDashboardStats,
    required this.getHomework,
    required this.createHomework,
    required this.updateHomework,
    required this.deleteHomework,
    required this.getReportComments,
    required this.saveReportComment,
  }) : super(TeacherInitial()) {
    on<TeacherDashboardRequested>(_onTeacherDashboardRequested);
    on<TeacherAttendanceRequested>(_onTeacherAttendanceRequested);
    on<TeacherAttendanceSubmitted>(_onTeacherAttendanceSubmitted);
    on<TeacherMarksEntryRequested>(_onTeacherMarksEntryRequested);
    on<TeacherMarksSubmitted>(_onTeacherMarksSubmitted);
    on<TeacherAttendanceHistoryRequested>(_onTeacherAttendanceHistoryRequested);
    on<TeacherHomeworkRequested>(_onTeacherHomeworkRequested);
    on<TeacherHomeworkCreated>(_onTeacherHomeworkCreated);
    on<TeacherHomeworkUpdated>(_onTeacherHomeworkUpdated);
    on<TeacherHomeworkDeleted>(_onTeacherHomeworkDeleted);
    on<TeacherReportCommentsRequested>(_onTeacherReportCommentsRequested);
    on<TeacherReportCommentSaved>(_onTeacherReportCommentSaved);
  }

  Future<void> _onTeacherHomeworkRequested(
    TeacherHomeworkRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    final result = await getHomework(event.teacherId);
    result.fold(
      (failure) => emit(TeacherError(failure.message)),
      (homeworkList) => emit(TeacherHomeworkLoaded(homeworkList)),
    );
  }

  Future<void> _onTeacherHomeworkCreated(
    TeacherHomeworkCreated event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    final result = await createHomework(event.homework);
    result.fold(
      (failure) => emit(TeacherError(failure.message)),
      (_) {
        emit(const TeacherOperationSuccess('Homework created successfully'));
        add(TeacherHomeworkRequested(event.homework.teacherId));
      },
    );
  }

  Future<void> _onTeacherHomeworkUpdated(
    TeacherHomeworkUpdated event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    final result = await updateHomework(event.homework);
    result.fold(
      (failure) => emit(TeacherError(failure.message)),
      (_) {
        emit(const TeacherOperationSuccess('Homework updated successfully'));
        add(TeacherHomeworkRequested(event.homework.teacherId));
      },
    );
  }

  Future<void> _onTeacherHomeworkDeleted(
    TeacherHomeworkDeleted event,
    Emitter<TeacherState> emit,
  ) async {
    final currentState = state;
    emit(TeacherLoading());
    final result = await deleteHomework(event.homeworkId);
    result.fold(
      (failure) => emit(TeacherError(failure.message)),
      (_) {
        emit(const TeacherOperationSuccess('Homework deleted successfully'));
        if (currentState is TeacherHomeworkLoaded) {
          final updatedList = currentState.homeworkList
              .where((h) => h.id != event.homeworkId)
              .toList();
          emit(TeacherHomeworkLoaded(updatedList));
        }
      },
    );
  }

  Future<void> _onTeacherReportCommentsRequested(
    TeacherReportCommentsRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    final studentsResult = await getStudentsByClass(event.className);
    final commentsResult = await getReportComments(
      className: event.className,
      term: event.term,
      year: event.year,
    );

    studentsResult.fold(
      (failure) => emit(TeacherError(failure.message)),
      (students) {
        commentsResult.fold(
          (failure) => emit(TeacherError(failure.message)),
          (comments) => emit(TeacherReportCommentsLoaded(
            students: students,
            comments: comments,
          )),
        );
      },
    );
  }

  Future<void> _onTeacherReportCommentSaved(
    TeacherReportCommentSaved event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    final result = await saveReportComment(event.comment);
    result.fold(
      (failure) => emit(TeacherError(failure.message)),
      (_) => emit(const TeacherOperationSuccess('Comment saved successfully')),
    );
  }

  Future<void> _onTeacherMarksSubmitted(
    TeacherMarksSubmitted event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());

    final result = await submitMarks(MarksParams(
      className: event.className,
      subject: event.subject,
      assessment: event.assessment,
      term: event.term,
      year: event.year,
      marks: event.marks,
    ));

    result.fold(
      (failure) => emit(TeacherError(failure.message)),
      (_) {
        emit(TeacherMarksSubmitSuccess(event.marks.length));
        add(TeacherMarksEntryRequested(
          className: event.className,
          subject: event.subject,
          assessment: event.assessment,
        ));
      },
    );
  }

  Future<void> _onTeacherAttendanceHistoryRequested(
    TeacherAttendanceHistoryRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    final result = await getAttendanceHistory(event.teacherId);
    
    result.fold(
      (failure) => emit(TeacherError(failure.message)),
      (history) => emit(TeacherAttendanceHistoryLoaded(history)),
    );
  }

  Future<void> _onTeacherAttendanceSubmitted(
    TeacherAttendanceSubmitted event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    
    final result = await submitAttendance(AttendanceParams(
      className: event.className,
      date: DateTime.now(),
      attendance: event.attendance.map(
        (key, value) => MapEntry(
          key,
          StudentStatus.values.firstWhere((e) => e.name == value),
        ),
      ),
    ));

    result.fold(
      (failure) => emit(TeacherError(failure.message)),
      (_) {
        emit(TeacherInitial());
        add(TeacherAttendanceRequested(event.className));
      },
    );
  }

  Future<void> _onTeacherDashboardRequested(
    TeacherDashboardRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    
    final result = await getTeacherDashboardStats(event.teacherId);
    
    result.fold(
      (failure) => emit(TeacherError(failure.message)),
      (stats) => emit(TeacherLoaded(
        studentsToday: stats.studentsToday,
        totalStudents: stats.totalStudents,
        submissionsDue: stats.submissionsDue,
        classesToday: stats.classesToday,
        activeNotifications: stats.activeNotifications,
        classProgress: stats.classProgress,
      )),
    );
  }

  Future<void> _onTeacherAttendanceRequested(
    TeacherAttendanceRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    final result = await getStudentsByClass(event.className);
    
    result.fold(
      (failure) => emit(TeacherError(failure.message)),
      (students) => emit(TeacherAttendanceLoaded(
        students: students,
        selectedClass: event.className,
      )),
    );
  }

  Future<void> _onTeacherMarksEntryRequested(
    TeacherMarksEntryRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    final result = await getStudentsByClass(event.className);
    
    result.fold(
      (failure) => emit(TeacherError(failure.message)),
      (students) => emit(TeacherMarksEntryLoaded(
        students: students,
        selectedClass: event.className,
        selectedSubject: event.subject,
        selectedAssessment: event.assessment,
      )),
    );
  }
}
