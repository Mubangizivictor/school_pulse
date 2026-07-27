import 'package:equatable/equatable.dart';
import '../../domain/entities/religion_entities.dart';

abstract class ReligionState extends Equatable {
  const ReligionState();

  @override
  List<Object?> get props => [];
}

class ReligionInitial extends ReligionState {}

class ReligionLoading extends ReligionState {}

class ReligionLoaded extends ReligionState {
  final List<ReligionActivity> activities;
  final List<SpiritualGroup> groups;

  const ReligionLoaded({required this.activities, required this.groups});

  @override
  List<Object?> get props => [activities, groups];
}

class ReligionError extends ReligionState {
  final String message;

  const ReligionError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReligionActionSuccess extends ReligionState {
  final String message;

  const ReligionActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
