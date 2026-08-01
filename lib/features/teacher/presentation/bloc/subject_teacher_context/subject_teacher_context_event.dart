import 'package:equatable/equatable.dart';

abstract class SubjectTeacherContextEvent extends Equatable {
  const SubjectTeacherContextEvent();

  @override
  List<Object?> get props => [];
}

/// Load the teacher's responsibilities and restore the last-used one.
class ContextRequested extends SubjectTeacherContextEvent {
  final String schoolId;
  final String userId;
  final bool forceRefresh;

  const ContextRequested({
    required this.schoolId,
    required this.userId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [schoolId, userId, forceRefresh];
}

/// Switch to another responsibility - a different subject, a different class
/// of the same subject, or a non-teaching role the same account holds.
class ContextSwitched extends SubjectTeacherContextEvent {
  final String assignmentId;

  const ContextSwitched(this.assignmentId);

  @override
  List<Object?> get props => [assignmentId];
}

/// Re-check the active assignment against the server. Raised before
/// sensitive writes and when the app returns to the foreground.
class ContextRevalidated extends SubjectTeacherContextEvent {
  const ContextRevalidated();
}

/// An admin changed this teacher's assignments while the panel was open.
class ContextAssignmentsChanged extends SubjectTeacherContextEvent {
  const ContextAssignmentsChanged();
}

/// Dismiss the one-shot notice after the UI has shown it.
class ContextNoticeCleared extends SubjectTeacherContextEvent {
  const ContextNoticeCleared();
}

/// Drop everything on logout or school switch.
class ContextCleared extends SubjectTeacherContextEvent {
  const ContextCleared();
}
