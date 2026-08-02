import 'package:equatable/equatable.dart';

abstract class ClassTeacherContextEvent extends Equatable {
  const ClassTeacherContextEvent();

  @override
  List<Object?> get props => [];
}

/// Load the teacher's responsibilities and settle on the Class Teacher one.
class ClassContextRequested extends ClassTeacherContextEvent {
  final String schoolId;
  final String userId;
  final bool forceRefresh;

  const ClassContextRequested({
    required this.schoolId,
    required this.userId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [schoolId, userId, forceRefresh];
}

/// Switch to another responsibility the same account holds. When the target
/// is not a Class Teacher row the panel hands over to the matching one, which
/// is why the resulting state carries [ClassTeacherContextState.handOffTo].
class ClassContextSwitched extends ClassTeacherContextEvent {
  final String assignmentId;

  const ClassContextSwitched(this.assignmentId);

  @override
  List<Object?> get props => [assignmentId];
}

/// Re-check the active assignment against the server. Raised before sensitive
/// writes and when the app returns to the foreground, so a permission an admin
/// removed mid-session is caught before it is spent.
class ClassContextRevalidated extends ClassTeacherContextEvent {
  const ClassContextRevalidated();
}

/// An admin changed this teacher's assignments while the panel was open.
class ClassContextAssignmentsChanged extends ClassTeacherContextEvent {
  const ClassContextAssignmentsChanged();
}

/// Dismiss the one-shot notice after the UI has shown it.
class ClassContextNoticeCleared extends ClassTeacherContextEvent {
  const ClassContextNoticeCleared();
}

/// Acknowledge a hand-off after the router has opened the other panel.
class ClassContextHandOffConsumed extends ClassTeacherContextEvent {
  const ClassContextHandOffConsumed();
}

/// Drop everything on logout or school switch.
class ClassContextCleared extends ClassTeacherContextEvent {
  const ClassContextCleared();
}
