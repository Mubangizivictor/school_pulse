import 'package:equatable/equatable.dart';

enum ReportWizardStatus { initial, loading, success, failure }

class ReportWizardState extends Equatable {
  final String? selectedClassId;
  final String? selectedClassName;
  final String? selectedYear;
  final String? selectedTerm;
  final String? selectedProfile;
  final List<String> enabledSections;
  final List<String> selectedStudentIds;
  final ReportWizardStatus status;
  final String? errorMessage;

  const ReportWizardState({
    this.selectedClassId,
    this.selectedClassName,
    this.selectedYear,
    this.selectedTerm,
    this.selectedProfile,
    this.enabledSections = const [
      'Academic Performance',
      'Competency Development',
      'Attendance & Punctuality',
      'Behaviour & Conduct',
      'Teacher\'s Comment',
      'Next Steps / Recommendations',
    ],
    this.selectedStudentIds = const [],
    this.status = ReportWizardStatus.initial,
    this.errorMessage,
  });

  ReportWizardState copyWith({
    String? selectedClassId,
    String? selectedClassName,
    String? selectedYear,
    String? selectedTerm,
    String? selectedProfile,
    List<String>? enabledSections,
    List<String>? selectedStudentIds,
    ReportWizardStatus? status,
    String? errorMessage,
  }) {
    return ReportWizardState(
      selectedClassId: selectedClassId ?? this.selectedClassId,
      selectedClassName: selectedClassName ?? this.selectedClassName,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedTerm: selectedTerm ?? this.selectedTerm,
      selectedProfile: selectedProfile ?? this.selectedProfile,
      enabledSections: enabledSections ?? this.enabledSections,
      selectedStudentIds: selectedStudentIds ?? this.selectedStudentIds,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        selectedClassId,
        selectedClassName,
        selectedYear,
        selectedTerm,
        selectedProfile,
        enabledSections,
        selectedStudentIds,
        status,
        errorMessage,
      ];
}
