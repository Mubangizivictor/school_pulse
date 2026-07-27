import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/academic_record.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/report_card.dart';
import '../../domain/usecases/get_academic_records.dart';
import '../../domain/usecases/get_attendance_records.dart';
import '../../domain/usecases/manage_report_cards.dart';

part 'academic_event.dart';
part 'academic_state.dart';

class AcademicBloc extends Bloc<AcademicEvent, AcademicState> {
  final GetAcademicRecords getAcademicRecords;
  final GetAttendanceRecords getAttendanceRecords;
  final GetReportCards getReportCards;

  AcademicBloc({
    required this.getAcademicRecords,
    required this.getAttendanceRecords,
    required this.getReportCards,
  }) : super(AcademicInitial()) {
    on<GetAcademicRecordsRequested>(_onGetAcademicRecordsRequested);
    on<GetAttendanceRecordsRequested>(_onGetAttendanceRecordsRequested);
    on<GetReportCardRequested>(_onGetReportCardRequested);
  }

  Future<void> _onGetAcademicRecordsRequested(
    GetAcademicRecordsRequested event,
    Emitter<AcademicState> emit,
  ) async {
    final currentState = state;
    List<AttendanceRecord> currentAttendance = [];
    if (currentState is AcademicLoaded) {
      currentAttendance = currentState.attendanceRecords;
    }

    emit(AcademicLoading());
    final result = await getAcademicRecords(
      GetAcademicRecordsParams(
        studentId: event.studentId,
        term: event.term,
        year: event.year,
      ),
    );
    result.fold(
      (failure) => emit(AcademicError(message: failure.message)),
      (records) => emit(AcademicLoaded(
        academicRecords: records,
        attendanceRecords: currentAttendance,
      )),
    );
  }

  Future<void> _onGetAttendanceRecordsRequested(
    GetAttendanceRecordsRequested event,
    Emitter<AcademicState> emit,
  ) async {
    final currentState = state;
    List<AcademicRecord> currentAcademic = [];
    if (currentState is AcademicLoaded) {
      currentAcademic = currentState.academicRecords;
    }

    emit(AcademicLoading());
    final result = await getAttendanceRecords(
      GetAttendanceRecordsParams(
        studentId: event.studentId,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );
    result.fold(
      (failure) => emit(AcademicError(message: failure.message)),
      (records) => emit(AcademicLoaded(
        academicRecords: currentAcademic,
        attendanceRecords: records,
      )),
    );
  }

  Future<void> _onGetReportCardRequested(
    GetReportCardRequested event,
    Emitter<AcademicState> emit,
  ) async {
    emit(AcademicLoading());
    final result = await getReportCards(
      studentId: event.studentId,
      term: event.term,
      year: event.year,
      status: ReportCardStatus.fullySigned,
    );

    result.fold(
      (failure) => emit(AcademicError(message: failure.message)),
      (reportCards) => emit(AcademicReportCardLoaded(
        reportCards.isNotEmpty ? reportCards.first : null,
      )),
    );
  }
}
