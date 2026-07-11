import 'package:equatable/equatable.dart';

abstract class GamesEvent extends Equatable {
  const GamesEvent();

  @override
  List<Object?> get props => [];
}

class GamesDashboardRequested extends GamesEvent {}
