import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';

import '../../data/datasources/headteacher_report_queue_remote_data_source.dart';

abstract class HeadteacherReportQueueEvent extends Equatable {
  const HeadteacherReportQueueEvent();
  @override
  List<Object?> get props => [];
}

class HeadteacherReportQueueRequested extends HeadteacherReportQueueEvent {
  final String schoolId;
  const HeadteacherReportQueueRequested(this.schoolId);
  @override
  List<Object?> get props => [schoolId];
}

class HeadteacherReportCardReturned extends HeadteacherReportQueueEvent {
  final String reportCardId;
  final String reason;
  final bool academicContentChanged;
  const HeadteacherReportCardReturned({
    required this.reportCardId,
    required this.reason,
    this.academicContentChanged = true,
  });
  @override
  List<Object?> get props => [reportCardId, reason, academicContentChanged];
}

class HeadteacherReportCardSigned extends HeadteacherReportQueueEvent {
  final CanonicalReportCard reportCard;
  const HeadteacherReportCardSigned(this.reportCard);
  @override
  List<Object?> get props => [reportCard];
}

class HeadteacherReportCardsSigned extends HeadteacherReportQueueEvent {
  final List<CanonicalReportCard> reportCards;
  const HeadteacherReportCardsSigned(this.reportCards);
  @override
  List<Object?> get props => [reportCards];
}

class HeadteacherReportQueueFeedbackCleared
    extends HeadteacherReportQueueEvent {
  const HeadteacherReportQueueFeedbackCleared();
}

class HeadteacherReportQueueState extends Equatable {
  final bool isLoading;
  final bool isActing;
  final String? errorMessage;
  final String? successMessage;
  final String schoolId;
  final List<CanonicalReportCard> pending;
  final List<CanonicalReportCard> finalized;

  const HeadteacherReportQueueState({
    this.isLoading = false,
    this.isActing = false,
    this.errorMessage,
    this.successMessage,
    this.schoolId = '',
    this.pending = const [],
    this.finalized = const [],
  });

  const HeadteacherReportQueueState.initial() : this(isLoading: true);

  HeadteacherReportQueueState copyWith({
    bool? isLoading,
    bool? isActing,
    String? errorMessage,
    String? successMessage,
    String? schoolId,
    List<CanonicalReportCard>? pending,
    List<CanonicalReportCard>? finalized,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return HeadteacherReportQueueState(
      isLoading: isLoading ?? this.isLoading,
      isActing: isActing ?? this.isActing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      schoolId: schoolId ?? this.schoolId,
      pending: pending ?? this.pending,
      finalized: finalized ?? this.finalized,
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
    finalized,
  ];
}

class HeadteacherReportQueueBloc
    extends Bloc<HeadteacherReportQueueEvent, HeadteacherReportQueueState> {
  final HeadteacherReportQueueRemoteDataSource dataSource;

  HeadteacherReportQueueBloc({required this.dataSource})
    : super(const HeadteacherReportQueueState.initial()) {
    on<HeadteacherReportQueueRequested>(_onRequested);
    on<HeadteacherReportCardReturned>(_onReturned);
    on<HeadteacherReportCardSigned>(_onSigned);
    on<HeadteacherReportCardsSigned>(_onBulkSigned);
    on<HeadteacherReportQueueFeedbackCleared>(_onFeedbackCleared);
  }

  Future<void> _onRequested(
    HeadteacherReportQueueRequested event,
    Emitter<HeadteacherReportQueueState> emit,
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
        statuses: const [AcademicWorkflowStatus.submittedToHeadteacher],
      );
      final finalized = await dataSource.getReportCardsByStatus(
        schoolId: event.schoolId,
        statuses: const [AcademicWorkflowStatus.academicallyFinalized],
      );
      emit(
        state.copyWith(
          isLoading: false,
          pending: pending,
          finalized: finalized,
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
    HeadteacherReportCardReturned event,
    Emitter<HeadteacherReportQueueState> emit,
  ) async {
    emit(state.copyWith(isActing: true, clearError: true, clearSuccess: true));
    try {
      await dataSource.returnByHeadteacher(
        reportCardId: event.reportCardId,
        reason: event.reason,
        academicContentChanged: event.academicContentChanged,
      );
      emit(
        state.copyWith(
          isActing: false,
          successMessage: 'Report returned.',
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
    add(HeadteacherReportQueueRequested(state.schoolId));
  }

  Future<void> _onSigned(
    HeadteacherReportCardSigned event,
    Emitter<HeadteacherReportQueueState> emit,
  ) async {
    emit(state.copyWith(isActing: true, clearError: true, clearSuccess: true));
    try {
      await dataSource.signAsHeadteacher(
        reportCardId: event.reportCard.reportCardId,
        expectedVersion: event.reportCard.version,
        expectedSourceHash: event.reportCard.sourceHash,
      );
      emit(
        state.copyWith(
          isActing: false,
          successMessage: 'Report academically finalized.',
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActing: false,
          errorMessage: 'Could not finalize this report: ${e.toString()}',
        ),
      );
    }
    add(HeadteacherReportQueueRequested(state.schoolId));
  }

  Future<void> _onBulkSigned(
    HeadteacherReportCardsSigned event,
    Emitter<HeadteacherReportQueueState> emit,
  ) async {
    emit(state.copyWith(isActing: true, clearError: true, clearSuccess: true));
    var signedCount = 0;
    var failedCount = 0;
    for (final card in event.reportCards) {
      try {
        // ignore: avoid_slow_async_io
        await dataSource.signAsHeadteacher(
          reportCardId: card.reportCardId,
          expectedVersion: card.version,
          expectedSourceHash: card.sourceHash,
        );
        signedCount++;
      } catch (_) {
        failedCount++;
      }
    }
    emit(
      state.copyWith(
        isActing: false,
        successMessage: failedCount == 0
            ? '$signedCount report${signedCount == 1 ? '' : 's'} '
                  'academically finalized.'
            : '$signedCount finalized, $failedCount could not be signed '
                  '(they may have changed since you reviewed them).',
        clearError: true,
      ),
    );
    add(HeadteacherReportQueueRequested(state.schoolId));
  }

  void _onFeedbackCleared(
    HeadteacherReportQueueFeedbackCleared event,
    Emitter<HeadteacherReportQueueState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
