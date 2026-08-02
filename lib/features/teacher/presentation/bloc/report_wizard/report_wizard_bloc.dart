import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/generate_reports.dart';
import 'report_wizard_event.dart';
import 'report_wizard_state.dart';

class ReportWizardBloc extends Bloc<ReportWizardEvent, ReportWizardState> {
  final GenerateReports generateReports;

  ReportWizardBloc({required this.generateReports}) : super(const ReportWizardState()) {
    on<ReportWizardClassSelected>((event, emit) {
      emit(state.copyWith(
        selectedClassId: event.classId,
        selectedClassName: event.className,
      ));
    });

    on<ReportWizardTermProfileSelected>((event, emit) {
      emit(state.copyWith(
        selectedYear: event.year,
        selectedTerm: event.term,
        selectedProfile: event.profile,
      ));
    });

    on<ReportWizardSectionsUpdated>((event, emit) {
      emit(state.copyWith(enabledSections: event.enabledSections));
    });

    on<ReportWizardStudentsSelected>((event, emit) {
      emit(state.copyWith(selectedStudentIds: event.studentIds));
    });

    on<ReportWizardSubmitRequested>((event, emit) async {
      if (state.selectedClassName == null ||
          state.selectedTerm == null ||
          state.selectedYear == null ||
          state.selectedStudentIds.isEmpty) {
        emit(state.copyWith(
          status: ReportWizardStatus.failure,
          errorMessage: 'Missing required information for report generation.',
        ));
        return;
      }

      emit(state.copyWith(status: ReportWizardStatus.loading));

      final result = await generateReports(GenerateReportsParams(
        className: state.selectedClassName!,
        term: state.selectedTerm!,
        year: state.selectedYear!,
        studentIds: state.selectedStudentIds,
        enabledSections: state.enabledSections,
      ));

      result.fold(
        (failure) => emit(state.copyWith(
          status: ReportWizardStatus.failure,
          errorMessage: failure.message,
        )),
        (_) => emit(state.copyWith(status: ReportWizardStatus.success)),
      );
    });

    on<ReportWizardReset>((event, emit) {
      emit(const ReportWizardState());
    });
  }
}
