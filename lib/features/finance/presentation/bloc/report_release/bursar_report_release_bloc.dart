import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';

import '../../../data/datasources/bursar_report_release_remote_data_source.dart';

abstract class BursarReportReleaseEvent extends Equatable {
  const BursarReportReleaseEvent();
  @override
  List<Object?> get props => [];
}

class BursarReportReleaseRequested extends BursarReportReleaseEvent {
  final String schoolId;
  final String? classId;
  final String? academicYearId;
  final String? termId;
  const BursarReportReleaseRequested(
    this.schoolId, {
    this.classId,
    this.academicYearId,
    this.termId,
  });
  @override
  List<Object?> get props => [schoolId, classId, academicYearId, termId];
}

class BursarReportAccessChanged extends BursarReportReleaseEvent {
  final List<String> reportCardIds;
  final String action; // 'release' | 'hold' | 'revoke'
  final String reason;
  const BursarReportAccessChanged({
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

class BursarReportReleaseState extends Equatable {
  final bool isLoading;
  final bool isActing;
  final String? errorMessage;
  final String? successMessage;
  final String schoolId;
  final String? classId;
  final String? academicYearId;
  final String? termId;
  final List<CanonicalReportCard> reportCards;

  const BursarReportReleaseState({
    this.isLoading = false,
    this.isActing = false,
    this.errorMessage,
    this.successMessage,
    this.schoolId = '',
    this.classId,
    this.academicYearId,
    this.termId,
    this.reportCards = const [],
  });

  const BursarReportReleaseState.initial() : this(isLoading: true);

  List<CanonicalReportCard> get held => reportCards
      .where((c) => c.financialAccessStatus == FinancialAccessStatus.held)
      .toList();
  List<CanonicalReportCard> get released => reportCards
      .where((c) => c.financialAccessStatus == FinancialAccessStatus.released)
      .toList();
  List<CanonicalReportCard> get revoked => reportCards
      .where((c) => c.financialAccessStatus == FinancialAccessStatus.revoked)
      .toList();

  BursarReportReleaseState copyWith({
    bool? isLoading,
    bool? isActing,
    String? errorMessage,
    String? successMessage,
    String? schoolId,
    String? classId,
    String? academicYearId,
    String? termId,
    List<CanonicalReportCard>? reportCards,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return BursarReportReleaseState(
      isLoading: isLoading ?? this.isLoading,
      isActing: isActing ?? this.isActing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      schoolId: schoolId ?? this.schoolId,
      classId: classId ?? this.classId,
      academicYearId: academicYearId ?? this.academicYearId,
      termId: termId ?? this.termId,
      reportCards: reportCards ?? this.reportCards,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isActing,
    errorMessage,
    successMessage,
    schoolId,
    classId,
    academicYearId,
    termId,
    reportCards,
  ];
}

class BursarReportReleaseBloc
    extends Bloc<BursarReportReleaseEvent, BursarReportReleaseState> {
  final BursarReportReleaseRemoteDataSource dataSource;

  BursarReportReleaseBloc({required this.dataSource})
    : super(const BursarReportReleaseState.initial()) {
    on<BursarReportReleaseRequested>(_onRequested);
    on<BursarReportAccessChanged>(_onAccessChanged);
    on<BursarReportReleaseFeedbackCleared>(_onFeedbackCleared);
  }

  Future<void> _onRequested(
    BursarReportReleaseRequested event,
    Emitter<BursarReportReleaseState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        schoolId: event.schoolId,
        classId: event.classId,
        academicYearId: event.academicYearId,
        termId: event.termId,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      final cards = await dataSource.getFinalizedReportCards(
        schoolId: event.schoolId,
        classId: event.classId,
        academicYearId: event.academicYearId,
        termId: event.termId,
      );
      emit(
        state.copyWith(isLoading: false, reportCards: cards, clearError: true),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Could not load finalized reports.',
        ),
      );
    }
  }

  Future<void> _onAccessChanged(
    BursarReportAccessChanged event,
    Emitter<BursarReportReleaseState> emit,
  ) async {
    emit(state.copyWith(isActing: true, clearError: true, clearSuccess: true));
    try {
      final result = await dataSource.setFinancialAccess(
        reportCardIds: event.reportCardIds,
        action: event.action,
        reason: event.reason,
      );
      final succeeded = List<String>.from(
        result['succeeded'] as List? ?? const [],
      );
      final failed = List<dynamic>.from(result['failed'] as List? ?? const []);
      final message = failed.isEmpty
          ? '${succeeded.length} report${succeeded.length == 1 ? '' : 's'} '
                'updated.'
          : '${succeeded.length} updated, ${failed.length} could not be '
                'updated.';
      emit(
        state.copyWith(
          isActing: false,
          successMessage: message,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActing: false,
          errorMessage: 'Could not update report access: ${e.toString()}',
        ),
      );
    }
    add(
      BursarReportReleaseRequested(
        state.schoolId,
        classId: state.classId,
        academicYearId: state.academicYearId,
        termId: state.termId,
      ),
    );
  }

  void _onFeedbackCleared(
    BursarReportReleaseFeedbackCleared event,
    Emitter<BursarReportReleaseState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
