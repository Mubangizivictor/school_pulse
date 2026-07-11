import 'package:equatable/equatable.dart';

abstract class HealthEvent extends Equatable {
  const HealthEvent();

  @override
  List<Object> get props => [];
}

class FetchHealthVisits extends HealthEvent {
  final String studentId;
  const FetchHealthVisits(this.studentId);

  @override
  List<Object> get props => [studentId];
}
