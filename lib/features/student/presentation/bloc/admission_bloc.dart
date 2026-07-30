import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
import '../../domain/services/admission_service.dart';
import 'admission_event.dart';
import 'admission_state.dart';

class AdmissionBloc extends Bloc<AdmissionEvent, AdmissionState> {
  final AdmissionService admissionService;
  final PermissionEvaluator permissionEvaluator;

  AdmissionBloc({
    required this.admissionService,
    required this.permissionEvaluator,
  }) : super(AdmissionInitial()) {
    on<LoadApplicationsRequested>(_onLoadApplications);
    on<SubmitApplicationRequested>(_onSubmitApplication);
    on<ReviewApplicationRequested>(_onReviewApplication);
    on<EnrollStudentRequested>(_onEnrollStudent);
  }

  Future<void> _onLoadApplications(
    LoadApplicationsRequested event,
    Emitter<AdmissionState> emit,
  ) async {
    emit(AdmissionLoading());
    final result = await admissionService.getPendingApplications(event.schoolId);
    result.fold(
      (failure) => emit(AdmissionError(failure.message)),
      (applications) => emit(AdmissionApplicationsLoaded(applications)),
    );
  }

  Future<void> _onSubmitApplication(
    SubmitApplicationRequested event,
    Emitter<AdmissionState> emit,
  ) async {
    final result = await admissionService.submitApplication(event.application);
    result.fold(
      (failure) => emit(AdmissionError(failure.message)),
      (_) => emit(const AdmissionActionSuccess('Application submitted')),
    );
  }

  Future<void> _onReviewApplication(
    ReviewApplicationRequested event,
    Emitter<AdmissionState> emit,
  ) async {
    final result = await admissionService.reviewApplication(
      event.applicationId,
      reviewerId: event.reviewerId,
      approve: event.approve,
      comments: event.comments,
    );
    result.fold(
      (failure) => emit(AdmissionError(failure.message)),
      (_) => emit(AdmissionActionSuccess(
        event.approve ? 'Application approved' : 'Application rejected',
      )),
    );
  }

  Future<void> _onEnrollStudent(
    EnrollStudentRequested event,
    Emitter<AdmissionState> emit,
  ) async {
    final permissionResult = await permissionEvaluator.can(
      Permission.admissionEnroll,
      event.operatorUser,
    );
    final allowed = permissionResult.fold((failure) => false, (value) => value);

    if (!allowed) {
      emit(const AdmissionActionDenied('You do not have permission to enroll students.'));
      return;
    }

    final result = await admissionService.admitStudent(
      event.applicationId,
      event.schoolId,
      event.schoolCode,
      event.academicYear,
      event.academicYearId,
      term: event.term,
      feeStructureId: event.feeStructureId,
      totalBilled: event.totalBilled,
    );
    result.fold(
      (failure) => emit(AdmissionError(failure.message)),
      (_) => emit(const AdmissionActionSuccess('Student enrolled')),
    );
  }
}
