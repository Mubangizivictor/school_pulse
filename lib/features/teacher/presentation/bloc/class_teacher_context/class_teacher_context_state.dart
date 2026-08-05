import 'package:equatable/equatable.dart';

import '../../../domain/entities/active_responsibility_context.dart';
import '../../../domain/entities/staff_role_assignment.dart';

/// Why the Class Teacher panel has no usable class. Each is a distinct state
/// in the approved UI, rendered through the existing empty-state components -
/// never a generic error.
enum ClassContextUnavailableReason {
  /// The account holds no Class Teacher row at all.
  noClassAssignment,

  /// A Class Teacher row exists but an admin suspended it.
  assignmentSuspended,

  /// A Class Teacher row exists but today is outside its date range.
  assignmentExpired,

  /// The school has not flagged a current academic year yet. Nothing in the
  /// panel can be scoped without one, so this blocks rather than degrades.
  noAcademicYear,

  loadFailed,
}

class ClassTeacherContextState extends Equatable {
  final bool isLoading;

  /// True while switching, so the dashboard shows its switching state without
  /// tearing down the content already on screen.
  final bool isSwitching;

  /// The Class Teacher context in effect. Every class-scoped query derives its
  /// coordinates from this and never from the widget tree.
  final ActiveResponsibilityContext? active;

  /// Every responsibility on the profile, for the switcher.
  final List<StaffRoleAssignment> available;

  final ClassContextUnavailableReason? unavailableReason;
  final String? errorMessage;

  /// False when the school has an academic year open but has not flagged a
  /// current term. The panel still works - the roster and attendance do not
  /// need a term - but report entry and term summaries do, and they read this
  /// rather than discovering an empty `termId` halfway through a write.
  final bool hasCurrentTerm;

  /// One-shot message explaining an automatic switch, e.g. after an admin
  /// ended the class responsibility in use. Cleared once shown.
  final String? notice;

  /// Set when the teacher switched to a responsibility this panel does not
  /// serve. The router reads it, opens that panel, and the bloc clears it -
  /// Subject Teacher work is never duplicated inside the Class Teacher panel.
  final StaffResponsibilityType? handOffTo;

  const ClassTeacherContextState({
    this.isLoading = false,
    this.isSwitching = false,
    this.active,
    this.available = const [],
    this.unavailableReason,
    this.errorMessage,
    this.hasCurrentTerm = true,
    this.notice,
    this.handOffTo,
  });

  const ClassTeacherContextState.initial() : this(isLoading: true);

  bool get hasActive => active != null;

  /// Every Class Teacher row on the profile. Normally one; more only where a
  /// school enabled the audited multi-class override.
  List<StaffRoleAssignment> get classAssignments => available
      .where((a) => a.roleType == StaffResponsibilityType.classTeacher)
      .toList();

  /// The responsibilities reached through the role switcher - subject
  /// teaching, headships, and anything else the same account holds.
  List<StaffRoleAssignment> get otherResponsibilities => available
      .where((a) => a.roleType != StaffResponsibilityType.classTeacher)
      .toList();

  /// Subject Teacher rows specifically, for the "My Subjects" entry in More.
  List<StaffRoleAssignment> get subjectAssignments => available
      .where((a) => a.roleType == StaffResponsibilityType.subjectTeacher)
      .toList();

  ClassTeacherContextState copyWith({
    bool? isLoading,
    bool? isSwitching,
    ActiveResponsibilityContext? active,
    List<StaffRoleAssignment>? available,
    ClassContextUnavailableReason? unavailableReason,
    String? errorMessage,
    bool? hasCurrentTerm,
    String? notice,
    StaffResponsibilityType? handOffTo,
    bool clearActive = false,
    bool clearUnavailable = false,
    bool clearError = false,
    bool clearNotice = false,
    bool clearHandOff = false,
  }) {
    return ClassTeacherContextState(
      isLoading: isLoading ?? this.isLoading,
      isSwitching: isSwitching ?? this.isSwitching,
      active: clearActive ? null : (active ?? this.active),
      available: available ?? this.available,
      unavailableReason: clearUnavailable
          ? null
          : (unavailableReason ?? this.unavailableReason),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasCurrentTerm: hasCurrentTerm ?? this.hasCurrentTerm,
      notice: clearNotice ? null : (notice ?? this.notice),
      handOffTo: clearHandOff ? null : (handOffTo ?? this.handOffTo),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSwitching,
    active,
    available,
    unavailableReason,
    errorMessage,
    hasCurrentTerm,
    notice,
    handOffTo,
  ];
}
