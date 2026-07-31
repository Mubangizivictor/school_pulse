import 'package:equatable/equatable.dart';

/// What a Transport Coordinator is allowed to see for one student -
/// assigned route/pickup only, never marks or finance.
class TransportStudentView extends Equatable {
  final String studentId;
  final String name;
  final String routeName;
  final String stopName;
  final String status;

  const TransportStudentView({
    required this.studentId,
    required this.name,
    required this.routeName,
    required this.stopName,
    required this.status,
  });

  @override
  List<Object?> get props => [studentId, name, routeName, stopName, status];
}
