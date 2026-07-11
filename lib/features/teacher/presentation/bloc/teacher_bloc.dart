import 'package:flutter_bloc/flutter_bloc.dart';
import 'teacher_event.dart';
import 'teacher_state.dart';

class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  TeacherBloc() : super(TeacherInitial()) {
    on<TeacherDashboardRequested>(_onTeacherDashboardRequested);
    on<TeacherAttendanceRequested>(_onTeacherAttendanceRequested);
    on<TeacherAttendanceSubmitted>(_onTeacherAttendanceSubmitted);
    on<TeacherMarksEntryRequested>(_onTeacherMarksEntryRequested);
  }

  Future<void> _onTeacherAttendanceSubmitted(
    TeacherAttendanceSubmitted event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    try {
      // TODO: Implement Firestore persistence
      // For now, simulate a network call
      await Future.delayed(const Duration(seconds: 1));
      
      // Re-fetch or just emit success. Usually we'd want a TeacherAttendanceSuccess state
      // but to keep it simple with existing states:
      emit(TeacherInitial()); // Or trigger a reload
      add(TeacherAttendanceRequested(event.className));
    } catch (e) {
      emit(TeacherError(e.toString()));
    }
  }

  Future<void> _onTeacherDashboardRequested(
    TeacherDashboardRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    try {
      // TODO: Transition to real repository call
      await Future.delayed(const Duration(seconds: 1));
      emit(const TeacherLoaded(
        studentsToday: 38,
        totalStudents: 42,
        submissionsDue: 12,
        classesToday: 4,
        activeNotifications: 3,
        classProgress: [
          ClassProgress(
            title: 'Mathematics - P.4 Blue',
            progress: 0.75,
            subtitle: 'Syllabus coverage: 75% completed',
          ),
          ClassProgress(
            title: 'English - P.4 Blue',
            progress: 0.60,
            subtitle: 'Syllabus coverage: 60% completed',
          ),
        ],
      ));
    } catch (e) {
      emit(TeacherError(e.toString()));
    }
  }

  Future<void> _onTeacherAttendanceRequested(
    TeacherAttendanceRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    try {
      // TODO: Transition to real repository call
      await Future.delayed(const Duration(seconds: 1));
      final students = [
        const TeacherStudent(id: '1', name: 'John Doe', studentId: 'STU001', className: 'Primary 4'),
        const TeacherStudent(id: '2', name: 'Jane Smith', studentId: 'STU002', className: 'Primary 4'),
        const TeacherStudent(id: '3', name: 'James Bond', studentId: 'STU003', className: 'Primary 4'),
        const TeacherStudent(id: '4', name: 'Alice Cooper', studentId: 'STU004', className: 'Primary 4'),
      ];
      emit(TeacherAttendanceLoaded(
        students: students,
        selectedClass: event.className,
      ));
    } catch (e) {
      emit(TeacherError(e.toString()));
    }
  }

  Future<void> _onTeacherMarksEntryRequested(
    TeacherMarksEntryRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    try {
      // TODO: Transition to real repository call
      await Future.delayed(const Duration(seconds: 1));
      final students = [
        const TeacherStudent(id: '1', name: 'John Doe', studentId: 'STU001', className: 'Primary 4'),
        const TeacherStudent(id: '2', name: 'Jane Smith', studentId: 'STU002', className: 'Primary 4'),
        const TeacherStudent(id: '3', name: 'James Bond', studentId: 'STU003', className: 'Primary 4'),
        const TeacherStudent(id: '4', name: 'Alice Cooper', studentId: 'STU004', className: 'Primary 4'),
      ];
      emit(TeacherMarksEntryLoaded(
        students: students,
        selectedClass: event.className,
        selectedSubject: event.subject,
        selectedAssessment: event.assessment,
      ));
    } catch (e) {
      emit(TeacherError(e.toString()));
    }
  }
}
