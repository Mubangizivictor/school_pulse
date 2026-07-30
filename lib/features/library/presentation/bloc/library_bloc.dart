import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/library_resource.dart';
import '../../domain/entities/library_borrowing.dart';
import '../../domain/entities/library_reservation.dart';
import '../../domain/entities/library_policy.dart';
import '../../domain/repositories/library_repository.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final LibraryRepository repository;
  StreamSubscription? _resourcesSubscription;
  StreamSubscription? _historySubscription;
  StreamSubscription? _reservationsSubscription;
  StreamSubscription? _policiesSubscription;

  LibraryBloc({required this.repository}) : super(LibraryInitial()) {
    on<WatchLibraryResources>(_onWatchLibraryResources);
    on<WatchBorrowingHistory>(_onWatchBorrowingHistory);
    on<WatchReservations>(_onWatchReservations);
    on<AddResourceRequested>(_onAddResourceRequested);
    on<UpdateResourceRequested>(_onUpdateResourceRequested);
    on<IssueResourceRequested>(_onIssueResourceRequested);
    on<ReturnResourceRequested>(_onReturnResourceRequested);
    on<ReserveResourceRequested>(_onReserveResourceRequested);
    on<FetchLibraryStats>(_onFetchLibraryStats);
    on<SearchResourcesRequested>(_onSearchResourcesRequested);
    on<WatchPoliciesRequested>(_onWatchPoliciesRequested);
    on<UpdatePolicyRequested>(_onUpdatePolicyRequested);
  }

  Future<void> _onWatchLibraryResources(WatchLibraryResources event, Emitter<LibraryState> emit) async {
    await _resourcesSubscription?.cancel();
    emit(LibraryLoading());
    _resourcesSubscription = repository.watchResources(event.schoolId).listen(
      (resources) => add(_UpdateResources(resources)),
    );
    on<_UpdateResources>((event, emit) => emit(LibraryResourcesLoaded(event.resources)));
  }

  Future<void> _onWatchBorrowingHistory(WatchBorrowingHistory event, Emitter<LibraryState> emit) async {
    await _historySubscription?.cancel();
    emit(LibraryLoading());
    _historySubscription = repository.watchBorrowingHistory(event.schoolId, borrowerId: event.borrowerId).listen(
      (history) => add(_UpdateHistory(history)),
    );
    on<_UpdateHistory>((event, emit) => emit(LibraryHistoryLoaded(event.history)));
  }

  Future<void> _onWatchReservations(WatchReservations event, Emitter<LibraryState> emit) async {
    await _reservationsSubscription?.cancel();
    emit(LibraryLoading());
    _reservationsSubscription = repository.watchReservations(event.schoolId, borrowerId: event.borrowerId).listen(
      (reservations) => add(_UpdateReservations(reservations)),
    );
    on<_UpdateReservations>((event, emit) => emit(LibraryReservationsLoaded(event.reservations)));
  }

  Future<void> _onAddResourceRequested(AddResourceRequested event, Emitter<LibraryState> emit) async {
    try {
      await repository.addResource(event.resource);
      emit(const LibraryActionSuccess('Resource added successfully'));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  Future<void> _onUpdateResourceRequested(UpdateResourceRequested event, Emitter<LibraryState> emit) async {
    try {
      await repository.updateResource(event.resource);
      emit(const LibraryActionSuccess('Resource updated successfully'));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  Future<void> _onIssueResourceRequested(IssueResourceRequested event, Emitter<LibraryState> emit) async {
    try {
      await repository.issueResource(event.borrowing);
      emit(const LibraryActionSuccess('Resource issued successfully'));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  Future<void> _onReturnResourceRequested(ReturnResourceRequested event, Emitter<LibraryState> emit) async {
    try {
      await repository.returnResource(
        event.schoolId,
        event.borrowingId,
        condition: event.condition,
        fineAmount: event.fineAmount,
      );
      emit(const LibraryActionSuccess('Resource returned successfully'));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  Future<void> _onReserveResourceRequested(ReserveResourceRequested event, Emitter<LibraryState> emit) async {
    try {
      await repository.reserveResource(event.reservation);
      emit(const LibraryActionSuccess('Resource reserved successfully'));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  Future<void> _onFetchLibraryStats(FetchLibraryStats event, Emitter<LibraryState> emit) async {
    emit(LibraryLoading());
    try {
      final stats = await repository.getLibraryStats(event.schoolId);
      emit(LibraryStatsLoaded(stats));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  Future<void> _onSearchResourcesRequested(SearchResourcesRequested event, Emitter<LibraryState> emit) async {
    // This could be handled by the watch event filtered in the UI, 
    // but for large datasets, we'd implement a repository search.
    // For now, we rely on the Watch stream being filtered in the UI or locally.
  }

  Future<void> _onWatchPoliciesRequested(WatchPoliciesRequested event, Emitter<LibraryState> emit) async {
    await _policiesSubscription?.cancel();
    _policiesSubscription = repository.watchPolicies(event.schoolId).listen(
      (policies) => add(_UpdatePolicies(policies)),
    );
    on<_UpdatePolicies>((event, emit) => emit(LibraryPoliciesLoaded(event.policies)));
  }

  Future<void> _onUpdatePolicyRequested(UpdatePolicyRequested event, Emitter<LibraryState> emit) async {
    try {
      await repository.updatePolicy(event.policy);
      emit(const LibraryActionSuccess('Policy updated successfully'));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _resourcesSubscription?.cancel();
    _historySubscription?.cancel();
    _reservationsSubscription?.cancel();
    _policiesSubscription?.cancel();
    return super.close();
  }
}

// Internal events for stream updates
class _UpdateResources extends LibraryEvent {
  final List<LibraryResource> resources;
  const _UpdateResources(this.resources);
}

class _UpdateHistory extends LibraryEvent {
  final List<LibraryBorrowing> history;
  const _UpdateHistory(this.history);
}

class _UpdateReservations extends LibraryEvent {
  final List<LibraryReservation> reservations;
  const _UpdateReservations(this.reservations);
}

class _UpdatePolicies extends LibraryEvent {
  final List<LibraryPolicy> policies;
  const _UpdatePolicies(this.policies);
}
