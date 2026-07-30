import 'package:equatable/equatable.dart';
import '../../../student/domain/entities/student.dart';

abstract class AttendanceQrState extends Equatable {
  const AttendanceQrState();

  @override
  List<Object?> get props => [];
}

class AttendanceQrInitial extends AttendanceQrState {}

class AttendanceQrLoading extends AttendanceQrState {}

class StudentScannedSuccess extends AttendanceQrState {
  final Student student;
  const StudentScannedSuccess(this.student);

  @override
  List<Object?> get props => [student];
}

class AttendanceMarkedSuccess extends AttendanceQrState {
  final String message;
  const AttendanceMarkedSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AttendanceQrError extends AttendanceQrState {
  final String message;
  const AttendanceQrError(this.message);

  @override
  List<Object?> get props => [message];
}

class AttendanceSyncSuccess extends AttendanceQrState {}
