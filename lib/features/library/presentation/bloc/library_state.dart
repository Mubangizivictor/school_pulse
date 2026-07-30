import 'package:equatable/equatable.dart';
import '../../domain/entities/library_resource.dart';
import '../../domain/entities/library_borrowing.dart';
import '../../domain/entities/library_reservation.dart';

abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryResourcesLoaded extends LibraryState {
  final List<LibraryResource> resources;
  const LibraryResourcesLoaded(this.resources);

  @override
  List<Object?> get props => [resources];
}

class LibraryHistoryLoaded extends LibraryState {
  final List<LibraryBorrowing> history;
  const LibraryHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class LibraryReservationsLoaded extends LibraryState {
  final List<LibraryReservation> reservations;
  const LibraryReservationsLoaded(this.reservations);

  @override
  List<Object?> get props => [reservations];
}

class LibraryStatsLoaded extends LibraryState {
  final Map<String, dynamic> stats;
  const LibraryStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class LibraryPoliciesLoaded extends LibraryState {
  final List<dynamic> policies;
  const LibraryPoliciesLoaded(this.policies);

  @override
  List<Object?> get props => [policies];
}

class LibraryActionSuccess extends LibraryState {
  final String message;
  const LibraryActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class LibraryError extends LibraryState {
  final String message;
  const LibraryError(this.message);

  @override
  List<Object?> get props => [message];
}
