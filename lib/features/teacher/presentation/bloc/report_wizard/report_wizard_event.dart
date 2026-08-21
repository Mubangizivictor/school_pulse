import 'package:equatable/equatable.dart';

abstract class ReportWizardEvent extends Equatable {
  const ReportWizardEvent();

  @override
  List<Object?> get props => [];
}

class ReportWizardClassSelected extends ReportWizardEvent {
  final String schoolId;
  final String classId;
  final String className;

  const ReportWizardClassSelected({
    required this.schoolId,
    required this.classId,
    required this.className,
  });

  @override
  List<Object?> get props => [schoolId, classId, className];
}

class ReportWizardTermProfileSelected extends ReportWizardEvent {
  final String year;
  final String term;
  final String profile;

  const ReportWizardTermProfileSelected({
    required this.year,
    required this.term,
    required this.profile,
  });

  @override
  List<Object?> get props => [year, term, profile];
}

class ReportWizardSectionsUpdated extends ReportWizardEvent {
  final List<String> enabledSections;

  const ReportWizardSectionsUpdated(this.enabledSections);

  @override
  List<Object?> get props => [enabledSections];
}

class ReportWizardStudentsSelected extends ReportWizardEvent {
  final List<String> studentIds;

  const ReportWizardStudentsSelected(this.studentIds);

  @override
  List<Object?> get props => [studentIds];
}

class ReportWizardSubmitRequested extends ReportWizardEvent {}

class ReportWizardReset extends ReportWizardEvent {}
