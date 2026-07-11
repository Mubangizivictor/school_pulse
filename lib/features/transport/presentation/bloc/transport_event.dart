import 'package:equatable/equatable.dart';

abstract class TransportEvent extends Equatable {
  const TransportEvent();

  @override
  List<Object> get props => [];
}

class FetchTransportInfo extends TransportEvent {
  final String studentId;
  const FetchTransportInfo(this.studentId);

  @override
  List<Object> get props => [studentId];
}
