import 'package:equatable/equatable.dart';
import '../../../domain/entities/fee_plan.dart';

abstract class FeePlanBuilderEvent extends Equatable {
  const FeePlanBuilderEvent();
  @override
  List<Object?> get props => [];
}

class FeePlansSubscriptionRequested extends FeePlanBuilderEvent {
  final String schoolId;
  const FeePlansSubscriptionRequested(this.schoolId);
  @override
  List<Object?> get props => [schoolId];
}

class FeePlansUpdated extends FeePlanBuilderEvent {
  final List<FeePlan> plans;
  const FeePlansUpdated(this.plans);
  @override
  List<Object?> get props => [plans];
}

class FeePlanArchiveRequested extends FeePlanBuilderEvent {
  final String schoolId;
  final String planId;
  const FeePlanArchiveRequested({required this.schoolId, required this.planId});
  @override
  List<Object?> get props => [schoolId, planId];
}

/// Publishes a brand-new plan, or (when [createNewVersion] is true) a new
/// version of an already-published plan with the same [planId]. Never
/// mutates a published version's lines directly - the callable is the only
/// path that can create/update a version.
class FeePlanPublishRequested extends FeePlanBuilderEvent {
  final String schoolId;
  final String? planId;
  final String academicYearId;
  final String termId;
  final String classId;
  final String studentCategory;
  final String name;
  final List<FeePlanLine> lines;
  final bool createNewVersion;

  const FeePlanPublishRequested({
    required this.schoolId,
    this.planId,
    required this.academicYearId,
    required this.termId,
    required this.classId,
    required this.studentCategory,
    required this.name,
    required this.lines,
    this.createNewVersion = false,
  });

  @override
  List<Object?> get props => [
    schoolId,
    planId,
    academicYearId,
    termId,
    classId,
    studentCategory,
    name,
    lines,
    createNewVersion,
  ];
}
