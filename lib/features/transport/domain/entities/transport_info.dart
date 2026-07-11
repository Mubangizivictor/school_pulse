import 'package:equatable/equatable.dart';

class TransportInfo extends Equatable {
  final String studentId;
  final String routeName;
  final String stopName;
  final String status;

  const TransportInfo({
    required this.studentId,
    required this.routeName,
    required this.stopName,
    required this.status,
  });

  @override
  List<Object?> get props => [studentId, routeName, stopName, status];
}
