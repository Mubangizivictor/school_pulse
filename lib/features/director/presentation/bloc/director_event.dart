import 'package:equatable/equatable.dart';

abstract class DirectorEvent extends Equatable {
  const DirectorEvent();

  @override
  List<Object?> get props => [];
}

class DirectorDashboardRequested extends DirectorEvent {}
