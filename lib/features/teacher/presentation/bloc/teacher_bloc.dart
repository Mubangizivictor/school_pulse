import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/enums/student_status.dart';
import 'package:school_pulse/features/teacher/domain/usecases/get_students_by_class.dart';
import 'package:school_pulse/features/teacher/domain/usecases/submit_attendance.dart';
import 'package:school_pulse/features/teacher/domain/usecases/get_attendance_history.dart';
import 'package:school_pulse/features/teacher/domain/usecases/get_teacher_dashboard_stats.dart';
import 'teacher_event.dart';
import 'teacher_state.dart';

class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final GetStudentsByClass getStudentsByClass;
  final SubmitAttendance submitAttendance;
  final GetAttendanceHistory getAttendanceHistory;
  final GetTeacherDashboardStats getTeacherDashboardStats;

  TeacherBloc({
    required this.getStudentsByClass,
    required this.submitAttendance,
    required this.getAttendanceHistory,
    required this.getTeacherDashboardStats,
  }) : super(TeacherInitial()) {
    on<TeacherDashboardRequested>(_onTeacherDashboardRequested);
    on<TeacherAttendanceRequested>(_onTeacherAttendanceRequested);
    on<TeacherAttendanceSubmitted>(_onTeacherAttendanceSubmitted);
    on<TeacherMarksEntryRequested>(_onTeacherMarksEntryRequested);
    on<TeacherAttendanceHistoryRequested>(_onTeacherAttendanceHistoryRequested);
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
