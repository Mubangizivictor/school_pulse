import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/active_responsibility_context.dart';
import '../../../domain/entities/canonical_report_card.dart';
import '../../../domain/repositories/class_report_repository.dart';

abstract class ReportCardPreviewEvent extends Equatable {
  const ReportCardPreviewEvent();
  @override
  List<Object?> get props => [];
}

class ReportCardPreviewRequested extends ReportCardPreviewEvent {
  final ActiveResponsibilityContext context;
  final String reportCardId;
  const ReportCardPreviewRequested({
    required this.context,
    required this.reportCardId,
  });
  @override
  List<Object?> get props => [context, reportCardId];
}

class ReportCardPreviewSubmittedToDean extends ReportCardPreviewEvent {
  const ReportCardPreviewSubmittedToDean();
}

class ReportCardPreviewPdfRequested extends ReportCardPreviewEvent {
  const ReportCardPreviewPdfRequested();
}

class ReportCardPreviewFeedbackCleared extends ReportCardPreviewEvent {
  const ReportCardPreviewFeedbackCleared();
}

class ReportCardPreviewState extends Equatable {
  final bool isLoading;
  final bool isActing;
  final String? errorMessage;
  final String? successMessage;
  final CanonicalReportCard? card;
  final List<int>? pdfBytes;

  const ReportCardPreviewState({
    this.isLoading = false,
    this.isActing = false,
    this.errorMessage,
    this.successMessage,
    this.card,
    this.pdfBytes,
  });

  const ReportCardPreviewState.initial() : this(isLoading: true);

  ReportCardPreviewState copyWith({
    bool? isLoading,
    bool? isActing,
    String? errorMessage,
    String? successMessage,
    CanonicalReportCard? card,
    List<int>? pdfBytes,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearPdf = false,
  }) {
    return ReportCardPreviewState(
      isLoading: isLoading ?? this.isLoading,
      isActing: isActing ?? this.isActing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      card: card ?? this.card,
      pdfBytes: clearPdf ? null : (pdfBytes ?? this.pdfBytes),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isActing,
    errorMessage,
    successMessage,
    card,
    pdfBytes,
  ];
}

class ReportCardPreviewBloc
    extends Bloc<ReportCardPreviewEvent, ReportCardPreviewState> {
  final ClassReportRepository reportRepository;
  ActiveResponsibilityContext? _context;
  String? _reportCardId;

  ReportCardPreviewBloc({required this.reportRepository})
    : super(const ReportCardPreviewState.initial()) {
    on<ReportCardPreviewRequested>(_onRequested);
    on<ReportCardPreviewSubmittedToDean>(_onSubmittedToDean);
    on<ReportCardPreviewPdfRequested>(_onPdfRequested);
    on<ReportCardPreviewFeedbackCleared>(_onFeedbackCleared);
  }

  Future<void> _onRequested(
    ReportCardPreviewRequested event,
    Emitter<ReportCardPreviewState> emit,
  ) async {
    _context = event.context;
    _reportCardId = event.reportCardId;
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final result = await reportRepository.getReportCard(
      context: event.context,
      reportCardId: event.reportCardId,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Could not load this report.',
        ),
      ),
      (card) =>
          emit(state.copyWith(isLoading: false, card: card, clearError: true)),
    );
  }

  Future<void> _onSubmittedToDean(
    ReportCardPreviewSubmittedToDean event,
    Emitter<ReportCardPreviewState> emit,
  ) async {
    final context = _context;
    final reportCardId = _reportCardId;
    if (context == null || reportCardId == null) return;

    emit(state.copyWith(isActing: true, clearError: true, clearSuccess: true));
    final result = await reportRepository.submitReportCardsToDean(
      context: context,
      reportCardIds: [reportCardId],
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isActing: false,
          errorMessage: 'Could not submit this report to the Dean.',
        ),
      ),
      (outcome) => emit(
        state.copyWith(
          isActing: false,
          successMessage: outcome.submitted.isNotEmpty
              ? 'Submitted to the Dean of Studies.'
              : 'Could not submit this report right now.',
          clearError: true,
        ),
      ),
    );
    add(
      ReportCardPreviewRequested(context: context, reportCardId: reportCardId),
    );
  }

  Future<void> _onPdfRequested(
    ReportCardPreviewPdfRequested event,
    Emitter<ReportCardPreviewState> emit,
  ) async {
    final reportCardId = _reportCardId;
    if (reportCardId == null) return;
    emit(state.copyWith(isActing: true, clearError: true, clearPdf: true));
    final result = await reportRepository.previewReportCardPdf(
      reportCardId: reportCardId,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isActing: false,
          errorMessage: 'Could not render the PDF preview.',
        ),
      ),
      (bytes) => emit(
        state.copyWith(isActing: false, pdfBytes: bytes, clearError: true),
      ),
    );
  }

  void _onFeedbackCleared(
    ReportCardPreviewFeedbackCleared event,
    Emitter<ReportCardPreviewState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
