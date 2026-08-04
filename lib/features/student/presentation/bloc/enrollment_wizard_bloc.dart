import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/admission_application.dart';
import '../../domain/entities/student_enums.dart';
import '../../domain/services/admission_service.dart';
import '../../domain/services/document_service.dart';
import 'enrollment_wizard_event.dart';
import 'enrollment_wizard_state.dart';

class EnrollmentWizardBloc extends Bloc<EnrollmentWizardEvent, EnrollmentWizardState> {
  final AdmissionService admissionService;
  final DocumentService documentService;
  final String draftId = const Uuid().v4();

  EnrollmentWizardBloc({
    required this.admissionService,
    required this.documentService,
  }) : super(const EnrollmentWizardState()) {
    on<NextStepRequested>(_onNextStep);
    on<PreviousStepRequested>(_onPreviousStep);
    on<StepUpdated>(_onStepUpdated);
    on<StudentInfoUpdated>(_onStudentInfoUpdated);
    on<AcademicPlacementUpdated>(_onAcademicPlacementUpdated);
    on<ParentInfoUpdated>(_onParentInfoUpdated);
    on<DocumentUploaded>(_onDocumentUploaded);
    on<DocumentUploadStarted>(_onDocumentUploadStarted);
    on<DocumentUploadFailed>(_onDocumentUploadFailed);
    on<AdmissionTypeSelected>(_onAdmissionTypeSelected);
    on<SubmitEnrollmentRequested>(_onSubmitEnrollment);
    on<DocumentUploadRequested>(_onDocumentUploadRequested);
  }

  void _onNextStep(NextStepRequested event, Emitter<EnrollmentWizardState> emit) {
    if (state.currentStep < 12 && state.canContinue) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void _onPreviousStep(PreviousStepRequested event, Emitter<EnrollmentWizardState> emit) {
    if (state.currentStep > 1) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  void _onStepUpdated(StepUpdated event, Emitter<EnrollmentWizardState> emit) {
    emit(state.copyWith(currentStep: event.step));
  }

  void _onStudentInfoUpdated(StudentInfoUpdated event, Emitter<EnrollmentWizardState> emit) {
    emit(state.copyWith(
      studentName: event.name,
      dateOfBirth: event.dateOfBirth,
      gender: event.gender,
    ));
  }

  void _onAcademicPlacementUpdated(AcademicPlacementUpdated event, Emitter<EnrollmentWizardState> emit) {
    emit(state.copyWith(
      targetClassId: event.targetClassId,
      targetStreamId: event.targetStreamId,
      academicYearId: event.academicYearId,
      previousSchool: event.previousSchool,
    ));
  }

  void _onParentInfoUpdated(ParentInfoUpdated event, Emitter<EnrollmentWizardState> emit) {
    emit(state.copyWith(
      applicantParentName: event.name,
      applicantParentPhone: event.phone,
    ));
  }

  void _onDocumentUploaded(DocumentUploaded event, Emitter<EnrollmentWizardState> emit) {
    final docs = Map<String, String>.from(state.attachedDocuments);
    docs[event.type] = event.url;
    final uploading = Set<String>.from(state.uploadingDocuments)..remove(event.type);
    emit(state.copyWith(attachedDocuments: docs, uploadingDocuments: uploading, errorMessage: null));
  }

  void _onDocumentUploadStarted(DocumentUploadStarted event, Emitter<EnrollmentWizardState> emit) {
    final uploading = Set<String>.from(state.uploadingDocuments)..add(event.type);
    emit(state.copyWith(uploadingDocuments: uploading));
  }

  void _onDocumentUploadFailed(DocumentUploadFailed event, Emitter<EnrollmentWizardState> emit) {
    final uploading = Set<String>.from(state.uploadingDocuments)..remove(event.type);
    emit(state.copyWith(uploadingDocuments: uploading, errorMessage: event.message));
  }

  Future<void> _onDocumentUploadRequested(
    DocumentUploadRequested event,
    Emitter<EnrollmentWizardState> emit,
  ) async {
    add(DocumentUploadStarted(event.type));
    final result = await documentService.uploadDocument(
      studentId: draftId,
      documentType: event.type,
      file: event.file,
    );
    result.fold(
      (failure) => add(DocumentUploadFailed(event.type, failure.message)),
      (url) => add(DocumentUploaded(event.type, url)),
    );
  }

  void _onAdmissionTypeSelected(AdmissionTypeSelected event, Emitter<EnrollmentWizardState> emit) {
    emit(state.copyWith(admissionType: event.type, currentStep: 2));
  }

  Future<void> _onSubmitEnrollment(
    SubmitEnrollmentRequested event,
    Emitter<EnrollmentWizardState> emit,
  ) async {
    if (state.dateOfBirth == null || state.targetClassId == null || state.academicYearId == null) {
      emit(state.copyWith(
        status: EnrollmentWizardStatus.failure,
        errorMessage: 'Missing required information',
      ));
      return;
    }

    emit(state.copyWith(status: EnrollmentWizardStatus.submitting));

    final application = AdmissionApplication(
      id: draftId,
      schoolId: event.schoolId,
      studentName: state.studentName,
      dateOfBirth: state.dateOfBirth!,
      gender: state.gender,
      targetClassId: state.targetClassId!,
      targetStreamId: state.targetStreamId,
      academicYearId: state.academicYearId!,
      previousSchool: state.previousSchool,
      applicantParentName: state.applicantParentName,
      applicantParentPhone: state.applicantParentPhone,
      status: AdmissionStatus.application,
      appliedAt: DateTime.now(),
      attachedDocuments: state.attachedDocuments,
    );

    final result = await admissionService.submitApplication(application);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: EnrollmentWizardStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: EnrollmentWizardStatus.success, currentStep: 12)),
    );
  }
}
