import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/religion_repository.dart';
import 'religion_event.dart';
import 'religion_state.dart';

class ReligionBloc extends Bloc<ReligionEvent, ReligionState> {
  final ReligionRepository repository;

  ReligionBloc({required this.repository}) : super(ReligionInitial()) {
    on<ReligionDashboardRequested>(_onReligionDashboardRequested);
    on<CreateReligionActivityRequested>(_onCreateReligionActivityRequested);
    on<UpdateSpiritualGroupRequested>(_onUpdateSpiritualGroupRequested);
  }

  Future<void> _onReligionDashboardRequested(
    ReligionDashboardRequested event,
    Emitter<ReligionState> emit,
  ) async {
    emit(ReligionLoading());
    final activitiesResult = await repository.getUpcomingActivities();
    final groupsResult = await repository.getSpiritualGroups();

    activitiesResult.fold(
      (failure) => emit(ReligionError(failure.message)),
      (activities) {
        groupsResult.fold(
          (failure) => emit(ReligionError(failure.message)),
          (groups) => emit(ReligionLoaded(activities: activities, groups: groups)),
        );
      },
    );
  }

  Future<void> _onCreateReligionActivityRequested(
    CreateReligionActivityRequested event,
    Emitter<ReligionState> emit,
  ) async {
    final result = await repository.createActivity(event.activity);
    result.fold(
      (failure) => emit(ReligionError(failure.message)),
      (_) {
        emit(const ReligionActionSuccess('Activity created successfully'));
        add(ReligionDashboardRequested());
      },
    );
  }

  Future<void> _onUpdateSpiritualGroupRequested(
    UpdateSpiritualGroupRequested event,
    Emitter<ReligionState> emit,
  ) async {
    final result = await repository.updateGroupMemberCount(event.groupId, event.memberCount);
    result.fold(
      (failure) => emit(ReligionError(failure.message)),
      (_) {
        emit(const ReligionActionSuccess('Group updated successfully'));
        add(ReligionDashboardRequested());
      },
    );
  }
}
