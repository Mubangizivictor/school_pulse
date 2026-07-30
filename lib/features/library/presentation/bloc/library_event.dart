import 'package:equatable/equatable.dart';
import '../../domain/entities/library_resource.dart';
import '../../domain/entities/library_borrowing.dart';
import '../../domain/entities/library_reservation.dart';
import '../../domain/entities/library_policy.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

class WatchLibraryResources extends LibraryEvent {
  final String schoolId;
  const WatchLibraryResources(this.schoolId);

  @override
  List<Object?> get props => [schoolId];
}

class WatchBorrowingHistory extends LibraryEvent {
  final String schoolId;
  final String? borrowerId;
  const WatchBorrowingHistory(this.schoolId, {this.borrowerId});

  @override
  List<Object?> get props => [schoolId, borrowerId];
}

class WatchReservations extends LibraryEvent {
  final String schoolId;
  final String? borrowerId;
  const WatchReservations(this.schoolId, {this.borrowerId});

  @override
  List<Object?> get props => [schoolId, borrowerId];
}

class AddResourceRequested extends LibraryEvent {
  final LibraryResource resource;
  const AddResourceRequested(this.resource);

  @override
  List<Object?> get props => [resource];
}

class UpdateResourceRequested extends LibraryEvent {
  final LibraryResource resource;
  const UpdateResourceRequested(this.resource);

  @override
  List<Object?> get props => [resource];
}

class IssueResourceRequested extends LibraryEvent {
  final LibraryBorrowing borrowing;
  const IssueResourceRequested(this.borrowing);

  @override
  List<Object?> get props => [borrowing];
}

class ReturnResourceRequested extends LibraryEvent {
  final String borrowingId;
  final String schoolId;
  final ResourceCondition condition;
  final double fineAmount;

  const ReturnResourceRequested({
    required this.borrowingId,
    required this.schoolId,
    required this.condition,
    required this.fineAmount,
  });

  @override
  List<Object?> get props => [borrowingId, schoolId, condition, fineAmount];
}

class ReserveResourceRequested extends LibraryEvent {
  final LibraryReservation reservation;
  const ReserveResourceRequested(this.reservation);

  @override
  List<Object?> get props => [reservation];
}

class FetchLibraryStats extends LibraryEvent {
  final String schoolId;
  const FetchLibraryStats(this.schoolId);

  @override
  List<Object?> get props => [schoolId];
}

class SearchResourcesRequested extends LibraryEvent {
  final String schoolId;
  final String query;
  const SearchResourcesRequested(this.schoolId, this.query);

  @override
  List<Object?> get props => [schoolId, query];
}

class WatchPoliciesRequested extends LibraryEvent {
  final String schoolId;
  const WatchPoliciesRequested(this.schoolId);

  @override
  List<Object?> get props => [schoolId];
}

class UpdatePolicyRequested extends LibraryEvent {
  final LibraryPolicy policy;
  const UpdatePolicyRequested(this.policy);

  @override
  List<Object?> get props => [policy];
}
