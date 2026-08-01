import 'package:flutter_bloc/flutter_bloc.dart';
import 'report_wizard_event.dart';
import 'report_wizard_state.dart';

class ReportWizardBloc extends Bloc<ReportWizardEvent, ReportWizardState> {
  ReportWizardBloc() : super(const ReportWizardState()) {
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

    on<ReportWizardReset>((event, emit) {
      emit(const ReportWizardState());
    });
  }
}
