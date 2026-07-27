import 'package:equatable/equatable.dart';
import '../../domain/entities/religion_entities.dart';

abstract class ReligionEvent extends Equatable {
  const ReligionEvent();

  @override
  List<Object?> get props => [];
}

class ReligionDashboardRequested extends ReligionEvent {}

class CreateReligionActivityRequested extends ReligionEvent {
  final ReligionActivity activity;

  const CreateReligionActivityRequested(this.activity);

  @override
  List<Object?> get props => [activity];
}

class UpdateSpiritualGroupRequested extends ReligionEvent {
  final String groupId;
  final int memberCount;

  const UpdateSpiritualGroupRequested(this.groupId, this.memberCount);

  @override
  List<Object?> get props => [groupId, memberCount];
}
