import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  const ParentReportCardsRequested({
    required this.schoolId,
    required this.studentId,
  });
  @override
  List<Object?> get props => [schoolId, studentId];
}

class ParentReportCardPdfRequested extends ParentReportCardEvent {
  final String reportCardId;
  const ParentReportCardPdfRequested(this.reportCardId);
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

  const ParentReportCardState({
    this.isLoading = false,
    this.isDownloading = false,
    this.errorMessage,
    this.downloadUrl,
    this.reportCards = const [],
  });

  const ParentReportCardState.initial() : this(isLoading: true);

  ParentReportCardState copyWith({
    bool? isLoading,
    bool? isDownloading,
    String? errorMessage,
    String? downloadUrl,
    List<CanonicalReportCard>? reportCards,
    bool clearError = false,
    bool clearDownloadUrl = false,
  }) {
    return ParentReportCardState(
      isLoading: isLoading ?? this.isLoading,
      isDownloading: isDownloading ?? this.isDownloading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      downloadUrl: clearDownloadUrl ? null : (downloadUrl ?? this.downloadUrl),
      reportCards: reportCards ?? this.reportCards,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isDownloading,
    errorMessage,
    downloadUrl,
    reportCards,
  ];
}

class ParentReportCardBloc
    extends Bloc<ParentReportCardEvent, ParentReportCardState> {
  final ParentReportCardRemoteDataSource dataSource;

  ParentReportCardBloc({required this.dataSource})
    : super(const ParentReportCardState.initial()) {
    on<ParentReportCardsRequested>(_onRequested);
    on<ParentReportCardPdfRequested>(_onPdfRequested);
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
      );
      emit(
        state.copyWith(isLoading: false, reportCards: cards, clearError: true),
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

  void _onFeedbackCleared(
    ParentReportCardFeedbackCleared event,
    Emitter<ParentReportCardState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearDownloadUrl: true));
  }
}
