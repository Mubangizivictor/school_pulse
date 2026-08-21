import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../../../domain/entities/active_responsibility_context.dart';
import '../../../domain/entities/class_dashboard_summary.dart';
import '../../../domain/entities/lesson.dart';
import '../../../domain/repositories/class_dashboard_repository.dart';

abstract class ClassTeacherDashboardEvent extends Equatable {
  const ClassTeacherDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) the home tab for a class. Raised on open, on
/// pull-to-refresh, and every time the active responsibility changes - which
/// is what clears the previous class's figures.
class ClassDashboardRequested extends ClassTeacherDashboardEvent {
  final ActiveResponsibilityContext context;
  final bool forceRefresh;

  const ClassDashboardRequested(this.context, {this.forceRefresh = false});

  @override
  List<Object?> get props => [context, forceRefresh];
}

/// Everything the Class Teacher home tab renders.
///
/// The counts are nullable on purpose. A tile with no data yet renders as a
/// dash, because "the register has not been taken" and "nobody was absent"
/// are different facts, and a dashboard showing 0 for both is lying to the
/// teacher about a class they are responsible for.
class ClassTeacherDashboardState extends Equatable {
  final bool isLoading;
  final String? errorMessage;

  /// The assignment these figures belong to. Held so a late response from a
  /// previous class can be discarded instead of painting over the new one.
  final String? roleAssignmentId;

  final ClassDashboardSummary? summary;

  const ClassTeacherDashboardState({
    this.isLoading = false,
    this.errorMessage,
    this.roleAssignmentId,
    this.summary,
  });

  const ClassTeacherDashboardState.initial() : this(isLoading: true);

  bool get hasSummary => summary != null;

  int? get totalStudents => summary?.totalStudents;

  /// Null until the register exists, so the tile shows a dash rather than
  /// claiming a full house.
  int? get presentToday => summary != null && summary!.attendance.hasSession
      ? summary!.attendance.presentCount
      : null;

  int? get absentToday => summary != null && summary!.attendance.hasSession
      ? summary!.attendance.absentCount
      : null;

  int? get pendingAssignments => summary?.pendingAssignments;

  List<Lesson> get todaysSchedule => summary?.todaysSchedule ?? const [];

  List<ClassActivityEntry> get recentActivities =>
      summary?.recentActivities ?? const [];

  bool get isFromCache => summary?.isFromCache ?? false;

  /// True when the class has students but no register for today - the state
  /// the "Roll Call" quick action exists for.
  bool get attendanceOutstanding {
    final s = summary;
    if (s == null) return false;
    return s.totalStudents > 0 && !s.attendance.isSubmitted;
  }

  double? _percentOf(int? value) {
    final total = summary?.totalStudents;
    if (value == null || total == null || total == 0) return null;
    return (value / total) * 100;
  }

  double? get presentPercentage => _percentOf(presentToday);
  double? get absentPercentage => _percentOf(absentToday);

  ClassTeacherDashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? roleAssignmentId,
    ClassDashboardSummary? summary,
    bool clearError = false,
  }) {
    return ClassTeacherDashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      roleAssignmentId: roleAssignmentId ?? this.roleAssignmentId,
      summary: summary ?? this.summary,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    roleAssignmentId,
    summary,
  ];
}

/// Deliberately not unified with [SubjectTeacherDashboardBloc] despite the
/// similar shape (stale-response guard on `roleAssignmentId`, near-identical
/// `_messageFor`): this bloc makes a single repository call producing one
/// rich summary, while the subject dashboard fans out two independent
/// repository calls and folds their failures separately. A shared base would
/// have to either force a fan-out shape on this bloc or hide a
/// single-vs-fan-out branch inside the base - both worse than the small
/// amount of duplication left as-is.
class ClassTeacherDashboardBloc
    extends Bloc<ClassTeacherDashboardEvent, ClassTeacherDashboardState> {
  final ClassDashboardRepository dashboardRepository;

  ClassTeacherDashboardBloc({required this.dashboardRepository})
    : super(const ClassTeacherDashboardState.initial()) {
    on<ClassDashboardRequested>(_onRequested);
  }

  Future<void> _onRequested(
    ClassDashboardRequested event,
    Emitter<ClassTeacherDashboardState> emit,
  ) async {
    // Start from a clean state rather than copyWith: carrying the previous
    // assignment's numbers across a switch would briefly show P5 East's
    // roster under P6 West.
    emit(
      ClassTeacherDashboardState(
        isLoading: true,
        roleAssignmentId: event.context.roleAssignmentId,
      ),
    );

    final result = await dashboardRepository.getDashboard(
      context: event.context,
      forceRefresh: event.forceRefresh,
    );

    // The teacher may have switched again while this was in flight.
    if (state.roleAssignmentId != event.context.roleAssignmentId) return;

    result.fold(
      (failure) => emit(
        state.copyWith(isLoading: false, errorMessage: _messageFor(failure)),
      ),
      (summary) => emit(
        state.copyWith(isLoading: false, summary: summary, clearError: true),
      ),
    );
  }

  String _messageFor(Failure failure) => switch (failure) {
    PermissionDeniedFailure() => failure.message,
    AssignmentInvalidFailure() => failure.message,
    NetworkFailure() => failure.message,
    ValidationFailure() => failure.message,
    _ => 'Could not load your class. Pull down to retry.',
  };
}
