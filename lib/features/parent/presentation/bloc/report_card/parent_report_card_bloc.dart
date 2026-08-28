import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/features/finance/domain/entities/financial_clearance_policy.dart';
import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';

import '../../../data/parent_report_card_remote_data_source.dart';

abstract class ParentReportCardEvent extends Equatable {
  const ParentReportCardEvent();
  @override
  List<Object?> get props => [];
}

class ParentReportCardsRequested extends ParentReportCardEvent {
  final String schoolId;
  final String studentId;
  final String? parentId;
  const ParentReportCardsRequested({
    required this.schoolId,
    required this.studentId,
    this.parentId,
  });
  @override
  List<Object?> get props => [schoolId, studentId, parentId];
}

class ParentReportCardPdfRequested extends ParentReportCardEvent {
  final String reportCardId;
  const ParentReportCardPdfRequested(this.reportCardId);
  @override
  List<Object?> get props => [reportCardId];
}

/// Fired when the parent actually opens a report row (best-effort audit).
class ParentReportCardOpened extends ParentReportCardEvent {
  final String reportCardId;
  const ParentReportCardOpened(this.reportCardId);
  @override
  List<Object?> get props => [reportCardId];
}

class ParentReportCardFeedbackCleared extends ParentReportCardEvent {
  const ParentReportCardFeedbackCleared();
}

class ParentReportCardState extends Equatable {
  final bool isLoading;
  final bool isDownloading;
  final String? errorMessage;
  final String? downloadUrl;
  final List<CanonicalReportCard> reportCards;

  /// The school's configured respectful message shown when a report is
  /// withheld. Never contains balances, policy details or staff notes.
  final String restrictionMessage;

  const ParentReportCardState({
    this.isLoading = false,
    this.isDownloading = false,
    this.errorMessage,
    this.downloadUrl,
    this.reportCards = const [],
    this.restrictionMessage =
        FinancialClearancePolicy.defaultRestrictionMessage,
  });

  const ParentReportCardState.initial() : this(isLoading: true);

  ParentReportCardState copyWith({
    bool? isLoading,
    bool? isDownloading,
    String? errorMessage,
    String? downloadUrl,
    List<CanonicalReportCard>? reportCards,
    String? restrictionMessage,
    bool clearError = false,
    bool clearDownloadUrl = false,
  }) {
    return ParentReportCardState(
      isLoading: isLoading ?? this.isLoading,
      isDownloading: isDownloading ?? this.isDownloading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      downloadUrl: clearDownloadUrl ? null : (downloadUrl ?? this.downloadUrl),
      reportCards: reportCards ?? this.reportCards,
      restrictionMessage: restrictionMessage ?? this.restrictionMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isDownloading,
    errorMessage,
    downloadUrl,
    reportCards,
    restrictionMessage,
  ];
}

class ParentReportCardBloc
    extends Bloc<ParentReportCardEvent, ParentReportCardState> {
  final ParentReportCardRemoteDataSource dataSource;

  ParentReportCardBloc({required this.dataSource})
    : super(const ParentReportCardState.initial()) {
    on<ParentReportCardsRequested>(_onRequested);
    on<ParentReportCardPdfRequested>(_onPdfRequested);
    on<ParentReportCardOpened>(_onOpened);
    on<ParentReportCardFeedbackCleared>(_onFeedbackCleared);
  }

  Future<void> _onRequested(
    ParentReportCardsRequested event,
    Emitter<ParentReportCardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final cards = await dataSource.getReleasedReportCards(
        schoolId: event.schoolId,
        studentId: event.studentId,
        parentId: event.parentId,
      );
      // Only bother fetching the restriction copy when there is nothing to
      // show - that's the only place it is surfaced.
      String message = state.restrictionMessage;
      if (cards.isEmpty) {
        message = await dataSource.getRestrictionMessage(event.schoolId);
      }
      emit(
        state.copyWith(
          isLoading: false,
          reportCards: cards,
          restrictionMessage: message,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Could not load report cards.',
        ),
      );
    }
  }

  Future<void> _onPdfRequested(
    ParentReportCardPdfRequested event,
    Emitter<ParentReportCardState> emit,
  ) async {
    emit(
      state.copyWith(
        isDownloading: true,
        clearError: true,
        clearDownloadUrl: true,
      ),
    );
    try {
      final url = await dataSource.getOfficialPdfDownloadUrl(
        event.reportCardId,
      );
      // Best-effort download audit (the server re-checks access itself).
      unawaited(
        dataSource.recordParentView(event.reportCardId, isDownload: true),
      );
      emit(
        state.copyWith(
          isDownloading: false,
          downloadUrl: url,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isDownloading: false,
          errorMessage: 'Could not get the official PDF right now.',
        ),
      );
    }
  }

  Future<void> _onOpened(
    ParentReportCardOpened event,
    Emitter<ParentReportCardState> emit,
  ) async {
    await dataSource.recordParentView(event.reportCardId);
  }

  void _onFeedbackCleared(
    ParentReportCardFeedbackCleared event,
    Emitter<ParentReportCardState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearDownloadUrl: true));
  }
}
