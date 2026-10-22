import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';

import '../../../data/datasources/dean_report_queue_remote_data_source.dart';

abstract class DeanReportQueueEvent extends Equatable {
  const DeanReportQueueEvent();
  @override
  List<Object?> get props => [];
}

class DeanReportQueueRequested extends DeanReportQueueEvent {
  final String schoolId;
  const DeanReportQueueRequested(this.schoolId);
  @override
  List<Object?> get props => [schoolId];
}

class DeanReportCardReturned extends DeanReportQueueEvent {
  final String reportCardId;
  final String reason;
  const DeanReportCardReturned({
    required this.reportCardId,
    required this.reason,
  });
  @override
  List<Object?> get props => [reportCardId, reason];
}

class DeanReportCardSigned extends DeanReportQueueEvent {
  final CanonicalReportCard reportCard;
  const DeanReportCardSigned(this.reportCard);
  @override
  List<Object?> get props => [reportCard];
}

class DeanReportCardsSignedAndForwarded extends DeanReportQueueEvent {
  final List<CanonicalReportCard> reportCards;
  const DeanReportCardsSignedAndForwarded(this.reportCards);
  @override
  List<Object?> get props => [reportCards];
}

class DeanReportQueueFeedbackCleared extends DeanReportQueueEvent {
  const DeanReportQueueFeedbackCleared();
}

class DeanReportQueueState extends Equatable {
  final bool isLoading;
  final bool isActing;
  final String? errorMessage;
  final String? successMessage;
  final String schoolId;
  final List<CanonicalReportCard> pending;
  final List<CanonicalReportCard> signed;

  const DeanReportQueueState({
    this.isLoading = false,
    this.isActing = false,
    this.errorMessage,
    this.successMessage,
    this.schoolId = '',
    this.pending = const [],
    this.signed = const [],
  });

  const DeanReportQueueState.initial() : this(isLoading: true);

  DeanReportQueueState copyWith({
    bool? isLoading,
    bool? isActing,
    String? errorMessage,
    String? successMessage,
    String? schoolId,
    List<CanonicalReportCard>? pending,
    List<CanonicalReportCard>? signed,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return DeanReportQueueState(
      isLoading: isLoading ?? this.isLoading,
      isActing: isActing ?? this.isActing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      schoolId: schoolId ?? this.schoolId,
      pending: pending ?? this.pending,
      signed: signed ?? this.signed,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isActing,
    errorMessage,
    successMessage,
    schoolId,
    pending,
    signed,
  ];
}

class DeanReportQueueBloc
    extends Bloc<DeanReportQueueEvent, DeanReportQueueState> {
  final DeanReportQueueRemoteDataSource dataSource;

  DeanReportQueueBloc({required this.dataSource})
    : super(const DeanReportQueueState.initial()) {
    on<DeanReportQueueRequested>(_onRequested);
    on<DeanReportCardReturned>(_onReturned);
    on<DeanReportCardSigned>(_onSigned);
    on<DeanReportCardsSignedAndForwarded>(_onSignedAndForwarded);
    on<DeanReportQueueFeedbackCleared>(_onFeedbackCleared);
  }

  Future<void> _onRequested(
    DeanReportQueueRequested event,
    Emitter<DeanReportQueueState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        schoolId: event.schoolId,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      final pending = await dataSource.getReportCardsByStatus(
        schoolId: event.schoolId,
        statuses: const [AcademicWorkflowStatus.submittedToDean],
      );
      final signed = await dataSource.getReportCardsByStatus(
        schoolId: event.schoolId,
        statuses: const [
          AcademicWorkflowStatus.deanSigned,
          AcademicWorkflowStatus.submittedToHeadteacher,
          AcademicWorkflowStatus.academicallyFinalized,
        ],
      );
      emit(
        state.copyWith(
          isLoading: false,
          pending: pending,
          signed: signed,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Could not load the report card queue.',
        ),
      );
    }
  }

  Future<void> _onReturned(
    DeanReportCardReturned event,
    Emitter<DeanReportQueueState> emit,
  ) async {
    emit(state.copyWith(isActing: true, clearError: true, clearSuccess: true));
    try {
      await dataSource.returnByDean(
        reportCardId: event.reportCardId,
        reason: event.reason,
      );
      emit(
        state.copyWith(
          isActing: false,
          successMessage: 'Report returned to the Class Teacher.',
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActing: false,
          errorMessage: 'Could not return this report: ${e.toString()}',
        ),
      );
    }
    add(DeanReportQueueRequested(state.schoolId));
  }

  Future<void> _onSigned(
    DeanReportCardSigned event,
    Emitter<DeanReportQueueState> emit,
  ) async {
    emit(state.copyWith(isActing: true, clearError: true, clearSuccess: true));
    try {
      await dataSource.signAsDean(
        reportCardId: event.reportCard.reportCardId,
        expectedVersion: event.reportCard.version,
        expectedSourceHash: event.reportCard.sourceHash,
      );
      await dataSource.submitToHeadteacher([event.reportCard.reportCardId]);
      emit(
        state.copyWith(
          isActing: false,
          successMessage: 'Signed and forwarded to the Headteacher.',
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActing: false,
          errorMessage: 'Could not sign this report: ${e.toString()}',
        ),
      );
    }
    add(DeanReportQueueRequested(state.schoolId));
  }

  Future<void> _onSignedAndForwarded(
    DeanReportCardsSignedAndForwarded event,
    Emitter<DeanReportQueueState> emit,
  ) async {
    emit(state.copyWith(isActing: true, clearError: true, clearSuccess: true));
    var signedCount = 0;
    var failedCount = 0;
    for (final card in event.reportCards) {
      try {
        // ignore: avoid_slow_async_io
        await dataSource.signAsDean(
          reportCardId: card.reportCardId,
          expectedVersion: card.version,
          expectedSourceHash: card.sourceHash,
        );
        signedCount++;
      } catch (_) {
        failedCount++;
      }
    }
    final signedIds = signedCount > 0
        ? event.reportCards
              .take(signedCount)
              .map((c) => c.reportCardId)
              .toList()
        : <String>[];
    if (signedIds.isNotEmpty) {
      try {
        await dataSource.submitToHeadteacher(signedIds);
      } catch (_) {
        // Signing succeeded but forwarding failed for the batch - the
        // reports remain visible in the Dean's own "signed" list rather
        // than silently vanishing, and can be retried.
      }
    }
    emit(
      state.copyWith(
        isActing: false,
        successMessage: failedCount == 0
            ? '$signedCount report${signedCount == 1 ? '' : 's'} signed '
                  'and forwarded to the Headteacher.'
            : '$signedCount signed, $failedCount could not be signed '
                  '(they may have changed since you reviewed them).',
        clearError: true,
      ),
    );
    add(DeanReportQueueRequested(state.schoolId));
  }

  void _onFeedbackCleared(
    DeanReportQueueFeedbackCleared event,
    Emitter<DeanReportQueueState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
