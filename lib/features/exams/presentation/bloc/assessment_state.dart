import 'package:equatable/equatable.dart';
import '../../domain/entities/assessment_type.dart';
import '../../domain/entities/grading_system.dart';
import '../../domain/entities/assessment_mark.dart';

enum AssessmentStatus { initial, loading, loaded, saving, success, failure }

class AssessmentState extends Equatable {
  final AssessmentStatus status;
  final List<AssessmentType> assessmentTypes;
  final List<GradingSystem> gradingSystems;
  final List<AssessmentMark> marks;
  final String? errorMessage;

  const AssessmentState({
    this.status = AssessmentStatus.initial,
    this.assessmentTypes = const [],
    this.gradingSystems = const [],
    this.marks = const [],
    this.errorMessage,
  });

  AssessmentState copyWith({
    AssessmentStatus? status,
    List<AssessmentType>? assessmentTypes,
    List<GradingSystem>? gradingSystems,
    List<AssessmentMark>? marks,
    String? errorMessage,
  }) {
    return AssessmentState(
      status: status ?? this.status,
      assessmentTypes: assessmentTypes ?? this.assessmentTypes,
      gradingSystems: gradingSystems ?? this.gradingSystems,
      marks: marks ?? this.marks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, assessmentTypes, gradingSystems, marks, errorMessage];
}
