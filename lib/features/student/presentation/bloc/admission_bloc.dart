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
    on<CheckDuplicatesRequested>(_onCheckDuplicates);
    on<SubmitApplicationRequested>(_onSubmitApplication);
    on<ReviewApplicationRequested>(_onReviewApplication);
    on<EnrollStudentRequested>(_onEnrollStudent);
  }

  Future<void> _onCheckDuplicates(
    CheckDuplicatesRequested event,
    Emitter<AdmissionState> emit,
  ) async {
    final result = await admissionService.checkForDuplicates(
      event.application.schoolId,
      event.application.studentName,
      event.application.dateOfBirth,
    );
    result.fold((failure) => emit(AdmissionError(failure.message)), (
      candidates,
    ) {
      if (candidates.isEmpty) {
        add(SubmitApplicationRequested(event.application));
      } else {
        emit(DuplicatesFound(candidates, event.application));
      }
    });
  }

  Future<void> _onLoadApplications(
    LoadApplicationsRequested event,
    Emitter<AdmissionState> emit,
  ) async {
    emit(AdmissionLoading());
    final result = await admissionService.getPendingApplications(
      event.schoolId,
    );
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
      (_) => emit(
        AdmissionActionSuccess(
          event.approve ? 'Application approved' : 'Application rejected',
        ),
      ),
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
      emit(
        const AdmissionActionDenied(
          'You do not have permission to enroll students.',
        ),
      );
      return;
    }

    final admitResult = await admissionService.admitStudent(
      event.applicationId,
      event.schoolId,
      event.schoolCode,
      event.academicYear,
      event.academicYearId,
      term: event.term,
      feeStructureId: event.feeStructureId,
      totalBilled: event.totalBilled,
    );

    await admitResult.fold(
      (failure) async => emit(AdmissionError(failure.message)),
      (studentId) async {
        final studentResult = await admissionService.repository.getStudentById(
          studentId,
        );
        final codes = studentResult.fold(
          (failure) => null,
          (student) => (
            uniqueSystemId: student.qrReference ?? '',
            studentCode: student.studentCode,
          ),
        );
        if (codes == null) {
          emit(
            AdmissionError(
              'Student was admitted but could not be loaded to finish enrollment.',
            ),
          );
          return;
        }

        final enrollResult = await admissionService.enrollStudent(
          studentId,
          schoolId: event.schoolId,
          uniqueSystemId: codes.uniqueSystemId,
          studentCode: codes.studentCode,
          academicYear: event.academicYear,
          term: event.term,
          feeStructureId: event.feeStructureId,
          totalBilled: event.totalBilled,
        );
        enrollResult.fold(
          (failure) => emit(AdmissionError(failure.message)),
          (enrolledId) =>
              emit(AdmissionEnrollSuccess('Student enrolled', enrolledId)),
        );
      },
    );
  }
}
