import 'package:equatable/equatable.dart';
import '../../domain/entities/assessment_type.dart';
import '../../domain/entities/assessment_mark.dart';

enum AssessmentStatus { initial, loading, loaded, saving, success, failure }

class AssessmentState extends Equatable {
  final AssessmentStatus status;
  final List<AssessmentType> assessmentTypes;
  final List<AssessmentMark> marks;
  final String? errorMessage;

  const AssessmentState({
    this.status = AssessmentStatus.initial,
    this.assessmentTypes = const [],
    this.marks = const [],
    this.errorMessage,
  });

  AssessmentState copyWith({
    AssessmentStatus? status,
    List<AssessmentType>? assessmentTypes,
    List<AssessmentMark>? marks,
    String? errorMessage,
  }) {
    return AssessmentState(
      status: status ?? this.status,
      assessmentTypes: assessmentTypes ?? this.assessmentTypes,
      marks: marks ?? this.marks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, assessmentTypes, marks, errorMessage];
}
