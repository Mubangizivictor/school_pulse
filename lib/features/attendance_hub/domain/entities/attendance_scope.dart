import 'package:equatable/equatable.dart';

/// A pickable group within a category - a class+stream for Students, a
/// department for Staff, a route for Transport, and so on. Kept generic so
/// one manual-attendance flow serves every category instead of one per type.
class AttendanceScope extends Equatable {
  final String id;
  final String name;

  const AttendanceScope({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

/// One rosterable person under a scope, generic across categories (student,
/// staff member, visitor, etc).
class AttendancePerson extends Equatable {
  final String id;
  final String name;
  final String? subtitle;

  const AttendancePerson({required this.id, required this.name, this.subtitle});

  @override
  List<Object?> get props => [id, name, subtitle];
}
