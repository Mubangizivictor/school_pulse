import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../../../domain/entities/staff_role_assignment.dart';
import '../../../domain/repositories/staff_assignment_repository.dart';
import '../../../domain/services/active_responsibility_service.dart';

/// Shared plumbing behind [ClassTeacherContextBloc] and
/// [SubjectTeacherContextBloc]: both blocs resolve "which responsibility is
/// this panel acting under" from the same [ActiveResponsibilityService], and
/// both need the same assignment-change subscription, switch/revalidate/clear
/// skeleton, and failure-to-message mapping around it.
///
/// What differs between the two panels - how a fresh load picks an assignment
/// (Class Teacher adopts an already-active class row before falling back to
/// [ClassTeacherAssignmentService]; Subject Teacher always calls
/// [ActiveResponsibilityService.resolve] directly) and what a state looks like
/// - stays in each bloc. This mixin only owns the parts that were previously
/// copied verbatim, so it is deliberately narrower than a generic base class
/// over the state/event types: those differ enough (extra unavailable-reason
/// values, class-only `handOffTo`/`hasCurrentTerm`, subject-only derived
/// assignment lists) that forcing one shape on both would leak into the
/// approved UI.
mixin TeacherResponsibilityContextMixin<TEvent, TState> on BlocBase<TState> {
  ActiveResponsibilityService get responsibilityService;
  StaffAssignmentRepository get assignmentRepository;

  StreamSubscription<List<StaffRoleAssignment>>? _assignmentWatch;
  String? _schoolId;
  String? _userId;

  String? get schoolId => _schoolId;
  String? get userId => _userId;

  void setActiveAccount({required String schoolId, required String userId}) {
    _schoolId = schoolId;
    _userId = userId;
  }

  /// The event this bloc raises when an admin changes the teacher's rows
  /// while the panel is open - each bloc's own type, so `add()` still speaks
  /// its normal event vocabulary.
  TEvent get assignmentsChangedEvent;

  /// Subscribes to the teacher's assignment rows so a suspension or re-scope
  /// reaches an open panel immediately rather than at the next cold start.
  void listenForAssignmentChanges(void Function(TEvent event) add) {
    final schoolId = _schoolId;
    final userId = _userId;
    if (schoolId == null || userId == null || _assignmentWatch != null) return;

    _assignmentWatch = assignmentRepository
        .watchAssignments(schoolId: schoolId, userId: userId)
        .listen(
          (_) => add(assignmentsChangedEvent),
          // A dropped listener must not break the panel; the revalidate before
          // every sensitive write still catches revocations.
          onError: (_) {},
        );
  }

  Future<void> cancelAssignmentWatch() async {
    await _assignmentWatch?.cancel();
    _assignmentWatch = null;
  }

  Future<void> clearAccount() async {
    await cancelAssignmentWatch();
    await responsibilityService.clear(schoolId: _schoolId);
    _schoolId = null;
    _userId = null;
  }

  String messageFor(Failure failure, {required String offlineNoun}) =>
      switch (failure) {
        AssignmentInvalidFailure() => failure.message,
        PermissionDeniedFailure() => failure.message,
        NetworkFailure() => 'You are offline. Showing your saved $offlineNoun.',
        CacheFailure() => 'Could not read your saved $offlineNoun.',
        // Raw Firestore text never reaches the user - it leaks document
        // paths and internal ids.
        _ => 'Could not load your $offlineNoun. Pull down to retry.',
      };
}
