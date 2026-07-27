import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/matron_repository.dart';
import 'matron_event.dart';
import 'matron_state.dart';

class MatronBloc extends Bloc<MatronEvent, MatronState> {
  final MatronRepository repository;

  MatronBloc({required this.repository}) : super(MatronInitial()) {
    on<MatronDashboardRequested>(_onMatronDashboardRequested);
    on<UnallocatedStudentsRequested>(_onUnallocatedStudentsRequested);
    on<AllocateStudentRequested>(_onAllocateStudentRequested);
    on<DormitoryStudentsRequested>(_onDormitoryStudentsRequested);
    on<SubmitNightAttendanceRequested>(_onSubmitNightAttendanceRequested);
  }

  Future<void> _onMatronDashboardRequested(
    MatronDashboardRequested event,
    Emitter<MatronState> emit,
  ) async {
    emit(MatronLoading());
    final result = await repository.getDashboardData();
    result.fold(
      (failure) => emit(MatronError(failure.message)),
      (data) => emit(data),
    );
  }

  Future<void> _onUnallocatedStudentsRequested(
    UnallocatedStudentsRequested event,
    Emitter<MatronState> emit,
  ) async {
    emit(MatronLoading());
    final result = await repository.getUnallocatedStudents();
    result.fold(
      (failure) => emit(MatronError(failure.message)),
      (students) => emit(UnallocatedStudentsLoaded(students)),
    );
  }

  Future<void> _onAllocateStudentRequested(
    AllocateStudentRequested event,
    Emitter<MatronState> emit,
  ) async {
    emit(MatronLoading());
    final result = await repository.allocateStudent(event.studentId, event.dormitoryId);
    result.fold(
      (failure) => emit(MatronError(failure.message)),
      (_) => emit(AllocationSuccessful()),
    );
  }

  Future<void> _onDormitoryStudentsRequested(
    DormitoryStudentsRequested event,
    Emitter<MatronState> emit,
  ) async {
    emit(MatronLoading());
    final result = await repository.getDormitoryStudents(event.dormitoryId);
    result.fold(
      (failure) => emit(MatronError(failure.message)),
      (students) => emit(DormitoryStudentsLoaded(students)),
    );
  }

  Future<void> _onSubmitNightAttendanceRequested(
    SubmitNightAttendanceRequested event,
    Emitter<MatronState> emit,
  ) async {
    emit(MatronLoading());
    final result = await repository.submitNightAttendance(event.dormitoryId, event.attendance);
    result.fold(
      (failure) => emit(MatronError(failure.message)),
      (_) => emit(AttendanceSubmittedSuccessfully()),
    );
  }
}
