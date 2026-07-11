import 'package:equatable/equatable.dart';

abstract class TransportCoordinatorEvent extends Equatable {
  const TransportCoordinatorEvent();

  @override
  List<Object?> get props => [];
}

class TransportCoordinatorDashboardRequested extends TransportCoordinatorEvent {}
