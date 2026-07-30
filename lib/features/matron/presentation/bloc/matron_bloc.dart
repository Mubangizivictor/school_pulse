import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/matron_repository.dart';
import 'matron_event.dart';
import 'matron_state.dart';

class MatronBloc extends Bloc<MatronEvent, MatronState> {
  final MatronRepository repository;

  MatronBloc({required this.repository}) : super(MatronInitial()) {
    on<MatronDashboardRequested>(_onMatronDashboardRequested);
    on<DormitoriesRequested>(_onDormitoriesRequested);
    on<UnallocatedStudentsRequested>(_onUnallocatedStudentsRequested);
    on<AllocateStudentRequested>(_onAllocateStudentRequested);
    on<DormitoryStudentsRequested>(_onDormitoryStudentsRequested);
    on<SubmitAttendanceRequested>(_onSubmitAttendanceRequested);
    on<WelfareRecordsRequested>(_onWelfareRecordsRequested);
    on<AddWelfareRecordRequested>(_onAddWelfareRecordRequested);
    on<DisciplineCasesRequested>(_onDisciplineCasesRequested);
    on<AddDisciplineCaseRequested>(_onAddDisciplineCaseRequested);
    on<HygieneChecksRequested>(_onHygieneChecksRequested);
    on<AddHygieneCheckRequested>(_onAddHygieneCheckRequested);
    on<StudentsOnLeaveRequested>(_onStudentsOnLeaveRequested);
  }

  Future<void> _onMatronDashboardRequested(
    MatronDashboardRequested event,
    Emitter<MatronState> emit,
  ) async {
    emit(MatronLoading());
    final result = await repository.getDashboardData(
      schoolId: event.schoolId,
      gender: event.gender,
    );
    result.fold(
      (failure) => emit(MatronError(failure.message)),
      (data) => emit(MatronDashboardLoaded(data)),
    );
  }

  Future<void> _onDormitoriesRequested(
    DormitoriesRequested event,
    Emitter<MatronState> emit,
  ) async {
    emit(MatronLoading());
    final result = await repository.getDormitories(gender: event.gender);
    result.fold(
      (failure) => emit(MatronError(failure.message)),
      (dorms) => emit(DormitoriesLoaded(dorms)),
    );
  }

  Future<void> _onUnallocatedStudentsRequested(
    UnallocatedStudentsRequested event,
    Emitter<MatronState> emit,
  ) async {
    emit(MatronLoading());
    final result = await repository.getUnallocatedStudents(
      gender: event.gender,
    );
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
    final result = await repository.allocateStudent(
      event.studentId,
      event.dormitoryId,
      event.bedNumber,
    );
    result.fold(
      (failure) => emit(MatronError(failure.message)),
      (_) => emit(const MatronSuccess('Student allocated successfully')),
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

  Future<void> _onSubmitAttendanceRequested(
    SubmitAttendanceRequested event,
    Emitter<MatronState> emit,
  ) async {
    emit(MatronLoading());
    final result = await repository.submitAttendance(
      dormitoryId: event.dormitoryId,
      type: event.type,
      attendance: event.attendance,
    );
    result.fold(
      (failure) => emit(MatronError(failure.message)),
      (_) => emit(const MatronSuccess('Attendance submitted successfully')),
    );
  }

  Future<void> _onWelfareRecordsRequested(
    WelfareRecordsRequested event,
    Emitter<MatronState> emit,
  ) async {
    emit(MatronLoading());
    final result = await repository.getWelfareRecords(
      schoolId: event.schoolId,
      studentId: event.studentId,
      gender: event.gender,
    );
    result.fold(
      (failure) => emit(MatronError(failure.message)),
      (records) => emit(WelfareRecordsLoaded(records)),
    );
  }

  Future<void> _onAddWelfareRecordRequested(
    AddWelfareRecordRequested event,
    Emitter<MatronState> emit,
  ) async {
    emit(MatronLoading());
    final result = await repository.addWelfareRecord(event.record);
    result.fold(
      (failure) => emit(MatronError(failure.message)),
      (_) => emit(const MatronSuccess('Welfare record added')),
    );
  }

  Future<void> _onDisciplineCasesRequested(
    DisciplineCasesRequested event,
    Emitter<MatronState> emit,
  ) async {
    emit(MatronLoading());
    final result = await repository.getDisciplineCases(
      studentId: event.studentId,
      gender: event.gender,
    );
    result.fold(
      (failure) => emit(MatronError(failure.message)),
      (cases) => emit(DisciplineCasesLoaded(cases)),
    );
  }

  Future<void> _onAddDisciplineCaseRequested(
    AddDisciplineCaseRequested event,
    Emitter<MatronState> emit,
  ) async {
    emit(MatronLoading());
    final result = await repository.addDisciplineCase(event.disciplineCase);
    result.fold(
      (failure) => emit(MatronError(failure.message)),
      (_) => emit(const MatronSuccess('Discipline case added')),
    );
  }

  Future<void> _onHygieneChecksRequested(
    HygieneChecksRequested event,
    Emitter<MatronState> emit,
  ) async {
    emit(MatronLoading());
    final result = await repository.getHygieneChecks(
      dormitoryId: event.dormitoryId,
      gender: event.gender,
    );
    result.fold(
      (failure) => emit(MatronError(failure.message)),
      (checks) => emit(HygieneChecksLoaded(checks)),
    );
  }

  Future<void> _onAddHygieneCheckRequested(
    AddHygieneCheckRequested event,
    Emitter<MatronState> emit,
  ) async {
    emit(MatronLoading());
    final result = await repository.addHygieneCheck(event.check);
    result.fold(
      (failure) => emit(MatronError(failure.message)),
      (_) => emit(const MatronSuccess('Hygiene check recorded')),
    );
  }

  Future<void> _onStudentsOnLeaveRequested(
    StudentsOnLeaveRequested event,
    Emitter<MatronState> emit,
  ) async {
    emit(MatronLoading());
    final result = await repository.getStudentsOnLeave(gender: event.gender);
    result.fold(
      (failure) => emit(MatronError(failure.message)),
      (students) => emit(StudentsOnLeaveLoaded(students)),
    );
  }
}
