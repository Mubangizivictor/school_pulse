import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../../domain/entities/assessment_mark.dart';
import '../../domain/entities/assessment_type.dart';
import '../../domain/entities/grading_system.dart';
import 'assessment_event.dart';
import 'assessment_state.dart';

class AssessmentBloc extends Bloc<AssessmentEvent, AssessmentState> {
  final AssessmentRepository repository;

  AssessmentBloc({required this.repository}) : super(const AssessmentState()) {
    on<LoadAssessmentConfig>(_onLoadAssessmentConfig);
    on<LoadMarksForEntry>(_onLoadMarksForEntry);
    on<UpdateMarkLocal>(_onUpdateMarkLocal);
    on<SaveMarksEvent>(_onSaveMarksEvent);
    on<SubmitMarksEvent>(_onSubmitMarksEvent);
    on<AddAssessmentType>(_onAddAssessmentType);
    on<AddGradingSystem>(_onAddGradingSystem);
    on<ModerateMarks>(_onModerateMarks);
    on<ApproveMarks>(_onApproveMarks);
  }

  Future<void> _onModerateMarks(
    ModerateMarks event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(state.copyWith(status: AssessmentStatus.saving));
    final result = await repository.moderateMarks(event.markIds, event.moderatorId);
    result.fold(
      (failure) => emit(state.copyWith(status: AssessmentStatus.failure, errorMessage: failure.message)),
      (_) {
        final updatedMarks = state.marks.map((m) {
          if (event.markIds.contains(m.id)) {
            return m.copyWith(
              status: MarkStatus.moderated,
              moderatedBy: event.moderatorId,
              updatedAt: DateTime.now(),
            );
          }
          return m;
        }).toList();
        emit(state.copyWith(status: AssessmentStatus.success, marks: updatedMarks));
      },
    );
  }

  Future<void> _onApproveMarks(
    ApproveMarks event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(state.copyWith(status: AssessmentStatus.saving));
    final result = await repository.approveMarks(event.markIds, event.approverId);
    result.fold(
      (failure) => emit(state.copyWith(status: AssessmentStatus.failure, errorMessage: failure.message)),
      (_) {
        final updatedMarks = state.marks.map((m) {
          if (event.markIds.contains(m.id)) {
            return m.copyWith(
              status: MarkStatus.approved,
              approvedBy: event.approverId,
              updatedAt: DateTime.now(),
            );
          }
          return m;
        }).toList();
        emit(state.copyWith(status: AssessmentStatus.success, marks: updatedMarks));
      },
    );
  }

  Future<void> _onAddAssessmentType(
    AddAssessmentType event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(state.copyWith(status: AssessmentStatus.saving));
    final result = await repository.createAssessmentType(event.schoolId, event.assessmentType);
    result.fold(
      (failure) => emit(state.copyWith(status: AssessmentStatus.failure, errorMessage: failure.message)),
      (_) {
        final updatedTypes = List<AssessmentType>.from(state.assessmentTypes)..add(event.assessmentType);
        emit(state.copyWith(status: AssessmentStatus.success, assessmentTypes: updatedTypes));
      },
    );
  }

  Future<void> _onAddGradingSystem(
    AddGradingSystem event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(state.copyWith(status: AssessmentStatus.saving));
    final result = await repository.createGradingSystem(event.gradingSystem);
    result.fold(
      (failure) => emit(state.copyWith(status: AssessmentStatus.failure, errorMessage: failure.message)),
      (_) {
        final updatedSystems = List<GradingSystem>.from(state.gradingSystems)..add(event.gradingSystem);
        emit(state.copyWith(status: AssessmentStatus.success, gradingSystems: updatedSystems));
      },
    );
  }

  Future<void> _onLoadAssessmentConfig(
    LoadAssessmentConfig event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(state.copyWith(status: AssessmentStatus.loading));
    
    final typesResult = await repository.getAssessmentTypes(event.schoolId);
    final systemsResult = await repository.getGradingSystems(event.schoolId);

    typesResult.fold(
      (failure) => emit(state.copyWith(
        status: AssessmentStatus.failure,
        errorMessage: failure.message,
      )),
      (types) {
        systemsResult.fold(
          (failure) => emit(state.copyWith(
            status: AssessmentStatus.failure,
            errorMessage: failure.message,
          )),
          (systems) => emit(state.copyWith(
            status: AssessmentStatus.loaded,
            assessmentTypes: types,
            gradingSystems: systems,
          )),
        );
      },
    );
  }

  Future<void> _onLoadMarksForEntry(
    LoadMarksForEntry event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(state.copyWith(status: AssessmentStatus.loading));

    final result = await repository.getMarks(
      schoolId: event.schoolId,
      assessmentTypeId: event.assessmentTypeId,
      subjectId: event.subjectId,
      classId: event.classId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: AssessmentStatus.failure,
        errorMessage: failure.message,
      )),
      (marks) => emit(state.copyWith(
        status: AssessmentStatus.loaded,
        marks: marks,
      )),
    );
  }

  void _onUpdateMarkLocal(
    UpdateMarkLocal event,
    Emitter<AssessmentState> emit,
  ) {
    final updatedMarks = state.marks.map((mark) {
      if (mark.studentId == event.studentId) {
        return mark.copyWith(
          score: event.score,
          updatedAt: DateTime.now(),
        );
      }
      return mark;
    }).toList();

    emit(state.copyWith(marks: updatedMarks));
  }

  Future<void> _onSaveMarksEvent(
    SaveMarksEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(state.copyWith(status: AssessmentStatus.saving));
    
    final result = await repository.saveMarks(event.schoolId, state.marks);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: AssessmentStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: AssessmentStatus.success)),
    );
  }

  Future<void> _onSubmitMarksEvent(
    SubmitMarksEvent event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(state.copyWith(status: AssessmentStatus.saving));
    
    final result = await repository.submitMarks(event.markIds);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: AssessmentStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: AssessmentStatus.success)),
    );
  }
}
