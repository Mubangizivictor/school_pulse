import 'package:equatable/equatable.dart';

import '../../../domain/entities/active_responsibility_context.dart';
import '../../../domain/entities/staff_role_assignment.dart';

/// Why the panel has no usable responsibility. Each of these is a distinct
/// screen state in the approved UI, not a generic error.
enum ContextUnavailableReason {
  noAssignments,
  assignmentSuspended,
  assignmentExpired,
  noAcademicYear,
  loadFailed,
}

class SubjectTeacherContextState extends Equatable {
  final bool isLoading;

  /// True while switching, so the dashboard can show its switching state
  /// without tearing down the content already on screen.
  final bool isSwitching;

  final ActiveResponsibilityContext? active;
  final List<StaffRoleAssignment> available;
  final ContextUnavailableReason? unavailableReason;
  final String? errorMessage;

  /// One-shot message explaining an automatic switch, e.g. after an admin
  /// ended the responsibility that was in use. Cleared once shown.
  final String? notice;

  const SubjectTeacherContextState({
    this.isLoading = false,
    this.isSwitching = false,
    this.active,
    this.available = const [],
    this.unavailableReason,
    this.errorMessage,
    this.notice,
  });

  const SubjectTeacherContextState.initial() : this(isLoading: true);

  bool get hasActive => active != null;

  /// The subject assignments the "Change Class/Subject" control lists.
  List<StaffRoleAssignment> get subjectAssignments => available
      .where((a) => a.roleType == StaffResponsibilityType.subjectTeacher)
      .toList();

  /// Subject assignments other than the one in effect, for the dashboard's
  /// "Other Subjects" tab.
  List<StaffRoleAssignment> get otherSubjectAssignments => subjectAssignments
      .where((a) => a.subjectId != active?.subjectId)
      .toList();

  /// Assignments for the subject currently in effect - the "Subject Classes"
  /// tab, i.e. every class this teacher takes for this subject.
  List<StaffRoleAssignment> get currentSubjectClasses {
    final subjectId = active?.subjectId;
    if (subjectId == null) return const [];
    return subjectAssignments.where((a) => a.subjectId == subjectId).toList();
  }

  /// The single class-teacher responsibility, when the school gave them one.
  StaffRoleAssignment? get classTeacherAssignment => available
      .where((a) => a.roleType == StaffResponsibilityType.classTeacher)
      .firstOrNull;

  /// Responsibilities beyond subject teaching, reached through the role
  /// switcher.
  List<StaffRoleAssignment> get otherResponsibilities => available
      .where((a) => a.roleType != StaffResponsibilityType.subjectTeacher)
      .toList();

  SubjectTeacherContextState copyWith({
    bool? isLoading,
    bool? isSwitching,
    ActiveResponsibilityContext? active,
    List<StaffRoleAssignment>? available,
    ContextUnavailableReason? unavailableReason,
    String? errorMessage,
    String? notice,
    bool clearActive = false,
    bool clearUnavailable = false,
    bool clearError = false,
    bool clearNotice = false,
  }) {
    return SubjectTeacherContextState(
      isLoading: isLoading ?? this.isLoading,
      isSwitching: isSwitching ?? this.isSwitching,
      active: clearActive ? null : (active ?? this.active),
      available: available ?? this.available,
      unavailableReason: clearUnavailable
          ? null
          : (unavailableReason ?? this.unavailableReason),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      notice: clearNotice ? null : (notice ?? this.notice),
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
    notice,
  ];
}
