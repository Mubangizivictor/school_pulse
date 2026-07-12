import 'package:equatable/equatable.dart';

class DeanStats extends Equatable {
  final int totalStudents;
  final int totalTeachers;
  final double averagePerformance;
  final double syllabusCoverage;

  const DeanStats({
    required this.totalStudents,
    required this.totalTeachers,
    required this.averagePerformance,
    required this.syllabusCoverage,
  });

  @override
  List<Object?> get props => [totalStudents, totalTeachers, averagePerformance, syllabusCoverage];
}
