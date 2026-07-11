import 'package:equatable/equatable.dart';

abstract class CateringEvent extends Equatable {
  const CateringEvent();

  @override
  List<Object?> get props => [];
}

class CateringDashboardRequested extends CateringEvent {}
