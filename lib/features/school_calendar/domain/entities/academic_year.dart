import 'package:equatable/equatable.dart';

class AcademicYear extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCurrent;

  const AcademicYear({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.isCurrent = false,
  });

  int get totalDays => endDate.difference(startDate).inDays + 1;

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    startDate,
    endDate,
    isCurrent,
  ];
}
