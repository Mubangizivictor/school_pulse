import 'package:equatable/equatable.dart';
import '../../domain/entities/admission_application.dart';

abstract class AdmissionState extends Equatable {
  const AdmissionState();

  @override
  List<Object?> get props => [];
}

class AdmissionInitial extends AdmissionState {}

class AdmissionLoading extends AdmissionState {}

class AdmissionApplicationsLoaded extends AdmissionState {
  final List<AdmissionApplication> applications;

  const AdmissionApplicationsLoaded(this.applications);

  @override
  List<Object?> get props => [applications];
}

/// Result of CheckDuplicatesRequested. Empty `candidates` means "no
/// probable duplicate found" - the screen proceeds straight to submit
/// without showing a warning.
class DuplicatesFound extends AdmissionState {
  final List<AdmissionApplication> candidates;
  final AdmissionApplication pendingApplication;

  const DuplicatesFound(this.candidates, this.pendingApplication);

  @override
  List<Object?> get props => [candidates, pendingApplication];
}

class AdmissionActionSuccess extends AdmissionState {
  final String message;

  const AdmissionActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Distinct from AdmissionActionSuccess so the review screen can trigger
// the parent-linking prompt only after an actual enrollment, not after
// every review/approve/reject action.
class AdmissionEnrollSuccess extends AdmissionActionSuccess {
  final String studentId;

  const AdmissionEnrollSuccess(super.message, this.studentId);

  @override
  List<Object?> get props => [message, studentId];
}

class AdmissionActionDenied extends AdmissionState {
  final String message;

  const AdmissionActionDenied(this.message);

  @override
  List<Object?> get props => [message];
}

class AdmissionError extends AdmissionState {
  final String message;

  const AdmissionError(this.message);

  @override
  List<Object?> get props => [message];
}
