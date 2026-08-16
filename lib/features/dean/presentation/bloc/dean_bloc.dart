import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/dean_repository.dart';
import 'dean_event.dart';
import 'dean_state.dart';

class DeanBloc extends Bloc<DeanEvent, DeanState> {
  final DeanRepository repository;

  DeanBloc({required this.repository}) : super(DeanInitial()) {
    on<AcademicDashboardRequested>(_onAcademicDashboardRequested);

    // Curriculum & Subjects
    on<CurriculaRequested>(_onCurriculaRequested);
    on<UpdateCurriculumRequested>(_onUpdateCurriculumRequested);
    on<SubjectsRequested>(_onSubjectsRequested);
    on<UpdateSubjectAllocationRequested>(_onUpdateSubjectAllocationRequested);

    // Teacher Workload
    on<TeacherWorkloadsRequested>(_onTeacherWorkloadsRequested);
    on<TeacherWorkloadDetailRequested>(_onTeacherWorkloadDetailRequested);

    // Lesson Monitoring
    on<LessonRecordsRequested>(_onLessonRecordsRequested);

    // Homework Monitoring
    on<HomeworkRecordsRequested>(_onHomeworkRecordsRequested);

    // Assessment & Marks QA
    on<PendingModerationAssessmentsRequested>(
      _onPendingModerationAssessmentsRequested,
    );
    on<ApproveAssessmentMarksRequested>(_onApproveAssessmentMarksRequested);
    on<RejectAssessmentMarksRequested>(_onRejectAssessmentMarksRequested);

    // Performance Analytics
    on<PerformanceAnalyticsRequested>(_onPerformanceAnalyticsRequested);

    // Student Academic Support & Interventions
    on<InterventionsRequested>(_onInterventionsRequested);
    on<CreateInterventionRequested>(_onCreateInterventionRequested);
    on<UpdateInterventionStatusRequested>(_onUpdateInterventionStatusRequested);

    // Class Observations
    on<ClassObservationsRequested>(_onClassObservationsRequested);
    on<RecordObservationRequested>(_onRecordObservationRequested);

    // Timetable & Exams
    on<MasterTimetableRequested>(_onMasterTimetableRequested);
    on<ExaminationSchedulesRequested>(_onExaminationSchedulesRequested);

    // Communication
    on<SendAcademicAnnouncementRequested>(_onSendAcademicAnnouncementRequested);
  }

  Future<void> _onAcademicDashboardRequested(
    AcademicDashboardRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.getAcademicDashboardStats();
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (stats) => emit(AcademicDashboardLoaded(stats)),
    );
  }

  Future<void> _onCurriculaRequested(
    CurriculaRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.getCurricula();
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (curricula) => emit(CurriculaLoaded(curricula)),
    );
  }

  Future<void> _onUpdateCurriculumRequested(
    UpdateCurriculumRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.updateCurriculum(event.curriculum);
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (_) =>
          emit(const DeanOperationSuccess('Curriculum updated successfully')),
    );
  }

  Future<void> _onSubjectsRequested(
    SubjectsRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.getSubjects();
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (subjects) => emit(SubjectsLoaded(subjects)),
    );
  }

  Future<void> _onUpdateSubjectAllocationRequested(
    UpdateSubjectAllocationRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.updateSubjectAllocation(
      event.subjectId,
      event.teacherIds,
    );
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (_) => emit(const DeanOperationSuccess('Subject allocation updated')),
    );
  }

  Future<void> _onTeacherWorkloadsRequested(
    TeacherWorkloadsRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.getTeacherWorkloads();
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (workloads) => emit(TeacherWorkloadsLoaded(workloads)),
    );
  }

  Future<void> _onTeacherWorkloadDetailRequested(
    TeacherWorkloadDetailRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.getTeacherWorkloadDetail(event.teacherId);
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (workload) => emit(TeacherWorkloadDetailLoaded(workload)),
    );
  }

  Future<void> _onLessonRecordsRequested(
    LessonRecordsRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.getLessonRecords(
      startDate: event.startDate,
      endDate: event.endDate,
      teacherId: event.teacherId,
      classId: event.classId,
      status: event.status,
    );
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (records) => emit(LessonRecordsLoaded(records)),
    );
  }

  Future<void> _onHomeworkRecordsRequested(
    HomeworkRecordsRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.getHomeworkRecords(
      classId: event.classId,
      teacherId: event.teacherId,
      startDate: event.startDate,
      endDate: event.endDate,
    );
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (records) => emit(HomeworkRecordsLoaded(records)),
    );
  }

  Future<void> _onPendingModerationAssessmentsRequested(
    PendingModerationAssessmentsRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.getPendingModerationAssessments();
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (assessments) => emit(PendingModerationAssessmentsLoaded(assessments)),
    );
  }

  Future<void> _onApproveAssessmentMarksRequested(
    ApproveAssessmentMarksRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.approveAssessmentMarks(event.assessmentId);
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (_) => emit(const DeanOperationSuccess('Assessment marks approved')),
    );
  }

  Future<void> _onRejectAssessmentMarksRequested(
    RejectAssessmentMarksRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.rejectAssessmentMarks(
      event.assessmentId,
      event.reason,
    );
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (_) => emit(
        const DeanOperationSuccess('Assessment marks returned for correction'),
      ),
    );
  }

  Future<void> _onPerformanceAnalyticsRequested(
    PerformanceAnalyticsRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.getPerformanceAnalytics(
      type: event.type,
      id: event.id,
      academicYear: event.academicYear,
      term: event.term,
    );
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (analytics) => emit(PerformanceAnalyticsLoaded(analytics)),
    );
  }

  Future<void> _onInterventionsRequested(
    InterventionsRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.getInterventions();
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (interventions) => emit(InterventionsLoaded(interventions)),
    );
  }

  Future<void> _onCreateInterventionRequested(
    CreateInterventionRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.createIntervention(event.intervention);
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (_) => emit(const DeanOperationSuccess('Intervention plan created')),
    );
  }

  Future<void> _onUpdateInterventionStatusRequested(
    UpdateInterventionStatusRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.updateInterventionStatus(
      event.id,
      event.status,
      event.outcomes,
    );
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (_) => emit(const DeanOperationSuccess('Intervention status updated')),
    );
  }

  Future<void> _onClassObservationsRequested(
    ClassObservationsRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.getClassObservations();
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (observations) => emit(ClassObservationsLoaded(observations)),
    );
  }

  Future<void> _onRecordObservationRequested(
    RecordObservationRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.recordObservation(event.observation);
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (_) => emit(const DeanOperationSuccess('Class observation recorded')),
    );
  }

  Future<void> _onMasterTimetableRequested(
    MasterTimetableRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.getMasterTimetable();
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (timetable) => emit(MasterTimetableLoaded(timetable)),
    );
  }

  Future<void> _onExaminationSchedulesRequested(
    ExaminationSchedulesRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.getExaminationSchedules();
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (schedules) => emit(ExaminationSchedulesLoaded(schedules)),
    );
  }

  Future<void> _onSendAcademicAnnouncementRequested(
    SendAcademicAnnouncementRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await repository.sendAcademicAnnouncement(
      title: event.title,
      message: event.message,
      targetRoles: event.targetRoles,
      targetIds: event.targetIds,
    );
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (_) => emit(const DeanOperationSuccess('Announcement sent')),
    );
  }
}
