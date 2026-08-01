import 'package:equatable/equatable.dart';

class ReportWizardState extends Equatable {
  final String? selectedClassId;
  final String? selectedClassName;
  final String? selectedYear;
  final String? selectedTerm;
  final String? selectedProfile;
  final List<String> enabledSections;
  final List<String> selectedStudentIds;

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
  });

  ReportWizardState copyWith({
    String? selectedClassId,
    String? selectedClassName,
    String? selectedYear,
    String? selectedTerm,
    String? selectedProfile,
    List<String>? enabledSections,
    List<String>? selectedStudentIds,
  }) {
    return ReportWizardState(
      selectedClassId: selectedClassId ?? this.selectedClassId,
      selectedClassName: selectedClassName ?? this.selectedClassName,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedTerm: selectedTerm ?? this.selectedTerm,
      selectedProfile: selectedProfile ?? this.selectedProfile,
      enabledSections: enabledSections ?? this.enabledSections,
      selectedStudentIds: selectedStudentIds ?? this.selectedStudentIds,
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
      ];
}
