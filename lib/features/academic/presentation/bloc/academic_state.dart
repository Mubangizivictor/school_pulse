part of 'academic_bloc.dart';

abstract class AcademicState extends Equatable {
  const AcademicState();

  @override
  List<Object?> get props => [];
}

class AcademicInitial extends AcademicState {}

class AcademicLoading extends AcademicState {}

class AcademicLoaded extends AcademicState {
  final List<AcademicRecord> academicRecords;
  final List<AttendanceRecord> attendanceRecords;

  const AcademicLoaded({
    this.academicRecords = const [],
    this.attendanceRecords = const [],
  });

  AcademicLoaded copyWith({
    List<AcademicRecord>? academicRecords,
    List<AttendanceRecord>? attendanceRecords,
  }) {
    return AcademicLoaded(
      academicRecords: academicRecords ?? this.academicRecords,
      attendanceRecords: attendanceRecords ?? this.attendanceRecords,
    );
  }

  @override
  List<Object?> get props => [academicRecords, attendanceRecords];
}

class AcademicError extends AcademicState {
  final String message;

  const AcademicError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AcademicReportCardLoaded extends AcademicState {
  final ReportCard? reportCard;

  const AcademicReportCardLoaded(this.reportCard);

  @override
  List<Object?> get props => [reportCard];
}
