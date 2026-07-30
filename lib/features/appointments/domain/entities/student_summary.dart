import 'package:equatable/equatable.dart';

/// Lightweight student-picker row for the "which child" booking step -
/// sourced directly from the `students` collection.
class StudentSummary extends Equatable {
  final String id;
  final String name;
  final String classId;

  const StudentSummary({required this.id, required this.name, required this.classId});

  @override
  List<Object?> get props => [id, name, classId];
}
