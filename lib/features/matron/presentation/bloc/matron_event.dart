import 'package:equatable/equatable.dart';

abstract class MatronEvent extends Equatable {
  const MatronEvent();

  @override
  List<Object?> get props => [];
}

class MatronDashboardRequested extends MatronEvent {}

class UpdateDormitoryAttendance extends MatronEvent {
  final String dormitoryName;
  final String studentId;
  final bool isPresent;

  const UpdateDormitoryAttendance({
    required this.dormitoryName,
    required this.studentId,
    required this.isPresent,
  });

  @override
  List<Object?> get props => [dormitoryName, studentId, isPresent];
}
