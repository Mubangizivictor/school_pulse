import 'dart:async';

import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/staff_role_assignment.dart';
import '../../domain/repositories/staff_assignment_repository.dart';
import '../../domain/services/academic_calendar_service.dart';
import '../../domain/services/active_responsibility_service.dart';

class ActiveResponsibilityServiceImpl implements ActiveResponsibilityService {
  final StaffAssignmentRepository assignmentRepository;
  final AcademicCalendarService calendarService;

  ActiveResponsibilityContext? _current;
  final _controller = StreamController<ActiveResponsibilityContext?>.broadcast();

  ActiveResponsibilityServiceImpl({
    required this.assignmentRepository,
    required this.calendarService,
  });

  @override
  ActiveResponsibilityContext? get current => _current;

  @override
  Stream<ActiveResponsibilityContext?> get changes => _controller.stream;

  @override
  Future<Either<Failure, ResponsibilityResolution>> resolve({
    required String schoolId,
    required String userId,
    bool forceRefresh = false,
  }) async {
    final period = await calendarService.getCurrentPeriod();

    // Scope to the current academic year only when the school has one set.
    // A school mid-way through configuring its calendar still gets a working
    // panel rather than an empty switcher.
    final assignmentsResult = await assignmentRepository.getValidAssignments(
      schoolId: schoolId,
      userId: userId,
      academicYearId: period.hasYear ? period.academicYearId : null,
      forceRefresh: forceRefresh,
    );

    return assignmentsResult.fold<Future<Either<Failure, ResponsibilityResolution>>>(
      (failure) async => Left(failure),
      (available) async {
        if (available.isEmpty) {
          _setCurrent(null);
          return const Right(ResponsibilityResolution());
        }

        final persistedResult = await assignmentRepository.getPersistedAssignmentId();
        final persistedId = persistedResult.getOrElse(() => null);

        final restored =
            available.where((a) => a.id == persistedId).firstOrNull;

        // Falling back is the normal path after an admin ends an assignment,
        // so it is a switch with an explanation rather than an error.
        final chosen = restored ?? available.first;
        final switchReason = (persistedId != null && restored == null)
            ? 'Your previous responsibility is no longer available. '
                'Switched to ${chosen.displayLabel}.'
            : null;

        final context = _buildContext(chosen, period);
        _setCurrent(context);
        await assignmentRepository.persistSelectedAssignment(chosen.id);

        return Right(ResponsibilityResolution(
          available: available,
          active: context,
          switchReason: switchReason,
        ));
      },
    );
  }

  @override
  Future<Either<Failure, ActiveResponsibilityContext>> switchTo({
    required String assignmentId,
    required String schoolId,
    required String userId,
  }) async {
    // Verified against the server, not against the list the switcher was
    // drawn from - that list may be seconds out of date, and switching is
    // exactly when a revoked assignment must be caught.
    final verified = await assignmentRepository.verifyAssignment(
      schoolId: schoolId,
      assignmentId: assignmentId,
      userId: userId,
    );

    return verified.fold<Future<Either<Failure, ActiveResponsibilityContext>>>(
      (failure) async => Left(failure),
      (assignment) async {
        final period = await calendarService.getCurrentPeriod();
        final context = _buildContext(assignment, period);
        _setCurrent(context);
        await assignmentRepository.persistSelectedAssignment(assignment.id);
        return Right(context);
      },
    );
  }

  @override
  Future<Either<Failure, ActiveResponsibilityContext>> revalidate() async {
    final active = _current;
    if (active == null) {
      return const Left(AssignmentInvalidFailure('No active responsibility.'));
    }

    final verified = await assignmentRepository.verifyAssignment(
      schoolId: active.schoolId,
      assignmentId: active.roleAssignmentId,
      userId: active.userId,
    );

    return verified.fold<Future<Either<Failure, ActiveResponsibilityContext>>>(
      (failure) async {
        // The assignment stopped granting access while the screen was open.
        // The context is downgraded rather than dropped so the screen can
        // show a permission message with the right subject still named.
        _setCurrent(active.copyWith(assignmentStatus: AssignmentStatus.suspended));
        return Left(failure);
      },
      (assignment) async {
        final period = await calendarService.getCurrentPeriod();
        // Permissions are re-read here as well: an admin may have narrowed
        // the scope without ending the assignment.
        final context = _buildContext(assignment, period);
        _setCurrent(context);
        return Right(context);
      },
    );
  }

  @override
  Future<void> clear({String? schoolId}) async {
    await assignmentRepository.clearCache(schoolId: schoolId);
    _setCurrent(null);
  }

  ActiveResponsibilityContext _buildContext(
    StaffRoleAssignment assignment,
    AcademicPeriod period,
  ) {
    return ActiveResponsibilityContext.fromAssignment(
      assignment,
      termId: period.termId,
      termName: period.termName,
      academicYearName: period.academicYearName,
    );
  }

  void _setCurrent(ActiveResponsibilityContext? context) {
    if (_current == context) return;
    _current = context;
    if (!_controller.isClosed) _controller.add(context);
  }

  /// Closes the change stream. Only for teardown in tests and on sign-out.
  Future<void> dispose() => _controller.close();
}
