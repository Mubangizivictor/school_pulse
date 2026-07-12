import 'package:equatable/equatable.dart';

abstract class DeanEvent extends Equatable {
  const DeanEvent();

  @override
  List<Object?> get props => [];
}

class DeanStatsRequested extends DeanEvent {}
