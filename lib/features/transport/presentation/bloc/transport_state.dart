import 'package:equatable/equatable.dart';
import '../../domain/entities/transport_info.dart';

abstract class TransportState extends Equatable {
  const TransportState();

  @override
  List<Object> get props => [];
}

class TransportInitial extends TransportState {}

class TransportLoading extends TransportState {}

class TransportLoaded extends TransportState {
  final TransportInfo info;
  const TransportLoaded(this.info);

  @override
  List<Object> get props => [info];
}

class TransportError extends TransportState {
  final String message;
  const TransportError(this.message);

  @override
  List<Object> get props => [message];
}
