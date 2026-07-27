import 'package:equatable/equatable.dart';

abstract class MatronEvent extends Equatable {
  const MatronEvent();

  @override
  List<Object?> get props => [];
}

class MatronDashboardRequested extends MatronEvent {}

class UnallocatedStudentsRequested extends MatronEvent {}

class AllocateStudentRequested extends MatronEvent {
  final String studentId;
  final String dormitoryId;

  const AllocateStudentRequested({
    required this.studentId,
    required this.dormitoryId,
  });

  @override
  List<Object?> get props => [studentId, dormitoryId];
}

class DormitoryStudentsRequested extends MatronEvent {
  final String dormitoryId;

  const DormitoryStudentsRequested(this.dormitoryId);

  @override
  List<Object?> get props => [dormitoryId];
}

class SubmitNightAttendanceRequested extends MatronEvent {
  final String dormitoryId;
  final Map<String, bool> attendance;

  const SubmitNightAttendanceRequested({
    required this.dormitoryId,
    required this.attendance,
  });

  @override
  List<Object?> get props => [dormitoryId, attendance];
}
