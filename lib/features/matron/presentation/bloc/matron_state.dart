import 'package:equatable/equatable.dart';

abstract class MatronState extends Equatable {
  const MatronState();

  @override
  List<Object?> get props => [];
}

class MatronInitial extends MatronState {}

class MatronLoading extends MatronState {}

class MatronLoaded extends MatronState {
  final List<DormitoryStatus> dormitories;
  final int totalStudents;
  final int studentsPresent;
  final int studentsOnLeave;

  const MatronLoaded({
    required this.dormitories,
    required this.totalStudents,
    required this.studentsPresent,
    required this.studentsOnLeave,
  });

  @override
  List<Object?> get props => [dormitories, totalStudents, studentsPresent, studentsOnLeave];
}

class DormitoryStatus extends Equatable {
  final String name;
  final int capacity;
  final int currentOccupants;
  final String status;

  const DormitoryStatus({
    required this.name,
    required this.capacity,
    required this.currentOccupants,
    required this.status,
  });

  @override
  List<Object?> get props => [name, capacity, currentOccupants, status];
}

class MatronError extends MatronState {
  final String message;

  const MatronError(this.message);

  @override
  List<Object?> get props => [message];
}
