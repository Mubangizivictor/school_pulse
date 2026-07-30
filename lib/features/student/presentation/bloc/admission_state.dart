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

class AdmissionActionSuccess extends AdmissionState {
  final String message;

  const AdmissionActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
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
