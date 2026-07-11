import 'package:equatable/equatable.dart';

abstract class ReceptionistEvent extends Equatable {
  const ReceptionistEvent();

  @override
  List<Object?> get props => [];
}

class ReceptionistDashboardRequested extends ReceptionistEvent {}
