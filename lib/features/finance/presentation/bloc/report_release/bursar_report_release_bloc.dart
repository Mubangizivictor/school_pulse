import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/features/finance/domain/entities/financial_clearance_policy.dart';
import 'package:school_pulse/features/finance/domain/entities/report_release_eligibility.dart';

import '../../../data/datasources/bursar_report_release_remote_data_source.dart'
    show BursarReportReleaseRemoteDataSource, ReportPeriodFacets;

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

abstract class BursarReportReleaseEvent extends Equatable {
  const BursarReportReleaseEvent();
  @override
  List<Object?> get props => [];
}

/// One-time: discover the school's finalized-report periods for the filter
/// dropdowns, then (if a year+term can be inferred) load that list.
class BursarReportReleaseStarted extends BursarReportReleaseEvent {
  final String schoolId;
  const BursarReportReleaseStarted(this.schoolId);
  @override
  List<Object?> get props => [schoolId];
}

/// Load (or reload) the eligibility list for a period + optional class.
class BursarReportReleaseRequested extends BursarReportReleaseEvent {
  final String academicYearId;
  final String termId;
  final String? classId;
  const BursarReportReleaseRequested({
    required this.academicYearId,
    required this.termId,
    this.classId,
  });
  @override
  List<Object?> get props => [academicYearId, termId, classId];
}

/// Change one or more client-side filters (does not refetch unless the
/// period/class changed - the list is filtered in memory for the rest).
class BursarReportReleaseFiltersChanged extends BursarReportReleaseEvent {
  final String? academicYearId;
  final String? termId;
  final String? classId;
  final String? streamId;
  final String? learnerQuery;
  final ReportReleaseUiStatus? statusFilter;
  final bool clearStatus;
  final bool clearStream;
  const BursarReportReleaseFiltersChanged({
    this.academicYearId,
    this.termId,
    this.classId,
    this.streamId,
    this.learnerQuery,
    this.statusFilter,
    this.clearStatus = false,
    this.clearStream = false,
  });
  @override
  List<Object?> get props => [
    academicYearId,
    termId,
    classId,
    streamId,
    learnerQuery,
    statusFilter,
    clearStatus,
    clearStream,
  ];
}

class BursarReleaseExceptionGranted extends BursarReportReleaseEvent {
  final String studentId;
  final String academicYearId;
  final String termId;
  final String reasonCode;
  final String? reasonNote;
  final DateTime? expiresAt;
  const BursarReleaseExceptionGranted({
    required this.studentId,
    required this.academicYearId,
    required this.termId,
    required this.reasonCode,
    this.reasonNote,
    this.expiresAt,
  });
  @override
  List<Object?> get props => [
    studentId,
    academicYearId,
    termId,
    reasonCode,
    reasonNote,
    expiresAt,
  ];
}

class BursarReleaseExceptionApproved extends BursarReportReleaseEvent {
  final String exceptionId;
  final String? note;
  const BursarReleaseExceptionApproved(this.exceptionId, {this.note});
  @override
  List<Object?> get props => [exceptionId, note];
}

/// Reject = revoke a `pendingApproval` exception.
class BursarReleaseExceptionRejected extends BursarReportReleaseEvent {
  final String exceptionId;
  final String reason;
  const BursarReleaseExceptionRejected(this.exceptionId, this.reason);
  @override
  List<Object?> get props => [exceptionId, reason];
}

class BursarReleaseExceptionRevoked extends BursarReportReleaseEvent {
  final String exceptionId;
  final String reason;
  const BursarReleaseExceptionRevoked(this.exceptionId, this.reason);
  @override
  List<Object?> get props => [exceptionId, reason];
}

class BursarReleaseExceptionRenewed extends BursarReportReleaseEvent {
  final String exceptionId;
  final DateTime newExpiresAt;
  final String? reasonNote;
  const BursarReleaseExceptionRenewed(
    this.exceptionId,
    this.newExpiresAt, {
    this.reasonNote,
  });
  @override
  List<Object?> get props => [exceptionId, newExpiresAt, reasonNote];
}

/// The legacy flat Bursar override (Direct override bar).
class BursarReportDirectOverride extends BursarReportReleaseEvent {
  final List<String> reportCardIds;
  final String action; // release | hold | revoke
  final String reason;
  const BursarReportDirectOverride({
    required this.reportCardIds,
    required this.action,
    required this.reason,
  });
  @override
  List<Object?> get props => [reportCardIds, action, reason];
}

class BursarReportReleaseFeedbackCleared extends BursarReportReleaseEvent {
  const BursarReportReleaseFeedbackCleared();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class BursarReportReleaseState extends Equatable {
  final bool isLoading;
  final bool isActing;
  final String? errorMessage;
  final String? successMessage;

  final String academicYearId;
  final String termId;
  final String? classId;
  final String? streamId;
  final String learnerQuery;
  final ReportReleaseUiStatus? statusFilter;

  final List<ReportReleaseEligibilityRow> allRows;
  final FinancialClearancePolicy policy;
  final String schoolId;
  final ReportPeriodFacets? facets;

  const BursarReportReleaseState({
    this.isLoading = false,
    this.isActing = false,
    this.errorMessage,
    this.successMessage,
    this.academicYearId = '',
    this.termId = '',
    this.classId,
    this.streamId,
    this.learnerQuery = '',
    this.statusFilter,
    this.allRows = const [],
    this.policy = const FinancialClearancePolicy(),
    this.schoolId = '',
    this.facets,
  });

  const BursarReportReleaseState.initial() : this(isLoading: false);

  /// Rows after the in-memory stream + learner + status filters.
  List<ReportReleaseEligibilityRow> get visibleRows {
    final q = learnerQuery.trim().toLowerCase();
    return allRows.where((r) {
      if (streamId != null &&
          streamId!.isNotEmpty &&
          (r.streamId ?? '') != streamId) {
        return false;
      }
      if (q.isNotEmpty && !r.studentName.toLowerCase().contains(q)) {
        return false;
      }
      if (statusFilter != null && r.uiStatus != statusFilter) return false;
      return true;
    }).toList();
  }

  List<ReportReleaseEligibilityRow> section(ReportReleaseUiStatus s) =>
      visibleRows.where((r) => r.uiStatus == s).toList();

  /// Distinct stream ids present in the loaded rows (for the filter chips).
  List<String> get availableStreams =>
      allRows
          .map((r) => r.streamId)
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  bool get canLoad => academicYearId.isNotEmpty && termId.isNotEmpty;

  BursarReportReleaseState copyWith({
    bool? isLoading,
    bool? isActing,
    String? errorMessage,
    String? successMessage,
    String? academicYearId,
    String? termId,
    String? classId,
    String? streamId,
    String? learnerQuery,
    ReportReleaseUiStatus? statusFilter,
    List<ReportReleaseEligibilityRow>? allRows,
    FinancialClearancePolicy? policy,
    String? schoolId,
    ReportPeriodFacets? facets,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearStatus = false,
    bool clearStream = false,
  }) {
    return BursarReportReleaseState(
      isLoading: isLoading ?? this.isLoading,
      isActing: isActing ?? this.isActing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      academicYearId: academicYearId ?? this.academicYearId,
      termId: termId ?? this.termId,
      classId: classId ?? this.classId,
      streamId: clearStream ? null : (streamId ?? this.streamId),
      learnerQuery: learnerQuery ?? this.learnerQuery,
      statusFilter: clearStatus ? null : (statusFilter ?? this.statusFilter),
      allRows: allRows ?? this.allRows,
      policy: policy ?? this.policy,
      schoolId: schoolId ?? this.schoolId,
      facets: facets ?? this.facets,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isActing,
    errorMessage,
    successMessage,
    academicYearId,
    termId,
    classId,
    streamId,
    learnerQuery,
    statusFilter,
    allRows,
    policy,
    schoolId,
    facets,
  ];
}

// ---------------------------------------------------------------------------
// Bloc
// ---------------------------------------------------------------------------

class BursarReportReleaseBloc
    extends Bloc<BursarReportReleaseEvent, BursarReportReleaseState> {
  final BursarReportReleaseRemoteDataSource dataSource;

  BursarReportReleaseBloc({required this.dataSource})
    : super(const BursarReportReleaseState.initial()) {
    on<BursarReportReleaseStarted>(_onStarted);
    on<BursarReportReleaseRequested>(_onRequested);
    on<BursarReportReleaseFiltersChanged>(_onFiltersChanged);
    on<BursarReleaseExceptionGranted>(_onGranted);
    on<BursarReleaseExceptionApproved>(_onApproved);
    on<BursarReleaseExceptionRejected>(_onRejected);
    on<BursarReleaseExceptionRevoked>(_onRevoked);
    on<BursarReleaseExceptionRenewed>(_onRenewed);
    on<BursarReportDirectOverride>(_onDirectOverride);
    on<BursarReportReleaseFeedbackCleared>(
      (e, emit) => emit(state.copyWith(clearError: true, clearSuccess: true)),
    );
  }

  Future<void> _onStarted(
    BursarReportReleaseStarted event,
    Emitter<BursarReportReleaseState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, schoolId: event.schoolId));
    try {
      final facets = await dataSource.getReportPeriods(
        schoolId: event.schoolId,
      );
      final year = facets.years.isNotEmpty ? facets.years.first : '';
      final term = facets.terms.isNotEmpty ? facets.terms.first : '';
      emit(
        state.copyWith(
          facets: facets,
          academicYearId: year,
          termId: term,
          clearError: true,
        ),
      );
      if (year.isNotEmpty && term.isNotEmpty) {
        await _load(emit);
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Could not load report periods.',
        ),
      );
    }
  }

  Future<void> _onRequested(
    BursarReportReleaseRequested event,
    Emitter<BursarReportReleaseState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        academicYearId: event.academicYearId,
        termId: event.termId,
        classId: event.classId,
        clearError: true,
        clearSuccess: true,
      ),
    );
    await _load(emit);
  }

  Future<void> _onFiltersChanged(
    BursarReportReleaseFiltersChanged event,
    Emitter<BursarReportReleaseState> emit,
  ) async {
    final periodOrClassChanged =
        (event.academicYearId != null &&
            event.academicYearId != state.academicYearId) ||
        (event.termId != null && event.termId != state.termId) ||
        (event.classId != null && event.classId != state.classId);

    emit(
      state.copyWith(
        academicYearId: event.academicYearId,
        termId: event.termId,
        classId: event.classId,
        streamId: event.streamId,
        learnerQuery: event.learnerQuery,
        statusFilter: event.statusFilter,
        clearStatus: event.clearStatus,
        clearStream: event.clearStream,
      ),
    );

    if (periodOrClassChanged && state.canLoad) {
      emit(state.copyWith(isLoading: true, clearError: true));
      await _load(emit);
    }
  }

  Future<void> _load(Emitter<BursarReportReleaseState> emit) async {
    if (!state.canLoad) {
      emit(state.copyWith(isLoading: false, allRows: const []));
      return;
    }
    try {
      final result = await dataSource.getEligibility(
        academicYearId: state.academicYearId,
        termId: state.termId,
        classId: state.classId,
      );
      emit(
        state.copyWith(
          isLoading: false,
          allRows: result.rows,
          policy: result.policy,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Could not load report-card release eligibility.',
        ),
      );
    }
  }

  Future<void> _runAction(
    Emitter<BursarReportReleaseState> emit,
    Future<void> Function() action,
    String successMessage,
  ) async {
    emit(state.copyWith(isActing: true, clearError: true, clearSuccess: true));
    try {
      await action();
      emit(state.copyWith(isActing: false, successMessage: successMessage));
    } catch (e) {
      emit(state.copyWith(isActing: false, errorMessage: _friendly(e)));
    }
    await _load(emit);
  }

  Future<void> _onGranted(
    BursarReleaseExceptionGranted e,
    Emitter<BursarReportReleaseState> emit,
  ) => _runAction(emit, () async {
    await dataSource.grantException(
      studentId: e.studentId,
      academicYearId: e.academicYearId,
      termId: e.termId,
      reasonCode: e.reasonCode,
      reasonNote: e.reasonNote,
      expiresAt: e.expiresAt,
      clientRequestId:
          'grant_${e.studentId}_${e.academicYearId}_${e.termId}_'
          '${DateTime.now().millisecondsSinceEpoch}',
    );
  }, 'Release exception recorded.');

  Future<void> _onApproved(
    BursarReleaseExceptionApproved e,
    Emitter<BursarReportReleaseState> emit,
  ) => _runAction(
    emit,
    () => dataSource.approveException(exceptionId: e.exceptionId, note: e.note),
    'Exception approved.',
  );

  Future<void> _onRejected(
    BursarReleaseExceptionRejected e,
    Emitter<BursarReportReleaseState> emit,
  ) => _runAction(
    emit,
    () => dataSource.revokeException(
      exceptionId: e.exceptionId,
      reason: e.reason,
    ),
    'Exception rejected.',
  );

  Future<void> _onRevoked(
    BursarReleaseExceptionRevoked e,
    Emitter<BursarReportReleaseState> emit,
  ) => _runAction(
    emit,
    () => dataSource.revokeException(
      exceptionId: e.exceptionId,
      reason: e.reason,
    ),
    'Exception revoked.',
  );

  Future<void> _onRenewed(
    BursarReleaseExceptionRenewed e,
    Emitter<BursarReportReleaseState> emit,
  ) => _runAction(emit, () async {
    await dataSource.renewException(
      exceptionId: e.exceptionId,
      newExpiresAt: e.newExpiresAt,
      reasonNote: e.reasonNote,
      clientRequestId:
          'renew_${e.exceptionId}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }, 'Exception renewed.');

  Future<void> _onDirectOverride(
    BursarReportDirectOverride e,
    Emitter<BursarReportReleaseState> emit,
  ) => _runAction(emit, () async {
    final res = await dataSource.setFinancialAccess(
      reportCardIds: e.reportCardIds,
      action: e.action,
      reason: e.reason,
    );
    final failed = (res['failed'] as List?) ?? const [];
    if (failed.isNotEmpty) {
      throw Exception('${failed.length} report(s) could not be updated.');
    }
  }, 'Direct override applied.');

  String _friendly(Object e) {
    final s = e.toString();
    if (s.contains('already-exists') || s.contains('already exists')) {
      return 'An active or pending exception already exists for this period.';
    }
    if (s.contains('permission-denied') || s.contains('not authorised')) {
      return 'You are not authorised to perform this action.';
    }
    if (s.contains('failed-precondition')) {
      return s.replaceFirst(RegExp(r'.*failed-precondition[,:]?\s*'), '');
    }
    return 'The action could not be completed. Please try again.';
  }
}
